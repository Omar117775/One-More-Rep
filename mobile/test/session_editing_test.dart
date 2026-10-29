import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile/core/app_controller.dart';
import 'package:mobile/core/app_scope.dart';
import 'package:mobile/design/app_theme.dart';
import 'package:mobile/features/train/session_history_screen.dart';
import 'package:mobile/features/train/session_log_screen.dart';
import 'package:mobile/localization/app_strings.dart';

import 'fake_auth_repository.dart';
import 'fakes.dart';

AppController _controller(FakeTrainRepository train) {
  final controller = AppController(
    auth: FakeAuthRepository(),
    train: train,
    analytics: FakeAnalyticsRepository(),
    cardio: FakeCardioRepository(),
    progress: FakeProgressRepository(),
  );
  controller.api.authToken = 'test-token';
  controller.user = testUser();
  return controller;
}

Widget _harness(AppController controller, Widget home) {
  return AppScope(
    controller: controller,
    child: MaterialApp(
      theme: buildAppTheme(),
      home: AppStringsScope(strings: AppStrings.english, child: home),
    ),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('ar');
  });

  testWidgets(
    'session history loads without inherited-widget lifecycle errors',
    (tester) async {
      final train = FakeTrainRepository(
        sessionsToReturn: [testSession(completedAt: '2026-05-20T19:30:00Z')],
      );
      await tester.pumpWidget(
        _harness(_controller(train), const SessionHistoryScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    },
  );

  testWidgets('editing a session prefills sets and saves changes', (
    tester,
  ) async {
    final train = FakeTrainRepository(sessionsToReturn: [testSession()]);
    final session = train.sessionsToReturn.single;
    await tester.pumpWidget(
      _harness(_controller(train), SessionLogScreen(session: session)),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Edit session'), findsOneWidget);
    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('42.5'), findsNWidgets(2));
    expect(find.text('Save changes'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), '50');
    await tester.tap(find.text('Save changes'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
    expect(train.lastUpdatedSessionId, session.id);
    expect(train.lastUpdateSets, hasLength(2));
    expect(train.lastUpdateSets!.first['weight_kg'], 50.0);
    expect(train.lastUpdateSets!.first['reps'], 10);
    expect(train.lastUpdateNotes, 'felt strong');
  });

  testWidgets('history edit action opens the edit form', (tester) async {
    final train = FakeTrainRepository(sessionsToReturn: [testSession()]);
    await tester.pumpWidget(
      _harness(_controller(train), const SessionHistoryScreen()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.byType(SessionLogScreen), findsOneWidget);
    expect(find.text('Edit session'), findsOneWidget);
  });
}
