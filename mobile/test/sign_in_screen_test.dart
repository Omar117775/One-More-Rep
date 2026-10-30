import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';
import 'package:mobile/core/app_controller.dart';
import 'package:mobile/core/app_scope.dart';
import 'package:mobile/design/app_theme.dart';
import 'package:mobile/features/auth/sign_in_screen.dart';
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

Widget _signInHarness(AppController controller) {
  return AppScope(
    controller: controller,
    child: MaterialApp(
      theme: buildAppTheme(),
      home: const AppStringsScope(
        strings: AppStrings.english,
        child: SignInScreen(),
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SignInScreen', () {
    testWidgets(
      'initializes without inherited-widget lifecycle errors and renders sign-in form',
      (tester) async {
        final controller = _controller();

        await tester.pumpWidget(_signInHarness(controller));
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('WELCOME BACK'), findsOneWidget);
        expect(find.text('SIGN IN'), findsOneWidget);
      },
    );

    testWidgets('splash is scroll-safe at compact landscape sizes', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(OneMoreRepApp(controller: _controller()));
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump(const Duration(milliseconds: 1200));

      expect(tester.takeException(), isNull);
      expect(find.text('ONE MORE REP'), findsOneWidget);
      expect(find.text('ENTER THE ARENA'), findsOneWidget);
    });

    testWidgets(
      'splash gate opens sign-in and a successful login reaches the shell',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = _controller();

        await tester.pumpWidget(OneMoreRepApp(controller: controller));
        await tester.pump(const Duration(milliseconds: 120));

        expect(tester.takeException(), isNull);
        await tester.tap(find.text('ENTER THE ARENA'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(tester.takeException(), isNull);
        expect(find.text('WELCOME BACK'), findsOneWidget);

        await tester.enterText(
          find.byType(TextField).at(0),
          'leonidas@example.com',
        );
        await tester.enterText(find.byType(TextField).at(1), 'hunter2x');
        await tester.tap(find.text('SIGN IN'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump(const Duration(milliseconds: 800));

        expect(tester.takeException(), isNull);
        expect(find.text('LAST 30 DAYS'), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
      },
    );
  });
}
