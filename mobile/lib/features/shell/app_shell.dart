import 'package:flutter/material.dart';

import '../../design/tokens.dart';
import '../../localization/app_strings.dart';
import '../cardio/cardio_screen.dart';
import '../home/home_screen.dart';
import '../progress/progress_screen.dart';
import '../settings/settings_screen.dart';
import '../train/train_screen.dart';

/// Responsive app shell: bottom navigation bar on phones, navigation rail
/// on wide screens. IndexedStack keeps tab state alive.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

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
                for (final label in destinations)
                  NavigationRailDestination(
                      icon: Icon(iconFor(destinations.indexOf(label))), label: Text(label)),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: IndexedStack(index: _index, children: screens)),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: goTo,
        destinations: [
          for (var i = 0; i < destinations.length; i++)
            NavigationDestination(
              icon: Icon(iconFor(i)),
              selectedIcon: Icon(iconFor(i, selected: true)),
              label: destinations[i],
            ),
        ],
      ),
    );
  }

  IconData iconFor(int index, {bool selected = false}) {
    return switch (index) {
      0 => (selected ? Icons.home_rounded : Icons.home_outlined),
      1 => (selected ? Icons.fitness_center : Icons.fitness_center_outlined),
      2 => (selected ? Icons.directions_run : Icons.directions_run_outlined),
      3 => (selected ? Icons.insights : Icons.insights_outlined),
      _ => (selected ? Icons.settings : Icons.settings_outlined),
    };
  }
}
