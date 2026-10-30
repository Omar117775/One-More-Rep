import 'package:flutter/material.dart';

import '../../components/common.dart';
import '../../core/app_scope.dart';
import '../../design/brand/spartan_emblem.dart';
import '../../design/motion/pressable_scale.dart';
import '../../design/tokens.dart';
import '../../localization/app_strings.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../subscriptions/subscriptions_screen.dart';

/// Settings: language toggle (rebuilds all screens), account navigation,
/// about info, and sign out.
/// Grouped layered-black sections with gold section markers.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.settingsTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppBreakpoints.contentMax,
          ),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _SectionLabel(text: strings.settingsAccountSection),
              const SizedBox(height: AppSpacing.sm),
              OmrCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsNavRow(
                      icon: Icons.person_outline,
                      title: 'Trainee Profile',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsNavRow(
                      icon: Icons.card_membership_outlined,
                      title: strings.settingsSubscriptionsRow,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => const SubscriptionsScreen()),
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsNavRow(
                      icon: Icons.notifications_outlined,
                      title: strings.notificationsTitle,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionLabel(text: strings.languageSection),
              const SizedBox(height: AppSpacing.sm),
              OmrCard(
                child: Column(
                  children: [
                    _LanguageTile(
                      title: strings.languageEnglish,
                      selected: !controller.isArabic,
                      onTap: () => controller.setLocale(const Locale('en')),
                    ),
                    const Divider(),
                    _LanguageTile(
                      title: strings.languageArabic,
                      selected: controller.isArabic,
                      onTap: () => controller.setLocale(const Locale('ar')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionLabel(text: strings.aboutSection),
              const SizedBox(height: AppSpacing.sm),
              OmrCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SpartanEmblem(size: 40, emphasis: 1.1),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(strings.appVersionLabel, style: AppText.body),
                          const SizedBox(height: AppSpacing.xs),
                          Text(strings.profileNote, style: AppText.secondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: AppSpacing.touchTarget + 4,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.danger,
                  ),
                  icon: const Icon(Icons.logout),
                  label: Text(strings.signOut),
                  onPressed: _confirmSignOut,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut() async {
    final strings = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.signOut, style: AppText.title),
        content: Text(strings.signOutConfirm, style: AppText.secondary),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(strings.signOut),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      if (!mounted) return;
      await AppScope.of(context).signOut();
    }
  }
}

/// Cap-style section label with a gold marker — the settings equivalent of
/// the Home section headers, kept lighter than full SectionHeader titles.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            color: AppColors.goldLight,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          text.toUpperCase(),
          style: AppText.microLabel.copyWith(letterSpacing: 1.1),
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.goldLight : AppColors.muted;
    return PressableScale(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSpacing.touchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: color,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: selected
                      ? AppText.body.copyWith(color: AppColors.goldLight)
                      : AppText.body,
                ),
              ),
              Icon(
                Icons.translate,
                size: 20,
                color: selected ? AppColors.goldLight : AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsNavRow extends StatelessWidget {
  const _SettingsNavRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.metallicGold, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: AppText.title.copyWith(fontSize: 14),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.neutralGray,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
