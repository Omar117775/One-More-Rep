import 'package:flutter/material.dart';

import '../tokens.dart';

/// Central motion tokens: curves and extra durations beyond [AppDurations].
/// `AppDurations` (tokens.dart) stays the source of truth for shared
/// durations; [AppMotion] references it and adds the luxury-tier timings.
abstract final class AppMotion {
  // Durations (re-exported from AppDurations for one import site).
  static const Duration fast = AppDurations.fast;
  static const Duration medium = AppDurations.medium;
  static const Duration slow = Duration(milliseconds: 560);

  /// Long, cinematic moments (hero entrances, page fades).
  static const Duration emphasis = AppDurations.page;

  /// Loop period for breathing/halo effects.
  static const Duration breathe = Duration(milliseconds: 2600);

  /// Long shimmer sweep loop.
  static const Duration shimmer = Duration(milliseconds: 3400);

  // Curves.
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeOutCubic = Curves.easeOutCubic;
  static const Curve easeInCubic = Curves.easeInCubic;
  static const Curve easeInOut = Curves.easeInOut;

  /// Gentle overshoot settle used when nav icons / cards activate.
  static const Curve settle = Curves.easeOutBack;

  /// Standard page transition sweep.
  static const Curve page = Curves.easeOutCubic;

  /// Count-up / numeric reveal.
  static const Curve countUp = Curves.easeOutCubic;
}
