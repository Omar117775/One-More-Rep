import 'package:flutter/material.dart';

import '../../components/common.dart';
import '../../design/brand/spartan_emblem.dart';
import '../../design/motion/pressable_scale.dart';
import '../../design/tokens.dart';
import '../../localization/app_strings.dart';

/// Achievement model representing a Spartan warrior milestone.
class SpartanAchievement {
  const SpartanAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.unlocked,
    required this.progress,
    required this.maxProgress,
    this.unlockedDate,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String category; // 'milestone', 'streak', 'pr'
  final bool unlocked;
  final int progress;
  final int maxProgress;
  final String? unlockedDate;
}

/// Standalone Achievements Gallery screen with locked/unlocked states,
/// category filtering, progress indicators, and detail modal.
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  String _selectedCategory = 'all';

  static const List<SpartanAchievement> _allAchievements = [
    SpartanAchievement(
      id: 'first_rep',
      title: 'First Blood',
      description: 'Log your very first training session in the arena.',
      icon: Icons.fitness_center,
      category: 'milestone',
      unlocked: true,
      progress: 1,
      maxProgress: 1,
      unlockedDate: 'Oct 24, 2026',
    ),
    SpartanAchievement(
      id: 'streak_7',
      title: 'Spartan Discipline',
      description: 'Maintain a 7-day uninterrupted training and cardio streak.',
      icon: Icons.local_fire_department,
      category: 'streak',
      unlocked: true,
      progress: 7,
      maxProgress: 7,
      unlockedDate: 'Oct 29, 2026',
    ),
    SpartanAchievement(
      id: 'heavy_bench',
      title: 'Shield Breaker',
      description: 'Surpass a 100 kg Bench Press personal record.',
      icon: Icons.military_tech,
      category: 'pr',
      unlocked: true,
      progress: 105,
      maxProgress: 100,
      unlockedDate: 'Oct 28, 2026',
    ),
    SpartanAchievement(
      id: 'volume_10k',
      title: 'Titan Volume',
      description: 'Move over 10,000 kg of cumulative weight in a single week.',
      icon: Icons.line_weight,
      category: 'milestone',
      unlocked: true,
      progress: 12400,
      maxProgress: 10000,
      unlockedDate: 'Oct 27, 2026',
    ),
    SpartanAchievement(
      id: 'streak_30',
      title: 'Iron Phalanx',
      description: 'Log workouts for 30 consecutive days without quitting.',
      icon: Icons.shield,
      category: 'streak',
      unlocked: false,
      progress: 14,
      maxProgress: 30,
    ),
    SpartanAchievement(
      id: 'marathon_pace',
      title: 'Thermopylae Runner',
      description: 'Complete 25 total kilometers of cardio within one month.',
      icon: Icons.directions_run,
      category: 'milestone',
      unlocked: false,
      progress: 18,
      maxProgress: 25,
    ),
    SpartanAchievement(
      id: 'deadlift_pr',
      title: 'Earthshaker',
      description: 'Shatter personal record with a 180 kg Deadlift.',
      icon: Icons.bolt,
      category: 'pr',
      unlocked: false,
      progress: 165,
      maxProgress: 180,
    ),
    SpartanAchievement(
      id: 'master_spartan',
      title: 'Agoge Champion',
      description: 'Complete 100 verified training sessions.',
      icon: Icons.workspace_premium,
      category: 'milestone',
      unlocked: false,
      progress: 42,
      maxProgress: 100,
    ),
  ];

  void _showDetail(SpartanAchievement item) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.secondaryBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            side: BorderSide(
              color: item.unlocked ? AppColors.metallicGold : AppColors.border,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.unlocked
                      ? AppColors.metallicGold.withValues(alpha: 0.18)
                      : AppColors.darkGraphite,
                  border: Border.all(
                    color: item.unlocked
                        ? AppColors.metallicGold
                        : AppColors.border,
                    width: 2,
                  ),
                ),
                child: Icon(
                  item.icon,
                  size: 36,
                  color: item.unlocked
                      ? AppColors.metallicGold
                      : AppColors.neutralGray,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                item.title,
                style: AppText.title.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                item.description,
                style: AppText.body.copyWith(
                  color: AppColors.neutralGray,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.unlocked ? Icons.check_circle : Icons.lock_clock,
                    size: 16,
                    color: item.unlocked
                        ? AppColors.success
                        : AppColors.metallicGold,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.unlocked
                        ? 'Unlocked on ${item.unlockedDate}'
                        : 'Progress: ${item.progress} / ${item.maxProgress}',
                    style: AppText.caption.copyWith(
                      color: item.unlocked
                          ? AppColors.success
                          : AppColors.neutralGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final unlockedCount = _allAchievements.where((a) => a.unlocked).length;

    final filtered = _selectedCategory == 'all'
        ? _allAchievements
        : _allAchievements.where((a) => a.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        title: Text(strings.achievementsTitle),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppBreakpoints.contentMax,
            ),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // Top Progress Card
                OmrCard(
                  child: Row(
                    children: [
                      const SpartanEmblem(size: 54, emphasis: 1.1),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Spartan Trophies',
                              style: AppText.title.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$unlockedCount of ${_allAchievements.length} ${strings.achievementsUnlockedCount}',
                              style: AppText.secondary.copyWith(fontSize: 12),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadii.pill),
                              child: LinearProgressIndicator(
                                value: unlockedCount / _allAchievements.length,
                                backgroundColor: AppColors.darkGraphite,
                                valueColor: const AlwaysStoppedAnimation(
                                  AppColors.metallicGold,
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Category Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _CategoryChip(
                        label: 'All',
                        selected: _selectedCategory == 'all',
                        onTap: () => setState(() => _selectedCategory = 'all'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _CategoryChip(
                        label: 'Milestones',
                        selected: _selectedCategory == 'milestone',
                        onTap: () => setState(() => _selectedCategory = 'milestone'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _CategoryChip(
                        label: 'Streaks',
                        selected: _selectedCategory == 'streak',
                        onTap: () => setState(() => _selectedCategory = 'streak'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _CategoryChip(
                        label: 'Records (PR)',
                        selected: _selectedCategory == 'pr',
                        onTap: () => setState(() => _selectedCategory = 'pr'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Grid of Achievements
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return PressableScale(
                      onTap: () => _showDetail(item),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryBlack,
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          border: Border.all(
                            color: item.unlocked
                                ? AppColors.metallicGold.withValues(alpha: 0.4)
                                : AppColors.border,
                            width: item.unlocked ? 1.4 : 1.0,
                          ),
                          boxShadow: item.unlocked
                              ? [
                                  BoxShadow(
                                    color: AppColors.metallicGold
                                        .withValues(alpha: 0.1),
                                    blurRadius: 14,
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: item.unlocked
                                    ? AppColors.metallicGold.withValues(alpha: 0.16)
                                    : AppColors.darkGraphite,
                              ),
                              child: Icon(
                                item.icon,
                                color: item.unlocked
                                    ? AppColors.metallicGold
                                    : AppColors.neutralGray.withValues(alpha: 0.5),
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              item.title,
                              style: AppText.title.copyWith(fontSize: 14),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.unlocked
                                  ? 'Unlocked'
                                  : '${item.progress} / ${item.maxProgress}',
                              style: AppText.caption.copyWith(
                                color: item.unlocked
                                    ? AppColors.success
                                    : AppColors.neutralGray,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.metallicGold.withValues(alpha: 0.16)
              : AppColors.secondaryBlack,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: selected ? AppColors.metallicGold : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppText.secondary.copyWith(
            color: selected ? AppColors.metallicGold : AppColors.neutralGray,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
