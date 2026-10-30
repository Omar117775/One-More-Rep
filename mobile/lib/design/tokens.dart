import 'package:flutter/material.dart';

/// Central design tokens for the One More Rep trainee app.
/// Never hardcode colors, spacing, radii or durations in feature code.
///
/// Palette: premium black base with metallic gold primary accents and warm
/// bronze secondary accents (spartan identity). Dark-first.
abstract final class AppColors {
  // Brand Spartan Palette (Exact Specification)
  static const deepBlack = Color(0xFF080808);
  static const secondaryBlack = Color(0xFF111111);
  static const darkGraphite = Color(0xFF191919);
  static const metallicGold = Color(0xFFC6A15B);
  static const metallicBronze = Color(0xFF9B763B);
  static const warmWhite = Color(0xFFF3F0E8);
  static const neutralGray = Color(0xFF929292);

  // Surface and Background Mappings
  static const background = deepBlack;
  /// Warm ember-black top of dark ambient gradients (splash, hero headers).
  static const backgroundAmbient = Color(0xFF14120E);
  static const surface = secondaryBlack;
  static const surfaceLight = darkGraphite;
  static const border = Color(0xFF262420);
  static const gold = metallicGold;
  static const goldLight = Color(0xFFDFC07A);
  static const goldDim = Color(0xFF7E6430);
  static const bronze = metallicBronze;
  /// Ink color used on top of gold/bronze accent fills for AA contrast.
  static const onAccent = deepBlack;
  static const white = warmWhite;
  static const muted = neutralGray;
  static const success = Color(0xFF2ECC71);
  static const danger = Color(0xFFE74C3C);
  static const warning = Color(0xFFE5A93C);
  static const barrier = Color(0xF0080808);
}

/// Light-surface tokens for the optional light variant (dark stays primary).
abstract final class AppColorsLight {
  static const background = Color(0xFFFAF7F0);
  static const surface = Color(0xFFF1ECE1);
  static const surfaceLight = Color(0xFFE6E0D1);
  static const border = Color(0xFFD9D2C0);
  static const text = Color(0xFF1B1917);
  static const muted = Color(0xFF6E675C);
}

abstract final class AppSpacing {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double touchTarget = 44;
}

abstract final class AppRadii {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double pill = 999;
}

abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 220);
  static const Duration medium = Duration(milliseconds: 320);
  static const Duration page = Duration(milliseconds: 340);
  static const Duration entrance = Duration(milliseconds: 1700);
}

abstract final class AppBreakpoints {
  /// Above this width the app shell switches from bottom navigation to a rail.
  static const double shell = 900;

  /// Maximum content width for centered layouts on large screens.
  static const double contentMax = 720;
}

/// Reusable text styles built on the Manrope font family.
abstract final class AppText {
  static const TextStyle display = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 29,
    fontWeight: FontWeight.w800,
    letterSpacing: 2.0,
    color: AppColors.white,
  );
  static const TextStyle headline = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    color: AppColors.white,
  );
  static const TextStyle title = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );
  static const TextStyle body = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );
  static const TextStyle secondary = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.muted,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: AppColors.muted,
  );
  static const TextStyle microLabel = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.1,
    color: AppColors.muted,
  );
}
