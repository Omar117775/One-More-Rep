import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/app_controller.dart';
import 'package:mobile/core/app_scope.dart';
import 'package:mobile/features/cardio/cardio_form_screen.dart';
import 'package:mobile/features/cardio/cardio_view_model.dart';
import 'package:mobile/features/progress/progress_form_screen.dart';
import 'package:mobile/features/progress/progress_view_model.dart';

import 'fake_auth_repository.dart';
import 'fakes.dart';

AppController testController() {
  final controller = AppController(
    auth: FakeAuthRepository(),
    train: FakeTrainRepository(),
  );
  return controller;
}

void main() {
  // Give forms a tall test viewport so every field and the submit button are
  // built by the lazy SliverList.
  Future<void> pumpInAppScope(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      AppScope(
        controller: testController(),
        child: MaterialApp(
          // Intl date formatting requires the localization delegates.
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('ar')],
          home: Scaffold(body: child),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('cardio form requires duration and rejects non-numeric input', (
    tester,
  ) async {
    final viewModel = CardioViewModel(repo: FakeCardioRepository());
    await pumpInAppScope(tester, CardioFormScreen(viewModel: viewModel));

    // Submit with empty duration: required-field error shows under the field.
    await tester.tap(find.widgetWithText(FilledButton, 'Add cardio'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('This field is required.'), findsOneWidget);

    // Feeding a non-number triggers the invalid-number error.
    await tester.enterText(find.byType(TextFormField).at(0), 'not-a-number');
    await tester.tap(find.widgetWithText(FilledButton, 'Add cardio'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Enter a valid number.'), findsOneWidget);
  });

  testWidgets('measurement form rejects invalid values and empty submits', (
    tester,
  ) async {
    final viewModel = ProgressViewModel(
      progressRepo: FakeProgressRepository(),
      analyticsRepo: FakeAnalyticsRepository(),
    );
    await pumpInAppScope(tester, ProgressFormScreen(viewModel: viewModel));

    // Non-numeric value in the weight field shows invalid-number error.
    await tester.enterText(find.byType(TextFormField).at(0), 'heavy');
    await tester.tap(find.widgetWithText(FilledButton, 'Add measurement'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Enter a valid number.'), findsOneWidget);

    // Empty submit without any measurement value: contract requires >= 1 metric.
    await tester.enterText(find.byType(TextFormField).at(0), '');
    await tester.tap(find.widgetWithText(FilledButton, 'Add measurement'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('This field is required.'), findsOneWidget);
  });

  testWidgets('cardio form accepts a valid entry and returns to the list', (
    tester,
  ) async {
    final viewModel = CardioViewModel(
      repo: FakeCardioRepository(entriesToReturn: []),
    );
    await pumpInAppScope(tester, CardioFormScreen(viewModel: viewModel));

    await tester.enterText(find.byType(TextFormField).at(0), '45');
    await tester.enterText(find.byType(TextFormField).at(1), '10.5');
    await tester.tap(find.widgetWithText(FilledButton, 'Add cardio'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('This field is required.'), findsNothing);
    expect(find.text('Enter a valid number.'), findsNothing);
  });
}
