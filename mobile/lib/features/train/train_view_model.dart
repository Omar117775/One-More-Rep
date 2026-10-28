import 'package:flutter/foundation.dart';

import '../../core/api_exception.dart';
import '../../data/models/assignment.dart';
import '../../data/models/workout_session.dart';
import '../../data/repositories/train_repository.dart';

enum TrainStatus { loading, ready, error }

/// View model for assignments + session history.
class TrainViewModel extends ChangeNotifier {
  TrainViewModel({required this.repo});

  final TrainRepository repo;

  TrainStatus status = TrainStatus.loading;
  String? errorMessage;
  List<Assignment> assignments = [];
  List<WorkoutSessionModel> sessions = [];

  List<Assignment> get sortedAssignments {
    final list = [...assignments];
    int rank(Assignment a) => a.isActive ? 0 : (a.isUpcoming ? 1 : 2);
    list.sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      if (byRank != 0) return byRank;
      final aEnds = a.endsOn;
      final bEnds = b.endsOn;
      if (aEnds != null && bEnds != null) return aEnds.compareTo(bEnds);
      return 0;
    });
    return list;
  }

  List<WorkoutSessionModel> get sessionsNewestFirst {
    final list = [...sessions];
    list.sort((a, b) => (b.startedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(a.startedAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
    return list;
  }

  Future<void> load() async {
    final keepReady = status == TrainStatus.ready && (sessions.isNotEmpty || assignments.isNotEmpty);
    if (!keepReady) status = TrainStatus.loading;
    notifyListeners();
    try {
      final results = await Future.wait<List<dynamic>>([
        repo.assignments(),
        repo.sessions(),
      ]);
      assignments = results[0] as List<Assignment>;
      sessions = results[1] as List<WorkoutSessionModel>;
      status = TrainStatus.ready;
      errorMessage = null;
    } on ApiException catch (error) {
      if (!keepReady) {
        errorMessage = error.message;
        status = TrainStatus.error;
      } else {
        errorMessage = error.message;
      }
    } catch (e) {
      if (!keepReady) {
        errorMessage = 'unexpected: $e';
        status = TrainStatus.error;
      } else {
        errorMessage = 'unexpected: $e';
      }
    }
    notifyListeners();
  }

  Future<bool> deleteSession(Object? sessionId) async {
    try {
      await repo.deleteSession(sessionId);
      sessions.removeWhere((s) => s.id == sessionId);
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return false;
    }
  }
}
