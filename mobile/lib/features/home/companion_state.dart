import '../../components/spartan_companion.dart' show SpartanState;
import '../../data/models/assignment.dart';
import '../../data/models/workout_session.dart';
import '../../data/models/analytics_summary.dart';

/// Companion mood derivation is pure logic shared between home and tests.
SpartanState companionFor({
  required AnalyticsSummary? analytics,
  required List<Assignment> assignments,
  required List<WorkoutSessionModel> sessions,
  required DateTime now,
  bool aiActive = false,
  bool hasPR = false,
  bool weeklyGoalAchieved = false,
}) {
  if (aiActive) return SpartanState.aiActive;
  if (hasPR) return SpartanState.pr;
  if (weeklyGoalAchieved) return SpartanState.weeklyGoal;

  final hasActiveAssignment = assignments.any(
    (a) => a.isActive || a.isUpcoming,
  );
  if (analytics?.workouts.hasData == true &&
      analytics!.workouts.weekly.length >= 2) {
    final current = analytics.workouts.weekly.last.volumeKg;
    final previous = analytics
        .workouts
        .weekly[analytics.workouts.weekly.length - 2]
        .volumeKg;
    if (previous > 0 && current > previous * 1.1) {
      return SpartanState.milestone;
    }
  }
  final completedRecently = sessions.any(
    (s) =>
        s.isCompleted &&
        s.completedAt != null &&
        now.difference(s.completedAt!) < const Duration(hours: 48),
  );
  if (completedRecently) return SpartanState.success;
  if (hasActiveAssignment) return SpartanState.training;
  return SpartanState.idle;
}
