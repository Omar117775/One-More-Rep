import 'package:flutter/material.dart';

import '../../components/common.dart';
import '../../core/app_scope.dart';
import '../../core/formatters.dart';
import '../../core/parsing.dart';
import '../../design/tokens.dart';
import '../../data/models/assignment.dart';
import '../../data/models/workout_session.dart';
import '../../localization/app_strings.dart';

/// In-session logging form. Prefills every exercise of the chosen program day
/// with its target sets/reps/weights; sets can be toggled complete, edited and
/// added/removed, then saved in-progress or finished.
class SessionLogScreen extends StatefulWidget {
  const SessionLogScreen({
    required this.assignment,
    required this.day,
    super.key,
  });

  final Assignment assignment;
  final ProgramDay day;

  static Future<void> push(
    BuildContext context, {
    required Assignment assignment,
    required ProgramDay day,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SessionLogScreen(assignment: assignment, day: day),
      ),
    );
  }

  @override
  State<SessionLogScreen> createState() => _SessionLogScreenState();
}

class _LoggedRow {
  _LoggedRow({
    required this.exerciseId,
    required this.setNumber,
    required this.repsController,
    required this.weightController,
    required this.completed,
  });

  final Object? exerciseId;
  int setNumber;
  final TextEditingController repsController;
  final TextEditingController weightController;
  bool completed;
}

