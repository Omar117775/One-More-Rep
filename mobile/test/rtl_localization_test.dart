import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';
import 'package:mobile/core/app_controller.dart';
import 'package:mobile/components/spartan_companion.dart' show SpartanState;
import 'package:mobile/data/models/analytics_summary.dart';
import 'package:mobile/features/home/companion_state.dart';

import 'fake_auth_repository.dart';
import 'fakes.dart';

AppController _controller() {
  final controller = AppController(
    auth: FakeAuthRepository(),
    train: FakeTrainRepository(),
    analytics: FakeAnalyticsRepository(),
  );
  controller.api.authToken = 'test-token';
  controller.user = testUser();
  return controller;
}

void main() {
  testWidgets('Arabic locale renders RTL across the shell and home screens',
      (tester) async {
    final controller = _controller()..setLocale(const Locale('ar'));
    await tester.pumpWidget(OneMoreRepApp(controller: controller));
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump(const Duration(milliseconds: 700));

    // Shell labels localized to Arabic (nav titles only appear in `wide` rail;
    // phone width uses NavigationBar which shows them too).
    expect(find.text('الرئيسية'), findsOneWidget);

    // Localized home copy from the centralized strings map.
    expect(find.text('لا يوجد برنامج نشط بعد'), findsOneWidget);
    expect(find.text('آخر ٣٠ يوماً'), findsOneWidget);

    // Directionality resolves through the widgets down the localized tree.
    final dirArabic = Directionality.of(tester.element(find.text('الرئيسية')));
    expect(dirArabic, TextDirection.rtl);
  });

  testWidgets('toggling language from Arabic back to English restores LTR',
      (tester) async {
    final controller = _controller()..setLocale(const Locale('ar'));
    await tester.pumpWidget(OneMoreRepApp(controller: controller));
    await tester.pump(const Duration(milliseconds: 400));

    controller.setLocale(const Locale('en'));
    await tester.pump(const Duration(milliseconds: 400));

    final dirEnglish = Directionality.of(tester.element(find.text('Home')));
    expect(dirEnglish, TextDirection.ltr);
    expect(find.text('Home'), findsOneWidget);
  });

  group('companion state derivation', () {
    test('active assignment drives the training state', () {
      final now = DateTime(2026, 5, 21);
      final state = companionFor(
        analytics: null,
        assignments: [testAssignment()],
        sessions: [],
        now: now,
      );
      expect(state, SpartanState.training);
    });

    test('no assignment at all falls back to idle', () {
      final state = companionFor(
        analytics: null,
        assignments: [],
        sessions: [],
        now: DateTime(2026, 5, 21),
      );
      expect(state, SpartanState.idle);
    });

    test('recent completed session surfaces the success celebration', () {
      final session = testSession(completedAt: '2026-05-21T07:00:00Z');
      expect(session.isCompleted, isTrue);
      final state = companionFor(
        analytics: null,
        assignments: [testAssignment()],
        sessions: [session],
        now: DateTime(2026, 5, 21, 8, 0),
      );
      expect(state, SpartanState.success);
    });

    test('volume surge over the previous week triggers milestone', () {
      final summary = AnalyticsSummary.fromJson({
        'from': '2026-04-21',
        'to': '2026-05-21',
        'workouts': {
          'has_data': true,
          'weekly': [
            {
              'week_start': '2026-04-27',
              'volume_kg': '600.0',
            },
            {
              'week_start': '2026-05-04',
              'volume_kg': '800.0',
            },
          ],
        },
      });
      final state = companionFor(
        analytics: summary,
        assignments: [testAssignment()],
        sessions: [],
        now: DateTime(2026, 5, 21),
      );
      expect(state, SpartanState.milestone);
    });
  });
}
