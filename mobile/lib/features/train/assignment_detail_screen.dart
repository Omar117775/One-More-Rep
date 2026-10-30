import 'package:flutter/material.dart';

import '../../components/common.dart';
import '../../core/app_scope.dart';
import '../../core/formatters.dart';
import '../../design/tokens.dart';
import '../../data/models/assignment.dart';
import '../../localization/app_strings.dart';
import 'session_log_screen.dart';

/// Program detail: description plus every day with its prescribed exercises.
/// Each day starts a logging session.
class AssignmentDetailScreen extends StatelessWidget {
  const AssignmentDetailScreen({required this.assignment, super.key});

  final Assignment assignment;

  static Future<void> push(BuildContext context, Assignment assignment) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AssignmentDetailScreen(assignment: assignment),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(assignment.program.name)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (assignment.program.description.isNotEmpty)
            Text(assignment.program.description, style: AppText.secondary),
          for (final day in assignment.program.days)
            _DayCard(assignment: assignment, day: day),
          if (assignment.program.days.isEmpty)
            const OmrCard(child: SizedBox.shrink()),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.assignment, required this.day});

  final Assignment assignment;
  final ProgramDay day;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);
    final locale = controller.strings.localeName;

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '${strings.dayLabel} ${formatInteger(day.dayNumber, locale: locale)}',
                  textAlign: TextAlign.center,
                  style: AppText.microLabel.copyWith(
                    color: AppColors.goldLight,
                    fontSize: 8.5,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  day.name.isEmpty
                      ? '${strings.dayLabel} ${formatInteger(day.dayNumber, locale: locale)}'
                      : day.name,
                  style: AppText.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < day.exercises.length; i++)
            _ExerciseRow(
              exercise: day.exercises[i],
              locale: locale,
              strings: strings,
            ),
          if (day.exercises.isEmpty)
            Text(strings.measurementsEmptySub, style: AppText.secondary),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: AppSpacing.touchTarget,
            child: OutlinedButton.icon(
              onPressed: day.exercises.isEmpty
                  ? null
                  : () {
                      SessionLogScreen.push(
                        context,
                        assignment: assignment,
                        day: day,
                      );
                    },
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: Text(strings.startSession),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.exercise,
    required this.locale,
    required this.strings,
  });

  final ProgramExercise exercise;
  final String locale;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final String line1 = exercise.exercise.name;
    final tags = <String>[
      '${formatInteger(exercise.targetSets, locale: locale)} ${strings.targetSetsShort}',
      '${exercise.repsLabel} ${strings.targetRepsShort}',
      if (exercise.targetWeightKg != null && exercise.targetWeightKg! > 0)
        '${formatDecimal(exercise.targetWeightKg, locale: locale)} ${strings.targetWeightShort}',
      if (exercise.restSeconds != null && exercise.restSeconds! > 0)
        '${strings.restShort} ${formatSecondsCompact(exercise.restSeconds, locale: locale)}',
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              Icons.fitness_center,
              size: 18,
              color: AppColors.goldLight,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line1,
                  style: AppText.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  tags.join('  •  '),
                  style: AppText.microLabel.copyWith(fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (exercise.exercise.instructions.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    exercise.exercise.instructions,
                    style: AppText.secondary.copyWith(fontSize: 11.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
