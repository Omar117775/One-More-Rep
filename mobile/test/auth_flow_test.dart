import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/app_controller.dart';
import 'package:mobile/core/app_scope.dart';
import 'package:mobile/design/app_theme.dart';
import 'package:mobile/features/auth/forgot_password_screen.dart';
import 'package:mobile/features/auth/onboarding_screen.dart';
import 'package:mobile/features/auth/registration_screen.dart';
import 'package:mobile/localization/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_auth_repository.dart';
import 'fakes.dart';

AppController _controller() => AppController(
  auth: FakeAuthRepository(),
  train: FakeTrainRepository(),
  analytics: FakeAnalyticsRepository(),
  cardio: FakeCardioRepository(),
  progress: FakeProgressRepository(),
);

Widget _wrap(Widget child, [AppController? controller]) {
  return AppScope(
    controller: controller ?? _controller(),
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
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Auth Flow Suite', () {
    testWidgets('OnboardingScreen renders slides and handles next/skip', (
      tester,
    ) async {
      var finished = false;
      await tester.pumpWidget(
        _wrap(OnboardingScreen(onFinish: () => finished = true)),
      );
      await tester.pumpAndSettle();

      expect(find.text('DISCIPLINE OVER MOTIVATION'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('PRECISION PERFORMANCE'), findsOneWidget);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(finished, isTrue);
    });

    testWidgets('RegistrationScreen validates fields and registers trainee', (
      tester,
    ) async {
      final ctrl = _controller();
      var switchedToSignIn = false;

      await tester.pumpWidget(
        _wrap(
          RegistrationScreen(onSwitchToSignIn: () => switchedToSignIn = true),
          ctrl,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('CREATE ACCOUNT'), findsNWidgets(2)); // header + button
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);

      // Select Female
      await tester.tap(find.text('Female'));
      await tester.pumpAndSettle();

      // Enter form data
      await tester.enterText(find.byType(TextField).at(0), 'Spartan Trainee');
      await tester.enterText(find.byType(TextField).at(1), 'trainee@sparta.fit');
      await tester.enterText(find.byType(TextField).at(2), 'secret123');
      await tester.enterText(find.byType(TextField).at(3), 'secret123');

      final submitBtn = find.text('CREATE ACCOUNT').last;
      await tester.ensureVisible(submitBtn);
      await tester.pumpAndSettle();
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(ctrl.isSignedIn, isTrue);
      expect(ctrl.user?.name, 'Spartan Trainee');

      final signInLink = find.text('Already have an account? Sign In');
      await tester.ensureVisible(signInLink);
      await tester.pumpAndSettle();
      await tester.tap(signInLink);
      expect(switchedToSignIn, isTrue);
    });

    testWidgets('ForgotPasswordScreen sends mock recovery code', (
      tester,
    ) async {
      var back = false;
      await tester.pumpWidget(
        _wrap(ForgotPasswordScreen(onBackToSignIn: () => back = true)),
      );
      await tester.pumpAndSettle();

      expect(find.text('RESET PASSWORD'), findsOneWidget);
      expect(find.text('SEND RECOVERY CODE'), findsOneWidget);

      await tester.tap(find.byType(IconButton).first);
      expect(back, isTrue);

      await tester.enterText(find.byType(TextField).at(0), 'spartan@fit.com');
      await tester.tap(find.text('SEND RECOVERY CODE'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('RECOVERY CODE'), findsOneWidget);
      expect(find.text('NEW PASSWORD'), findsOneWidget);
    });
  });
}
