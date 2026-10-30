import 'package:flutter/foundation.dart';

import 'mock_profile_repository.dart';
import 'profile.dart';
import 'profile_repository.dart';

/// Load status — mirrors repo-backed view models so a real repository can
/// replace the mock without changing the UI shell.
enum ProfileStatus { loading, error, ready }

/// Thin loader over the mock profile. Editing belongs to the backend: this
/// view model exposes read-only data and never persists anything.
class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({ProfileRepository? repository})
    : _repository = repository ?? const MockProfileRepository();

  final ProfileRepository _repository;

  ProfileStatus status = ProfileStatus.loading;
  String? errorMessage;
  TraineeProfile? profile;

  Future<void> load() async {
    status = ProfileStatus.loading;
    notifyListeners();
    try {
      profile = await _repository.profile();
      status = ProfileStatus.ready;
    } catch (error) {
      errorMessage = error.toString();
      status = ProfileStatus.error;
    }
    notifyListeners();
  }
}
