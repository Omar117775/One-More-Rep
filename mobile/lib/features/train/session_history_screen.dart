import 'package:flutter/material.dart';

import '../../components/common.dart';
import '../../components/states.dart';
import '../../core/app_scope.dart';
import '../../core/formatters.dart';
import '../../design/tokens.dart';
import '../../data/models/workout_session.dart';
import '../../localization/app_strings.dart';

/// Session history with delete and detail (slides-up sheet per session).
class SessionHistoryScreen extends StatefulWidget {
  const SessionHistoryScreen({super.key});

  static Future<void> push(BuildContext context) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const SessionHistoryScreen()),
      );

  @override
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> {
  SessionLoadStatus _status = SessionLoadStatus.loading;
  String? _error;
  List<WorkoutSessionModel> _sessions = [];
  bool _busyDelete = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _status = SessionLoadStatus.loading;
      _error = null;
    });
    try {
      final sessions = await AppScope.of(context).train.sessions();
      if (!mounted) return;
      setState(() {
        _sessions = sessions;
        _status = SessionLoadStatus.ready;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _status = SessionLoadStatus.error;
      });
    }
  }

  Future<void> _delete(WorkoutSessionModel session) async {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.deleteSession, style: AppText.title),
        content: Text(strings.deleteSessionConfirm, style: AppText.secondary),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text(strings.delete),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              minimumSize: const Size(96, AppSpacing.touchTarget),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() {
        _busyDelete = true;
      });
      final ok = await controller.train.deleteSession(session.id);
      if (!mounted) return;
      setState(() {
        _busyDelete = false;
      });
      if (ok) {
        setState(() {
          _sessions.removeWhere((s) => s.id == session.id);
        });
      } else {
        await _load();
      }
    }
  }

  void _openDetail(WorkoutSessionModel session) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surfaceLight,
      builder: (_) => _SessionDetailSheet(session: session),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);
    final locale = controller.strings.localeName;

    return Scaffold(
      appBar: AppBar(title: Text(strings.sessionHistory)),
      body: switch (_status) {
        SessionLoadStatus.loading => const OmrLoading(),
        SessionLoadStatus.error =>
          OmrErrorPanel(message: _error ?? strings.errorGeneric, onRetry: _load),
        SessionLoadStatus.ready =>
          _sessions.isEmpty
              ? OmrEmptyPanel(
                  icon: Icons.fact_check_outlined,
                  title: strings.sessionsEmpty,
                  subtitle: strings.sessionsEmptySub,
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _sessions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final session = _sessions[index];
                      return OmrCard(
                        onTap: () => _openDetail(session),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formatDateTime(session.startedAt, locale: locale),
                                        style: AppText.title,
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        '${formatInteger(session.totalSets, locale: locale)} ${strings.targetSetsShort} • '
                                        '${formatInteger(session.completedSets, locale: locale)} ${strings.completedBadge} • '
                                        '${formatDecimal(session.volume, locale: locale)} kg',
                                        style: AppText.secondary,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: session.isCompleted
                                        ? AppColors.success.withValues(alpha: 0.14)
                                        : AppColors.warning.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(AppRadii.pill),
                                    border: Border.all(
                                      color: session.isCompleted
                                          ? AppColors.success.withValues(alpha: 0.45)
                                          : AppColors.warning.withValues(alpha: 0.45),
                                    ),
                                  ),
                                  child: Text(
                                    session.isCompleted
                                        ? strings.completedBadge
                                        : strings.pendingBadge,
                                    style: AppText.microLabel.copyWith(
                                      color: session.isCompleted
                                          ? AppColors.success
                                          : AppColors.warning,
                                    ),
                                  ),
                                ),
                                IconPill(
                                  icon: Icons.delete_outline,
                                  tooltip: strings.deleteSession,
                                  onPressed: _busyDelete ? null : () => _delete(session),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      },
    );
  }
}

enum SessionLoadStatus { loading, ready, error }

class _SessionDetailSheet extends StatelessWidget {
  const _SessionDetailSheet({required this.session});

  final WorkoutSessionModel session;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);
    final locale = controller.strings.localeName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatDateTime(session.startedAt, locale: locale),
            style: AppText.headline.copyWith(fontSize: 20),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${strings.sessionStartedAt}: ${formatDateTime(session.startedAt, locale: locale)}'
            '${session.completedAt != null ? '\n${strings.sessionCompletedAt}: ${formatDateTime(session.completedAt, locale: locale)}' : ''}',
            style: AppText.secondary,
          ),
          if (session.notes != null && session.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(session.notes!, style: AppText.body),
          ],
          const SizedBox(height: AppSpacing.md),
          for (final group in _groupedByExercise(session.sets).entries)
            _ExerciseSetGroup(
              name: group.key,
              sets: group.value,
              locale: locale,
              strings: strings,
            ),
        ],
      ),
    );
  }
}

class _ExerciseSetGroup extends StatelessWidget {
  const _ExerciseSetGroup({
    required this.name,
    required this.sets,
    required this.locale,
    required this.strings,
  });

  final String name;
  final List<SessionSet> sets;
  final String locale;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: AppText.title),
          const SizedBox(height: AppSpacing.xs),
          for (final set in sets)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    child: Text(
                      '#${formatInteger(set.setNumber, locale: locale)}',
                      style: AppText.secondary,
                    ),
                  ),
                  Text(
                    '${set.isCompleted ? '✓' : '•'} '
                    '${set.reps > 0 ? formatInteger(set.reps, locale: locale) : '—'} ${strings.targetRepsShort}'
                    ' · ${set.weightKg != null ? formatDecimal(set.weightKg, locale: locale) : '—'} ${strings.targetWeightShort}',
                    style: AppText.secondary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

Map<String, List<SessionSet>> _groupedByExercise(List<SessionSet> sets) {
  final groups = <String, List<SessionSet>>{};
  for (final set in sets) {
    final key = set.exercise.name.isNotEmpty
        ? set.exercise.name
        : (set.exerciseId?.toString() ?? '—');
    groups[key] = [...groups[key] ?? const [], set];
  }
  return groups;
}
