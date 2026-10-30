import 'profile.dart';
import 'profile_repository.dart';

/// MOCK DATA — Phase 4 stop-gap until the backend profile exists (P7).
/// Static, English-only content. Swap for a `lib/data/` repository later.
/// Values are deterministic; nothing here is persisted.
class MockProfileRepository implements ProfileRepository {
  const MockProfileRepository();

  static final TraineeProfile _profile = TraineeProfile(
    displayName: 'Alex Rivera',
    handle: '@alex.rios',
    joinedOn: DateTime(2026, 1, 12),
    ageYears: 27,
    heightCm: 178,
    weightKg: 78,
    isMale: true,
    sessionsCompleted: 118,
    currentStreakDays: 9,
    volume30dKg: 42350,
    weeklyGoalSessions: 4,
    weeklyDoneSessions: 3,
    goals: [
      'Add 5 kg to the bench press by December',
      'Run 5 km under 25 minutes',
      'Keep the training streak above 30 days',
    ],
  );

  @override
  Future<TraineeProfile> profile() async => _profile;
}
