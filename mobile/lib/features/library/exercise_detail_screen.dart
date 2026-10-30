import 'package:flutter/material.dart';

import '../../components/common.dart';
import '../../design/tokens.dart';
import '../../localization/app_strings.dart';
import 'exercise.dart';
import 'exercise_ui.dart';

/// Read-only exercise detail: instructions, difficulty badge and meta chips.
/// Submitted through the shared page transition built into the theme.
class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({required this.exercise, super.key});

  final Exercise exercise;

  static Future<void> push(BuildContext context, Exercise exercise) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExerciseDetailScreen(exercise: exercise),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final (:label, :color) = difficultyBadge(
      strings,
      exercise.difficulty,
    );

    return Scaffold(
      appBar: AppBar(title: Text(strings.libraryTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: (exercise.isCardio ? AppColors.bronze : AppColors.gold)
                      .withValues(alpha: 0.14),
                  border: Border.all(
                    color: (exercise.isCardio
                            ? AppColors.bronze
                            : AppColors.gold)
                        .withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(
                  groupIcon(exercise.group),
                  size: 28,
                  color: exercise.isCardio
                      ? AppColors.bronze
                      : AppColors.goldLight,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.name, style: AppText.headline),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _MetaChip(
                          label: groupLabel(strings, exercise.group),
                        ),
                        _MetaChip(
                          label: exercise.isCardio
                              ? strings.typeCardio
                              : strings.typeStrength,
                        ),
                        _MetaChip(
                          label: '${strings.equipmentLabel} '
                              '${exercise.equipment}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: strings.difficultyLabel),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: AppText.title.copyWith(color: color),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: strings.instructionsLabel),
          OmrCard(
            child: Text(exercise.instructions, style: AppText.body),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppText.microLabel.copyWith(fontSize: 10.5, letterSpacing: 0.2),
      ),
    );
  }
}
