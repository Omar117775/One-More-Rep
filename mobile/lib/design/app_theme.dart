import 'package:flutter/material.dart';

import 'tokens.dart';

/// Builds the dark-first premium theme from centralized tokens.
ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Manrope',
    splashFactory: InkSparkle.splashFactory,
  );

  final colorScheme = base.colorScheme.copyWith(
    brightness: Brightness.dark,
    primary: AppColors.blue,
    onPrimary: Colors.white,
    secondary: AppColors.blueLight,
    onSecondary: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.white,
    error: AppColors.danger,
    onError: Colors.white,
    outline: AppColors.border,
  );

  final textTheme = base.textTheme
      .apply(bodyColor: AppColors.white, displayColor: AppColors.white)
      .copyWith(
        displayMedium: AppText.display,
        headlineMedium: AppText.headline,
        titleMedium: AppText.title,
        bodyMedium: AppText.body,
        bodySmall: AppText.secondary,
        labelSmall: AppText.caption,
      );

  final shapeRounded = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadii.md),
  );

  return base.copyWith(
    colorScheme: colorScheme,
    textTheme: textTheme,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: AppText.secondary,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + AppSpacing.xs / 2,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.blueLight, width: 1.5),
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
      textStyle: AppText.body,
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(AppColors.surfaceLight),
        shape: WidgetStatePropertyAll(shapeRounded),
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.surfaceLight,
      surfaceTintColor: Colors.transparent,
      headerForegroundColor: AppColors.white,
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: AppColors.surface,
      dialBackgroundColor: AppColors.surfaceLight,
      hourMinuteColor: AppColors.surfaceLight,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceLight,
      contentTextStyle: AppText.body,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.blue.withValues(alpha: 0.22),
      labelTextStyle: WidgetStatePropertyAll(
        AppText.microLabel.copyWith(fontSize: 11, letterSpacing: 0.4),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: AppColors.background,
      indicatorColor: AppColors.blue.withValues(alpha: 0.22),
      selectedIconTheme: const IconThemeData(color: AppColors.blueLight),
      unselectedIconTheme: const IconThemeData(color: AppColors.muted),
      selectedLabelTextStyle: AppText.title.copyWith(fontSize: 12),
      unselectedLabelTextStyle: AppText.secondary.copyWith(fontSize: 12),
      groupAlignment: -0.9,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.blueLight
            : AppColors.muted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.blue.withValues(alpha: 0.35)
            : AppColors.border,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
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
        foregroundColor: AppColors.blueLight,
        minimumSize: const Size.fromHeight(AppSpacing.touchTarget),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.blueLight,
        minimumSize: const Size(
          AppSpacing.touchTarget,
          AppSpacing.touchTarget,
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(
          AppSpacing.touchTarget,
          AppSpacing.touchTarget,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        side: const BorderSide(color: AppColors.border),
      ),
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.blueLight,
      linearTrackColor: AppColors.border,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.white),
      titleTextStyle: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.white,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _fadeSlideTransition,
        TargetPlatform.iOS: _fadeSlideTransition,
        TargetPlatform.macOS: _fadeSlideTransition,
        TargetPlatform.windows: _fadeSlideTransition,
        TargetPlatform.linux: _fadeSlideTransition,
        TargetPlatform.fuchsia: _fadeSlideTransition,
      },
    ),
  );
}

const PageTransitionsBuilder _fadeSlideTransition = _FadeSlideBuilder();

class _FadeSlideBuilder extends PageTransitionsBuilder {
  const _FadeSlideBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.of(context).disableAnimations) {
      return child;
    }
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
