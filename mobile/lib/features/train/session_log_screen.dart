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
///
/// Pass [session] to edit an existing workout; otherwise [assignment] and
/// [day] start a new session.
class SessionLogScreen extends StatefulWidget {
  const SessionLogScreen({this.assignment, this.day, this.session, super.key})
    : assert(session != null || (assignment != null && day != null)),
      assert(session == null || (assignment == null && day == null));

  final Assignment? assignment;
  final ProgramDay? day;
  final WorkoutSessionModel? session;

  bool get isEditing => session != null;

  static Future<WorkoutSessionModel?> push(
    BuildContext context, {
    required Assignment assignment,
    required ProgramDay day,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<WorkoutSessionModel>(
        builder: (_) => SessionLogScreen(assignment: assignment, day: day),
      ),
    );
  }

  static Future<WorkoutSessionModel?> pushEdit(
    BuildContext context, {
    required WorkoutSessionModel session,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<WorkoutSessionModel>(
        builder: (_) => SessionLogScreen(session: session),
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
  late final TextEditingController _notesController;
  final Map<Object?, List<_LoggedRow>> _rowsPerExercise = {};
  late final List<ProgramExercise> _plannedExercises;
  bool _saving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.session?.notes ?? '');
    _plannedExercises = widget.session == null
        ? widget.day!.exercises
        : _exercisesFromSession(widget.session!);
    if (widget.session == null) {
      for (final planned in _plannedExercises) {
        final rows = <_LoggedRow>[];
        final targetSets =
            (planned.targetSets != null && planned.targetSets! > 0)
            ? planned.targetSets!
            : 3;
        final targets = planned.targetRepsMin ?? planned.targetRepsMax ?? 0;
        final reps = targets > 0 ? targets : 0;
        for (var i = 1; i <= targetSets; i++) {
          rows.add(
            _LoggedRow(
              exerciseId: planned.exerciseId,
              setNumber: i,
              repsController: TextEditingController(
                text: reps > 0 ? '$reps' : '',
              ),
              weightController: TextEditingController(
                text:
                    planned.targetWeightKg != null &&
                        planned.targetWeightKg! > 0
                    ? _trimDecimals(planned.targetWeightKg!)
                    : '',
              ),
              completed: true,
            ),
          );
        }
        _rowsPerExercise[planned.exerciseId ?? planned.exercise.id] = rows;
      }
    } else {
      for (final planned in _plannedExercises) {
        final key = planned.exerciseId ?? planned.exercise.id;
        final sets =
            widget.session!.sets
                .where((set) => (set.exerciseId ?? set.exercise.id) == key)
                .toList()
              ..sort((a, b) => a.setNumber.compareTo(b.setNumber));
        _rowsPerExercise[key] = [
          for (final set in sets)
            _LoggedRow(
              exerciseId: key,
              setNumber: set.setNumber,
              repsController: TextEditingController(
                text: set.reps > 0 ? '${set.reps}' : '',
              ),
              weightController: TextEditingController(
                text: set.weightKg != null && set.weightKg! > 0
                    ? _trimDecimals(set.weightKg!)
                    : '',
              ),
              completed: set.isCompleted,
            ),
        ];
      }
    }
  }

  /// Reconstructs editable exercises from the sets already logged on a
  /// session. Keeps the order in which exercises first appear.
  List<ProgramExercise> _exercisesFromSession(WorkoutSessionModel session) {
    final grouped = <Object?, List<SessionSet>>{};
    for (final set in session.sets) {
      final key = set.exerciseId ?? set.exercise.id;
      grouped.putIfAbsent(key, () => []).add(set);
    }
    return [
      for (final entry in grouped.entries)
        ProgramExercise(
          id: null,
          exerciseId: entry.key,
          targetSets: entry.value.length,
          exercise: entry.value.first.exercise,
        ),
    ];
  }

  String _trimDecimals(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();

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
      final WorkoutSessionModel saved;
      if (widget.session == null) {
        saved = await controller.train.createSession(
          assignmentId: widget.assignment!.id,
          startedAt: now,
          completedAt: finish ? now : null,
          notes: _notesController.text,
          sets: sets,
        );
      } else {
        saved = await controller.train.updateSession(
          widget.session!.id,
          notes: _notesController.text,
          completedAt: finish ? now : null,
          sets: sets,
        );
      }
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(finish ? strings.completedBadge : strings.savedNote),
          ),
        );
        Navigator.of(context).pop(saved);
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
          widget.isEditing
              ? strings.editSession
              : widget.day!.name.isEmpty
              ? '${strings.dayLabel} ${formatInteger(widget.day!.dayNumber, locale: locale)}'
              : widget.day!.name,
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
                  child: Text(
                    widget.isEditing ? strings.saveChanges : strings.saveDraft,
                  ),
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
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                _errorText!,
                style: AppText.secondary.copyWith(color: AppColors.danger),
              ),
            ),
          for (final planned in _plannedExercises)
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
  const _ExerciseSection({
    required this.planned,
    required this.rows,
    required this.onChanged,
  });

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
    final targetReps =
        widget.planned.targetRepsMin ?? widget.planned.targetRepsMax;
    final reps =
        last?.repsController.text ??
        (targetReps != null && targetReps > 0 ? '$targetReps' : '');
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
      if (widget.planned.targetWeightKg != null &&
          widget.planned.targetWeightKg! > 0)
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
              tooltip: strings.addSet,
              onPressed: _addRow,
            ),
            const SizedBox(width: AppSpacing.xs),
            IconPill(
              icon: Icons.remove,
              tooltip: strings.removeSet,
              onPressed: _removeRow,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        for (var i = 0; i < _rows.length; i++)
          _RowWidget(index: i, row: _rows[i]),
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
            child: Text('#${row.setNumber}', style: AppText.secondary),
          ),
          Expanded(
            flex: 3,
            child: TextField(
              controller: row.weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(hintText: strings.targetWeightShort),
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
