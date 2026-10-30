import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../design/tokens.dart';
import '../shell/app_shell.dart';
import '../splash/splash_screen.dart';
import 'sign_in_screen.dart';

/// Single root gate for the session and route switching.
///
/// On launch, displays the SplashScreen while attempting background
/// session restoration. If a valid token is found, automatically transitions
/// to the AppShell. If the user taps "ENTER THE ARENA" before/without restoration,
/// transitions to the SignInScreen.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showSignIn = false;
  bool _restoreAttempted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_restoreAttempted) {
      _restoreAttempted = true;
      _tryRestore();
    }
  }

  Future<void> _tryRestore() async {
    final controller = AppScope.of(context);
    if (!controller.isSignedIn) {
      try {
        await controller.tryRestoreSession();
      } catch (_) {
        // Best-effort session restoration.
      }
    }
  }

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
      duration: MediaQuery.of(context).disableAnimations
          ? Duration.zero
          : AppDurations.page,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: screen,
    );
  }
}
