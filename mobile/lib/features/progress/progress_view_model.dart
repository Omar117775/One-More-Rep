import 'package:flutter/foundation.dart';

import '../../core/api_exception.dart';
import '../../data/models/analytics_summary.dart';
import '../../data/models/progress_entry.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../data/repositories/progress_repository.dart';

enum ProgressStatus { loading, ready, error }

/// View model for progress charts + body measurement CRUD.
class ProgressViewModel extends ChangeNotifier {
  ProgressViewModel({required this.progressRepo, required this.analyticsRepo});

  final ProgressRepository progressRepo;
  final AnalyticsRepository analyticsRepo;

  ProgressStatus status = ProgressStatus.loading;
  String? errorMessage;
  int rangeDays = 30;
  AnalyticsSummary? analytics;
  List<ProgressEntry> entries = [];
  bool busy = false;

  List<ProgressEntry> get entriesNewestFirst {
    final list = [...entries];
    list.sort((a, b) => b.measuredOn.compareTo(a.measuredOn));
    return list;
  }

  void setRange(int days) {
    if (days == rangeDays) return;
    rangeDays = days;
    _loadAnalytics();
  }

  Future<void> load() async {
    status = ProgressStatus.loading;
    notifyListeners();
    try {
      final now = DateTime.now().toUtc();
      final results = await Future.wait<dynamic>([
        analyticsRepo.fetch(
          from: now.subtract(Duration(days: rangeDays)),
          to: now,
        ),
        progressRepo.list(),
      ]);
      analytics = results[0] as AnalyticsSummary;
      entries = results[1] as List<ProgressEntry>;
      status = ProgressStatus.ready;
      errorMessage = null;
    } on ApiException catch (error) {
      if (status != ProgressStatus.ready) {
        errorMessage = error.message;
        status = ProgressStatus.error;
      } else {
        errorMessage = error.message;
      }
    } catch (e) {
      if (status != ProgressStatus.ready) {
        errorMessage = 'unexpected: $e';
        status = ProgressStatus.error;
      } else {
        errorMessage = 'unexpected: $e';
      }
    }
    notifyListeners();
  }

  Future<void> _loadAnalytics() async {
    if (status != ProgressStatus.ready || analytics == null) {
      return load();
    }
    busy = true;
    notifyListeners();
    try {
      final now = DateTime.now().toUtc();
      analytics = await analyticsRepo.fetch(
        from: now.subtract(Duration(days: rangeDays)),
        to: now,
      );
      errorMessage = null;
    } on ApiException catch (error) {
      errorMessage = error.message;
    }
    busy = false;
    notifyListeners();
  }

  Future<bool> delete(Object? id) async {
    try {
      await progressRepo.delete(id);
      entries.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> save({
    required bool isUpdate,
    Object? id,
    required DateTime measuredOn,
    double? weightKg,
    double? bodyFatPercentage,
    double? waistCm,
    double? chestCm,
    double? armCm,
  }) async {
    try {
      if (isUpdate) {
        final updated = await progressRepo.update(
          id,
          measuredOn: measuredOn,
          weightKg: weightKg,
          bodyFatPercentage: bodyFatPercentage,
          waistCm: waistCm,
          chestCm: chestCm,
          armCm: armCm,
        );
        entries = entries.map((e) => e.id == id ? updated : e).toList();
      } else {
        entries = [
          ...entries,
          await progressRepo.create(
            measuredOn: measuredOn,
            weightKg: weightKg,
            bodyFatPercentage: bodyFatPercentage,
            waistCm: waistCm,
            chestCm: chestCm,
            armCm: armCm,
          ),
        ];
      }
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      fieldErrors = error.fieldErrors;
      notifyListeners();
      return false;
    }
  }

  Map<String, List<String>> fieldErrors = const {};
}
