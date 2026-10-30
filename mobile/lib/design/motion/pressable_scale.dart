import 'package:flutter/material.dart';

import 'app_motion.dart';

/// Press feedback wrapper: gently scales down (and dims a touch) while the
/// pointer is down, springing back on release. Purely visual — the child's
/// own gesture handlers (buttons, InkWell) keep priority in the gesture
/// arena, so no behavior changes.
///
/// Reduced motion scales are disabled (still sends taps through).
class PressableScale extends StatefulWidget {
  const PressableScale({
    required this.child,
    this.onTap,
    this.pressedScale = 0.975,
    super.key,
  });

  final Widget child;

  /// Optional tap binding for non-interactive children (cards, tiles).
  final VoidCallback? onTap;

  /// Pressed-down scale factor.
  final double pressedScale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (MediaQuery.of(context).disableAnimations) {
      return;
    }
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTap: widget.onTap,
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: reduced ? Duration.zero : AppMotion.fast,
        curve: AppMotion.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
