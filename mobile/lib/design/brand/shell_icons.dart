import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../motion/app_motion.dart';
import '../tokens.dart';

/// Destination ident for the original code-drawn shell icons.
enum ShellIconKind { home, train, cardio, progress, settings }

/// Animated nav icon slot: each app destination painted as a custom path
/// (gold fill + gold glow when selected, muted outline otherwise) with a
/// gentle settle bounce on activation. Reduced motion renders the target
/// state statically.
///
/// Pass it as the `icon` (selected: false) and `selectedIcon`
/// (selected: true) of `NavigationDestination` / `NavigationRailDestination`;
/// the fresh mount replays the settle animation when a tab activates.
class AnimatedIconSlot extends StatefulWidget {
  const AnimatedIconSlot({
    required this.kind,
    required this.selected,
    this.size = 26,
    super.key,
  });

  final ShellIconKind kind;
  final bool selected;
  final double size;

  @override
  State<AnimatedIconSlot> createState() => _AnimatedIconSlotState();
}

class _AnimatedIconSlotState extends State<AnimatedIconSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _reduced = false;
  bool _pendingEntrance = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.medium,
    );
    // Do NOT read inherited widgets here; defer to didChangeDependencies.
    if (widget.selected) {
      _pendingEntrance = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.of(context).disableAnimations;
    if (_pendingEntrance) {
      _pendingEntrance = false;
      _runEntrance();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedIconSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      _runEntrance();
    }
    if (!widget.selected) {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  void _runEntrance() {
    if (_reduced) {
      _controller.value = 1;
      return;
    }
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final settledScale = 0.86 + Curves.easeOutBack.transform(t) * 0.14;
        return Transform.scale(
          scale: widget.selected ? settledScale : 1.0,
          child: SizedBox.square(
            dimension: widget.size,
            child: CustomPaint(
              painter: _ShellIconPainter(
                kind: widget.kind,
                filled: widget.selected,
                fillAlpha: t,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShellIconPainter extends CustomPainter {
  _ShellIconPainter({
    required this.kind,
    required this.filled,
    required this.fillAlpha,
  });

  final ShellIconKind kind;
  final bool filled;
  final double fillAlpha;

  static const double _extent = 24;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final scale = size.shortestSide / _extent;
    canvas.scale(scale);
    canvas.translate(
      (size.width / scale - _extent) / 2,
      (size.height / scale - _extent) / 2,
    );

    // Soft gold halo behind the filled icon.
    if (filled && fillAlpha > 0) {
      canvas.drawCircle(
        const Offset(12, 12),
        11,
        Paint()
          ..shader = RadialGradient(
            colors: [
              AppColors.gold.withValues(alpha: 0.28 * fillAlpha),
              AppColors.goldDim.withValues(alpha: 0.0),
            ],
          ).createShader(const Rect.fromLTWH(1, 1, 22, 22)),
      );
    }

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = filled ? AppColors.goldLight : AppColors.muted;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.gold.withValues(alpha: fillAlpha);

    final inkPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.onAccent.withValues(alpha: fillAlpha);

    switch (kind) {
      case ShellIconKind.home:
        _paintHome(canvas, strokePaint, fillPaint, inkPaint);
      case ShellIconKind.train:
        _paintTrain(canvas, strokePaint, fillPaint, inkPaint);
      case ShellIconKind.cardio:
        _paintCardio(canvas, strokePaint, fillPaint, inkPaint);
      case ShellIconKind.progress:
        _paintProgress(canvas, strokePaint, fillPaint, inkPaint);
      case ShellIconKind.settings:
        _paintSettings(canvas, strokePaint, fillPaint, inkPaint);
    }

    canvas.restore();
  }

  void _paintHome(
    Canvas canvas,
    Paint stroke,
    Paint fill,
    Paint ink,
  ) {
    final roof = Path()
      ..moveTo(3.2, 11.6)
      ..lineTo(12, 3.9)
      ..lineTo(20.8, 11.6)
      ..close();
    final walls = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(5.6, 10.2, 18.4, 19.9),
          const Radius.circular(1.6),
        ),
      );
    if (filled) {
      canvas.drawPath(roof, fill);
      canvas.drawPath(walls, fill);
      // Door cut.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(10.1, 14.6, 13.9, 19.9),
          const Radius.circular(1.2),
        ),
        ink,
      );
    }
    canvas.drawPath(roof, stroke);
    canvas.drawPath(walls, stroke);
    if (filled) return;
    canvas.drawLine(
      const Offset(10.2, 19.9),
      const Offset(10.2, 15.2),
      stroke,
    );
    canvas.drawLine(
      const Offset(10.2, 15.2),
      const Offset(13.8, 15.2),
      stroke,
    );
    canvas.drawLine(
      const Offset(13.8, 15.2),
      const Offset(13.8, 19.9),
      stroke,
    );
  }

  void _paintTrain(
    Canvas canvas,
    Paint stroke,
    Paint fill,
    Paint ink,
  ) {
    final bar = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(7.4, 10.9, 16.6, 13.1),
          const Radius.circular(1),
        ),
      );
    final leftPlate = _roundedPlate(3.4, 6.6, 7, 17.4);
    final rightPlate = _roundedPlate(17, 6.6, 20.6, 17.4);
    if (filled) {
      canvas.drawPath(bar, fill);
      canvas.drawPath(leftPlate, fill);
      canvas.drawPath(rightPlate, fill);
    }
    canvas.drawPath(bar, stroke);
    canvas.drawPath(leftPlate, stroke);
    canvas.drawPath(rightPlate, stroke);
  }

  Path _roundedPlate(double l, double t, double r, double b) {
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(l, t, r, b),
          const Radius.circular(1.6),
        ),
      );
  }

  void _paintCardio(
    Canvas canvas,
    Paint stroke,
    Paint fill,
    Paint ink,
  ) {
    final heart = Path()
      ..moveTo(12, 20.4)
      ..cubicTo(6.4, 16.2, 3.6, 12.9, 3.6, 9.7)
      ..cubicTo(3.6, 7, 5.7, 5, 8.3, 5)
      ..cubicTo(10.1, 5, 11.4, 6, 12, 7.5)
      ..cubicTo(12.6, 6, 13.9, 5, 15.7, 5)
      ..cubicTo(18.3, 5, 20.4, 7, 20.4, 9.7)
      ..cubicTo(20.4, 12.9, 17.6, 16.2, 12, 20.4)
      ..close();
    if (filled) {
      canvas.drawPath(heart, fill);
    }
    canvas.drawPath(heart, stroke);
    if (filled) {
      // Pulse line across the heart.
      final pulse = Path()
        ..moveTo(6.6, 11.7)
        ..lineTo(9.4, 11.7)
        ..lineTo(10.8, 9.1)
        ..lineTo(12.9, 14)
        ..lineTo(14.5, 11.7)
        ..lineTo(17.4, 11.7);
      canvas.drawPath(
        pulse,
        Paint()
          ..color = AppColors.onAccent.withValues(alpha: fillAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  void _paintProgress(
    Canvas canvas,
    Paint stroke,
    Paint fill,
    Paint ink,
  ) {
    final bars = [
      _roundedPlate(4.4, 13.2, 7.4, 19.6),
      _roundedPlate(10.5, 9.4, 13.5, 19.6),
      _roundedPlate(16.6, 5.2, 19.6, 19.6),
    ];
    if (filled) {
      for (final bar in bars) {
        canvas.drawPath(bar, fill);
      }
    }
    for (final bar in bars) {
      canvas.drawPath(bar, stroke);
    }
    Paint baselinePaint = stroke;
    if (filled) {
      baselinePaint = Paint()
        ..color = AppColors.bronze
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7
        ..strokeCap = StrokeCap.round;
    }
    canvas.drawLine(
      const Offset(3.8, 19.6),
      const Offset(20.2, 19.6),
      baselinePaint,
    );
  }

  void _paintSettings(
    Canvas canvas,
    Paint stroke,
    Paint fill,
    Paint ink,
  ) {
    // Gear teeth: thick rounded strokes radiating around the body.
    final teeth = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = filled ? AppColors.gold.withValues(alpha: fillAlpha) : stroke.color;
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final from = Offset(12 + 7.4 * math.cos(angle), 12 + 7.4 * math.sin(angle));
      final to = Offset(12 + 10.4 * math.cos(angle), 12 + 10.4 * math.sin(angle));
      canvas.drawLine(from, to, teeth);
    }
    if (filled) {
      canvas.drawCircle(const Offset(12, 12), 7.8, fill);
      canvas.drawCircle(const Offset(12, 12), 3, ink);
    }
    canvas.drawCircle(const Offset(12, 12), 7.8, stroke);
    if (!filled) {
      canvas.drawCircle(const Offset(12, 12), 3.1, stroke);
    }
  }

  @override
  bool shouldRepaint(_ShellIconPainter oldDelegate) =>
      oldDelegate.kind != kind ||
      oldDelegate.filled != filled ||
      oldDelegate.fillAlpha != fillAlpha;
}
