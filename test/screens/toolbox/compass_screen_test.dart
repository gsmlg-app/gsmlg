import 'dart:async';
import 'dart:math' as math;

import 'package:app_compass/app_compass.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/toolbox/compass/compass_dial.dart';
import 'package:gsmlg/screens/toolbox/compass/compass_screen.dart';

void main() {
  test('platform support is restricted to native Android and iOS', () {
    for (final platform in TargetPlatform.values) {
      expect(
        isCompassPlatformSupported(isWeb: true, platform: platform),
        isFalse,
      );
      expect(
        isCompassPlatformSupported(isWeb: false, platform: platform),
        platform == TargetPlatform.android || platform == TargetPlatform.iOS,
      );
    }
  });

  _compassTestWidgets(
    'waits without inventing a north reading, then shows actual heading',
    (tester) async {
      final source = _Source();
      await _start(tester, source);
      expect(find.text('—'), findsOneWidget);
      expect(find.text('Waiting for compass readings…'), findsOneWidget);
      expect(source.listens, 1);
      source.emit(_ready(128));
      await tester.pump();
      expect(find.text('128° · Southeast'), findsOneWidget);
      expect(find.text('Magnetic north'), findsOneWidget);
      expect(find.text('Waiting for compass readings…'), findsNothing);
      expect(_angle(tester), closeTo(-128 * math.pi / 180, 0.00001));
      final semantics = tester.widget<Semantics>(
        find
            .ancestor(
              of: find.text('128° · Southeast'),
              matching: find.byType(Semantics),
            )
            .first,
      );
      expect(semantics.properties.label, '128° · Southeast');
      expect(semantics.properties.liveRegion, isNot(true));
      await _dispose(tester);
      expect(source.active, 0);
    },
  );

  _compassTestWidgets(
    'calibration preserves only a valid estimate and warning',
    (tester) async {
      final source = _Source();
      await _start(tester, source);
      for (final heading in <double?>[null, double.nan, -1, 360]) {
        source.emit(
          CompassReading(
            status: CompassStatus.calibrating,
            magneticHeadingDegrees: heading,
          ),
        );
        await tester.pump();
        expect(find.text('—'), findsOneWidget);
        expect(find.text('Calibration recommended'), findsOneWidget);
      }
      source.emit(
        const CompassReading(
          status: CompassStatus.calibrating,
          magneticHeadingDegrees: 88,
        ),
      );
      await tester.pump();
      expect(find.text('88° · East'), findsOneWidget);
      expect(find.text('Calibration recommended'), findsOneWidget);
      await _dispose(tester);
    },
  );

  _compassTestWidgets(
    'missing hardware ends waiting without offering failure retry',
    (tester) async {
      final source = _Source();
      await _start(tester, source);
      source.emit(
        const CompassReading(
          status: CompassStatus.unavailable,
          unavailableReason: CompassUnavailableReason.sensorNotFound,
        ),
      );
      await tester.pump();
      expect(
        find.text('This device does not have the required compass sensors.'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsNothing);
      await tester.pump(const Duration(seconds: 6));
      expect(find.text('Unable to read the compass. Try again.'), findsNothing);
      await _dispose(tester);
    },
  );

  for (final failure in ['stream', 'native', 'invalid', 'done', 'refresh']) {
    _compassTestWidgets(
      '$failure failure stops and retry starts exactly one listener',
      (tester) async {
        final source = _Source();
        if (failure == 'refresh') {
          source.refreshError = StateError('private native detail');
        }
        await _start(tester, source);
        switch (failure) {
          case 'stream':
            source.latest.error(StateError('private native detail'));
          case 'native':
            source.emit(
              const CompassReading(
                status: CompassStatus.unavailable,
                unavailableReason: CompassUnavailableReason.sensorFailure,
              ),
            );
          case 'invalid':
            source.emit(_ready(double.infinity));
          case 'done':
            source.latest.done();
          case 'refresh':
            break;
        }
        await tester.pump();
        await tester.pump();
        expect(
          find.text('Unable to read the compass. Try again.'),
          findsOneWidget,
        );
        expect(find.textContaining('private native detail'), findsNothing);
        expect(source.active, 0);
        source.refreshError = null;
        await tester.ensureVisible(find.text('Retry'));
        await tester.pump();
        await tester.tap(find.text('Retry'));
        await tester.pump();
        await tester.pump();
        expect(source.active, 1);
        expect(source.maxActive, 1);
        expect(find.text('—'), findsOneWidget);
        source.emit(_ready(359.6));
        await tester.pump();
        expect(find.text('0° · North'), findsOneWidget);
        await _dispose(tester);
      },
    );
  }

  _compassTestWidgets(
    'five second first-event timeout is retryable sensor failure',
    (tester) async {
      final source = _Source();
      await _start(tester, source);
      await tester.pump(const Duration(milliseconds: 4999));
      expect(find.text('Unable to read the compass. Try again.'), findsNothing);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      expect(
        find.text('Unable to read the compass. Try again.'),
        findsOneWidget,
      );
      expect(source.active, 0);
      await _dispose(tester);
    },
  );

  _compassTestWidgets('synchronous first event cancels timeout', (
    tester,
  ) async {
    final source = _Source()..synchronousReading = _ready(42);
    await _start(tester, source);
    expect(find.text('42° · Northeast'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
    expect(find.text('Retry'), findsNothing);
    await _dispose(tester);
  });

  _compassTestWidgets(
    'all non-resumed lifecycle states stop and resume refreshes',
    (tester) async {
      final source = _Source();
      await _start(tester, source);
      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.detached,
      ]) {
        source.emit(_ready(90));
        await tester.pump();
        tester.binding.handleAppLifecycleStateChanged(state);
        source.latest.data(
          _ready(180),
        ); // Even a callback before cancel completes is stale.
        await tester.pump();
        expect(source.active, 0);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();
        await tester.pump();
        expect(source.active, 1);
        expect(find.text('—'), findsOneWidget);
        expect(source.maxActive, 1);
      }
      expect(source.refreshes, 5);
      await _dispose(tester);
    },
  );

  _compassTestWidgets('maintained covered route cancels and pop resumes once', (
    tester,
  ) async {
    final source = _Source();
    final nav = GlobalKey<NavigatorState>();
    await _start(tester, source, navigatorKey: nav);
    final old = source.latest;
    nav.currentState!.push(
      MaterialPageRoute<void>(
        maintainState: true,
        builder: (_) => const Scaffold(body: Text('Cover')),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(CompassScreen, skipOffstage: false), findsOneWidget);
    expect(source.active, 0);
    old.data(_ready(222));
    nav.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(source.active, 1);
    expect(source.listens, 2);
    expect(find.text('—'), findsOneWidget);
    expect(source.maxActive, 1);
    await _dispose(tester);
  });

  _compassTestWidgets(
    'help pauses readings and explains calibration without resetting',
    (tester) async {
      final source = _Source();
      await _start(tester, source);
      await tester.tap(find.byTooltip('Using and calibrating the compass'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(source.active, 0);
      expect(find.textContaining('figure-eight'), findsOneWidget);
      expect(
        find.textContaining('metal and magnetic accessories'),
        findsOneWidget,
      );
      await tester.tap(find.text('Close'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(source.active, 1);
      expect(source.listens, 2);
      await _dispose(tester);
    },
  );

  _compassTestWidgets(
    'rapid lifecycle changes await cancellation and ignore old callbacks',
    (tester) async {
      final source = _Source();
      await _start(tester, source);
      final old = source.latest;
      source.cancelGate = Completer<void>();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(source.listens, 1);
      old.data(_ready(270));
      expect(find.text('270° · West'), findsNothing);
      source.cancelGate!.complete();
      await tester.pump();
      await tester.pump();
      expect(source.listens, 2);
      expect(source.maxActive, 1);
      source.cancelGate = null;
      await _dispose(tester);
      old.data(_ready(12));
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  _compassTestWidgets(
    'a delayed refresh cannot start while covered or disposed',
    (tester) async {
      final source = _Source()..refreshGate = Completer<void>();
      await _start(tester, source);
      expect(source.listens, 0);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      source.refreshGate!.complete();
      await tester.pump();
      expect(source.listens, 0);
      source.refreshGate = Completer<void>();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await _dispose(tester);
      source.refreshGate!.complete();
      await tester.pump();
      expect(source.listens, 0);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      expect(tester.takeException(), isNull);
    },
  );

  _compassTestWidgets(
    'orientation changes clear heading and obtain a new reference',
    (tester) async {
      final source = _Source();
      await _start(tester, source);
      source.emit(_ready(90));
      await tester.pump();
      tester.binding.handleMetricsChanged();
      await tester.pump();
      await tester.pump();
      expect(source.refreshes, 2);
      expect(source.active, 1);
      expect(find.text('—'), findsOneWidget);
      source.emit(_ready(180));
      await tester.pump();
      expect(find.text('180° · South'), findsOneWidget);
      await _dispose(tester);
    },
  );

  for (final platform in [
    TargetPlatform.macOS,
    TargetPlatform.linux,
    TargetPlatform.windows,
  ]) {
    _compassTestWidgets('$platform direct access makes zero source calls', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = platform;
      final source = _Source();
      await _start(tester, source);
      expect(
        find.text('Compass is available on Android and iOS.'),
        findsOneWidget,
      );
      expect(source.refreshes, 0);
      expect(source.listens, 0);
      await _dispose(tester);
    });
  }

  _compassTestWidgets(
    'north crossing animates one degree and retargets current position',
    (tester) async {
      final source = _Source();
      await _start(tester, source);
      source.emit(_ready(359));
      await tester.pump();
      expect(_angle(tester), closeTo(-359 * math.pi / 180, 0.00001));
      source.emit(_ready(0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 90));
      expect(_angle(tester), closeTo(-359.5 * math.pi / 180, 0.00001));
      source.emit(_ready(1));
      await tester.pump();
      expect(_angle(tester), closeTo(-359.5 * math.pi / 180, 0.00001));
      await tester.pump(const Duration(milliseconds: 180));
      expect(_angle(tester), closeTo(-361 * math.pi / 180, 0.00001));
      await _dispose(tester);
    },
  );

  _compassTestWidgets('reduced motion directly positions every reading', (
    tester,
  ) async {
    final source = _Source();
    await _start(tester, source, disableAnimations: true);
    source.emit(_ready(359));
    await tester.pump();
    source.emit(_ready(0));
    await tester.pump();
    expect(_angle(tester), 0);
    await _dispose(tester);
  });

  for (final brightness in Brightness.values) {
    for (final size in [const Size(320, 700), const Size(700, 320)]) {
      _compassTestWidgets(
        '$brightness $size supports large font without overflow',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final source = _Source();
          await _start(tester, source, brightness: brightness, textScale: 2);
          source.emit(_ready(128));
          await tester.pump();
          expect(tester.takeException(), isNull);
          expect(
            tester.getSize(find.byType(CompassDial)).width,
            lessThanOrEqualTo(360),
          );
          await _dispose(tester);
        },
      );
    }
  }
}

void _compassTestWidgets(String description, WidgetTesterCallback callback) {
  testWidgets(description, (tester) async {
    final originalPlatform = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      await callback(tester);
    } finally {
      debugDefaultTargetPlatformOverride = originalPlatform;
    }
  });
}

CompassReading _ready(double heading) => CompassReading(
  status: CompassStatus.ready,
  magneticHeadingDegrees: heading,
);

Future<void> _start(
  WidgetTester tester,
  _Source source, {
  GlobalKey<NavigatorState>? navigatorKey,
  bool disableAnimations = false,
  Brightness brightness = Brightness.light,
  double textScale = 1,
}) async {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      localizationsDelegates: AppLocale.localizationsDelegates,
      supportedLocales: AppLocale.supportedLocales,
      theme: ThemeData(brightness: brightness),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: disableAnimations,
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: CompassScreen(source: source),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump();
}

double _angle(WidgetTester tester) {
  final rotation = tester.widget<RotationTransition>(
    find
        .descendant(
          of: find.byType(CompassDial),
          matching: find.byType(RotationTransition),
        )
        .first,
  );
  return rotation.turns.value * 2 * math.pi;
}

class _Source implements CompassSource {
  int listens = 0;
  int cancels = 0;
  int active = 0;
  int maxActive = 0;
  int refreshes = 0;
  Object? refreshError;
  Completer<void>? refreshGate;
  Completer<void>? cancelGate;
  CompassReading? synchronousReading;
  final subscriptions = <_Subscription>[];
  _Subscription get latest => subscriptions.last;

  @override
  Stream<CompassReading> get readings => _Readings(this);

  @override
  Future<void> refreshOrientation() async {
    refreshes++;
    await refreshGate?.future;
    if (refreshError != null) throw refreshError!;
  }

  void emit(CompassReading reading) => latest.data(reading);
}

class _Readings extends Stream<CompassReading> {
  _Readings(this.source);
  final _Source source;

  @override
  StreamSubscription<CompassReading> listen(
    void Function(CompassReading)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    source.listens++;
    source.active++;
    source.maxActive = math.max(source.maxActive, source.active);
    final subscription = _Subscription(source, onData, onError, onDone);
    source.subscriptions.add(subscription);
    if (source.synchronousReading != null) {
      subscription.data(source.synchronousReading!);
    }
    return subscription;
  }
}

class _Subscription implements StreamSubscription<CompassReading> {
  _Subscription(this.source, this._onData, this._onError, this._onDone);
  final _Source source;
  void Function(CompassReading)? _onData;
  Function? _onError;
  void Function()? _onDone;
  bool _cancelled = false;
  void data(CompassReading reading) => _onData?.call(reading);
  void error(Object error) =>
      Function.apply(_onError!, [error, StackTrace.current]);
  void done() => _onDone?.call();

  @override
  Future<void> cancel() async {
    if (_cancelled) return;
    _cancelled = true;
    source.cancels++;
    await source.cancelGate?.future;
    source.active--;
  }

  @override
  void onData(void Function(CompassReading)? handleData) =>
      _onData = handleData;
  @override
  void onError(Function? handleError) => _onError = handleError;
  @override
  void onDone(void Function()? handleDone) => _onDone = handleDone;
  @override
  bool get isPaused => false;
  @override
  void pause([Future<void>? resumeSignal]) {}
  @override
  void resume() {}
  @override
  Future<E> asFuture<E>([E? futureValue]) => throw UnimplementedError();
}
