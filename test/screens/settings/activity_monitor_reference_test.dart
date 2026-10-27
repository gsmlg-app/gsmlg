import 'package:app_locale/app_locale.dart';
import 'package:app_system_metrics/app_system_metrics.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart' show DmButton, DmThemeData;
import 'package:duskmoon_visualization/duskmoon_visualization_compat.dart'
    hide Curve;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/settings/device/activity_monitor_charts.dart';
import 'package:gsmlg/screens/settings/device/activity_monitor_dashboard.dart';

void main() {
  testWidgets('core histories follow native IDs when enumeration changes', (
    tester,
  ) async {
    await _show(tester);
    final chart = tester.widget<ActivityHistoryChart>(
      find.descendant(
        of: find.byKey(const ValueKey('core-history-1')),
        matching: find.byType(ActivityHistoryChart),
      ),
    );
    expect(chart.values, [10, 20, 30]);
    expect(chart.secondaryValues, [4, 8, 12]);
    expect(chart.maxValue, 100);
    expect(find.byType(ActivityCoreMeter), findsNWidgets(2));
    expect(find.text('Efficiency E1'), findsOneWidget);
    expect(find.text('Performance P2'), findsOneWidget);
  });

  testWidgets('disk operations and network packets switch the plotted rates', (
    tester,
  ) async {
    await _show(tester);
    ActivityHistoryChart chart(String key) =>
        tester.widget(find.byKey(ValueKey(key)));
    expect(chart('disk-history').values, [1024, 2048, 3072]);
    expect(chart('network-history').values, [2048, 4096, 6144]);
    await tester.ensureVisible(find.text('Operations'));
    await tester.tap(find.widgetWithText(DmButton, 'Operations'));
    await tester.pump();
    expect(chart('disk-history').values, [10, 20, 30]);
    expect(chart('disk-history').secondaryValues, [5, 10, 15]);
    await tester.ensureVisible(find.text('Packets'));
    await tester.tap(find.widgetWithText(DmButton, 'Packets'));
    await tester.pump();
    expect(chart('network-history').values, [30, 60, 90]);
    expect(chart('network-history').secondaryValues, [20, 40, 60]);
    expect(chart('network-history').mirrored, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a mirrored chart keeps receive above and send below zero', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocale.localizationsDelegates,
        supportedLocales: AppLocale.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: ActivityHistoryChart(
                values: const [0, 100, 1],
                secondaryValues: const [100, 0, 99],
                mirrored: true,
                height: 120,
                color: ThemeData().colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
    final areas = tester.widgetList<AreaPath>(find.byType(AreaPath)).toList();
    expect(areas, hasLength(2));
    expect(areas[0].points.every((p) => p.y <= 60), isTrue);
    expect(areas[1].points.every((p) => p.y >= 60), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('memory pressure changes only at sampled categorical levels', (
    tester,
  ) async {
    await _show(tester);
    final finder = find.byKey(const ValueKey('memory-pressure-history'));
    await tester.ensureVisible(finder);
    await tester.pump();
    final chart = tester.widget<ActivityHistoryChart>(finder);
    expect(chart.values, [1, 2, 3]);
    expect(chart.maxValue, 3);
    final line = tester.widget<LinePath>(
      find.descendant(of: finder, matching: find.byType(LinePath)),
    );
    final points = line.curve!.generate(line.points);
    for (var i = 1; i < points.length; i++) {
      expect(
        points[i].x == points[i - 1].x || points[i].y == points[i - 1].y,
        isTrue,
        reason: 'Categorical pressure must change as a step, never a slope.',
      );
    }
    expect(tester.takeException(), isNull);
  });

  for (final width in [390.0, 1440.0]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'reference panels fit $width with $brightness and large text',
        (tester) async {
          tester.view.physicalSize = Size(width, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await _show(tester, brightness: brightness, scale: 1.8);
          for (final key in [
            'cpu-total-history',
            'gpu-panel',
            'disk-history',
            'network-history',
          ]) {
            await tester.ensureVisible(find.byKey(ValueKey(key)));
            await tester.pump();
            expect(tester.takeException(), isNull);
          }
          await tester.ensureVisible(
            find.text('Data sources and measurement notes'),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final brightness in Brightness.values) {
    testWidgets(
      'all ten-core panels fit fullscreen on macOS with $brightness',
      (tester) async {
        tester.view.physicalSize = const Size(1635, 799);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await _show(tester, brightness: brightness, fullscreen: true);

        final scroll = tester.state<ScrollableState>(find.byType(Scrollable));
        expect(
          scroll.position.maxScrollExtent,
          lessThanOrEqualTo(1),
          reason: [
            for (final key in [
              'cpu-history-panel',
              'core-load-panel',
              'gpu-panel',
              'memory-panel',
              'cpu-panel',
              'disk-panel',
              'network-panel',
              'activity-notes',
            ])
              '$key: ${tester.getRect(find.byKey(ValueKey(key)))}',
          ].join('\n'),
        );
        expect(find.byType(ActivityCoreMeter), findsNWidgets(10));
        for (var id = 0; id < 10; id++) {
          expect(
            tester.getRect(find.byKey(ValueKey('core-history-$id'))).bottom,
            lessThanOrEqualTo(799),
          );
        }
        for (final key in [
          'gpu-panel',
          'cpu-total-history',
          'memory-pressure-history',
          'disk-history',
          'network-history',
        ]) {
          expect(
            tester.getRect(find.byKey(ValueKey(key))).bottom,
            lessThanOrEqualTo(799),
          );
        }
        final l10n = tester.element(find.byType(ActivityMonitorDashboard)).l10n;
        expect(
          find.text(l10n.activityMonitorDataNotes).hitTestable(),
          findsOneWidget,
        );
        expect(
          find.text(l10n.activityMonitorMemoryNotes).hitTestable(),
          findsOneWidget,
        );
        expect(find.text('Pause').hitTestable(), findsOneWidget);
        await tester.tap(find.widgetWithText(DmButton, 'Operations'));
        await tester.pump();
        expect(
          tester
              .widget<ActivityHistoryChart>(
                find.byKey(const ValueKey('disk-history')),
              )
              .values,
          [10, 20, 30],
        );
        await tester.tap(find.widgetWithText(DmButton, 'Packets'));
        await tester.pump();
        expect(
          tester
              .widget<ActivityHistoryChart>(
                find.byKey(const ValueKey('network-history')),
              )
              .values,
          [30, 60, 90],
        );
        expect(scroll.position.maxScrollExtent, lessThanOrEqualTo(1));
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Future<void> _show(
  WidgetTester tester, {
  Brightness brightness = Brightness.dark,
  double scale = 1,
  bool fullscreen = false,
}) async {
  final history = [
    for (var i = 1; i <= 3; i++) _sample(i, tenCores: fullscreen),
  ];
  await tester.pumpWidget(
    MaterialApp(
      theme: fullscreen
          ? (brightness == Brightness.dark
                    ? DmThemeData.moonlight()
                    : DmThemeData.sunshine())
                .copyWith(platform: TargetPlatform.macOS)
          : ThemeData(brightness: brightness),
      localizationsDelegates: AppLocale.localizationsDelegates,
      supportedLocales: AppLocale.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(
        appBar: fullscreen
            ? AppBar(title: const Text('Activity Monitor'))
            : null,
        body: SingleChildScrollView(
          child: ActivityMonitorDashboard(
            snapshot: history.last,
            history: history,
            running: true,
            onToggleSampling: fullscreen ? () {} : null,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

ActivitySnapshot _sample(int index, {bool tenCores = false}) =>
    ActivitySnapshot(
      timestamp: DateTime.utc(2026, 10, 27, 0, 0, index),
      architecture: 'arm64',
      model: 'MacBookPro18,4',
      cpuBrand: 'Apple M1 Max',
      cpuUsage: index * 10,
      cpuUserUsage: index * 6,
      cpuSystemUsage: index * 4,
      cores: [
        for (final id
            in tenCores
                ? List.generate(10, (i) => i)
                : index == 2
                ? [2, 1]
                : [1, 2])
          ActivityCpuCore(
            id: id,
            type: id == 1 ? 'efficiency' : 'performance',
            usage: index * 10,
            userUsage: index * 6,
            systemUsage: index * 4,
          ),
      ],
      memory: ActivityMemory(
        totalBytes: 34359738368,
        usedBytes: 17179869184,
        appBytes: 8589934592,
        cachedBytes: 4294967296,
        pressure: switch (index) {
          1 => 1,
          2 => 2,
          _ => 4,
        },
        wiredBytes: 4294967296,
        compressedBytes: 4294967296,
      ),
      disk: ActivityDisk(
        available: true,
        devices: const ['disk0'],
        readBytesPerSecond: index * 1024,
        writeBytesPerSecond: index * 512,
        readOperationsPerSecond: index * 10,
        writeOperationsPerSecond: index * 5,
      ),
      network: ActivityNetwork(
        available: true,
        receivedBytesPerSecond: index * 2048,
        sentBytesPerSecond: index * 1024,
        receivedPacketsPerSecond: index * 30,
        sentPacketsPerSecond: index * 20,
      ),
      gpus: [ActivityGpu(name: 'Apple M1 Max', usage: index * 20)],
      processCount: 1000,
      threadCount: 6000,
    );
