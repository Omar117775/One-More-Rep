import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../localization/app_strings.dart';

/// Axis labels + values for the custom-painted charts.
class ChartData {
  const ChartData({required this.labels, required this.values});

  /// Short label per point/bar (e.g. "12 Nov").
  final List<String> labels;

  /// Values for line charts may contain null gaps (missing measurements).
  /// Bar charts expect non-null values; null is treated as 0.
  final List<double?> values;

  bool get isEmpty {
    final meaningful =
        values.whereType<double>().where((v) => v > 0).toList();
    return meaningful.isEmpty;
  }
}

/// Animated smooth line chart with gradient fill. Static under reduced motion.
/// Time always progresses on the horizontal axis in natural reading order.
class AnimatedLineChart extends StatelessWidget {
  const AnimatedLineChart({
    required this.data,
    this.height = 180,
    this.accent = AppColors.blueLight,
    super.key,
  });

  final ChartData data;
  final double height;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _ChartEmpty(height: height);
    }
    final animate = !MediaQuery.of(context).disableAnimations;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => CustomPaint(
        size: Size.fromHeight(height),
        painter: _LinePainter(
          data: data,
          accent: accent,
          progress: animate ? t : 1,
        ),
      ),
    );
  }
}

/// Animated bar chart with rounded bars. Static under reduced motion.
class AnimatedBarChart extends StatelessWidget {
  const AnimatedBarChart({
    required this.data,
    this.height = 180,
    this.accent = AppColors.blueLight,
    super.key,
  });

  final ChartData data;
  final double height;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _ChartEmpty(height: height);
    }
    final animate = !MediaQuery.of(context).disableAnimations;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => CustomPaint(
        size: Size.fromHeight(height),
        painter: _BarPainter(data: data, accent: accent, progress: animate ? t : 1),
      ),
    );
  }
}

class _ChartEmpty extends StatelessWidget {
  const _ChartEmpty({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.query_stats_outlined,
                color: AppColors.muted, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(
              AppStrings.of(context).noDataForPeriod,
              style: AppText.secondary,
            ),
          ],
        ),
      ),
    );
  }
}

abstract class _BaseChartPainter extends CustomPainter {
  _BaseChartPainter({required this.data, required this.accent, required this.progress});

  final ChartData data;
  final Color accent;
  final double progress;

  static const double _labelGap = 26;

  @override
  void paint(Canvas canvas, Size size) {
    final numeric = data.values
        .map((v) => v ?? 0)
        .whereType<double>()
        .toList();
    final maxValue = (numeric.reduce((a, b) => a > b ? a : b)) > 0
        ? numeric.reduce((a, b) => a > b ? a : b)
        : 1;
    final top = maxValue * 1.08;
    final bottom = 0.0;
    final chartRect = Rect.fromLTRB(
      4,
      14,
      size.width - 4,
      size.height - _labelGap,
    );

    // Grid lines.
    final grid = Paint()
      ..color = AppColors.border.withValues(alpha: 0.55)
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = chartRect.top + (chartRect.height * i / 3);
      canvas.drawLine(Offset(chartRect.left, y), Offset(chartRect.right, y), grid);
    }
    // Max value label.
    _drawText(
      canvas,
      maxValue.toStringAsFixed(maxValue < 10 ? 1 : 0),
      Offset(chartRect.left + 2, chartRect.top - 12),
      AppText.microLabel,
    );

    _paintSeries(canvas, chartRect, bottom, top);
  }

  void _paintSeries(Canvas canvas, Rect rect, double bottom, double top);

  double yFor(double value, Rect rect, double bottom, double top) {
    final t = (value - bottom) / (top - bottom);
    return rect.bottom - t.clamp(0, 1) * rect.height;
  }

  void _drawText(Canvas canvas, String text, Offset at, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at);
  }
}

class _LinePainter extends _BaseChartPainter {
  _LinePainter({required super.data, required super.accent, required super.progress});

