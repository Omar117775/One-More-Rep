import 'profile.dart';

/// Source of truth for the trainee profile. Backed by
/// [MockProfileRepository] for now; a backend-backed implementation can be
/// dropped in (Phase 7) without UI changes.
abstract class ProfileRepository {
  Future<TraineeProfile> profile();
}