class _SessionLogScreenState extends State<SessionLogScreen> {
  final _notesController = TextEditingController();
  final Map<Object?, List<_LoggedRow>> _rowsPerExercise = {};
  bool _saving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    for (final planned in widget.day.exercises) {
      final rows = <_LoggedRow>[];
      final targetSets = (planned.targetSets != null && planned.targetSets! > 0)
          ? planned.targetSets!
          : 3;
      final targets = planned.targetRepsMin ?? planned.targetRepsMax ?? 0;
      final reps = targets > 0 ? targets : 0;
      for (var i = 1; i <= targetSets; i++) {
        rows.add(
          _LoggedRow(
            exerciseId: planned.exerciseId,
            setNumber: i,
            repsController: TextEditingController(text: reps > 0 ? '$reps' : ''),
            weightController: TextEditingController(
              text: planned.targetWeightKg != null && planned.targetWeightKg! > 0
                  ? _trimDecimals(planned.targetWeightKg!)
                  : '',
            ),
            completed: true,
          ),
        );
      }
      _rowsPerExercise[planned.exerciseId ?? planned.exercise.id] = rows;
    }
  }

  String _trimDecimals(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();

  @override
  void dispose() {
    _notesController.dispose();
    for (final rows in _rowsPerExercise.values) {
      for (final row in rows) {
        row.repsController.dispose();
        row.weightController.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _save({required bool finish}) async {
    if (_saving) return;
    final controller = AppScope.of(context);
    final strings = AppStrings.of(context);
    setState(() => _errorText = null);

    final sets = <Map<String, dynamic>>[];
    for (final rows in _rowsPerExercise.values) {
      var number = 0;
      for (final row in rows) {
        number += 1;
        final reps = parseInt(row.repsController.text) ?? 0;
        if (reps <= 0) continue;
        final weight = parseDecimal(row.weightController.text);
        sets.add(
          buildSetPayload(
            exerciseId: row.exerciseId,
            setNumber: number,
            reps: reps,
            weightKg: weight != null && weight > 0 ? weight : null,
            isCompleted: row.completed,
          ),
        );
      }
    }
    if (sets.isEmpty) {
      setState(() => _errorText = strings.noSetsSelected);
      return;
    }
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      await controller.train.createSession(
        assignmentId: widget.assignment.id,
        startedAt: now,
        completedAt: finish ? now : null,
        notes: _notesController.text,
        sets: sets,
      );
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.completedBadge)),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      setState(() {
        _saving = false;
        _errorText = strings.saveSessionFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);
    final locale = controller.strings.localeName;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.day.name.isEmpty
              ? '${strings.dayLabel} ${formatInteger(widget.day.dayNumber, locale: locale)}'
              : widget.day.name,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : () => _save(finish: false),
                  child: Text(strings.saveDraft),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: PrimaryButton(
                  label: strings.finishSession,
                  loading: _saving,
                  onPressed: () => _save(finish: true),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (_errorText != null)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.5)),
              ),
              child: Text(_errorText!, style: AppText.secondary.copyWith(color: AppColors.danger)),
            ),
          for (final planned in widget.day.exercises)
            _ExerciseSection(
              planned: planned,
              rows: _rowsPerExercise,
              onChanged: () => setState(() {}),
            ),
          const SizedBox(height: AppSpacing.md),
          OmrTextField(
            label: strings.sessionNotes,
            controller: _notesController,
            hintText: strings.notesHint,
            autoValidate: AutovalidateMode.disabled,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _ExerciseSection extends StatefulWidget {
  const _ExerciseSection({required this.planned, required this.rows, required this.onChanged});

  final ProgramExercise planned;
  final Map<Object?, List<_LoggedRow>> rows;
  final VoidCallback onChanged;

  @override
  State<_ExerciseSection> createState() => _ExerciseSectionState();
}

class _ExerciseSectionState extends State<_ExerciseSection> {
  Object? get _key => widget.planned.exerciseId ?? widget.planned.exercise.id;

  List<_LoggedRow> get _rows => widget.rows[_key] ?? <_LoggedRow>[];

  void _addRow() {
    final last = _rows.isNotEmpty ? _rows.last : null;
    final reps = last?.repsController.text ?? (widget.planned.targetRepsMin ?? widget.planned.targetRepsMax ?? 0).toString();
    final weight = last?.weightController.text ?? '';
    setState(() {
      widget.rows[_key] = [
        ..._rows,
        _LoggedRow(
          exerciseId: _key,
          setNumber: _rows.length + 1,
          repsController: TextEditingController(text: reps),
          weightController: TextEditingController(text: weight),
          completed: true,
        ),
      ];
    });
    widget.onChanged();
  }

  void _removeRow() {
    if (_rows.length <= 1) return;
    final removed = _rows.removeLast();
    removed.repsController.dispose();
    removed.weightController.dispose();
    setState(() {});
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);
    final locale = controller.strings.localeName;

    final tags = <String>[
      '${strings.targetSetsShort}: ${formatInteger(widget.planned.targetSets, locale: locale)}',
      '${strings.targetRepsShort}: ${widget.planned.repsLabel}',
      if (widget.planned.targetWeightKg != null && widget.planned.targetWeightKg! > 0)
        '${strings.targetWeightShort}: ${formatDecimal(widget.planned.targetWeightKg, locale: locale)} kg',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.planned.exercise.name,
                    style: AppText.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    tags.join('  •  '),
                    style: AppText.microLabel.copyWith(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconPill(
              icon: Icons.add,
              tooltip: strings.addCardio,
              onPressed: _addRow,
            ),
            const SizedBox(width: AppSpacing.xs),
            IconPill(
              icon: Icons.remove,
              tooltip: strings.cancel,
              onPressed: _removeRow,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        for (var i = 0; i < _rows.length; i++)
          _RowWidget(
            index: i,
            row: _rows[i],
          ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

class _CompletedToggle extends StatefulWidget {
  const _CompletedToggle({required this.row});

  final _LoggedRow row;

  @override
  State<_CompletedToggle> createState() => _CompletedToggleState();
}

class _CompletedToggleState extends State<_CompletedToggle> {
  bool _value = true;

  @override
  void initState() {
    super.initState();
    _value = widget.row.completed;
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: _value,
      visualDensity: VisualDensity.compact,
      onChanged: (value) => setState(() {
        _value = value ?? false;
        widget.row.completed = _value;
      }),
    );
  }
}

class _RowWidget extends StatelessWidget {
  const _RowWidget({required this.index, required this.row});

  final int index;
  final _LoggedRow row;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              '#${row.setNumber}',
              style: AppText.secondary,
            ),
          ),
          Expanded(
            flex: 3,
            child: TextField(
              controller: row.weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: strings.targetWeightShort,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            flex: 2,
            child: TextField(
              controller: row.repsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: strings.targetRepsShort),
              textAlign: TextAlign.center,
            ),
          ),
          _CompletedToggle(row: row),
        ],
      ),
    );
  }
}
