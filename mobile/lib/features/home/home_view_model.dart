import 'package:flutter/foundation.dart';

import '../../core/api_exception.dart';
import '../../data/models/analytics_summary.dart';
import '../../data/models/assignment.dart';
import '../../data/models/workout_session.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../data/repositories/train_repository.dart';

enum HomeStatus { loading, ready, error }

/// Data bundle for the home dashboard.
class HomeData {
  const HomeData({
    required this.analytics,
    required this.assignments,
    required this.sessions,
  });

  final AnalyticsSummary analytics;
  final List<Assignment> assignments;
  final List<WorkoutSessionModel> sessions;

  Assignment? get activeAssignment {
    final active = assignments.where((a) => a.isActive).toList()
      ..sort(_byEndsOn);
    if (active.isNotEmpty) return active.first;
    final upcoming = assignments.where((a) => a.isUpcoming).toList()..sort(_byEndsOn);
    return upcoming.isEmpty ? null : upcoming.first;
  }

  int _byEndsOn(Assignment a, Assignment b) {
    final aEnds = a.endsOn;
    final bEnds = b.endsOn;
    if (aEnds != null && bEnds != null) return aEnds.compareTo(bEnds);
    if (aEnds != null) return -1;
    if (bEnds != null) return 1;
    return 0;
  }
}

/// View model for the home dashboard with explicit load/error states.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required this.train,
    required this.analytics,
    required this.nowProvider,
  });

  final TrainRepository train;
  final AnalyticsRepository analytics;
  final DateTime Function() nowProvider;

  HomeStatus status = HomeStatus.loading;
  String? errorMessage;
  HomeData? data;

  Future<void> load() async {
    status = status == HomeStatus.ready ? HomeStatus.ready : HomeStatus.loading;
    if (status != HomeStatus.ready) errorMessage = null;
    notifyListeners();
    try {
      final now = nowProvider().toUtc();
      final results = await Future.wait([
        train.assignments(),
        train.sessions(),
        analytics.fetch(from: now.subtract(const Duration(days: 30)), to: now),
      ]);
      data = HomeData(
        assignments: results[0] as List<Assignment>,
        sessions: results[1] as List<WorkoutSessionModel>,
        analytics: results[2] as AnalyticsSummary,
      );
      status = HomeStatus.ready;
      errorMessage = null;
    } on ApiException catch (error) {
      if (data == null) {
        // Full-screen error only on first load; refresh failures keep stale UI.
        errorMessage = error.message;
        status = HomeStatus.error;
      } else {
        errorMessage = error.message;
      }
    } catch (e) {
      if (data == null) {
        errorMessage = 'unexpected: $e';
        status = HomeStatus.error;
      } else {
        errorMessage = 'unexpected: $e';
      }
    }
    notifyListeners();
  }
}
