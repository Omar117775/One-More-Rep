/// Workout programs domain types (Phase 5: local mock catalog until coach
/// publishing + subscriptions land on the backend — see
/// [MockProgramRepository]).
library;

class WorkoutProgram {
  const WorkoutProgram({
    required this.id,
    required this.name,
    required this.description,
    required this.weeks,
    required this.sessionsPerWeek,
    required this.level,
    required this.tag,
    required this.weeklySchedule,
  });

  final String id;
  final String name;
  final String description;

  /// Program length in weeks.
  final int weeks;
  final int sessionsPerWeek;

  /// beginner / intermediate / advanced — localized in the UI layer through
  /// the difficulty strings (same ladder as exercises).
  final ProgramLevel level;

  /// Mock catalog tag, e.g. Strength / Hypertrophy / Conditioning.
  /// Tag copy is catalog content (English-only by design, like the rest of
  /// the mock data); UI labels around it are localized via AppStrings.
  final String tag;

  /// One entry per session in the weekly schedule, e.g. "Day 1 — Full body".
  final List<String> weeklySchedule;
}

enum ProgramLevel { beginner, intermediate, advanced }
