import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Spartan states communicated by the companion.
enum SpartanState { idle, training, success, milestone }

/// Reusable animated Spartan companion built from brand shapes (shield +
/// helmet silhouette drawn with CustomPaint, royal-blue accents) since no
/// Rive/Lottie asset ships with the project.
///
/// Motion rules:
/// - one-shot animations for idle intro, success and milestone;
/// - the only repeating loop is the subtle "training" pulse;
/// - fully static when [MediaQuery.disableAnimations] is on.
class SpartanCompanion extends StatefulWidget {
  const SpartanCompanion({required this.state, this.size = 96, super.key});

  final SpartanState state;
  final double size;

  @override
  State<SpartanCompanion> createState() => _SpartanCompanionState();
}

class _SpartanCompanionState extends State<SpartanCompanion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    _applyState(widget.state, reduced);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final pulse = _loopValue(t, widget.state);
        final scale = switch (widget.state) {
          SpartanState.success => _easeOutBack(t) * 1.04,
          _ => 0.94 + 0.06 * _introEase(t) + pulse * 0.03,
        };
        final aura = switch (widget.state) {
          SpartanState.training => pulse,
          SpartanState.success => t < 0.4 ? t / 0.4 : (1 - (t - 0.4) / 0.6).clamp(0, 1).toDouble(),
          SpartanState.milestone => (1 - t).clamp(0, 1).toDouble(),
          _ => 0.35 + 0.15 * (1 - _introEase(t)),
        };
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _SpartanPainter(
              state: widget.state,
              progress: t,
              scale: scale,
              aura: aura.toDouble(),
              animate: !MediaQuery.of(context).disableAnimations,
            ),
          ),
        );
      },
    );
  }

  void _applyState(SpartanState state, bool reducedMotion) {
    if (reducedMotion) {
      _controller.stop();
      _controller.duration = const Duration(milliseconds: 1200);
      _controller.value = 1;
      return;
    }
    switch (state) {
      case SpartanState.training:
        if (_controller.duration != const Duration(milliseconds: 900)) {
          _controller
            ..stop()
            ..duration = const Duration(milliseconds: 900)
            ..repeat();
        } else if (_controller.status != AnimationStatus.forward) {
          _controller.repeat();
        }
      default:
        if (_controller.duration != const Duration(milliseconds: 1200) ||
            _controller.status == AnimationStatus.completed ||
            _controller.status == AnimationStatus.dismissed) {
          _controller
            ..stop()
            ..duration = const Duration(milliseconds: 1200)
            ..forward(from: 0);
        }
    }
  }

  double _introEase(double t) => Curves.easeOutCubic.transform((t * 2).clamp(0, 1).toDouble());

  double _loopValue(double t, SpartanState state) {
    if (state != SpartanState.training) return 0;
    final phase = (t % 1.0) * 2; // triangle wave 0→1→0
    final value = phase <= 1 ? phase : 2 - phase;
    return Curves.easeInOutSine.transform(value);
  }

  double _easeOutBack(double t) {
    final c = 1.70158;
    final x = t - 1;
    return 1 + (c + 1) * x * x * x + c * x * x;
  }
}

class _SpartanPainter extends CustomPainter {
  const _SpartanPainter({
    required this.state,
    required this.progress,
    required this.scale,
    required this.aura,
    required this.animate,
  });

