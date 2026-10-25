import 'dart:async';

import 'package:app_locale/app_locale.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:gsmlg/screens/settings/device/activity_monitor_dashboard.dart';
import 'package:gsmlg/screens/settings/device/activity_monitor_screen.dart';
import 'package:gsmlg/screens/settings/settings_routes.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/sparkline_chart.dart';

const _channel = MethodChannel('app_system_metrics');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var requests = 0;
  Future<Object?> Function(MethodCall)? handler;

  setUp(() {
    requests = 0;
    handler = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          expect(call.method, 'getActivityData');
          requests++;
          if (handler != null) return await handler!(call);
          return _sample(requests);
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.windows,
  ]) {
    _activityTestWidgets(
      'unsupported $platform does not call the native plugin',
      (tester) async {
        await _start(tester);
        expect(
          find.textContaining('Linux on x86_64 and ARM64'),
          findsOneWidget,
        );
        expect(requests, 0);
        await _dispose(tester);
      },
      platforms: [platform],
    );
  }

  _activityTestWidgets('Linux samples generic cores and MemAvailable memory', (
    tester,
  ) async {
    handler = (_) async => _linuxSample(requests);
    await _start(tester);
    expect(requests, 1);
    expect(find.text('Core 1'), findsOneWidget);
    expect(find.text('Core 2'), findsOneWidget);
    expect(find.text('1P · 1E'), findsNothing);
    expect(find.text('Waiting for next sample'), findsWidgets);
    final first = tester
        .widget<ActivityMonitorDashboard>(find.byType(ActivityMonitorDashboard))
        .snapshot;
    expect(first.cpuUsage, isNull);
    expect(first.memory.usedBytes, 12000000000);
    expect(first.memory.wiredBytes, isNull);
    expect(first.memory.compressedBytes, isNull);
    expect(first.memory.pressure, isNull);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(requests, 2);
    expect(find.text('20.0%'), findsNWidgets(3));
    expect(find.text('1.0 KiB/s'), findsWidgets);
    await _dispose(tester);
  }, platforms: const [TargetPlatform.linux]);

  _activityTestWidgets('shows honest baseline and then live interval values', (
    tester,
  ) async {
    await _start(tester);
    expect(find.text('Activity Monitor'), findsOneWidget);
    expect(find.text('Performance P1'), findsOneWidget);
    expect(find.text('Efficiency E1'), findsOneWidget);
    expect(find.text('1P · 1E'), findsOneWidget);
    expect(find.text('Waiting for next sample'), findsWidgets);
    expect(find.text('20.0%'), findsNothing);
    expect(requests, 1);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(requests, 2);
    expect(find.text('20.0%'), findsNWidgets(3));
    expect(find.text('1.0 KiB/s'), findsWidgets);
    expect(tester.takeException(), isNull);
    await _dispose(tester);
    await tester.pump(const Duration(seconds: 2));
    expect(requests, 2);
  });

  _activityTestWidgets(
    'native errors stop sampling and Retry starts a fresh baseline',
    (tester) async {
      handler = (_) async => throw PlatformException(code: 'READ_FAILED');
      await _start(tester);
      expect(
        find.text('Could not read device activity. Try again.'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 5));
      expect(requests, 1);
      handler = (_) async => _sample(requests);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump();
      expect(find.byType(ActivityMonitorDashboard), findsOneWidget);
      expect(find.text('Waiting for next sample'), findsWidgets);
      expect(requests, 2);
      await _dispose(tester);
    },
  );

  _activityTestWidgets(
    'all non-resumed states pause and resume with a new baseline',
    (tester) async {
      await _start(tester);
      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.detached,
      ]) {
        final before = requests;
        tester.binding.handleAppLifecycleStateChanged(state);
        await tester.pump(const Duration(seconds: 3));
        expect(requests, before);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();
        await tester.pump();
        expect(requests, before + 1);
        expect(find.text('Waiting for next sample'), findsWidgets);
      }
      await _dispose(tester);
    },
  );

  _activityTestWidgets('covered route pauses and returning restarts sampling', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    await _start(tester, navigator: navigator);
    final before = requests;
    unawaited(
      navigator.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('Cover')),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(requests, before);
    navigator.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(requests, before + 1);
    expect(find.text('Waiting for next sample'), findsWidgets);
    await _dispose(tester);
  });

  _activityTestWidgets(
    'pending sample cannot overlap or overwrite a resumed session',
    (tester) async {
      final errors = <String>[];
      final logs = Logger.root.onRecord.listen((record) {
        if (record.error != null) {
          errors.add('${record.error}\n${record.stackTrace}');
        }
      });
      addTearDown(logs.cancel);
      final pending = Completer<Object?>();
      handler = (_) => pending.future;
      await _start(tester);
      expect(
        find.text('Collecting device activity…'),
        findsOneWidget,
        reason: errors.join('\n'),
      );
      await tester.pump(const Duration(seconds: 3));
      expect(requests, 1, reason: 'a pending request must block timer polling');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(requests, 1, reason: 'resume must wait for the pending request');
      handler = (_) async => _sample(requests + 10);
      pending.complete(_sample(1));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      expect(requests, 2);
      expect(find.text('Waiting for next sample'), findsWidgets);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(find.text('20.0%'), findsNWidgets(3));
      expect(errors, isEmpty);
      await _dispose(tester);
    },
  );

  _activityTestWidgets('pending result after dispose is ignored', (
    tester,
  ) async {
    final pending = Completer<Object?>();
    handler = (_) => pending.future;
    await _start(tester);
    await _dispose(tester);
    pending.complete(_sample(1));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(requests, 1);
    expect(tester.takeException(), isNull);
  });

  _activityTestWidgets('retains at most 60 history samples', (tester) async {
    await _start(tester);
    for (var i = 0; i < 65; i++) {
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
    }
    final dashboard = tester.widget<ActivityMonitorDashboard>(
      find.byType(ActivityMonitorDashboard),
    );
    expect(dashboard.history.length, 60);
    await _dispose(tester);
  });

  _activityTestWidgets('CPU trend stops at unavailable intervals', (
    tester,
  ) async {
    handler = (_) async => _sample(requests == 4 ? 0 : requests);
    await _start(tester);
    for (var i = 0; i < 2; i++) {
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
    }
    Iterable<SparklineChart> cpuCharts() => tester
        .widgetList<SparklineChart>(find.byType(SparklineChart))
        .where((chart) => chart.maxValue == 100 && chart.values.contains(20));
    expect(cpuCharts(), hasLength(1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(cpuCharts(), isEmpty);
    for (var i = 0; i < 2; i++) {
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
    }
    expect(cpuCharts().single.values, hasLength(2));
    await _dispose(tester);
  });

  _activityTestWidgets('settings child route opens Activity Monitor directly', (
    tester,
  ) async {
    final settings = settingsRoutes();
    final activity = settings.routes.whereType<GoRoute>().singleWhere(
      (route) => route.name == ActivityMonitorScreen.name,
    );
    final router = GoRouter(
      initialLocation: '/settings/activity-monitor',
      routes: [
        GoRoute(
          path: settings.path,
          builder: (_, _) => const SizedBox(),
          routes: [activity],
        ),
      ],
    );
    addTearDown(router.dispose);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocale.localizationsDelegates,
        supportedLocales: AppLocale.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byType(ActivityMonitorDashboard), findsOneWidget);
    await _dispose(tester);
  });

  for (final brightness in Brightness.values) {
    for (final width in [390.0, 1280.0]) {
      _activityTestWidgets('fits width $width in $brightness with large text', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(Size(width, 1100));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await _start(tester, brightness: brightness, textScale: 1.5);
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        expect(tester.takeException(), isNull);
        await _dispose(tester);
      });
    }
  }
}

