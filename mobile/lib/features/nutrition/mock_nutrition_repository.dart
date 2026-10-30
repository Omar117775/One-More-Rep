import 'nutrition.dart';
import 'nutrition_repository.dart';

/// MOCK DATA — Phase 4 stop-gap until backend nutrition endpoints exist.
/// Deterministic, English-only content; nothing is persisted. Swap for a
/// `lib/data/` repository later. Reads body stats from the mock profile
/// (single source of mock body data in `mock_profile_repository.dart` via a
/// small point-in-time copy here).
class MockNutritionRepository implements NutritionRepository {
  const MockNutritionRepository();

  static const NutritionTargets _targets = NutritionTargets(
    calories: 2400,
    proteinG: 150,
    carbsG: 260,
    fatG: 70,
    waterL: 3.0,
  );

  /// Deterministic 30-day history so range chips slice real data.
  static List<NutritionDay> _history() {
    final now = DateTime.now();
    return [
      for (var i = 0; i < 30; i++)
        NutritionDay(
          date: DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: i)),
          caloriesConsumed: 2050.0 + ((i * 173) % 620),
          proteinG: (120 + ((i * 29) % 60)).toDouble(),
          waterL: 2.2 + (((i * 31) % 14) / 10.0),
        ),
    ];
  }

  static const List<MealEntry> _todaysMeals = [
    MealEntry(
      type: MealType.breakfast,
      name: 'Proat bowl & berries',
      calories: 520,
    ),
    MealEntry(
      type: MealType.lunch,
      name: 'Chicken & rice bowl',
      calories: 780,
    ),
    MealEntry(
      type: MealType.snack,
      name: 'Greek yogurt & honey',
      calories: 190,
    ),
    MealEntry(type: MealType.dinner, name: 'Salmon & greens', calories: 560),
  ];

  /// Point-in-time copy of the mock profile body stats used for the energy
  /// estimate (kept in sync with mock_profile_repository.dart).
  static const ({int ageYears, int heightCm, double weightKg, bool isMale})
  _bodyStats = (ageYears: 27, heightCm: 178, weightKg: 78, isMale: true);

  @override
  Future<NutritionOverview> overview() async => NutritionOverview(
    targets: _targets,
    days: _history(),
    todaysMeals: _todaysMeals,
  );

  @override
  Future<({int ageYears, int heightCm, double weightKg, bool isMale})>
  profileBodyStats() async => _bodyStats;
}
