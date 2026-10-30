import 'package:flutter/material.dart';

import 'app_motion.dart';

/// Premium push transition for all `MaterialPageRoute`s (wired through
/// `pageTransitionsTheme` in the theme builders).
///
/// Incoming page rises slightly (y-offset), fades and settles from a 0.98
/// scale; the outgoing page fades back a touch for depth. Honors
/// `MediaQuery.disableAnimations` — under reduced motion, a pure fade
/// replaces the combined move.
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Widget buildTransitions<T extends Object?>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final reduced = MediaQuery.of(context).disableAnimations;
    if (reduced) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: AppMotion.easeOut,
        ),
        child: child,
      );
    }

    final curved = CurvedAnimation(
      parent: animation,
      curve: AppMotion.page,
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.055),
          end: Offset.zero,
        ).animate(curved),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1).animate(curved),
          child: child,
        ),
      ),
    );
  }
}
