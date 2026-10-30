import 'workout_program.dart';

/// Source of truth for the programs catalog. Backed by
/// [MockProgramRepository] for now; a backend-backed implementation can slot
/// in later (trainee programs are already served by AssignmentRepository —
/// this catalog is the general library view).
abstract class ProgramRepository {
  Future<List<WorkoutProgram>> programs();
}
