import 'package:flutter/foundation.dart';

import 'mock_program_repository.dart';
import 'program_repository.dart';
import 'workout_program.dart';

/// Load status — mirrors repo-backed view models so a real repository can
/// replace the mock without changing the UI shell.
enum ProgramsStatus { loading, error, ready }

/// Thin loader over the programs catalog. Read-only by design: enrollment,
/// pricing and validity rules belong to the backend (see architecture rules).
class ProgramsViewModel extends ChangeNotifier {
  ProgramsViewModel({ProgramRepository? repository})
    : _repository = repository ?? const MockProgramRepository();

  final ProgramRepository _repository;

  ProgramsStatus status = ProgramsStatus.loading;
  String? errorMessage;
  List<WorkoutProgram> programs = const [];

  Future<void> load() async {
    status = ProgramsStatus.loading;
    notifyListeners();
    try {
      programs = await _repository.programs();
      status = ProgramsStatus.ready;
    } catch (error) {
      errorMessage = error.toString();
      status = ProgramsStatus.error;
    }
    notifyListeners();
  }
}
