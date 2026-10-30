import 'package:flutter/foundation.dart';

import 'mock_nutrition_repository.dart';
import 'nutrition.dart';
import 'nutrition_repository.dart';

/// Load status — mirrors repo-backed view models so a real repository can
/// replace the mock without changing the UI shell.
enum NutritionStatus { loading, error, ready }

/// Range chips over the dated history (7 / 30 days).
enum NutritionRange { seven, thirty }

/// Nutrition state + the documented-formula energy estimate. The estimate
/// is always surfaced next to the localized disclaimer chip — it is never
/// presented as a measured record.
class NutritionViewModel extends ChangeNotifier {
  NutritionViewModel({NutritionRepository? repository})
    : _repository = repository ?? const MockNutritionRepository();

  final NutritionRepository _repository;

  NutritionStatus status = NutritionStatus.loading;
  String? errorMessage;
  NutritionOverview? data;
  NutritionRange range = NutritionRange.seven;

  /// Mifflin-St Jeor daily-energy estimate (kcal) — ESTIMATE only.
  int? energyEstimateKcal;

  Future<void> load() async {
    status = NutritionStatus.loading;
    notifyListeners();
    try {
      data = await _repository.overview();
      final stats = await _repository.profileBodyStats();
      energyEstimateKcal = tdeeEstimate(
        weightKg: stats.weightKg,
        heightCm: stats.heightCm.toDouble(),
        ageYears: stats.ageYears,
        isMale: stats.isMale,
      ).round();
      status = NutritionStatus.ready;
    } catch (error) {
      errorMessage = error.toString();
      status = NutritionStatus.error;
    }
    notifyListeners();
  }

  void setRange(NutritionRange range) {
    this.range = range;
    notifyListeners();
  }

  List<NutritionDay> get visibleDays {
    final overview = data;
    if (overview == null) return const [];
    final take = range == NutritionRange.seven ? 7 : 30;
    return [
      for (final day in overview.days.take(take)) day,
    ];
  }

  double get caloriesTarget => (data?.targets.calories ?? 0).toDouble();

  double get caloriesConsumedToday => data?.latestDay?.caloriesConsumed ?? 0;
}
