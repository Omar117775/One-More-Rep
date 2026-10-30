import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens.dart';
import 'app_motion.dart';

/// Animated ring progress for achievement-style metrics: gold→bronze sweep
/// over a dim track, rounded caps. Stack children over it for centered
/// labels. Reduced motion renders the final sweep instantly.
class ProgressRingBar extends StatelessWidget {
  const ProgressRingBar({
    required this.value,
    required this.size,
    this.strokeWidth = 10,
    this.duration = AppMotion.slow,
    super.key,
  });

  /// Progress in 0..1; values are clamped.
  final double value;

  /// Full widget (ring) diameter.
  final double size;

  final double strokeWidth;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    final clamped = value.clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: clamped),
      duration: reduced ? Duration.zero : duration,
      curve: AppMotion.easeOutCubic,
      builder: (context, progress, _) => CustomPaint(
        size: Size.square(size),
        painter: _RingPainter(progress: progress, strokeWidth: strokeWidth),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.strokeWidth});

  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - strokeWidth / 2;
    const start = -math.pi / 2;

    // Track.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = AppColors.border,
    );

    if (progress <= 0) return;

    // Value sweep with a metallic gold→bronze gradient.
    final sweepRect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        colors: const [AppColors.gold, AppColors.goldLight, AppColors.bronze],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(sweepRect);

    canvas.drawArc(sweepRect, start, progress * 2 * math.pi, false, paint);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
