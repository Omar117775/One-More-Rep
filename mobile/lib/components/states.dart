import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../localization/app_strings.dart';

/// Shared async-state widgets: loading spinner, error panel with retry,
/// and empty-state panel with optional action.

class OmrLoading extends StatelessWidget {
  const OmrLoading({this.label, super.key});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(strokeWidth: 2.6),
            if (label != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(label!, style: AppText.secondary, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}

class OmrErrorPanel extends StatelessWidget {
  const OmrErrorPanel({required this.message, this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, color: AppColors.danger, size: 40),
            const SizedBox(height: AppSpacing.md),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppBreakpoints.contentMax),
              child: Text(
                message,
                style: AppText.body,
                textAlign: TextAlign.center,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton(
                onPressed: onRetry,
                child: Text(strings.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class OmrEmptyPanel extends StatelessWidget {
  const OmrEmptyPanel({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceLight,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, color: AppColors.blueLight, size: 32),
            ),
            const SizedBox(height: AppSpacing.md),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppBreakpoints.contentMax),
              child: Text(
                title,
                style: AppText.title,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppBreakpoints.contentMax),
              child: Text(
                subtitle,
                style: AppText.secondary,
                textAlign: TextAlign.center,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: 220,
                child: OutlinedButton(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
