import 'package:flutter/material.dart';

import '../../design/brand/shell_icons.dart';
import '../../design/tokens.dart';
import '../../localization/app_strings.dart';
import '../cardio/cardio_screen.dart';
import '../home/home_screen.dart';
import '../progress/progress_screen.dart';
import '../settings/settings_screen.dart';
import '../train/train_screen.dart';

/// Responsive app shell: bottom navigation bar on phones, navigation rail
/// on wide screens. IndexedStack keeps tab state alive. Destination icons
/// are original code-drawn animated slots (see lib/design/brand).
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const List<ShellIconKind> _kinds = [
    ShellIconKind.home,
    ShellIconKind.train,
    ShellIconKind.cardio,
    ShellIconKind.progress,
    ShellIconKind.settings,
  ];

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final wide = MediaQuery.sizeOf(context).width >= AppBreakpoints.shell;

    final destinations = [
      strings.navHome,
      strings.navTrain,
      strings.navCardio,
      strings.navProgress,
      strings.navSettings,
    ];

    void goTo(int index) => setState(() => _index = index);

    final screens = <Widget>[
      HomeScreen(onNavigate: goTo),
      const TrainScreen(),
      const CardioScreen(),
      const ProgressScreen(),
      const SettingsScreen(),
    ];

    if (wide) {
      return Scaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: goTo,
              extended: false,
              minExtendedWidth: 140,
              destinations: [
                for (var i = 0; i < destinations.length; i++)
                  NavigationRailDestination(
                    icon: AnimatedIconSlot(
                      kind: _kinds[i],
                      selected: false,
                    ),
                    selectedIcon: AnimatedIconSlot(
                      kind: _kinds[i],
                      selected: true,
                    ),
                    label: Text(destinations[i]),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: IndexedStack(index: _index, children: screens),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.darkGraphite.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color: AppColors.metallicGold.withValues(alpha: 0.28),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.metallicGold.withValues(alpha: 0.08),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              child: NavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                height: 68,
                selectedIndex: _index,
                onDestinationSelected: goTo,
                destinations: [
                  for (var i = 0; i < destinations.length; i++)
                    NavigationDestination(
                      icon: AnimatedIconSlot(kind: _kinds[i], selected: false),
                      selectedIcon: AnimatedIconSlot(kind: _kinds[i], selected: true),
                      label: destinations[i],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
