import 'package:flutter/material.dart';

import '../../components/common.dart';
import '../../components/stat_tile.dart';
import '../../components/states.dart';
import '../../core/app_scope.dart';
import '../../core/formatters.dart';
import '../../design/brand/spartan_emblem.dart';
import '../../design/motion/progress_ring_bar.dart';
import '../../design/tokens.dart';
import '../../localization/app_strings.dart';
import '../progress/progress_screen.dart';
import 'profile_repository.dart';
import 'profile_view_model.dart';

/// Mock trainee profile (P4): ember-glow avatar, headline stats with
/// count-up numbers, the weekly-goal ring (first ProgressRingBar consumer),
/// goals summary and a body-at-a-glance link into the existing Progress
/// screen. Editing is explicitly mock — toast only, nothing persists.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({this.repository, super.key});

  /// Optional injection point for tests; defaults to the mock catalog.
  final ProfileRepository? repository;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel ??= ProfileViewModel(repository: widget.repository)..load();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final viewModel = _viewModel!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.profileTitle)),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          switch (viewModel.status) {
            case ProfileStatus.loading:
              return const OmrLoading();
            case ProfileStatus.error:
              return OmrErrorPanel(
                message: viewModel.errorMessage ?? strings.errorGeneric,
                onRetry: viewModel.load,
              );
            case ProfileStatus.ready:
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppBreakpoints.contentMax,
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      _IdentityHeader(viewModel: viewModel),
                      const SizedBox(height: AppSpacing.lg),
                      SectionHeader(title: strings.profileStatsHeader),
                      _StatsSection(viewModel: viewModel),
                      const SizedBox(height: AppSpacing.lg),
                      SectionHeader(title: strings.profileWeeklyGoalHeader),
                      _WeeklyGoalCard(viewModel: viewModel),
                      const SizedBox(height: AppSpacing.lg),
                      SectionHeader(title: strings.profileGoalsHeader),
                      OmrCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final goal
                                in viewModel.profile!.goals) ...[
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: AppSpacing.xs),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 18,
                                      color: AppColors.goldLight,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    // Mock goals copy (English-only catalog
                                    // content); the header is localized.
                                    Expanded(
                                      child: Text(goal, style: AppText.body),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SectionHeader(title: strings.profileBodyHeader),
                      _BodyGlanceCard(viewModel: viewModel),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        height: AppSpacing.touchTarget,
                        child: OutlinedButton.icon(
                          // Explicitly mock: never implies persistence.
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(strings.profileEditToast)),
                            );
                          },
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          label: Text(strings.profileEditCta),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}

class _IdentityHeader extends StatelessWidget {
  const _IdentityHeader({required this.viewModel});

  final ProfileViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);
    final locale = controller.strings.localeName;
    final profile = viewModel.profile!;

    return OmrCard(
      child: Row(
        children: [
          // Admired sign-in pattern: static emblem inside a gold-glow shell.
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.10),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldDim.withValues(alpha: 0.30),
                  blurRadius: 22,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const SpartanEmblem(size: 46, emphasis: 1.15),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  style: AppText.headline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  profile.handle,
                  style: AppText.secondary.copyWith(
                    color: AppColors.goldLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  // Joined date is a dated record → localized formatting.
                  '${strings.profileJoined} '
                  '${formatDate(profile.joinedOn, locale: locale)}',
                  style: AppText.microLabel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.viewModel});

  final ProfileViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);
    final locale = controller.strings.localeName;
    final profile = viewModel.profile!;

    return Column(
      children: [
        AnimatedStatTile(
          icon: Icons.fitness_center,
          label: strings.profileStatSessions,
          value: formatInteger(profile.sessionsCompleted, locale: locale),
          countValue: profile.sessionsCompleted.toDouble(),
          countFormat: (v) => formatInteger(v.round(), locale: locale),
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedStatTile(
          icon: Icons.local_fire_department_rounded,
          accent: AppColors.bronze,
          label: strings.profileStatStreak,
          value:
              '${formatInteger(profile.currentStreakDays, locale: locale)} '
              '${strings.trainDays}',
          countValue: profile.currentStreakDays.toDouble(),
          countFormat: (v) =>
              '${formatInteger(v.round(), locale: locale)} ${strings.trainDays}',
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedStatTile(
          icon: Icons.insights,
          label: strings.profileStatVolume,
          value: '${formatDecimal(profile.volume30dKg, locale: locale, maxDigits: 0)} kg',
          countValue: profile.volume30dKg,
          countFormat: (v) =>
              '${formatDecimal(v, locale: locale, maxDigits: 0)} kg',
        ),
      ],
    );
  }
}

/// Weekly-goal ring — the first [ProgressRingBar] consumer in the app.
class _WeeklyGoalCard extends StatelessWidget {
  const _WeeklyGoalCard({required this.viewModel});

  final ProfileViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);
    final locale = controller.strings.localeName;
    final profile = viewModel.profile!;
    final progress = profile.weeklyGoalSessions > 0
        ? profile.weeklyDoneSessions / profile.weeklyGoalSessions
        : 0.0;

    return OmrCard(
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ProgressRingBar(value: progress, size: 88, strokeWidth: 9),
              Text(
                '${formatInteger(profile.weeklyDoneSessions, locale: locale)}'
                ' / ${formatInteger(profile.weeklyGoalSessions, locale: locale)}',
                style: AppText.title.copyWith(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              '${strings.profileWeeklyGoalHeader}\n'
              '${profile.weeklyGoalSessions} '
              '${strings.profileSessionsShort}',
              style: AppText.secondary.copyWith(height: 1.25),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyGlanceCard extends StatelessWidget {
  const _BodyGlanceCard({required this.viewModel});

  final ProfileViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);
    final locale = controller.strings.localeName;
    final profile = viewModel.profile!;

    return OmrCard(
      onTap: () => ProgressScreen.pushStandalone(context),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${formatDecimal(profile.weightKg, locale: locale)} kg'
                  '  •  ${profile.heightCm} ${strings.unitCentimeters}'
                  '  •  ${profile.ageYears} ${strings.unitYears}',
                  style: AppText.body,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  // Point at the source of truth: dated progress records
                  // live in the Progress screen (history, never overwritten).
                  '${strings.profileOpenProgress}: '
                  '${strings.chartBodyWeight}',
                  style: AppText.secondary.copyWith(fontSize: 11.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.goldLight,
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }
}
