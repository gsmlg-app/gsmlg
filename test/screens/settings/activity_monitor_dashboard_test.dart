import 'package:app_locale/app_locale.dart';
import 'package:app_system_metrics/app_system_metrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/settings/device/activity_monitor_dashboard.dart';
import 'package:gsmlg/screens/settings/device/activity_monitor_charts.dart';

void main() {
  testWidgets('GPU utilization has an independent percentage history', (
    tester,
  ) async {
    await _show(tester, [
      _sample([('Apple M1 Max', 0)]),
      _sample([('Apple M1 Max', 25)]),
      _sample([('Apple M1 Max', 50)]),
    ]);

    final chart = _gpuCharts(tester).single;
    expect(chart.values, [0, 25, 50]);
    expect(chart.maxValue, 100);
    expect(find.text('50.0%'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('GPU histories follow names when devices are reordered', (
    tester,
  ) async {
    await _show(tester, [
      _sample([('Intel GPU', 10), ('AMD GPU', 80)]),
      _sample([('AMD GPU', 70), ('Intel GPU', 20)]),
    ]);

    final charts = _gpuCharts(tester).toList();
    expect(charts, hasLength(2));
    expect(charts[0].values, [80, 70]);
    expect(charts[1].values, [10, 20]);
  });

  for (final gap in [
    <(String, double?)>[('Apple M1 Max', null)],
    <(String, double?)>[],
    <(String, double?)>[('Apple M1 Max', 40), ('Apple M1 Max', 70)],
  ]) {
    testWidgets('GPU history restarts after missing or ambiguous data: $gap', (
      tester,
    ) async {
      await _show(tester, [
        _sample([('Apple M1 Max', 20)]),
        _sample(gap),
        _sample([('Apple M1 Max', 30)]),
        _sample([('Apple M1 Max', 40)]),
      ]);

      expect(_gpuCharts(tester).single.values, [30, 40]);
    });
  }

  testWidgets('GPU history waits for two consecutive available readings', (
    tester,
  ) async {
    await _show(tester, [
      _sample([('Apple M1 Max', null)]),
      _sample([('Apple M1 Max', 0)]),
    ]);

    expect(_gpuCharts(tester), isEmpty);
    expect(find.text('0.0%'), findsOneWidget);
  });

  testWidgets('unavailable current GPU usage does not show stale history', (
    tester,
  ) async {
    await _show(tester, [
      _sample([('Apple M1 Max', 10)]),
      _sample([('Apple M1 Max', 20)]),
      _sample([('Apple M1 Max', null)]),
    ]);

    expect(_gpuCharts(tester), isEmpty);
    expect(find.text('Apple M1 Max'), findsOneWidget);
  });

  testWidgets('duplicate GPU names do not combine unrelated histories', (
    tester,
  ) async {
    await _show(tester, [
      _sample([('AMD GPU', 20), ('AMD GPU', 50)]),
      _sample([('AMD GPU', 30), ('AMD GPU', 60)]),
    ]);

    expect(_gpuCharts(tester), isEmpty);
    expect(find.text('30.0%'), findsOneWidget);
    expect(find.text('60.0%'), findsOneWidget);
  });
}

Iterable<ActivityHistoryChart> _gpuCharts(WidgetTester tester) => tester
    .widgetList<ActivityHistoryChart>(
      find.descendant(
        of: find.byKey(const ValueKey('gpu-panel')),
        matching: find.byType(ActivityHistoryChart),
      ),
    )
    .where((chart) => chart.values.length >= 2);

Future<void> _show(WidgetTester tester, List<ActivitySnapshot> history) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocale.localizationsDelegates,
      supportedLocales: AppLocale.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: ActivityMonitorDashboard(
            snapshot: history.last,
            history: history,
            running: true,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.ensureVisible(find.byKey(const ValueKey('gpu-panel')));
  await tester.pump();
}

ActivitySnapshot _sample(List<(String, double?)> gpus) => ActivitySnapshot(
  timestamp: DateTime.utc(2026, 10, 27),
  architecture: 'arm64',
  model: 'MacBookPro18,2',
  cpuBrand: 'Apple CPU',
  cpuUsage: null,
  cores: const [],
  memory: const ActivityMemory(),
  disk: const ActivityDisk(),
  network: const ActivityNetwork(),
  gpus: [
    for (final (name, usage) in gpus) ActivityGpu(name: name, usage: usage),
  ],
);
