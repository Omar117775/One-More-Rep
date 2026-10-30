/// Nutrition domain (Phase 4: local mock data — see
/// [MockNutritionRepository]).
library;

/// Mock meal-log entry for today.
class MealEntry {
  const MealEntry({
    required this.type,
    required this.name,
    required this.calories,
  });

  final MealType type;

  /// Mock meal copy (English-only catalog content, like the other mock
  /// data); the meal-type label is localized via AppStrings.
  final String name;
  final int calories;
}

enum MealType { breakfast, lunch, dinner, snack }

/// One dated day of nutrition records (dated records, never overwritten).
class NutritionDay {
  const NutritionDay({
    required this.date,
    required this.caloriesConsumed,
    required this.proteinG,
    required this.waterL,
  });

  final DateTime date;
  final double caloriesConsumed;
  final double proteinG;
  final double waterL;
}

class NutritionTargets {
  const NutritionTargets({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.waterL,
  });

  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final double waterL;
}

class NutritionOverview {
  const NutritionOverview({
    required this.targets,
    required this.days,
    required this.todaysMeals,
  });

  final NutritionTargets targets;

  /// Newest-first dated history (mock: 30 days) powering the range chips.
  final List<NutritionDay> days;

  /// Today's meal log (mock entries).
  final List<MealEntry> todaysMeals;

  NutritionDay? get latestDay =>
      days.isNotEmpty ? days.first : null;
}

/// Documented BMR formula (Mifflin-St Jeor). Returns kcal/day for the
/// basal rate — this is always labeled as an ESTIMATE in the UI: it is
/// distinct from recorded measurements, per the architecture rules.
double bmrMifflinStJeor({
  required double weightKg,
  required double heightCm,
  required int ageYears,
  required bool isMale,
}) {
  final base = 10 * weightKg + 6.25 * heightCm - 5 * ageYears;
  return base + (isMale ? 5 : -161);
}

/// Estimated daily energy expenditure (moderate activity factor 1.55 —
/// Harris-Benedict activity table). UI copy always marks this estimate.
double tdeeEstimate({
  required double weightKg,
  required double heightCm,
  required int ageYears,
  required bool isMale,
}) => bmrMifflinStJeor(
  weightKg: weightKg,
  heightCm: heightCm,
  ageYears: ageYears,
  isMale: isMale,
) * 1.55;
