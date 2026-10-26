import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/sparkline_chart.dart';

void main() {
  const histories = {
    'uneven rising values': <double>[0, 1, 100],
    'uneven falling values': <double>[100, 99, 0],
    'a changing device workload': <double>[0, 1, 100, 99, 0, 0, 50, 51, 99],
  };

  for (final entry in histories.entries) {
    testWidgets('paints ${entry.key} without overflowing the stack', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                child: SparklineChart(
                  values: entry.value,
                  maxValue: 100,
                  color: ThemeData().colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SparklineChart), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
