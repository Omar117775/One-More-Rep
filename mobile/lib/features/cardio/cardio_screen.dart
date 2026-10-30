import 'package:flutter/material.dart';

import '../../components/common.dart';
import '../../components/states.dart';
import '../../core/app_scope.dart';
import '../../core/formatters.dart';
import '../../design/tokens.dart';
import '../../data/models/cardio_entry.dart';
import '../../localization/app_strings.dart';
import 'cardio_activities.dart' show CardioActivityOption;
import 'cardio_form_screen.dart';
import 'cardio_view_model.dart';

/// Cardio tab: history list with create/edit/delete via the form screen.
class CardioScreen extends StatefulWidget {
  const CardioScreen({super.key});

  @override
  State<CardioScreen> createState() => _CardioScreenState();
}

class _CardioScreenState extends State<CardioScreen> {
  CardioViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel ??= CardioViewModel(repo: AppScope.of(context).cardio)..load();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final viewModel = _viewModel!;
    return Scaffold(
      appBar: AppBar(title: Text(strings.cardioTitle)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'cardio-add',
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(strings.addCardio),
        onPressed: () {
          CardioFormScreen.push(context).then((_) => viewModel.load());
        },
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          switch (viewModel.status) {
            case CardioStatus.loading:
              return const OmrLoading();
            case CardioStatus.error:
              return OmrErrorPanel(
                message: viewModel.errorMessage ?? strings.errorGeneric,
                onRetry: viewModel.load,
              );
            case CardioStatus.ready:
              final list = viewModel.entriesNewestFirst;
              if (list.isEmpty) {
                return OmrEmptyPanel(
                  icon: Icons.directions_run,
                  title: strings.cardioEmpty,
                  subtitle: strings.cardioEmptySub,
                );
              }
              return RefreshIndicator(
                onRefresh: viewModel.load,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.xl + 64,
                  ),
                  itemCount: list.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) =>
                      _EntryCard(entry: list[index], viewModel: viewModel),
                ),
              );
          }
        },
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry, required this.viewModel});

  final CardioEntry entry;
  final CardioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);
    final locale = controller.strings.localeName;

    return OmrCard(
      onTap: () {
        CardioFormScreen.push(
          context,
          entry: entry,
        ).then((_) => viewModel.load());
      },
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              color: AppColors.gold.withValues(alpha: 0.14),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            ),
            child: Icon(entryIcon, color: AppColors.goldLight, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cardioActivityLabel(strings, entry.activityType),
                  style: AppText.title,
                ),
                const SizedBox(height: 3),
                Text(
                  formatDateTime(entry.performedAt, locale: locale),
                  style: AppText.secondary,
                ),
                const SizedBox(height: 3),
                Text(
                  '${formatSecondsCompact(entry.durationSeconds, locale: locale)}'
                  '${entry.distanceKm != null ? ' • ${formatDecimal(entry.distanceKm, locale: locale)} km' : ''}'
                  '${entry.averageHeartRate != null ? ' • ❤ ${formatInteger(entry.averageHeartRate, locale: locale)}' : ''}',
                  style: AppText.secondary,
                ),
              ],
            ),
          ),
          IconPill(
            icon: Icons.delete_outline,
            tooltip: strings.deleteEntry,
            onPressed: () => _confirmDelete(context, strings),
          ),
        ],
      ),
    );
  }

  IconData get entryIcon =>
      CardioActivityOption.resolve(entry.activityType).icon;

  String cardioActivityLabel(AppStrings strings, String type) =>
      CardioActivityOption.resolve(type).label(strings);

  Future<void> _confirmDelete(BuildContext context, AppStrings strings) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.deleteEntry, style: AppText.title),
        content: Text(strings.deleteEntryConfirm, style: AppText.secondary),
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(strings.savedNote)));
      }
    }
  }
}
