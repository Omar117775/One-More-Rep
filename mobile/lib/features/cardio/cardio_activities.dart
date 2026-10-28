import 'package:flutter/material.dart';

import '../../localization/app_strings.dart';

/// Canonical cardio activity values sent to the API, with display labels
/// resolved through the centralized strings.
class CardioActivityOption {
  const CardioActivityOption(this.value);

  final String value;

  String label(AppStrings strings) => switch (value) {
        'run' => strings.activityRun,
        'walk' => strings.activityWalk,
        'cycling' => strings.activityCycling,
        'swimming' => strings.activitySwimming,
        'rowing' => strings.activityRowing,
        _ => strings.activityOther,
      };

  IconData get icon => switch (value) {
        'run' => Icons.directions_run,
        'walk' => Icons.directions_walk,
        'cycling' => Icons.directions_bike,
        'swimming' => Icons.pool,
        'rowing' => Icons.rowing,
        _ => Icons.more_horiz,
      };

  static const List<CardioActivityOption> options = [
    CardioActivityOption('run'),
    CardioActivityOption('walk'),
    CardioActivityOption('cycling'),
    CardioActivityOption('swimming'),
    CardioActivityOption('rowing'),
    CardioActivityOption('other'),
  ];

  /// Resolves any activity type value (canonical or free-text) to an option;
  /// unrecognized types fall back to "other".
  static CardioActivityOption resolve(String type) {
    final value = type.trim().toLowerCase();
    for (final option in options) {
      if (value == option.value) return option;
    }
    switch (value) {
      case 'running':
        return options[0];
      case 'walking':
        return options[1];
      case 'cycle' || 'bike' || 'biking':
        return options[2];
      case 'swim':
        return options[3];
      case 'row':
        return options[4];
    }
    return CardioActivityOption('other');
  }
}
