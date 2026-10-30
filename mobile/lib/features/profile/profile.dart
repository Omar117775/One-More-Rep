/// Trainee profile domain (Phase 4: local mock data until the profile/P7
/// features land on the backend — see [MockProfileRepository]).
library;

class TraineeProfile {
  const TraineeProfile({
    required this.displayName,
    required this.handle,
    required this.joinedOn,
    required this.ageYears,
    required this.heightCm,
    required this.weightKg,
    required this.isMale,
    required this.sessionsCompleted,
    required this.currentStreakDays,
    required this.volume30dKg,
    required this.weeklyGoalSessions,
    required this.weeklyDoneSessions,
    required this.goals,
  });

  final String displayName;
  final String handle;
  final DateTime joinedOn;

  // Body stats — feed the Mifflin-St Jeor estimate on the Nutrition screen.
  final int ageYears;
  final int heightCm;
  final double weightKg;
  final bool isMale;

  // Headline training stats.
  final int sessionsCompleted;
  final int currentStreakDays;
  final double volume30dKg;

  // Weekly goal ring.
  final int weeklyGoalSessions;
  final int weeklyDoneSessions;

  /// Mock goals summary copy (English-only catalog content, like the other
  /// mock data); the section header is localized via AppStrings.
  final List<String> goals;
}
