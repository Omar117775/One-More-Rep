import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/app_controller.dart';
import '../core/app_scope.dart';
import '../localization/app_strings.dart';
import '../design/app_theme.dart';
import 'features/auth/sign_in_screen.dart';
import 'features/shell/app_shell.dart';
import 'features/splash/splash_screen.dart';

/// Root widget: builds theme, localization plumbing and the sign-in gate.
/// The splash-CTA gate lives in [SplashScreen]; a signed-in session opens
/// the [AppShell].
class OneMoreRepApp extends StatelessWidget {
  const OneMoreRepApp({required this.controller, super.key});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final isArabic = controller.isArabic;
          final strings = isArabic ? AppStrings.arabic : AppStrings.english;
          return MaterialApp(
            title: 'One More Rep',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(),
            locale: controller.locale,
            supportedLocales: supportedLocales,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return AppStringsScope(
                strings: strings,
                child: child ?? const SizedBox.shrink(),
              );
            },
            routes: {
              '/sign-in': (context) => const SignInScreen(),
            },
            home: controller.isSignedIn ? const AppShell() : const SplashScreen(),
          );
        },
      ),
    );
  }
}
