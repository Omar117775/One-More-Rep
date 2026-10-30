import 'package:flutter/material.dart';

import '../../components/common.dart';
import '../../components/states.dart';
import '../../core/app_scope.dart';
import '../../core/formatters.dart';
import '../../design/tokens.dart';
import '../../data/models/assignment.dart';
import '../../localization/app_strings.dart';
import 'assignment_detail_screen.dart';
import 'session_history_screen.dart';
import 'train_view_model.dart';

/// Train tab: assigned programs list with status badges.
class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key});

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  TrainViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel ??= TrainViewModel(repo: AppScope.of(context).train)..load();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final viewModel = _viewModel!;
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.trainTitle),
        actions: [
          IconButton(
            tooltip: strings.sessionHistory,
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              SessionHistoryScreen.push(context).then((_) => viewModel.load());
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          switch (viewModel.status) {
            case TrainStatus.loading:
              return const OmrLoading();
            case TrainStatus.error:
              return OmrErrorPanel(
                message: viewModel.errorMessage ?? strings.errorGeneric,
                onRetry: viewModel.load,
              );
            case TrainStatus.ready:
              final list = viewModel.sortedAssignments;
              if (list.isEmpty) {
                return OmrEmptyPanel(
                  icon: Icons.flag_outlined,
                  title: strings.trainNoAssignments,
                  subtitle: strings.trainNoAssignmentsSub,
                );
              }
              return RefreshIndicator(
                onRefresh: viewModel.load,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: list.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    return _AssignmentCard(
                      assignment: list[index],
                      onTap: () {
                        AssignmentDetailScreen.push(
                          context,
                          list[index],
                        ).then((_) => viewModel.load());
                      },
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.assignment, required this.onTap});

  final Assignment assignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);
    final locale = controller.strings.localeName;

    // Status semantics: gold = live/active emphasis, bronze = upcoming,
    // muted = archived. Tokens only — no raw colors.
    final (label, color) = assignment.isActive
        ? (strings.trainActive, AppColors.goldLight)
        : assignment.isUpcoming
        ? (strings.trainUpcoming, AppColors.bronze)
        : (strings.trainEnded, AppColors.muted);

    return OmrCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  assignment.program.name,
                  style: AppText.title.copyWith(fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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
          if (assignment.program.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              assignment.program.description,
              style: AppText.secondary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _MetaChip(
                icon: Icons.calendar_view_week_rounded,
                text: '${assignment.program.days.length} ${strings.trainDays}',
              ),
              _MetaChip(
                icon: Icons.fitness_center,
                text:
                    '${formatInteger(assignment.program.totalExercises, locale: locale)} ${strings.exercisesCount}',
              ),
              if (assignment.startsOn != null)
                _MetaChip(
                  text:
                      '${strings.trainStarts} ${formatDate(assignment.startsOn, locale: locale)}',
                ),
              if (assignment.endsOn != null)
                _MetaChip(
                  text:
                      '${strings.trainEnds} ${formatDate(assignment.endsOn, locale: locale)}',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({this.icon, required this.text});

  final IconData? icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: AppColors.goldLight),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppText.microLabel.copyWith(
              fontSize: 10.5,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
