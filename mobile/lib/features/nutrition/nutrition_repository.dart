import 'nutrition.dart';

/// Source of truth for nutrition data. Backed by [MockNutritionRepository]
/// for now; a backend-backed implementation can be dropped in later
/// without UI changes.
abstract class NutritionRepository {
  Future<NutritionOverview> overview();

  /// Reads the mock trainee profile stats so the energy estimate can be
  /// computed. In the real system the backend computes and returns this.
  Future<({int ageYears, int heightCm, double weightKg, bool isMale})>
  profileBodyStats();
}
