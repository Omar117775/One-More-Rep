import 'package:flutter/material.dart';

import '../tokens.dart';
import 'spartan_emblem.dart';

/// The [SpartanEmblem] with layered entrance/breath/shimmer motion.
///
/// Entrance: fade + scale settle. Breath: soft gold halo pulsing behind the
/// helmet. Shimmer: a highlight band sweeping across the plume crest.
/// Reduced motion (`MediaQuery.disableAnimations`) renders one static,
/// glowing emblem instead. The widget renders exactly [size] square; the
/// halo is part of that box (it fades to transparent at the edges).
class AnimatedSpartanMark extends StatefulWidget {
  const AnimatedSpartanMark({this.size = 96, super.key});

  final double size;

  @override
  State<AnimatedSpartanMark> createState() => _AnimatedSpartanMarkState();
}

class _AnimatedSpartanMarkState extends State<AnimatedSpartanMark>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _breath;
  late final AnimationController _shimmer;

  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  bool _motionStarted = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );
    _scale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entrance, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _entrance.dispose();
    _breath.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  void _startMotion() {
    _motionStarted = true;
    _entrance.forward();
    _breath.repeat(reverse: true);
    _shimmer.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    if (!reduced && !_motionStarted) {
      _startMotion();
    }
    if (reduced) {
      // Freeze at the settled state with a soft, constant halo.
      _entrance.value = 1;
      _breath.value = 0.5;
      _shimmer.stop();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_entrance, _breath, _shimmer]),
      builder: (context, _) {
        final haloAlpha =
            0.09 + _breath.value * 0.09 * (reduced ? 0.5 : 1.0);

        Widget mark = SpartanEmblem(
          size: widget.size * 0.88,
          emphasis: 1.0,
        );
        if (!reduced) {
          final t = _shimmer.value;
          final c = (-0.35 + 1.7 * t).clamp(0.02, 0.98);
          final stops = <double>[
            (c - 0.18).clamp(0.0, c - 0.01),
            c,
            (c + 0.18).clamp(c + 0.01, 1.0),
          ];
          mark = ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.goldLight.withValues(alpha: 0.65),
                Colors.transparent,
              ],
              stops: stops,
            ).createShader(bounds),
            child: mark,
          );
        }

        return SizedBox.square(
          dimension: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.2),
                      colors: [
                        AppColors.gold.withValues(alpha: haloAlpha),
                        AppColors.goldDim.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Transform.scale(
                scale: reduced ? 1.0 : _scale.value,
                child: Opacity(
                  opacity: reduced ? 1.0 : _opacity.value,
                  child: mark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
