import 'package:flutter/material.dart';

import '../../components/common.dart';
import '../../components/spartan_companion.dart';
import '../../components/stat_tile.dart';
import '../../components/states.dart';
import '../../core/app_scope.dart';
import '../../core/formatters.dart';
import '../../data/models/analytics_summary.dart';
import '../../data/models/assignment.dart';
import '../../design/tokens.dart';
import '../../localization/app_strings.dart';
import 'companion_state.dart';
import 'home_view_model.dart';

/// Home dashboard: greeting, companion, 30-day summaries, active program
/// card, quick actions. Pull-to-refresh; distinct loading/empty/error states.
class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.onNavigate, super.key});

  final ValueChanged<int> onNavigate;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = AppScope.of(context);
    _viewModel ??= HomeViewModel(
      train: controller.train,
      analytics: controller.analytics,
      nowProvider: () => DateTime.now(),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final viewModel = _viewModel!;
    return Scaffold(
      appBar: AppBar(title: Text('ONE MORE REP', style: AppText.title.copyWith(fontSize: 15, letterSpacing: 1.6))),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final status = viewModel.status;
          if (status == HomeStatus.loading) {
            return const OmrLoading();
          }
          if (status == HomeStatus.error) {
            return OmrErrorPanel(message: viewModel.errorMessage ?? strings.errorGeneric, onRetry: viewModel.load);
          }
          return RefreshIndicator(
            onRefresh: viewModel.load,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _HomeContent(viewModel: viewModel, onNavigate: widget.onNavigate),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.viewModel, required this.onNavigate});

  final HomeViewModel viewModel;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);
    final locale = controller.strings.localeName;
    final data = viewModel.data!;

    final companion = companionFor(
      analytics: data.analytics,
      assignments: data.assignments,
      sessions: data.sessions,
      now: DateTime.now(),
    );

    final workouts = data.analytics.workouts;
    final cardio = data.analytics.cardio;
    final body = data.analytics.body;
    final latestWeight = _latestWeight(body);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_greeting(strings), style: AppText.secondary),
        const SizedBox(height: AppSpacing.xs),
        Text(
          controller.user?.displayName ?? '',
          style: AppText.headline,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: AnimatedCompanion(state: companion),
          ),
        ),
        _ActiveProgramCard(assignment: data.activeAssignment, onNavigate: onNavigate),
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(title: strings.homeQuickActions),
        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width > 560 ? 4 : 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.15,
          children: [
            QuickActionTile(icon: Icons.fitness_center, label: strings.homeQuickWorkout, onTap: () => onNavigate(1)),
            QuickActionTile(icon: Icons.directions_run, label: strings.homeQuickCardio, onTap: () => onNavigate(2)),
            QuickActionTile(icon: Icons.add_chart, label: strings.homeQuickProgress, onTap: () => onNavigate(3)),
            QuickActionTile(icon: Icons.history, label: strings.sessionHistory, onTap: () => onNavigate(1)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(title: strings.last30Days),
        AnimatedStatTile(
          icon: Icons.fitness_center,
          label: strings.homeWorkoutsSummary,
          value: workouts.hasData
              ? '${formatInteger(workouts.completedSessions, locale: locale)} / ${formatInteger(workouts.sessions, locale: locale)}'
              : '—',
          caption: workouts.hasData
              ? '${formatDecimal(workouts.volumeKg, locale: locale)} kg · ${formatInteger(workouts.sets, locale: locale)} ${strings.targetSetsShort}'
              : strings.homeNoWorkouts30,
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedStatTile(
          icon: Icons.directions_run,
          accent: AppColors.success,
          label: strings.homeCardioSummary,
          value: cardio.hasData
              ? formatSecondsCompact(cardio.durationSeconds, locale: locale)
              : '—',
          caption: cardio.hasData
              ? '${formatInteger(cardio.sessions, locale: locale)} ${strings.navCardio}'
              : strings.homeNoCardio30,
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedStatTile(
          icon: Icons.monitor_weight_outlined,
          accent: AppColors.warning,
          label: strings.homeBodySummary,
          value: latestWeight != null
              ? '${formatDecimal(latestWeight, locale: locale)} kg'
              : '—',
          caption: body.hasData ? formatDate(body.series.last.measuredOn, locale: locale) : strings.homeNoBody30,
        ),
      ],
    );
  }

  double? _latestWeight(BodyAnalytics body) {
    if (!body.hasData) return null;
    for (final point in body.series.reversed) {
      if (point.weightKg != null) return point.weightKg;
    }
    return null;
  }

  String _greeting(AppStrings strings) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return strings.greetingMorning;
    if (hour >= 12 && hour < 17) return strings.greetingAfternoon;
    if (hour >= 17 && hour < 22) return strings.greetingEvening;
    return strings.greetingNight;
  }
}

class AnimatedCompanion extends StatelessWidget {
  const AnimatedCompanion({required this.state, super.key});

  final SpartanState state;

  @override
  Widget build(BuildContext context) {
    return SpartanCompanion(state: state, size: 108);
  }
}

class _ActiveProgramCard extends StatelessWidget {
  const _ActiveProgramCard({required this.assignment, required this.onNavigate});

  final Assignment? assignment;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);
    final locale = controller.strings.localeName;

    final card = OmrCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: assignment == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium_outlined, color: AppColors.blueLight),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(strings.homeNoProgram, style: AppText.title),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(strings.homeNoProgramSub, style: AppText.secondary),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.homeActiveProgram, style: AppText.caption),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  assignment!.program.name,
                  style: AppText.title.copyWith(fontSize: 19),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (assignment!.program.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    assignment!.program.description,
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
                    _Chip(text: '${assignment!.program.days.length} ${strings.trainDays}'),
                    _Chip(
                      text: assignment!.startsOn != null
                          ? '${strings.trainStarts}: ${formatDate(assignment!.startsOn, locale: locale)}'
                          : strings.trainActive,
                    ),
                    if (assignment!.endsOn != null)
                      _Chip(text: '${strings.trainEnds}: ${formatDate(assignment!.endsOn, locale: locale)}'),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: AppSpacing.touchTarget,
                  child: FilledButton.icon(
                    onPressed: () => onNavigate(1),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(strings.homeBeginSession),
                  ),
                ),
              ],
            ),
    );
    return card;
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: AppText.microLabel.copyWith(fontSize: 10.5, letterSpacing: 0.2),
      ),
    );
  }
}
