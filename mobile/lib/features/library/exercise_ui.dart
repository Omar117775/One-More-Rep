import 'package:flutter/material.dart';

import '../../design/tokens.dart';
import '../../localization/app_strings.dart';
import 'exercise.dart';

/// Presentation helpers shared by the library screens. Icons per muscle group
/// and localized labels — the model itself stays localization-free.
IconData groupIcon(ExerciseGroup group) => switch (group) {
  ExerciseGroup.chest => Icons.shield_rounded,
  ExerciseGroup.back => Icons.back_hand_rounded,
  ExerciseGroup.legs => Icons.directions_walk_rounded,
  ExerciseGroup.shoulders => Icons.accessibility_new_rounded,
  ExerciseGroup.arms => Icons.fitness_center,
  ExerciseGroup.core => Icons.center_focus_strong_rounded,
};

String groupLabel(AppStrings strings, ExerciseGroup group) => switch (group) {
  ExerciseGroup.chest => strings.groupChest,
  ExerciseGroup.back => strings.groupBack,
  ExerciseGroup.legs => strings.groupLegs,
  ExerciseGroup.shoulders => strings.groupShoulders,
  ExerciseGroup.arms => strings.groupArms,
  ExerciseGroup.core => strings.groupCore,
};

String difficultyLabel(AppStrings strings, ExerciseDifficulty difficulty) =>
    switch (difficulty) {
      ExerciseDifficulty.beginner => strings.difficultyBeginner,
      ExerciseDifficulty.intermediate => strings.difficultyIntermediate,
      ExerciseDifficulty.advanced => strings.difficultyAdvanced,
    };

/// Badge styling per difficulty: gold = advanced emphasis, bronze =
/// intermediate, muted = beginner. Token-driven only.
({String label, Color color}) difficultyBadge(
  AppStrings strings,
  ExerciseDifficulty difficulty,
) => switch (difficulty) {
  ExerciseDifficulty.beginner => (
    label: difficultyLabel(strings, difficulty),
    color: AppColors.muted,
  ),
  ExerciseDifficulty.intermediate => (
    label: difficultyLabel(strings, difficulty),
    color: AppColors.bronze,
  ),
  ExerciseDifficulty.advanced => (
    label: difficultyLabel(strings, difficulty),
    color: AppColors.goldLight,
  ),
};