  @override
  void _paintSeries(Canvas canvas, Rect rect, double bottom, double top) {
    final n = data.values.length;
    final xs = <Offset?>[];
    for (var i = 0; i < n; i++) {
      final v = data.values[i];
      final x = rect.left + (rect.width * (i == 0 ? 0 : i / (n - 1).clamp(1, 1 << 30)));
      xs.add(v == null ? null : Offset(x, yFor(v, rect, bottom, top)));
    }

    for (final segment in _segments(xs)) {
      final path = Path();
      for (var i = 0; i < segment.length; i++) {
        if (i == 0) {
          path.moveTo(segment[i].dx, segment[i].dy);
        } else {
          path.lineTo(segment[i].dx, segment[i].dy);
        }
      }
      final pathLength = segment.last.dx - segment.first.dx;
      final cut = pathLength.clamp(1, double.infinity) * progress;

      // Gradient fill below the line, revealed with the animation.
      if (progress >= 1) {
        final fill = Path()
          ..moveTo(segment.first.dx, rect.bottom)
          ..lineTo(segment.first.dx, segment.first.dy);
        for (final p in segment.skip(1)) {
          fill.lineTo(p.dx, p.dy);
        }
        fill
          ..lineTo(segment.last.dx, rect.bottom)
          ..close();
        canvas.drawPath(
          fill,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [accent.withValues(alpha: 0.28), accent.withValues(alpha: 0)],
            ).createShader(rect),
        );
      }

      final clipRect = Rect.fromLTRB(
        segment.first.dx,
        rect.top - 20,
        segment.first.dx + cut,
        rect.bottom,
      );
      canvas
        ..save()
        ..clipRect(clipRect)
        ..drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.6
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..color = accent,
        );
      if (progress >= 1) {
        for (final p in segment) {
          canvas.drawCircle(p, 3.4, Paint()..color = accent);
        }
      }
      canvas.restore();
    }

    // X labels (first + last kept legible).
    if (data.labels.isNotEmpty) {
      _drawText(canvas, data.labels.first, Offset(rect.left, rect.bottom + 8),
          AppText.microLabel);
      _drawText(
        canvas,
        data.labels.last,
        Offset(rect.right - 34, rect.bottom + 8),
        AppText.microLabel,
      );
    }
  }

  Iterable<List<Offset>> _segments(List<Offset?> xs) sync* {
    var current = <Offset>[];
    for (final point in xs) {
      if (point == null) {
        if (current.length > 1) yield current;
        current = <Offset>[];
      } else {
        current.add(point);
      }
    }
    if (current.length > 1) yield current;
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.accent != accent;
}

class _BarPainter extends _BaseChartPainter {
  _BarPainter({required super.data, required super.accent, required super.progress});

  @override
  void _paintSeries(Canvas canvas, Rect rect, double bottom, double top) {
    final n = data.values.length;
    final slot = rect.width / n.clamp(1, n);
    final barWidth = (slot * 0.58).clamp(4.0, 26.0);
    for (var i = 0; i < n; i++) {
      final v = data.values[i] ?? 0;
      if (v <= 0) continue;
      final t = (i / (n - 1).clamp(1, 1 << 30));
      if (t > progress) continue;
      final x = rect.left + slot * (i + 0.5);
      final y = yFor(v, rect, bottom, top);
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTRB(x - barWidth / 2, y, x + barWidth / 2, rect.bottom),
        const Radius.circular(5),
      );
      canvas.drawRRect(
        rrect,
        Paint()..color = accent.withValues(alpha: i == n - 1 ? 0.95 : 0.62),
      );
      if (i == n - 1) {
        canvas.drawRRect(
          rrect,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..color = accent,
        );
      }
    }
    if (data.labels.isNotEmpty) {
      _drawText(canvas, data.labels.first, Offset(rect.left, rect.bottom + 8),
          AppText.microLabel);
      _drawText(
        canvas,
        data.labels.last,
        Offset(rect.right - 34, rect.bottom + 8),
        AppText.microLabel,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.accent != accent;
}
