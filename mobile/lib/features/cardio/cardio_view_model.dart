import 'package:flutter/material.dart';

import '../../core/api_exception.dart';
import '../../data/models/cardio_entry.dart';
import '../../data/repositories/cardio_repository.dart';

enum CardioStatus { loading, ready, error }

/// View model for the cardio history list and mutations.
class CardioViewModel extends ChangeNotifier {
  CardioViewModel({required this.repo});

  final CardioRepository repo;

  CardioStatus status = CardioStatus.loading;
  String? errorMessage;
  List<CardioEntry> entries = [];

  List<CardioEntry> get entriesNewestFirst {
    final list = [...entries];
    list.sort((a, b) => (b.performedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(a.performedAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
    return list;
  }

  Future<void> load() async {
    final keepReady = status == CardioStatus.ready && entries.isNotEmpty;
    if (!keepReady) status = CardioStatus.loading;
    notifyListeners();
    try {
      entries = await repo.list();
      status = CardioStatus.ready;
      errorMessage = null;
    } on ApiException catch (error) {
      if (!keepReady) {
        errorMessage = error.message;
        status = CardioStatus.error;
      } else {
        errorMessage = error.message;
      }
    } catch (e) {
      if (!keepReady) {
        errorMessage = 'unexpected: $e';
        status = CardioStatus.error;
      } else {
        errorMessage = 'unexpected: $e';
      }
    }
    notifyListeners();
  }

  Future<bool> delete(Object? id) async {
    try {
      await repo.delete(id);
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
    required String activityType,
    required int durationSeconds,
    double? distanceKm,
    int? averageHeartRate,
    required DateTime performedAt,
  }) async {
    try {
      if (isUpdate) {
        final updated = await repo.update(
          id,
          activityType: activityType,
          durationSeconds: durationSeconds,
          distanceKm: distanceKm,
          averageHeartRate: averageHeartRate,
          performedAt: performedAt,
        );
        entries = entries.map((e) => e.id == id ? updated : e).toList();
      } else {
        entries = [
          ...entries,
          await repo.create(
            activityType: activityType,
            durationSeconds: durationSeconds,
            distanceKm: distanceKm,
            averageHeartRate: averageHeartRate,
            performedAt: performedAt,
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
