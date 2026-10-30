import 'package:flutter/foundation.dart';

import 'exercise.dart';
import 'exercise_repository.dart';
import 'mock_exercise_repository.dart';

/// Load status for the library list. Mirrors the repo-backed view models so
/// a real repository can replace the mock without changing the UI shell.
enum LibraryStatus { loading, error, ready }

/// Filters + search over the exercise catalog. Purely presentational — no
/// pricing, permissions or validity decisions live here.
class LibraryViewModel extends ChangeNotifier {
  LibraryViewModel({ExerciseRepository? repository})
    : _repository = repository ?? const MockExerciseRepository();

  final ExerciseRepository _repository;

  LibraryStatus status = LibraryStatus.loading;
  String? errorMessage;
  List<Exercise> exercises = const [];

  String _query = '';
  ExerciseGroup? _group;
  bool? _isCardio; // null = both, false = strength, true = cardio

  ExerciseGroup? get groupFilter => _group;
  bool? get typeFilter => _isCardio;

  Future<void> load() async {
    status = LibraryStatus.loading;
    notifyListeners();
    try {
      exercises = await _repository.exercises();
      status = LibraryStatus.ready;
    } catch (error) {
      errorMessage = error.toString();
      status = LibraryStatus.error;
    }
    notifyListeners();
  }

  void search(String query) {
    _query = query.trim().toLowerCase();
    notifyListeners();
  }

  void setGroup(ExerciseGroup? group) {
    _group = group;
    notifyListeners();
  }

  /// `null` shows both strength and cardio entries.
  void setType(bool? isCardio) {
    _isCardio = isCardio;
    notifyListeners();
  }

  List<Exercise> get filtered {
    return exercises.where((exercise) {
      if (_group != null && exercise.group != _group) return false;
      if (_isCardio != null && exercise.isCardio != _isCardio) return false;
      if (_query.isEmpty) return true;
      return exercise.name.toLowerCase().contains(_query) ||
          exercise.equipment.toLowerCase().contains(_query);
    }).toList(growable: false);
  }
}
