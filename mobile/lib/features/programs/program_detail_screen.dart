import 'package:flutter/material.dart';

import '../../components/common.dart';
import '../../design/tokens.dart';
import '../../localization/app_strings.dart';
import 'workout_program.dart';

/// Read-only program detail from the mock catalog: level/length meta, weekly
/// schedule and an explicitly-mock enrollment CTA that only shows a "coming
/// soon" snackbar. No navigation, no server action, nothing implied.
class ProgramDetailScreen extends StatelessWidget {
  const ProgramDetailScreen({required this.program, super.key});

  final WorkoutProgram program;

  static Future<void> push(BuildContext context, WorkoutProgram program) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProgramDetailScreen(program: program),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final levelLabel = switch (program.level) {
      ProgramLevel.beginner => strings.difficultyBeginner,
      ProgramLevel.intermediate => strings.difficultyIntermediate,
      ProgramLevel.advanced => strings.difficultyAdvanced,
    };

    return Scaffold(
      appBar: AppBar(title: Text(strings.programsTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppBreakpoints.contentMax,
          ),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(program.name, style: AppText.headline),
                        const SizedBox(height: AppSpacing.xs),
                        Text(program.description, style: AppText.secondary),
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
                      color: AppColors.gold.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      strings.mockPreview,
                      style: AppText.microLabel.copyWith(
                        color: AppColors.goldLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  _MetaChip(
                    text: '${program.weeks} ${strings.programWeeksLabel}',
                  ),
                  _MetaChip(
                    text:
                        '${program.sessionsPerWeek} '
                        '${strings.programSessionsLabel}',
                  ),
                  _MetaChip(text: '${strings.programLevelLabel}: $levelLabel'),
                  _MetaChip(text: program.tag),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(title: strings.programSchedule),
              for (var i = 0; i < program.weeklySchedule.length; i++)
                _ScheduleRow(
                  dayNumber: i + 1,
                  detail: program.weeklySchedule[i],
                ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: AppSpacing.touchTarget,
                child: FilledButton.icon(
                  // Explicitly mock: signals the enrollment flow is not live.
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(strings.comingSoonToast)),
                    );
                  },
                  icon: const Icon(Icons.lock_outline_rounded, size: 20),
                  label: Text(strings.comingSoon),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.dayNumber, required this.detail});

  final int dayNumber;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            ),
            child: Text(
              '${strings.dayLabel}\n$dayNumber',
              textAlign: TextAlign.center,
              style: AppText.microLabel.copyWith(
                color: AppColors.goldLight,
                fontSize: 9,
                letterSpacing: 0,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              detail,
              style: AppText.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.text});

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
      child: Text(
        text,
        style: AppText.microLabel.copyWith(fontSize: 10.5, letterSpacing: 0.2),
      ),
    );
  }
}
