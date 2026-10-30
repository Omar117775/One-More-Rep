import 'exercise.dart';

/// Source of truth for the exercise library. Backed by
/// [MockExerciseRepository] for now; a real backend-backed implementation
/// (appending to `lib/data/`) can be dropped in without UI changes.
abstract class ExerciseRepository {
  Future<List<Exercise>> exercises();
}
