import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../localization/app_strings.dart';

/// Premium dark card with border used across the app.
class OmrCard extends StatelessWidget {
  const OmrCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(AppRadii.md), child: card),
    );
  }
}

/// Section header with accent bar and optional action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        right: AppSpacing.xs,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              color: AppColors.blueLight,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: AppText.title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(strings.seeAll)),
        ],
      ),
    );
  }
}

/// Primary full-width filled button with loading state and press feedback.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    this.onPressed,
    this.loading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final disabled = loading || onPressed == null;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: disabled ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}

/// Rounded icon action chip used for quick actions and card rows.
class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSpacing.touchTarget),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.blueLight, size: 26),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: AppText.secondary,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icon pill button (edit/delete confirm rows), 44dp touch target.
class IconPill extends StatelessWidget {
  const IconPill({required this.icon, required this.tooltip, this.onPressed, super.key});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 22),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.border),
      ),
    );
  }
}

/// Localized text field with consistent dark styling.
class OmrTextField extends StatelessWidget {
  const OmrTextField({
    required this.label,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscure = false,
    this.suffixIcon,
    this.hintText,
    this.autoValidate,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffixIcon;
  final String? hintText;
  final AutovalidateMode? autoValidate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.caption),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscure,
          autovalidateMode: autoValidate ?? AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(hintText: hintText, suffixIcon: suffixIcon),
        ),
      ],
    );
  }
}
