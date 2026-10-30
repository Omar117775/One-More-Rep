/// Exercise library domain types (Phase 5: served by a local mock catalog
/// until the backend exercise-library endpoints land — see
/// [MockExerciseRepository]).
library;

/// Muscle group buckets used by the catalog and the filter chips.
enum ExerciseGroup { chest, back, legs, shoulders, arms, core }

/// Difficulty ladder surfaced as a badge in the UI.
enum ExerciseDifficulty { beginner, intermediate, advanced }

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.group,
    required this.equipment,
    required this.isCardio,
    required this.instructions,
    required this.difficulty,
  });

  final String id;
  final String name;
  final ExerciseGroup group;

  /// Equipment required, e.g. barbell / dumbbell / bodyweight.
  final String equipment;

  /// Type: strength (false) or cardio (true).
  final bool isCardio;
  final String instructions;
  final ExerciseDifficulty difficulty;
}
