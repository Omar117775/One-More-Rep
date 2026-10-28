import 'package:flutter/material.dart';

import '../../components/charts.dart';
import '../../components/common.dart';
import '../../components/states.dart';
import '../../core/app_scope.dart';
import '../../core/formatters.dart';
import '../../design/tokens.dart';
import '../../data/models/progress_entry.dart';
import '../../localization/app_strings.dart';
import 'progress_form_screen.dart';
import 'progress_view_model.dart';

/// Progress tab: range selector, animated charts, measurements CRUD.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  ProgressViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel ??= ProgressViewModel(
      progressRepo: AppScope.of(context).progress,
      analyticsRepo: AppScope.of(context).analytics,
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final viewModel = _viewModel!;
    return Scaffold(
      appBar: AppBar(title: Text(strings.progressTitle)),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          switch (viewModel.status) {
            case ProgressStatus.loading:
              return const OmrLoading();
            case ProgressStatus.error:
              return OmrErrorPanel(
                message: viewModel.errorMessage ?? strings.errorGeneric,
                onRetry: viewModel.load,
              );
            case ProgressStatus.ready:
              return RefreshIndicator(
                onRefresh: viewModel.load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    _RangeSelector(viewModel: viewModel),
                    const SizedBox(height: AppSpacing.md),
                    if (viewModel.busy) const LinearProgressIndicator(minHeight: 2),
                    _ChartsSection(viewModel: viewModel),
                    const SizedBox(height: AppSpacing.lg),
                    SectionHeader(title: strings.measurementsHeader),
                    _MeasurementsList(viewModel: viewModel),
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

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.viewModel});

  final ProgressViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final choices = {
      7: strings.range7,
      30: strings.range30,
      90: strings.range90,
      365: strings.range365,
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
                selected: viewModel.rangeDays == entry.key,
                selectedColor: AppColors.blue.withValues(alpha: 0.35),
                showCheckmark: false,
                onSelected: (_) => viewModel.setRange(entry.key),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChartsSection extends StatelessWidget {
  const _ChartsSection({required this.viewModel});

  final ProgressViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);
    final locale = controller.strings.localeName;
    final analytics = viewModel.analytics!;

    final weightData = ChartData(
      labels: analytics.body.series.map((p) => formatDate(p.measuredOn, locale: locale)).toList(),
      values: analytics.body.series.map((p) => p.weightKg).toList(),
    );

    final volumeData = ChartData(
      labels: analytics.workouts.weekly.map((w) => formatWeekLabel(w.weekStart, locale: locale)).toList(),
      values: analytics.workouts.weekly.map((w) => w.volumeKg).toList(),
    );

    final cardioData = ChartData(
      labels: analytics.cardio.weekly.map((w) => formatWeekLabel(w.weekStart, locale: locale)).toList(),
      values: analytics.cardio.weekly
          .map((w) => w.durationSeconds / 60.0)
          .cast<double?>()
          .toList(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: strings.chartBodyWeight),
        OmrCard(
          child: AnimatedLineChart(data: weightData, accent: AppColors.blueLight),
        ),
        const SizedBox(height: AppSpacing.md),
        SectionHeader(title: strings.chartWorkoutVolume),
        OmrCard(
          child: AnimatedBarChart(data: volumeData, accent: AppColors.blue),
        ),
        const SizedBox(height: AppSpacing.md),
        SectionHeader(title: strings.chartCardioDuration),
        OmrCard(
          child: AnimatedBarChart(data: cardioData, accent: AppColors.success),
        ),
      ],
    );
  }
}

class _MeasurementsList extends StatelessWidget {
  const _MeasurementsList({required this.viewModel});

  final ProgressViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);
    final locale = controller.strings.localeName;

    if (viewModel.entries.isEmpty) {
      return OmrEmptyPanel(
        icon: Icons.monitor_weight_outlined,
        title: strings.measurementsEmpty,
        subtitle: strings.measurementsEmptySub,
        actionLabel: strings.addMeasurement,
        onAction: () {
          ProgressFormScreen.push(
            context,
            viewModel: viewModel,
          ).then((_) => viewModel.load());
        },
      );
    }

    return Column(
      children: [
        for (final entry in viewModel.entriesNewestFirst)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _EntryCard(entry: entry, locale: locale, strings: strings, viewModel: viewModel),
          ),
      ],
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.entry,
    required this.locale,
    required this.strings,
    required this.viewModel,
  });

  final ProgressEntry entry;
  final String locale;
  final AppStrings strings;
  final ProgressViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final values = <String>[
      if (entry.weightKg != null)
        '${strings.weightKg}: ${formatDecimal(entry.weightKg, locale: locale, maxDigits: 2)}',
      if (entry.bodyFatPercentage != null)
        '${strings.bodyFatPercentage}: ${formatDecimal(entry.bodyFatPercentage, locale: locale, maxDigits: 2)}',
      if (entry.waistCm != null)
        '${strings.waistCm}: ${formatDecimal(entry.waistCm, locale: locale, maxDigits: 2)}',
      if (entry.chestCm != null)
        '${strings.chestCm}: ${formatDecimal(entry.chestCm, locale: locale, maxDigits: 2)}',
      if (entry.armCm != null)
        '${strings.armCm}: ${formatDecimal(entry.armCm, locale: locale, maxDigits: 2)}',
    ];

    return OmrCard(
      onTap: () {
        ProgressFormScreen.push(context, viewModel: viewModel, entry: entry)
            .then((_) => viewModel.load());
      },
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              color: AppColors.warning.withValues(alpha: 0.14),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
            ),
            child: Text(
              '${entry.measuredOn.day}',
              style: AppText.title.copyWith(color: AppColors.warning, fontSize: 16),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDate(entry.measuredOn, locale: locale),
                  style: AppText.title,
                ),
                const SizedBox(height: 3),
                Text(
                  values.isEmpty ? '—' : values.join('  •  '),
                  style: AppText.secondary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconPill(
            icon: Icons.delete_outline,
            tooltip: strings.deleteMeasurement,
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.deleteMeasurement, style: AppText.title),
        content: Text(strings.deleteMeasurementConfirm, style: AppText.secondary),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text(strings.delete),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              minimumSize: const Size(96, AppSpacing.touchTarget),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final ok = await viewModel.delete(entry.id);
      if (ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.savedNote)),
        );
      }
    }
  }
}
