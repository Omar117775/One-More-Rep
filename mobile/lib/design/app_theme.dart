import 'package:flutter/material.dart';

import 'motion/app_page_transitions.dart';
import 'tokens.dart';

/// Builds the canonical dark (primary) theme from centralized tokens.
/// Dark is the brand look; [buildLightAppTheme] exists for a future opt-in.
ThemeData buildAppTheme() => _buildThemeFromTokens(Brightness.dark);

/// Gold/bronze accents over warm ivory surfaces. Opt-in via `themeMode`.
ThemeData buildLightAppTheme() => _buildThemeFromTokens(Brightness.light);

ThemeData _buildThemeFromTokens(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final background = isDark ? AppColors.background : AppColorsLight.background;
  final surface = isDark ? AppColors.surface : AppColorsLight.surface;
  final surfaceHigh = isDark
      ? AppColors.surfaceLight
      : AppColorsLight.surfaceLight;
  final textColor = isDark ? AppColors.white : AppColorsLight.text;
  final mutedColor = isDark ? AppColors.muted : AppColorsLight.muted;
  final borderColor = isDark ? AppColors.border : AppColorsLight.border;

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: background,
    fontFamily: 'Manrope',
    splashFactory: InkSparkle.splashFactory,
  );

  final colorScheme = base.colorScheme.copyWith(
    brightness: brightness,
    primary: AppColors.gold,
    onPrimary: AppColors.onAccent,
    secondary: AppColors.bronze,
    onSecondary: AppColors.onAccent,
    surface: surface,
    onSurface: textColor,
    error: AppColors.danger,
    onError: isDark ? Colors.white : Colors.white,
    outline: borderColor,
  );

  TextStyle darkAware(TextStyle style) => style.copyWith(color: textColor);

  final textTheme = base.textTheme
      .apply(bodyColor: textColor, displayColor: textColor)
      .copyWith(
        displayMedium: darkAware(AppText.display),
        headlineMedium: darkAware(AppText.headline),
        titleMedium: darkAware(AppText.title),
        bodyMedium: darkAware(AppText.body),
        bodySmall: darkAware(AppText.secondary.copyWith(color: mutedColor)),
        labelSmall: darkAware(AppText.caption.copyWith(color: mutedColor)),
      );

  final shapeRounded = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadii.md),
  );

  return base.copyWith(
    colorScheme: colorScheme,
    textTheme: textTheme,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      hintStyle: darkAware(AppText.secondary.copyWith(color: mutedColor)),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + AppSpacing.xs / 2,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.goldLight, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: darkAware(AppText.body),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(surfaceHigh),
        shape: WidgetStatePropertyAll(shapeRounded),
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: surfaceHigh,
      surfaceTintColor: Colors.transparent,
      headerForegroundColor: textColor,
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: surface,
      dialBackgroundColor: surfaceHigh,
      hourMinuteColor: surfaceHigh,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceHigh,
      contentTextStyle: darkAware(AppText.body),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: AppColors.gold.withValues(alpha: 0.22),
      labelTextStyle: WidgetStatePropertyAll(
        AppText.microLabel.copyWith(
          fontSize: 11,
          letterSpacing: 0.4,
          color: textColor,
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: isDark ? AppColors.background : AppColorsLight.surface,
      indicatorColor: AppColors.gold.withValues(alpha: 0.22),
      selectedIconTheme: const IconThemeData(color: AppColors.goldLight),
      unselectedIconTheme: const IconThemeData(color: AppColors.muted),
      selectedLabelTextStyle: darkAware(
        AppText.title.copyWith(
          fontSize: 12,
          color: isDark ? AppColors.white : AppColorsLight.text,
        ),
      ),
      unselectedLabelTextStyle: darkAware(
        AppText.secondary.copyWith(fontSize: 12, color: mutedColor),
      ),
      groupAlignment: -0.9,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.goldLight
            : AppColors.muted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.gold.withValues(alpha: 0.35)
            : borderColor,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.onAccent,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 15,
          letterSpacing: 1.1,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.goldLight,
        minimumSize: const Size.fromHeight(AppSpacing.touchTarget),
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.goldLight,
        minimumSize: const Size(AppSpacing.touchTarget, AppSpacing.touchTarget),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(AppSpacing.touchTarget, AppSpacing.touchTarget),
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        side: BorderSide(color: borderColor),
      ),
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    dividerTheme: DividerThemeData(
      color: borderColor,
      thickness: 1,
      space: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.goldLight,
      linearTrackColor: AppColors.border,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textColor),
      titleTextStyle: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: AppPageTransitionsBuilder(),
        TargetPlatform.iOS: AppPageTransitionsBuilder(),
        TargetPlatform.macOS: AppPageTransitionsBuilder(),
        TargetPlatform.windows: AppPageTransitionsBuilder(),
        TargetPlatform.linux: AppPageTransitionsBuilder(),
        TargetPlatform.fuchsia: AppPageTransitionsBuilder(),
      },
    ),
  );
}