  final SpartanState state;
  final double progress;
  final double scale;
  final double aura;
  final bool animate;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    _paintAura(canvas, center, radius);
    _paintRings(canvas, center, radius);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale, scale);
    _paintShield(canvas, radius);
    _paintHelmet(canvas, radius);
    canvas.restore();

    if (state == SpartanState.milestone && animate) {
      _paintBurst(canvas, center, radius);
    }
  }

  void _paintAura(Canvas canvas, Offset center, double radius) {
    final glow = Color.lerp(
      AppColors.blue.withValues(alpha: state == SpartanState.milestone ? 0.10 : 0.16),
      AppColors.blueLight.withValues(alpha: 0.5),
      aura,
    )!;
    canvas.drawCircle(
      center,
      radius * (1.0 + 0.06 * aura),
      Paint()
        ..color = glow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
  }

  void _paintRings(Canvas canvas, Offset center, double radius) {
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = AppColors.border;
    canvas.drawCircle(center, radius, ringPaint);

    if (state == SpartanState.success && animate && progress < 0.75) {
      final t = (progress / 0.75).clamp(0, 1).toDouble();
      canvas.drawCircle(
        center,
        radius * (1 + t * 0.35),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = (1 - t) * 3.5
          ..color = AppColors.success.withValues(alpha: (1 - t) * 0.8),
      );
    }
    if (state == SpartanState.milestone && animate && progress < 0.7) {
      final t = (progress / 0.7).clamp(0, 1).toDouble();
      canvas.drawPaint(Paint()..color = const Color(0x00000000));
      for (var i = 0; i < 8; i++) {
        final angle = i * 3.14159 / 4 + 0.4;
        final from = radius * (1.1 + t * 0.25);
        final to = radius * (1.25 + t * 0.45);
        canvas.drawLine(
          center + Offset.fromDirection(angle, from),
          center + Offset.fromDirection(angle, to),
          Paint()
            ..color = AppColors.warning.withValues(alpha: (1 - t) * 0.85)
            ..strokeWidth = 2.4
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  void _paintShield(Canvas canvas, double radius) {
    final shieldPaint = Paint()
      ..color = AppColors.surfaceLight
      ..style = PaintingStyle.fill
      ..maskFilter = null;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = AppColors.blue;

    final r = radius * 0.86;
    final path = Path()
      ..moveTo(0, -r)
      ..cubicTo(r * 0.92, -r, r, -r * 0.9, r, -r * 0.55)
      ..cubicTo(r, r * 0.25, r * 0.55, r * 0.92, 0, r)
      ..cubicTo(-r * 0.55, r * 0.92, -r, r * 0.25, -r, -r * 0.55)
      ..cubicTo(-r, -r * 0.9, -r * 0.92, -r, 0, -r)
      ..close();
    canvas.drawPath(path, shieldPaint);
    canvas.drawPath(path, borderPaint);
  }

  void _paintHelmet(Canvas canvas, double radius) {
    final helmPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.white.withValues(alpha: 0.92);
    final slitPaint = Paint()..color = AppColors.background;
    final crestPaint = Paint()..color = AppColors.blueLight;

    final r = radius * 0.62;
    // Crest fin.
    final crest = Path()
      ..moveTo(-r * 0.14, -r * 1.28)
      ..quadraticBezierTo(0, -r * 1.85, r * 0.14, -r * 1.28)
      ..quadraticBezierTo(0, -r * 1.45, -r * 0.14, -r * 1.28)
      ..close();
    canvas.drawPath(crest, crestPaint);

    // Dome.
    final dome = Path()
      ..moveTo(-r, r * 0.18)
      ..lineTo(-r, -r * 0.05)
      ..cubicTo(-r, -r * 1.15, r, -r * 1.15, r, -r * 0.05)
      ..lineTo(r, r * 0.18)
      ..lineTo(r * 0.42, r * 0.18)
      ..lineTo(r * 0.42, r * 0.55)
      ..cubicTo(r * 0.42, r * 0.95, -r * 0.42, r * 0.95, -r * 0.42, r * 0.55)
      ..lineTo(-r * 0.42, r * 0.18)
      ..close();
    canvas.drawPath(dome, helmPaint);

    // Eye slit.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(-r * 0.62, -r * 0.1, -r * 0.12, r * 0.14),
        const Radius.circular(6),
      ),
      slitPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(r * 0.12, -r * 0.1, r * 0.62, r * 0.14),
        const Radius.circular(6),
      ),
      slitPaint,
    );
  }

  void _paintBurst(Canvas canvas, Offset center, double radius) {
    for (var i = 0; i < 4; i++) {
      final angle = -3.14159 / 2 + (i * 3.14159 / 3);
      canvas.drawCircle(
        center + Offset.fromDirection(angle, radius * 0.75),
        2.6,
        Paint()..color = AppColors.warning,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpartanPainter oldDelegate) =>
      oldDelegate.state != state ||
      oldDelegate.progress != progress ||
      oldDelegate.scale != scale ||
      oldDelegate.aura != aura ||
      oldDelegate.animate != animate;
}
