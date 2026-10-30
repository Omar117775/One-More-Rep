import 'package:flutter/material.dart';

import '../../components/states.dart';
import '../../design/motion/pressable_scale.dart';
import '../../design/tokens.dart';
import '../../localization/app_strings.dart';
import 'program_detail_screen.dart';
import 'program_repository.dart';
import 'programs_view_model.dart';
import 'workout_program.dart';

/// Workout programs: premium list of the mock catalog. Gradient-black cards
/// with a bronze accent bar; detail via the theme page transition. The
/// enrollment CTA is explicitly labeled mock ("Coming soon") — no fake
/// server flows.
class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({this.repository, super.key});

  /// Optional injection point so tests can supply fixtures; defaults to the
  /// mock catalog.
  final ProgramRepository? repository;

  static Future<void> push(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const ProgramsScreen()));

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  ProgramsViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel ??= ProgramsViewModel(repository: widget.repository)..load();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final viewModel = _viewModel!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.programsTitle)),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          switch (viewModel.status) {
            case ProgramsStatus.loading:
              return const OmrLoading();
            case ProgramsStatus.error:
              return OmrErrorPanel(
                message: viewModel.errorMessage ?? strings.errorGeneric,
                onRetry: viewModel.load,
              );
            case ProgramsStatus.ready:
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppBreakpoints.contentMax,
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.xl,
                    ),
                    itemCount: viewModel.programs.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) =>
                        _ProgramCard(program: viewModel.programs[index]),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.program});

  final WorkoutProgram program;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final levelLabel = switch (program.level) {
      ProgramLevel.beginner => strings.difficultyBeginner,
      ProgramLevel.intermediate => strings.difficultyIntermediate,
      ProgramLevel.advanced => strings.difficultyAdvanced,
    };

    return PressableScale(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ProgramDetailScreen.push(context, program),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surface,
                  AppColors.surfaceLight,
                  AppColors.surface,
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      color: AppColors.bronze,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                program.name,
                                style: AppText.title.copyWith(fontSize: 17),
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
                                color: AppColors.gold.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(
                                  AppRadii.pill,
                                ),
                                border: Border.all(
                                  color: AppColors.gold.withValues(
                                    alpha: 0.45,
                                  ),
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
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          program.description,
                          style: AppText.secondary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          children: [
                            _MetaChip(
                              text:
                                  '${program.weeks} '
                                  '${strings.programWeeksLabel}',
                            ),
                            _MetaChip(
                              text:
                                  '${program.sessionsPerWeek} '
                                  '${strings.programSessionsLabel}',
                            ),
                            _MetaChip(text: levelLabel),
                            _MetaChip(text: program.tag),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
