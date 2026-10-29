import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/app_controller.dart';
import '../core/app_scope.dart';
import '../localization/app_strings.dart';
import '../design/app_theme.dart';
import 'features/auth/auth_gate.dart';

/// Root widget: builds theme, localization plumbing and the auth gate.
/// [AuthGate] swaps splash / sign-in / shell without pushing routes over the
/// root, so a successful login always reaches the shell.
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
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
