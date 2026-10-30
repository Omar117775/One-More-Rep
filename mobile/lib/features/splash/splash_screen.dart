import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design/brand/animated_spartan_mark.dart';
import '../../design/tokens.dart';
import '../../localization/app_strings.dart';

/// Premium splash: animated spartan emblem over a black-black ambient scene
/// with rising ember particles, glow, title, tagline and CTA into sign-in.
class SplashScreen extends StatefulWidget {
  const SplashScreen({required this.onEnterArena, super.key});

  /// The root widget owns the auth gate; the splash only asks to show sign-in.
  final VoidCallback onEnterArena;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _emberController;

  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleOpacity;
  late final Animation<double> _ctaOpacity;

  bool _motionStarted = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: AppDurations.entrance,
    );
    _emberController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 14000),
    );

    _titleOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.15, 0.78, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.24), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.15, 0.8, curve: Curves.easeOutCubic),
          ),
        );
    _subtitleOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.38, 0.9, curve: Curves.easeOut),
    );
    _ctaOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _emberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final animate = !MediaQuery.of(context).disableAnimations;
    if (animate && !_motionStarted) {
      _motionStarted = true;
      _entranceController.forward();
      _emberController.repeat();
    }
    if (!animate) {
      _emberController.stop();
      _entranceController.value = 1;
    }

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _AmbientBackground()),
          Positioned.fill(
            child: _EmberCanvas(controller: _emberController),
          ),
          SafeArea(
            child: AnimatedBuilder(
              animation: _entranceController,
              builder: (context, _) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Keep the emblem bounded by both axes so compact
                    // landscape windows do not overflow; the page scrolls
                    // as a fallback.
                    final emblemSize = math
                        .min(
                          constraints.maxWidth - 72,
                          constraints.maxHeight * 0.46,
                        )
                        .clamp(88.0, 380.0);
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  AnimatedSpartanMark(size: emblemSize),
                                  const SizedBox(height: 28),
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
                                      style: AppText.microLabel.copyWith(
                                        fontSize: 11,
                                        letterSpacing: 2.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Opacity(
                                    opacity: _ctaOpacity.value,
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: FilledButton(
                                        onPressed: widget.onEnterArena,
                                        child: Text(strings.splashCta),
                                      ),
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
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
                  AppColors.backgroundAmbient,
                  AppColors.background,
                  AppColors.background,
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
              color: AppColors.goldDim.withValues(alpha: 0.12),
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
              color: AppColors.bronze.withValues(alpha: 0.05),
            ),
          ),
        ),
      ],
    );
  }
}

/// Slow rising embers drawn entirely in code; deterministic seed so widget
/// tests are stable. Frozen at frame zero under reduced motion.
class _EmberCanvas extends StatelessWidget {
  const _EmberCanvas({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _EmberPainter(controller: controller),
    );
  }
}

class _EmberPainter extends CustomPainter {
  _EmberPainter({required this.controller}) : super(repaint: controller);

  final AnimationController controller;

  static final List<_Ember> _embers = List<_Ember>.generate(
    26,
    (i) {
      final random = math.Random(7 + i);
      return _Ember(
        x: random.nextDouble(),
        y: random.nextDouble(),
        drift: random.nextDouble() * 2 * math.pi,
        radius: 0.8 + random.nextDouble() * 1.4,
        alpha: 0.04 + random.nextDouble() * 0.18,
        speed: 0.03 + random.nextDouble() * 0.09,
      );
    },
  );

  @override
  void paint(Canvas canvas, Size size) {
    final t = controller.value;
    for (final ember in _embers) {
      final y = (ember.y - t * ember.speed) % 1.0;
      final x = ember.x + math.sin(t * 2 * math.pi + ember.drift) * 0.012;
      final brightness = (math.sin(t * 4 * math.pi + ember.drift) + 1) / 2;
      final paint = Paint()
        ..color = AppColors.gold.withValues(
          alpha: ember.alpha * (0.55 + 0.45 * brightness),
        );
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        ember.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_EmberPainter oldDelegate) => false;
}

class _Ember {
  const _Ember({
    required this.x,
    required this.y,
    required this.drift,
    required this.radius,
    required this.alpha,
    required this.speed,
  });

  /// Normalized start positions (0..1 of the viewport).
  final double x;
  final double y;
  final double drift;
  final double radius;
  final double alpha;
  final double speed;
}