Future<void> _start(
  WidgetTester tester, {
  GlobalKey<NavigatorState>? navigator,
  Brightness brightness = Brightness.light,
  double textScale = 1,
}) async {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigator,
      theme: ThemeData(brightness: brightness),
      localizationsDelegates: AppLocale.localizationsDelegates,
      supportedLocales: AppLocale.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: const ActivityMonitorScreen(),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump();
}

Map<String, Object?> _sample(int tick) => {
  'timestamp_ms': 1700000000000 + tick * 1000,
  'monotonic_ms': tick * 1000,
  'architecture': 'arm64',
  'model': 'MacBookPro18,2',
  'cpu_brand': 'Apple M1 Max',
  'cores': [
    for (var id = 1; id <= 2; id++)
      {
        'id': id,
        'type': id == 1 ? 'performance' : 'efficiency',
        'user': tick * 20,
        'system': 0,
        'nice': 0,
        'idle': tick * 80,
      },
  ],
  'memory': {
    'physical': 32000000000,
    'active': 8000000000,
    'anonymous': 8000000000,
    'purgeable': 0,
    'wired': 1000000000,
    'compressed': 2000000000,
    'swap_used': 0,
    'swap_total': 0,
    'pressure': 1,
  },
  'disk': {
    'available': true,
    'devices': ['disk0'],
    'read_bytes': tick * 1024,
    'write_bytes': tick * 512,
  },
  'network': {
    'available': true,
    'interfaces': [
      {'name': 'en0', 'rx_bytes': tick * 1024, 'tx_bytes': tick * 512},
    ],
  },
  'gpu': [
    {'name': 'Apple M1 Max', 'utilization': null},
  ],
  'processes': 400,
  'threads': 2000,
  'threads_complete': true,
};

Map<String, Object?> _linuxSample(int tick) => {
  ..._sample(tick),
  'architecture': 'x86_64',
  'model': 'Linux workstation',
  'cpu_brand': 'AMD Ryzen',
  'cores': [
    for (final core in _sample(tick)['cores']! as List)
      {...core as Map<String, Object?>, 'type': null},
  ],
  'memory': {
    'physical': 32000000000,
    'available': 20000000000,
    'free': 1000000000,
    'active': 8000000000,
    'inactive': 12000000000,
    'swap_used': 0,
    'swap_total': 0,
  },
  'gpu': <Object?>[],
};

void _activityTestWidgets(
  String description,
  WidgetTesterCallback callback, {
  List<TargetPlatform> platforms = const [
    TargetPlatform.macOS,
    TargetPlatform.linux,
  ],
}) {
  for (final platform in platforms) {
    testWidgets('$description on ${platform.name}', (tester) async {
      final original = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = platform;
      try {
        await callback(tester);
      } finally {
        await _dispose(tester);
        debugDefaultTargetPlatformOverride = original;
      }
    });
  }
}
