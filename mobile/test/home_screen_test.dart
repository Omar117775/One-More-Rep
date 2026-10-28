import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';
import 'package:mobile/core/app_controller.dart';
import 'package:mobile/data/models/analytics_summary.dart';
import 'package:mobile/data/models/cardio_entry.dart';
import 'package:mobile/data/models/progress_entry.dart';

import 'fake_auth_repository.dart';
import 'fakes.dart';

/// Pumps the real root app with fake repositories and a signed-in session.
Future<AppController> pumpSignedInApp(
  WidgetTester tester, {
  required FakeTrainRepository train,
  required FakeAnalyticsRepository analytics,
  FakeCardioRepository? cardio,
  FakeProgressRepository? progress,
}) async {
  final controller = AppController(
    auth: FakeAuthRepository(),
    train: train,
    analytics: analytics,
    cardio: cardio,
    progress: progress,
  );
  controller.api.authToken = 'test-token';
  controller.user = testUser();
  await tester.pumpWidget(OneMoreRepApp(controller: controller));
  await tester.pump(const Duration(milliseconds: 120));
  await tester.pump(const Duration(milliseconds: 700));
  return controller;
}

void main() {
  group('home dashboard', () {
    testWidgets('shows empty-state hints when analytics and assignments are empty',
        (tester) async {
      await pumpSignedInApp(
        tester,
        train: FakeTrainRepository(assignmentsToReturn: [], sessionsToReturn: []),
        analytics: FakeAnalyticsRepository(),
      );

      expect(find.text('LAST 30 DAYS'), findsOneWidget);
      expect(find.text('No workouts in the last 30 days'), findsOneWidget);
      expect(find.text('No cardio in the last 30 days'), findsOneWidget);
      expect(find.text('No active program yet'), findsOneWidget);
    });

    testWidgets('shows real summary values when analytics has data', (tester) async {
      final summary = AnalyticsSummary.fromJson({
        'from': '2026-04-21',
        'to': '2026-05-21',
        'workouts': {
          'has_data': true,
          'sessions': 4,
          'completed_sessions': 3,
          'sets': 12,
          'reps': 110,
          'volume_kg': '1230.5',
          'weekly': [
            {'week_start': '2026-04-27', 'volume_kg': '600.0', 'sessions': 2},
            {'week_start': '2026-05-04', 'volume_kg': '630.5', 'sessions': 2},
          ],
        },
        'cardio': {
          'has_data': true,
          'sessions': 2,
          'duration_seconds': 5400,
          'weekly': [
            {'week_start': '2026-04-27', 'duration_seconds': 2700, 'sessions': 1},
          ],
        },
        'body': {
          'has_data': true,
          'series': [
            {
              'id': 1,
              'measured_on': '2026-05-01',
              'weight_kg': '84.2',
            },
          ],
        },
      });
      await pumpSignedInApp(
        tester,
        train: FakeTrainRepository(
          assignmentsToReturn: [testAssignment()],
          sessionsToReturn: [],
        ),
        analytics: FakeAnalyticsRepository(summary: summary),
      );

      expect(find.text('3 / 4'), findsOneWidget);
      expect(find.text('1h 30m'), findsOneWidget); // 5400s cardio duration
      expect(find.text('84.2 kg'), findsOneWidget);
      expect(find.text('Hypertrophy Base'), findsOneWidget);
    });

    testWidgets('quick actions switch tabs through the shell', (tester) async {
      await pumpSignedInApp(
        tester,
        train: FakeTrainRepository(assignmentsToReturn: [], sessionsToReturn: []),
        analytics: FakeAnalyticsRepository(),
      );

      // Tap the "Log workout" quick action icon -> Train tab.
      await tester.tap(find.byIcon(Icons.fitness_center).first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Training Programs'), findsOneWidget);

      // Back to the Home tab via the bottom navigation bar, then "Add cardio".
      await tester.tap(find.byIcon(Icons.home_outlined).first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byIcon(Icons.directions_run).first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byIcon(Icons.add), findsWidgets);
    });
  });

  group('home data models', () {
    test('cardio seconds formatting survives string decimals in payloads', () {
      final entry = CardioEntry.fromJson({
        'id': 2,
        'activity_type': 'run',
        'duration_seconds': 2700,
        'distance_km': '4.75',
        'performed_at': '2026-05-20T07:15:00Z',
      });
      expect(entry.durationSeconds, 2700);
      expect(entry.distanceKm, closeTo(4.75, 0.0001));
    });

    test('progress entries keep all five optional metric fields', () {
      final entry = ProgressEntry.fromJson({
        'id': 3,
        'weight_kg': '84.2',
        'body_fat_percentage': '18.1',
        'waist_cm': '80.5',
        'chest_cm': null,
        'arm_cm': null,
        'measured_on': '2026-05-01',
      });
      expect(entry.weightKg, closeTo(84.2, 0.001));
      expect(entry.bodyFatPercentage, closeTo(18.1, 0.001));
      expect(entry.waistCm, closeTo(80.5, 0.001));
      expect(entry.chestCm, isNull);
      expect(entry.armCm, isNull);
      expect(entry.hasAnyMeasurement, isTrue);
    });
  });
}
