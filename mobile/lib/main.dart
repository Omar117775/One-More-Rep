
import 'package:flutter/material.dart';

void main() {
  runApp(const OneMoreRepApp());
}

abstract final class AppColors {
  static const background = Color(0xFF080D16);
  static const surface = Color(0xFF111A29);
  static const surfaceLight = Color(0xFF19263A);
  static const blue = Color(0xFF2864F0);
  static const blueLight = Color(0xFF65A0FF);
  static const white = Color(0xFFF5F7FC);
  static const muted = Color(0xFF8B98AD);
  static const border = Color(0xFF26364D);
}

class OneMoreRepApp extends StatelessWidget {
  const OneMoreRepApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Manrope',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.blue,
        secondary: AppColors.blueLight,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onSurface: AppColors.white,
      ),
    );

    return MaterialApp(
      title: 'One More Rep',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(
          bodyColor: AppColors.white,
          displayColor: AppColors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _glowController;

  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleOpacity;

  bool _showPreview = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

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

    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.045),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.68, curve: Curves.easeOutCubic),
      ),
    );

    _titleOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.38, 0.82, curve: Curves.easeOut),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.28),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.38, 0.84, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _AmbientBackground()),

          SafeArea(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _entranceController,
                _glowController,
              ]),
              builder: (context, child) {
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
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.blue.withValues(
                                    alpha: glow,
                                  ),
                                  blurRadius: 42,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Image.asset(
                                  'assets/images/logo.jpg',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const _LogoFallback();
                                  },
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
                        child: const Text(
                          'ONE MORE REP',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 29,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 9),

                    Opacity(
                      opacity: _subtitleOpacity.value,
                      child: const Text(
                        'BUILT THROUGH DISCIPLINE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.4,
                        ),
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
                                setState(() => _showPreview = true);
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'ENTER THE ARENA',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'STRENGTH  •  DISCIPLINE  •  PROGRESS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 9,
                              letterSpacing: 1.1,
                              fontWeight: FontWeight.w600,
                            ),
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

          if (_showPreview)
            _PreviewOverlay(
              onClose: () => setState(() => _showPreview = false),
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

class _PreviewOverlay extends StatelessWidget {
  const _PreviewOverlay({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: AppColors.background.withValues(alpha: 0.98),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                    tooltip: 'Close preview',
                  ),
                ),

                const Spacer(),

                const Icon(
                  Icons.shield_outlined,
                  size: 58,
                  color: AppColors.blueLight,
                ),

                const SizedBox(height: 24),

                const Text(
                  'YOUR NEXT LEVEL\nSTARTS HERE.',
                  style: TextStyle(
                    fontSize: 31,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'Train with purpose. Track every rep. '
                  'Build consistency one session at a time.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: AppColors.muted,
                  ),
                ),

                const SizedBox(height: 30),

                const _FeatureRow(
                  icon: Icons.fitness_center,
                  title: 'Structured workouts',
                  subtitle: 'Follow your training plan.',
                ),

                const SizedBox(height: 18),

                const _FeatureRow(
                  icon: Icons.insights_outlined,
                  title: 'Track your progress',
                  subtitle: 'See your performance over time.',
                ),

                const SizedBox(height: 18),

                const _FeatureRow(
                  icon: Icons.psychology_outlined,
                  title: 'AI-powered coaching',
                  subtitle: 'A smarter training experience.',
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: onClose,
                    child: const Text('BACK TO SPLASH'),
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

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, color: AppColors.blueLight),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
