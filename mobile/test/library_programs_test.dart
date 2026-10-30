import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/app_controller.dart';
import 'package:mobile/core/app_scope.dart';
import 'package:mobile/features/library/exercise_detail_screen.dart';
import 'package:mobile/features/library/library_screen.dart';
import 'package:mobile/features/programs/program_detail_screen.dart';
import 'package:mobile/features/programs/programs_screen.dart';

import 'fake_auth_repository.dart';
import 'fakes.dart';

AppController _controller() => AppController(
  auth: FakeAuthRepository(),
  train: FakeTrainRepository(),
);

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(600, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    AppScope(
      controller: _controller(),
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ar')],
        home: child,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  testWidgets('exercise library renders catalog and opens detail', (
    tester,
  ) async {
    await _pump(tester, const LibraryScreen());

    // Header + search + filter chips render.
    expect(find.text('Exercise Library'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.byType(ChoiceChip), findsWidgets);

    // Mock catalog cards render; entries carry difficulty badges.
    expect(find.text('Barbell Bench Press'), findsOneWidget);
    expect(find.text('Beginner'), findsWidgets);

    // Opening a card pushes the detail screen with instructions.
    await tester.tap(find.text('Barbell Bench Press'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ExerciseDetailScreen), findsOneWidget);
    expect(find.text('INSTRUCTIONS'), findsOneWidget);
    // The difficulty badge is also present (list cards behind remain in
    // the tree, hence findsWidgets rather than findsOneWidget).
    expect(find.text('Intermediate'), findsWidgets);

    // Back returns to the list.
    await tester.pageBack();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(LibraryScreen), findsOneWidget);
  });

  testWidgets('exercise library filters by group chip', (tester) async {
    await _pump(tester, const LibraryScreen());

    // A chest exercise and a leg exercise both render initially.
    expect(find.text('Barbell Bench Press'), findsOneWidget);
    expect(find.text('Back Squat'), findsOneWidget);

    // Filter to Legs — chest entries leave the list.
    await tester.tap(find.text('Legs').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Back Squat'), findsOneWidget);
    expect(find.text('Barbell Bench Press'), findsNothing);
  });

  testWidgets('programs screen shows mock cards and mock-only CTA', (
    tester,
  ) async {
    await _pump(tester, const ProgramsScreen());

    expect(find.byType(ProgramsScreen), findsOneWidget);
    expect(find.text('MOCK PREVIEW'), findsWidgets);
    expect(find.text('Foundations of Strength'), findsOneWidget);
    expect(find.text('Hypertrophy Engine'), findsOneWidget);

    // Open a program: weekly schedule + coming-soon CTA render.
    await tester.tap(find.text('Foundations of Strength'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ProgramDetailScreen), findsOneWidget);
    expect(find.text('WEEKLY SCHEDULE'), findsOneWidget);
    expect(find.text('Coming soon'), findsOneWidget);

    // The CTA answers with the local mock toast; it never navigates.
    await tester.tap(find.text('Coming soon'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      find.textContaining('Program enrollment ships with the backend'),
      findsOneWidget,
    );
    expect(find.byType(ProgramDetailScreen), findsOneWidget);
  });
}
