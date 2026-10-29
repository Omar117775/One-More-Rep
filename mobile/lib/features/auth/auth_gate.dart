import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../design/tokens.dart';
import '../shell/app_shell.dart';
import '../splash/splash_screen.dart';
import 'sign_in_screen.dart';

/// Single root gate for the in-memory P5 session.
///
/// The gate is the stable `MaterialApp.home`, so a successful sign-in swaps
/// the visible screen in place instead of leaving a pushed sign-in route on the
/// navigator stack. Persistent session restore remains P7 work.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showSignIn = false;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    final Widget screen;
    if (controller.isSignedIn) {
      screen = const AppShell(key: ValueKey('shell'));
    } else if (_showSignIn) {
      screen = const SignInScreen(key: ValueKey('sign-in'));
    } else {
      screen = SplashScreen(
        key: const ValueKey('splash'),
        onEnterArena: () => setState(() => _showSignIn = true),
      );
    }

    return AnimatedSwitcher(
      duration: MediaQuery.of(context).disableAnimations ? Duration.zero : AppDurations.page,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: screen,
    );
  }
}
