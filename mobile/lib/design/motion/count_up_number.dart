import 'package:flutter/material.dart';

import 'app_motion.dart';

/// Animated numeric reveal: tweens from 0 (or the previous value) to [value],
/// rendering through [format]. The final frame renders exactly
/// [format](value), so visible end states stay deterministic for tests.
///
/// Pass a plain [Text] value separately for composite strings — only feed
/// CountUpNumber genuinely numeric series (weights, counts, percentages).
/// Reduced motion renders the final value immediately.
class CountUpNumber extends StatelessWidget {
  const CountUpNumber({
    required this.value,
    required this.format,
    this.style,
    this.duration = AppMotion.medium,
    super.key,
  });

  final double value;

  /// Maps the interpolated value to the localized display string.
  final String Function(double value) format;

  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value),
      duration: reduced ? Duration.zero : duration,
      curve: AppMotion.countUp,
      builder: (context, v, _) => Text(
        format(v),
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
