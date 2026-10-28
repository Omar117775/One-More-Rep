import 'package:flutter/material.dart';

/// Central design tokens for the One More Rep trainee app.
/// Never hardcode colors, spacing, radii or durations in feature code.
abstract final class AppColors {
  static const background = Color(0xFF080D16);
  static const surface = Color(0xFF111A29);
  static const surfaceLight = Color(0xFF19263A);
  static const blue = Color(0xFF2864F0);
  static const blueLight = Color(0xFF65A0FF);
  static const white = Color(0xFFF5F7FC);
  static const muted = Color(0xFF8B98AD);
  static const border = Color(0xFF26364D);
  static const success = Color(0xFF34C98A);
  static const danger = Color(0xFFFF5D6E);
  static const warning = Color(0xFFF5B83D);
  static const barrier = Color(0xF0060B14);
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
