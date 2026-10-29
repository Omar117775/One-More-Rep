import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile/components/charts.dart';
import 'package:mobile/core/app_controller.dart';
import 'package:mobile/core/app_scope.dart';
import 'package:mobile/data/models/analytics_summary.dart';
import 'package:mobile/data/models/progress_entry.dart';
import 'package:mobile/design/app_theme.dart';
import 'package:mobile/features/progress/progress_screen.dart';
import 'package:mobile/localization/app_strings.dart';

import 'fake_auth_repository.dart';
import 'fakes.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('ar');
  });

  testWidgets('progress screen shows derived weight and weekly trends', (
    tester,
  ) async {
    final analytics = AnalyticsSummary(
      from: DateTime.utc(2026, 4, 1),
      to: DateTime.utc(2026, 5, 1),
      workouts: WorkoutAnalytics(
        hasData: true,
        sessions: 4,
        volumeKg: 2500,
        weekly: [
          WorkoutWeek(weekStart: DateTime.utc(2026, 4, 20), volumeKg: 1000),
          WorkoutWeek(weekStart: DateTime.utc(2026, 4, 27), volumeKg: 1500),
        ],
      ),
      cardio: CardioAnalytics(
        hasData: true,
        sessions: 2,
        durationSeconds: 1500,
        weekly: [
          CardioWeek(
            weekStart: DateTime.utc(2026, 4, 20),
            durationSeconds: 600,
          ),
          CardioWeek(
            weekStart: DateTime.utc(2026, 4, 27),
            durationSeconds: 900,
          ),
        ],
      ),
      body: BodyAnalytics(
        hasData: true,
        series: [
          BodyPoint(measuredOn: DateTime.utc(2026, 4, 1), weightKg: 84),
          BodyPoint(measuredOn: DateTime.utc(2026, 4, 20), weightKg: 83),
          BodyPoint(measuredOn: DateTime.utc(2026, 4, 30), weightKg: 82),
        ],
      ),
    );
    final controller = AppController(
      auth: FakeAuthRepository(),
      train: FakeTrainRepository(),
      analytics: FakeAnalyticsRepository(summary: analytics),
      cardio: FakeCardioRepository(),
      progress: FakeProgressRepository(
        entriesToReturn: [
          ProgressEntry(
            id: 1,
            weightKg: 82,
            measuredOn: DateTime.utc(2026, 4, 30),
          ),
        ],
      ),
    );
    controller.api.authToken = 'test-token';
    controller.user = testUser();

    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const AppStringsScope(
            strings: AppStrings.english,
            child: ProgressScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
    expect(find.textContaining('−2 kg over'), findsOneWidget);
    expect(find.text('+50% vs first week'), findsNWidgets(2));
    expect(find.byType(AnimatedLineChart), findsOneWidget);
  });
}
