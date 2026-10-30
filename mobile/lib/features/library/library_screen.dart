import 'package:flutter/material.dart';

import '../../components/common.dart';
import '../../components/states.dart';
import '../../design/tokens.dart';
import '../../localization/app_strings.dart';
import 'exercise.dart';
import 'exercise_detail_screen.dart';
import 'exercise_repository.dart';
import 'exercise_ui.dart';
import 'library_view_model.dart';

/// Exercise library: search field, group/type filter chips and the mock
/// catalog cards. Detail opens via the theme page transition. Local mock
/// data only — no API calls.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({this.repository, super.key});

  /// Optional injection point so tests can supply fixtures; defaults to the
  /// mock catalog.
  final ExerciseRepository? repository;

  static Future<void> push(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const LibraryScreen()));

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  LibraryViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel ??= LibraryViewModel(repository: widget.repository)..load();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final viewModel = _viewModel!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.libraryTitle)),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          switch (viewModel.status) {
            case LibraryStatus.loading:
              return const OmrLoading();
            case LibraryStatus.error:
              return OmrErrorPanel(
                message: viewModel.errorMessage ?? strings.errorGeneric,
                onRetry: viewModel.load,
              );
            case LibraryStatus.ready:
              final list = viewModel.filtered;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.xs,
                    ),
                    child: TextField(
                      onChanged: viewModel.search,
                      decoration: InputDecoration(
                        hintText: strings.librarySearchHint,
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      ),
                    ),
                  ),
                  _FilterRow(viewModel: viewModel),
                  Expanded(
                    child: list.isEmpty
                        ? OmrEmptyPanel(
                            icon: Icons.search_off_rounded,
                            title: strings.libraryEmpty,
                            subtitle: strings.librarySearchHint,
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg,
                              AppSpacing.md,
                              AppSpacing.lg,
                              AppSpacing.xl,
                            ),
                            itemCount: list.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) =>
                                _ExerciseCard(exercise: list[index]),
                          ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.viewModel});

  final LibraryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final groups = ExerciseGroup.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: AppSpacing.touchTarget * 0.72,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: ChoiceChip(
                  label: Text(strings.libraryAll),
                  selected: viewModel.groupFilter == null,
                  selectedColor: AppColors.gold.withValues(alpha: 0.35),
                  showCheckmark: false,
                  onSelected: (_) => viewModel.setGroup(null),
                ),
              ),
              for (final group in groups)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: ChoiceChip(
                    label: Text(groupLabel(strings, group)),
                    selected: viewModel.groupFilter == group,
                    selectedColor: AppColors.gold.withValues(alpha: 0.35),
                    showCheckmark: false,
                    onSelected: (_) => viewModel.setGroup(group),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: AppSpacing.touchTarget * 0.72,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: ChoiceChip(
                  label: Text(strings.libraryAll),
                  selected: viewModel.typeFilter == null,
                  selectedColor: AppColors.gold.withValues(alpha: 0.35),
                  showCheckmark: false,
                  onSelected: (_) => viewModel.setType(null),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: ChoiceChip(
                  label: Text(strings.typeStrength),
                  selected: viewModel.typeFilter == false,
                  selectedColor: AppColors.gold.withValues(alpha: 0.35),
                  showCheckmark: false,
                  onSelected: (_) => viewModel.setType(false),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: ChoiceChip(
                  label: Text(strings.typeCardio),
                  selected: viewModel.typeFilter == true,
                  selectedColor: AppColors.gold.withValues(alpha: 0.35),
                  showCheckmark: false,
                  onSelected: (_) => viewModel.setType(true),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final (:label, :color) = difficultyBadge(
      strings,
      exercise.difficulty,
    );

    return OmrCard(
      onTap: () => ExerciseDetailScreen.push(context, exercise),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (exercise.isCardio
                      ? AppColors.bronze
                      : AppColors.gold)
                  .withValues(alpha: 0.14),
              border: Border.all(
                color: (exercise.isCardio ? AppColors.bronze : AppColors.gold)
                    .withValues(alpha: 0.4),
              ),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(
              groupIcon(exercise.group),
              size: 22,
              color: exercise.isCardio ? AppColors.bronze : AppColors.goldLight,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: AppText.title.copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${groupLabel(strings, exercise.group)}'
                  '  •  ${exercise.equipment}',
                  style: AppText.secondary.copyWith(fontSize: 11.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(color: color.withValues(alpha: 0.45)),
            ),
            child: Text(
              label,
              style: AppText.microLabel.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
