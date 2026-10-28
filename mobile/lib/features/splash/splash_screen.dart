import 'package:flutter/material.dart';

import '../../design/tokens.dart';
import '../../localization/app_strings.dart';
import '../auth/sign_in_screen.dart';

/// Premium splash: logo, glow, title, tagline and CTA into the sign-in gate.
/// Visual language preserved from the original splash; strings centralized.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _glowController;

  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleOpacity;

  bool _motionStarted = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(vsync: this, duration: AppDurations.entrance);
    _glowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));

    _logoOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.58, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.72, curve: Curves.easeOutCubic),
      ),
    );
    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.045), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.68, curve: Curves.easeOutCubic),
      ),
    );
    _titleOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.38, 0.82, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.28), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.38, 0.84, curve: Curves.easeOutCubic),
      ),
    );
    _subtitleOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final animate = !MediaQuery.of(context).disableAnimations;
    if (animate && !_motionStarted) {
      _motionStarted = true;
      _entranceController.forward();
      _glowController.repeat(reverse: true);
    }
    if (!animate) {
      _glowController.stop();
      _entranceController.value = 1;
    }

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _AmbientBackground()),
          SafeArea(
            child: AnimatedBuilder(
              animation: Listenable.merge([_entranceController, _glowController]),
              builder: (context, _) {
                final glow = 0.12 + (_glowController.value * 0.12);
                return Column(
                  children: [
                    const Spacer(flex: 2),
                    Transform.translate(
                      offset: _logoSlide.value * 100,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Opacity(
                          opacity: _logoOpacity.value,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 28),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadii.lg),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.blue.withValues(alpha: glow),
                                  blurRadius: 42,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadii.lg),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Image.asset(
                                  'assets/images/logo.jpg',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, _) =>
                                      const _LogoFallback(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),
                    SlideTransition(
                      position: _titleSlide,
                      child: Opacity(
                        opacity: _titleOpacity.value,
                        child: Text(
                          'ONE MORE REP',
                          textAlign: TextAlign.center,
                          style: AppText.display,
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Opacity(
                      opacity: _subtitleOpacity.value,
                      child: Text(
                        strings.splashTagline.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: AppText.microLabel.copyWith(fontSize: 11, letterSpacing: 2.4),
                      ),
                    ),
                    const Spacer(flex: 2),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder<void>(
                                    pageBuilder: (_, animation, _) => FadeTransition(
                                      opacity: CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      ),
                                      child: const SignInScreen(),
                                    ),
                                    transitionDuration: AppDurations.page,
                                    reverseTransitionDuration: AppDurations.page,
                                  ),
                                );
                              },
                              child: Text(strings.splashCta),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            strings.splashMotto,
                            textAlign: TextAlign.center,
                            style: AppText.microLabel,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF101D31),
                  AppColors.background,
                  Color(0xFF080D16),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -120,
          right: -100,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blue.withValues(alpha: 0.10),
            ),
          ),
        ),
        Positioned(
          bottom: -170,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blueLight.withValues(alpha: 0.045),
            ),
          ),
        ),
      ],
    );
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      alignment: Alignment.center,
      child: const Icon(
        Icons.shield_outlined,
        size: 110,
        color: AppColors.blueLight,
      ),
    );
  }
}
