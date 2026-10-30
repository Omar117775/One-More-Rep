import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens.dart';

/// Original Spartan-brand emblem drawn entirely with [Path]s — no image
/// assets. A stylized front-facing Corinthian helmet: fanned gold crest,
/// bronze dome with face cutouts (eye slots, nose guard, cheek guards).
///
/// [emphasis] (0..1+) scales outline weight and ambient glow so the same
/// artwork can serve large splash moments and compact in-app marks.
class SpartanEmblem extends StatelessWidget {
  const SpartanEmblem({this.size = 96, this.emphasis = 1.0, super.key});

  /// Rendered square size in logical pixels.
  final double size;

  /// Stroke and glow intensity multiplier.
  final double emphasis;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _SpartanPainter(emphasis: emphasis),
      ),
    );
  }
}

class _SpartanPainter extends CustomPainter {
  _SpartanPainter({required this.emphasis});

  final double emphasis;

  // Normalized 0..100 design space (x right, y down).
  static const double _cx = 50;
  static const double _cy = 46;
  static const double _domeRadius = 34;
  static const double _crestInner = 27;
  static const double _crestOuter = 46;
  static const int _plumes = 6;
  static const double _plumeSpan = 21; // degrees per plume
  static const double _plumeGap = 2; // degrees between plumes
  static const double _crestSpan = _plumes * (_plumeSpan + _plumeGap);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final scale = size.shortestSide / 100;
    canvas.scale(scale);
    canvas.translate((size.width / scale - 100) / 2, 0);

    _paintGlow(canvas);
    _paintCrest(canvas);
    _paintShell(canvas);
    _paintDetails(canvas);

    canvas.restore();
  }

  Offset _polar(double radius, double degrees) {
    // 0° points up, negative degrees to the left, positive to the right.
    final a = math.pi * degrees / 180;
    return Offset(_cx + radius * math.sin(a), _cy - radius * math.cos(a));
  }

  void _paintGlow(Canvas canvas) {
    final paint = Paint()
      ..shader = RadialGradient(
        radius: 1.0,
        colors: [
          AppColors.gold.withValues(alpha: 0.13 * emphasis),
          AppColors.goldDim.withValues(alpha: 0.0),
        ],
      ).createShader(const Rect.fromLTWH(-4, -4, 108, 108));
    canvas.drawCircle(const Offset(_cx, _cy), 52, paint);
  }

  void _paintCrest(Canvas canvas) {
    final shader = SweepGradient(
      colors: const [
        AppColors.gold,
        AppColors.goldLight,
        AppColors.bronze,
        AppColors.gold,
        AppColors.goldLight,
        AppColors.gold,
      ],
      stops: const [0.05, 0.22, 0.45, 0.68, 0.86, 1.0],
    ).createShader(Rect.fromCircle(
      center: const Offset(_cx, _cy),
      radius: _crestOuter + 2,
    ));
    final fill = Paint()..shader = shader;

    final start = -_crestSpan / 2;
    for (var i = 0; i < _plumes; i++) {
      final a0 = start + i * (_plumeSpan + _plumeGap);
      final a1 = a0 + _plumeSpan;
      final inner0 = _polar(_crestInner, a0);
      final inner1 = _polar(_crestInner, a1);
      final outer1 = _polar(_crestOuter, a1);
      final outer0 = _polar(_crestOuter, a0);
      final path = Path()
        ..moveTo(inner0.dx, inner0.dy)
        ..arcToPoint(
          inner1,
          radius: const Radius.circular(_crestInner),
          largeArc: false,
          clockwise: true,
        )
        ..lineTo(outer1.dx, outer1.dy)
        ..arcToPoint(
          outer0,
          radius: const Radius.circular(_crestOuter),
          largeArc: false,
          clockwise: false,
        )
        ..close();
      canvas.drawPath(path, fill);
    }

    // Fine outer edge to sharpen the plume tips.
    final edgePaint = Paint()
      ..color = AppColors.bronze.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;
    final outerStart = _polar(_crestOuter, -_crestSpan / 2);
    final outerEnd = _polar(_crestOuter, _crestSpan / 2);
    final crestEdge = Path()
      ..moveTo(outerStart.dx, outerStart.dy)
      ..arcToPoint(
        outerEnd,
        radius: const Radius.circular(_crestOuter),
        largeArc: true,
        clockwise: true,
      );
    canvas.drawPath(crestEdge, edgePaint);
  }

  void _paintShell(Canvas canvas) {
    final shell = Path()
      ..moveTo(_cx - _domeRadius + 0.5, _cy)
      ..arcToPoint(
        const Offset(_cx + _domeRadius - 0.5, _cy),
        radius: const Radius.circular(_domeRadius - 0.5),
        largeArc: true,
        clockwise: true,
      )
      ..quadraticBezierTo(87.5, 76, 71, 93)
      ..lineTo(29, 93)
      ..quadraticBezierTo(12.5, 76, _cx - _domeRadius + 0.5, _cy)
      ..close();

    // Face cutouts leave brow bar / nose guard / cheek guards intact.
    final eyeSlotL = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(24, 44, 44, 56),
          const Radius.circular(6),
        ),
      );
    final eyeSlotR = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(56, 44, 76, 56),
          const Radius.circular(6),
        ),
      );
    final mouthSlot = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(41, 66, 59, 96),
          const Radius.circular(6),
        ),
      );

    final cut = Path.combine(
      PathOperation.union,
      Path.combine(PathOperation.union, eyeSlotL, eyeSlotR),
      mouthSlot,
    );
    final shellWithFace = Path.combine(
      PathOperation.difference,
      shell,
      cut,
    );

    final shellPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.goldLight, AppColors.gold, AppColors.bronze],
        stops: [0.0, 0.55, 1.0],
      ).createShader(const Rect.fromLTRB(10, 10, 90, 96));
    canvas.drawPath(shellWithFace, shellPaint);

    // Inner face-plate depth line around the cutouts (kept inside the shell).
    canvas.save();
    canvas.clipPath(shellWithFace);
    canvas.drawPath(
      cut,
      Paint()
        ..color = AppColors.onAccent.withValues(alpha: 0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
    canvas.restore();

    canvas.drawPath(
      shell,
      Paint()
        ..color = AppColors.goldLight.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9 + emphasis
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _paintDetails(Canvas canvas) {
    final detail = Paint()
      ..color = AppColors.onAccent.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;

    // Brow emboss.
    canvas.drawLine(const Offset(27, 39), const Offset(73, 39), detail);
    // Nose guard emboss.
    canvas.drawLine(const Offset(50, 36), const Offset(50, 62), detail);
  }

  @override
  bool shouldRepaint(_SpartanPainter oldDelegate) =>
      oldDelegate.emphasis != emphasis;
}
