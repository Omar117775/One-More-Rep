import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/components/charts.dart';

void main() {
  setUpAll(() {});

  Widget scaffold(Widget chart) {
    return MaterialApp(
      home: Scaffold(body: Center(child: chart)),
    );
  }

  testWidgets('charts show the empty placeholder when there is no data',
      (tester) async {
    await tester.pumpWidget(
      scaffold(
        Column(
          children: [
            AnimatedLineChart(data: ChartData(labels: const [], values: const [])),
            AnimatedBarChart(data: ChartData(labels: const ['w1'], values: const [0.0])),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Empty placeholder text appears for each of the two charts.
    expect(find.text('No data for this period'), findsNWidgets(2));
  });

  testWidgets('line chart renders a data series with animated progress',
      (tester) async {
    await tester.pumpWidget(
      scaffold(
        AnimatedLineChart(
          data: ChartData(
            labels: const ['01 Jan', '07 Jan'],
            // Gaps in the measured series must render without throwing.
            values: const [null, 80.0, 82.5, null, 81.0],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(AnimatedLineChart), findsOneWidget);

    // Reduced-motion path renders the same widget statically.
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: scaffold(
          AnimatedLineChart(
            data: ChartData(
              labels: const ['01 Jan', '07 Jan'],
              values: const [80.0, 82.5],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(AnimatedLineChart), findsOneWidget);
  });

  testWidgets('bar chart renders weekly values', (tester) async {
    await tester.pumpWidget(
      scaffold(
        AnimatedBarChart(
          data: ChartData(
            labels: const ['27 Apr', '04 May'],
            values: const [600.0, 630.5, 0.0],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(AnimatedBarChart), findsOneWidget);
  });

  testWidgets('ChartData.isEmpty ignores null gaps but respects positive values',
      (tester) async {
    const allGaps = ChartData(labels: [], values: [null, null, null]);
    expect(allGaps.isEmpty, isTrue);

    const withValues = ChartData(labels: [], values: [null, 1.0, null]);
    expect(withValues.isEmpty, isFalse);

    const zeros = ChartData(labels: [], values: [0.0, 0.0]);
    expect(zeros.isEmpty, isTrue);
  });
}
