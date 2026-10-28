import 'package:flutter/material.dart';

import '../../components/common.dart';
import '../../core/app_scope.dart';
import '../../design/tokens.dart';
import '../../localization/app_strings.dart';

/// Settings: language toggle (rebuilds all screens), API base URL, sign out.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _apiUrlController;
  bool _savedFlash = false;

  @override
  void initState() {
    super.initState();
    _apiUrlController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final url = AppScope.of(context).apiBaseUrl;
    if (_apiUrlController.text != url) {
      _apiUrlController.text = url;
    }
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.settingsTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppBreakpoints.contentMax),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(strings.languageSection, style: AppText.caption),
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
              Text(strings.apiSection, style: AppText.caption),
              const SizedBox(height: AppSpacing.sm),
              OmrCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OmrTextField(
                      label: strings.apiBaseUrl,
                      controller: _apiUrlController,
                      keyboardType: TextInputType.url,
                      autoValidate: AutovalidateMode.disabled,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (_savedFlash)
                      Text(strings.savedNote, style: AppText.secondary.copyWith(color: AppColors.success)),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      height: AppSpacing.touchTarget,
                      child: OutlinedButton(
                        onPressed: () {
                          controller.setApiBaseUrl(_apiUrlController.text);
                          setState(() => _savedFlash = true);
                        },
                        child: Text(strings.saveApiUrl),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(strings.aboutSection, style: AppText.caption),
              const SizedBox(height: AppSpacing.sm),
              OmrCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strings.appVersionLabel, style: AppText.body),
                    const SizedBox(height: AppSpacing.xs),
                    Text(strings.profileNote, style: AppText.secondary),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: AppSpacing.touchTarget + 4,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
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
    final color = selected ? AppColors.blueLight : AppColors.muted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        constraints: const BoxConstraints(minHeight: AppSpacing.touchTarget),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked, color: color, size: 22),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(title, style: AppText.body)),
            Icon(
              Icons.translate,
              size: 20,
              color: selected ? AppColors.blueLight : AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

