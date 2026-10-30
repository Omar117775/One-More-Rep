import 'package:flutter/material.dart';

import '../../components/charts.dart';
import '../../components/common.dart';
import '../../components/states.dart';
import '../../core/app_scope.dart';
import '../../core/formatters.dart';
import '../../design/motion/progress_ring_bar.dart';
import '../../design/tokens.dart';
import '../../localization/app_strings.dart';
import 'nutrition.dart';
import 'nutrition_repository.dart';
import 'nutrition_view_model.dart';

/// Mock nutrition overview (P4), laid out after ProgressScreen: range chips,
/// energy-estimate card (clearly labeled ESTIMATE with the Mifflin-St Jeor
/// disclaimer), dated history charts, today's rings/stat tiles and the meal
/// log. Add-meal is explicitly mock — toast only.
class NutritionScreen extends StatefulWidget {
  const NutritionScreen({this.repository, super.key});

  /// Optional injection point for tests; defaults to the mock catalog.
  final NutritionRepository? repository;

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  NutritionViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel ??= NutritionViewModel(repository: widget.repository)..load();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final viewModel = _viewModel!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.nutritionTitle)),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          switch (viewModel.status) {
            case NutritionStatus.loading:
              return const OmrLoading();
            case NutritionStatus.error:
              return OmrErrorPanel(
                message: viewModel.errorMessage ?? strings.errorGeneric,
                onRetry: viewModel.load,
              );
            case NutritionStatus.ready:
              return RefreshIndicator(
                onRefresh: viewModel.load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    _RangeChips(viewModel: viewModel),
                    const SizedBox(height: AppSpacing.md),
                    _EnergyCard(viewModel: viewModel),
                    const SizedBox(height: AppSpacing.md),
                    _TodayTargets(viewModel: viewModel),
                    const SizedBox(height: AppSpacing.md),
                    SectionHeader(title: strings.nutritionHistoryHeader),
                    _HistoryCharts(viewModel: viewModel),
                    const SizedBox(height: AppSpacing.lg),
                    SectionHeader(title: strings.nutritionMealsHeader),
                    ...viewModel.data!.todaysMeals.map(
                      (meal) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _MealCard(meal: meal),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      height: AppSpacing.touchTarget,
                      child: OutlinedButton.icon(
                        // Explicitly mock: no fake logging flow.
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(strings.nutritionAddMealToast),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        label: Text(strings.nutritionAddMeal),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}

class _RangeChips extends StatelessWidget {
  const _RangeChips({required this.viewModel});

  final NutritionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final choices = {
      NutritionRange.seven: strings.range7,
      NutritionRange.thirty: strings.range30,
    };
    return SizedBox(
      height: AppSpacing.touchTarget,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: [
          for (final entry in choices.entries)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: ChoiceChip(
                label: Text(entry.value),
                selected: viewModel.range == entry.key,
                selectedColor: AppColors.gold.withValues(alpha: 0.35),
                showCheckmark: false,
                onSelected: (_) => viewModel.setRange(entry.key),
              ),
            ),
        ],
      ),
    );
  }
}

/// Energy estimate — ALWAYS paired with the ESTIMATE chip + disclaimer so it
/// can never be confused with a recorded measurement.
class _EnergyCard extends StatelessWidget {
  const _EnergyCard({required this.viewModel});

