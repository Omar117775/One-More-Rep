import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Animated summary tile used on the home dashboard. The value slides in with
/// a single-shot motion; static when reduced motion is enabled.
class AnimatedStatTile extends StatelessWidget {
  const AnimatedStatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.caption,
    this.accent = AppColors.blueLight,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? caption;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final animated = !MediaQuery.of(context).disableAnimations;

    final header = Text(
      label,
      style: AppText.caption,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    Widget valueWidget = Text(
      value,
      style: AppText.headline.copyWith(fontSize: 22),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (animated) {
      valueWidget = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) {
          return Transform.translate(
            offset: Offset(0, (1 - t) * 8),
            child: Opacity(opacity: t, child: child),
          );
        },
        child: valueWidget,
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              color: accent.withValues(alpha: 0.14),
              border: Border.all(color: accent.withValues(alpha: 0.4)),
            ),
            child: Icon(icon, color: accent, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header,
                valueWidget,
                if (caption != null)
                  Text(
                    caption!,
                    style: AppText.secondary.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
