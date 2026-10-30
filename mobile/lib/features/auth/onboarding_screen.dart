import 'package:flutter/material.dart';

import '../../components/common.dart';
import '../../design/brand/spartan_emblem.dart';
import '../../design/motion/pressable_scale.dart';
import '../../design/tokens.dart';
import '../../localization/app_strings.dart';

/// Onboarding walkthrough introducing Spartan discipline, warrior mindset,
/// precision workouts, and progress tracking.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({required this.onFinish, super.key});

  final VoidCallback onFinish;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: AppDurations.medium,
        curve: Curves.easeOutCubic,
      );
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    final slides = [
      _OnboardingSlide(
        icon: Icons.shield_outlined,
        title: strings.onboardingTitle1,
        description: strings.onboardingDesc1,
      ),
      _OnboardingSlide(
        icon: Icons.timer_outlined,
        title: strings.onboardingTitle2,
        description: strings.onboardingDesc2,
      ),
      _OnboardingSlide(
        icon: Icons.fitness_center_outlined,
        title: strings.onboardingTitle3,
        description: strings.onboardingDesc3,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppBreakpoints.contentMax,
            ),
            child: Column(
              children: [
                // Top Bar with Skip
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SpartanEmblem(size: 38, emphasis: 1.0),
                      TextButton(
                        onPressed: widget.onFinish,
                        child: Text(
                          strings.onboardingSkip,
                          style: AppText.secondary.copyWith(
                            color: AppColors.neutralGray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Slide Carousel
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: slides.length,
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                        child: slides[index],
                      );
                    },
                  ),
                ),

                // Bottom Indicator and Actions
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          slides.length,
                          (i) => AnimatedContainer(
                            duration: AppDurations.fast,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == i ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == i
                                  ? AppColors.metallicGold
                                  : AppColors.neutralGray.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(AppRadii.pill),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // CTA Button
                      PressableScale(
                        onTap: _nextPage,
                        child: SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            label: _currentPage == 2
                                ? strings.onboardingStart
                                : strings.onboardingNext,
                            onPressed: _nextPage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.secondaryBlack,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.metallicGold.withValues(alpha: 0.4),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.metallicGold.withValues(alpha: 0.18),
                blurRadius: 36,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 56,
            color: AppColors.metallicGold,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppText.display.copyWith(
            fontSize: 22,
            letterSpacing: 1.6,
            color: AppColors.warmWhite,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          description,
          textAlign: TextAlign.center,
          style: AppText.body.copyWith(
            color: AppColors.neutralGray,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