  final NutritionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);
    final locale = controller.strings.localeName;

    return OmrCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.14),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.goldLight,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      strings.nutritionEnergyHeader,
                      style: AppText.caption,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bronze.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        border: Border.all(
                          color: AppColors.bronze.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Text(
                        strings.nutritionEstimateChip,
                        style: AppText.microLabel.copyWith(
                          color: AppColors.bronze,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  viewModel.energyEstimateKcal != null
                      ? '${formatInteger(viewModel.energyEstimateKcal!, locale: locale)} '
                          '${strings.unitKcal}'
                      : '—',
                  style: AppText.headline.copyWith(fontSize: 22),
                ),
                Text(
                  '${strings.nutritionTargetLabel} '
                  '${formatInteger(
                    viewModel.data!.targets.calories,
                    locale: locale,
                  )} '
                  '${strings.unitKcal} '
                  '• ${strings.nutritionDisclaimer}',
                  style: AppText.secondary.copyWith(
                    fontSize: 11,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Today vs targets: calorie ring + macro value tiles.
class _TodayTargets extends StatelessWidget {
  const _TodayTargets({required this.viewModel});

  final NutritionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);
    final locale = controller.strings.localeName;
    final targets = viewModel.data!.targets;
    final latest = viewModel.data!.latestDay!;
    final protein = latest.proteinG;

    final calorieProgress = viewModel.caloriesTarget > 0
        ? viewModel.caloriesConsumedToday / viewModel.caloriesTarget
        : 0.0;

    return OmrCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ProgressRingBar(value: calorieProgress, size: 88, strokeWidth: 9),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatInteger(
                      viewModel.caloriesConsumedToday.round(),
                      locale: locale,
                    ),
                    style: AppText.title.copyWith(fontSize: 14),
                  ),
                  Text(
                    '/ ${formatInteger(targets.calories, locale: locale)}',
                    style: AppText.microLabel.copyWith(fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MacroRow(
                  label: strings.nutritionProtein,
                  value:
                      '${formatDecimal(protein, locale: locale, maxDigits: 0)} '
                      '${strings.unitGrams}',
                  target:
                      '${formatDecimal(targets.proteinG.toDouble(), locale: locale, maxDigits: 0)} '
                      '${strings.unitGrams}',
                ),
                const Divider(
                  height: AppSpacing.sm + 2,
                  color: AppColors.border,
                ),
                _MacroRow(
                  label: strings.nutritionCarbs,
                  // Not recorded in the mock day records — shown honestly
                  // as no-value placeholders with the target alongside.
                  value: '—',
                  target:
                      '${formatDecimal(targets.carbsG.toDouble(), locale: locale, maxDigits: 0)} '
                      '${strings.unitGrams}',
                ),
                const Divider(
                  height: AppSpacing.sm + 2,
                  color: AppColors.border,
                ),
                _MacroRow(
                  label: strings.nutritionFat,
                  value: '—',
                  target:
                      '${formatDecimal(targets.fatG.toDouble(), locale: locale, maxDigits: 0)} '
                      '${strings.unitGrams}',
                ),
                const Divider(
                  height: AppSpacing.sm + 2,
                  color: AppColors.border,
                ),
                _MacroRow(
                  label: strings.nutritionWater,
                  value:
                      '${formatDecimal(latest.waterL, locale: locale, maxDigits: 1)} '
                      '${strings.unitLiter}',
                  target:
                      '${formatDecimal(targets.waterL, locale: locale, maxDigits: 1)} '
                      '${strings.unitLiter}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({
    required this.label,
    required this.value,
    required this.target,
  });

  final String label;
  final String value;
  final String target;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppText.caption),
        const Spacer(),
        Text(value, style: AppText.body),
        if (target.isNotEmpty) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(target, style: AppText.secondary.copyWith(fontSize: 11)),
        ],
      ],
    );
  }
}

/// Dated history: calories bars (gold) + protein line (bronze) for the
/// selected range. Values are mock records — clearly dated, never smoothed.
class _HistoryCharts extends StatelessWidget {
  const _HistoryCharts({required this.viewModel});

  final NutritionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);
    final locale = controller.strings.localeName;
    final days = [...viewModel.visibleDays]
      ..sort((a, b) => a.date.compareTo(b.date));

    final caloriesData = ChartData(
      labels: [
        for (final day in days) formatDate(day.date, locale: locale),
      ],
      values: [for (final day in days) day.caloriesConsumed],
    );

    final proteinData = ChartData(
      labels: [
        for (final day in days) formatDate(day.date, locale: locale),
      ],
      values: [for (final day in days) day.proteinG],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.nutritionCalories, style: AppText.caption),
        const SizedBox(height: AppSpacing.xs),
        OmrCard(
          child: AnimatedBarChart(
            data: caloriesData,
            accent: AppColors.gold,
            height: 120,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(strings.nutritionProtein, style: AppText.caption),
        const SizedBox(height: AppSpacing.xs),
        OmrCard(
          child: AnimatedLineChart(
            data: proteinData,
            accent: AppColors.bronze,
            height: 120,
          ),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal});

  final MealEntry meal;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);
    final locale = controller.strings.localeName;

    return OmrCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.bronze.withValues(alpha: 0.14),
              border: Border.all(color: AppColors.bronze.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(_mealIcon, color: AppColors.bronze, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _mealLabel(strings),
                  style: AppText.title.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 2),
                // Mock meal copy (English-only catalog content).
                Text(
                  meal.name,
                  style: AppText.secondary.copyWith(fontSize: 11.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${formatInteger(meal.calories, locale: locale)} '
                '${strings.unitKcal}',
                style: AppText.title.copyWith(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData get _mealIcon => switch (meal.type) {
    MealType.breakfast => Icons.free_breakfast_outlined,
    MealType.lunch => Icons.restaurant_outlined,
    MealType.dinner => Icons.dinner_dining_outlined,
    MealType.snack => Icons.bakery_dining_outlined,
  };

  String _mealLabel(AppStrings strings) => switch (meal.type) {
    MealType.breakfast => strings.mealBreakfast,
    MealType.lunch => strings.mealLunch,
    MealType.dinner => strings.mealDinner,
    MealType.snack => strings.mealSnack,
  };
}
