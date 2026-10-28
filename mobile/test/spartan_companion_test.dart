import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/components/spartan_companion.dart';

void main() {
  Widget wrap(SpartanState state, {bool disableAnimations = false, Widget? testerHost}) {
    return MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: SpartanCompanion(state: state, size: 96),
          ),
        ),
      ),
    );
  }

  testWidgets('companion renders each state without exceptions', (tester) async {
    for (final state in SpartanState.values) {
      await tester.pumpWidget(wrap(state));
      // Let one-shot animations run partway; training state loops forever so
      // intentionally avoid pumpAndSettle here.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(SpartanCompanion), findsOneWidget);
    }
  });

  testWidgets('training state keeps looping (no settle trap) and stays stable',
      (tester) async {
    await tester.pumpWidget(wrap(SpartanState.training));
    // Multiple pump cycles: the pulse loops, so pumpAndSettle would never
    // settle. This asserts the widget survives indefinite looping.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.byType(SpartanCompanion), findsOneWidget);
  });

  testWidgets('reduced motion renders a static completed frame', (tester) async {
    await tester.pumpWidget(wrap(SpartanState.milestone, disableAnimations: true));
    await tester.pump();
    expect(find.byType(SpartanCompanion), findsOneWidget);

    // Jumping further frames stays stable under reduced motion.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(SpartanCompanion), findsOneWidget);
  });
}
