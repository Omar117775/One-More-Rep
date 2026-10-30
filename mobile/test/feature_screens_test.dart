import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile/components/rest_timer_widget.dart';
import 'package:mobile/core/app_controller.dart';
import 'package:mobile/core/app_scope.dart';
import 'package:mobile/design/app_theme.dart';
import 'package:mobile/features/achievements/achievements_screen.dart';
import 'package:mobile/features/ai_trainer/ai_trainer_screen.dart';
import 'package:mobile/features/notifications/notifications_screen.dart';
import 'package:mobile/features/subscriptions/mock_subscription_repository.dart';
import 'package:mobile/features/subscriptions/payments_screen.dart';
import 'package:mobile/features/subscriptions/subscriptions_view_model.dart';
import 'package:mobile/localization/app_strings.dart';

import 'fake_auth_repository.dart';
import 'fakes.dart';

Widget _wrapScreen(Widget child, [AppController? controller]) {
  final ctrl = controller ??
      AppController(
        auth: FakeAuthRepository(),
        train: FakeTrainRepository(),
        analytics: FakeAnalyticsRepository(),
        cardio: FakeCardioRepository(),
        progress: FakeProgressRepository(),
      );
  return AppScope(
    controller: ctrl,
    child: MaterialApp(
      theme: buildAppTheme(),
      home: AppStringsScope(
        strings: AppStrings.english,
        child: child,
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('ar', null);
  });

  group('Feature Screens Suite', () {
    testWidgets('AiTrainerScreen renders prompt chips, sends message, and receives reply', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapScreen(const AiTrainerScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('SPARTAN AI COACH'), findsOneWidget);
      expect(find.text('Recommend a 4-day Spartan split'), findsOneWidget);

      // Tap prompt chip
      await tester.tap(find.text('Recommend a 4-day Spartan split'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Analyzing your regimen...'), findsOneWidget);

      // Wait for AI response timer
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Hypertrophy & Heavy Compounds'), findsOneWidget);
    });

    testWidgets('AchievementsScreen renders badges and category filters', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapScreen(const AchievementsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('ACHIEVEMENTS'), findsOneWidget);
      expect(find.text('Spartan Trophies'), findsOneWidget);
      expect(find.text('First Blood'), findsOneWidget);
      expect(find.text('Shield Breaker'), findsOneWidget);

      // Filter by Records (PR)
      await tester.tap(find.text('Records (PR)'));
      await tester.pumpAndSettle();

      expect(find.text('Shield Breaker'), findsOneWidget);
      expect(find.text('First Blood'), findsNothing);
    });

    testWidgets('NotificationsScreen displays items and handles mark all read', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapScreen(const NotificationsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('NOTIFICATIONS'), findsOneWidget);
      expect(find.text('Time to Train: Upper Body Phalanx'), findsOneWidget);
      expect(find.text('Mark all read'), findsOneWidget);

      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();

      expect(find.text('Mark all read'), findsNothing);
    });

    testWidgets('RestTimerWidget countdown ticks and handles play/pause and +30s', (
      tester,
    ) async {
      var completed = false;
      await tester.pumpWidget(
        _wrapScreen(
          Scaffold(
            body: Center(
              child: RestTimerWidget(
                initialSeconds: 5,
                onCompleted: () => completed = true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('00:05'), findsOneWidget);
      expect(find.text('SPARTAN REST TIMER'), findsOneWidget);

      // Advance 2 seconds
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('00:03'), findsOneWidget);

      // Tap +30s
      await tester.tap(find.text('+30s'));
      await tester.pump();
      expect(find.text('00:33'), findsOneWidget);

      // Complete timer
      await tester.pump(const Duration(seconds: 34));
      await tester.pump();
      expect(completed, isTrue);
      expect(find.text('REST FINISHED! NEXT SET'), findsOneWidget);
    });

    testWidgets('PaymentsScreen validates Vodafone Cash reference and updates history', (
      tester,
    ) async {
      final vm = SubscriptionsViewModel(
        repository: const MockSubscriptionRepository(),
      );
      await vm.load();

      await tester.pumpWidget(
        _wrapScreen(PaymentsScreen(viewModel: vm)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Payments'), findsOneWidget);
      expect(find.text('Vodafone Cash'), findsOneWidget);

      // Enter reference
      final field = find.byType(TextFormField).first;
      await tester.ensureVisible(field);
      await tester.enterText(field, 'VF-998822');

      final submitBtn = find.text('Submit reference');
      await tester.ensureVisible(submitBtn);
      await tester.pumpAndSettle();
      await tester.tap(submitBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('VF-998822'), findsOneWidget);
    });
  });
}
