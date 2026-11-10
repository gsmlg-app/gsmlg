import 'dart:isolate';

import 'package:app_duckdb/app_duckdb.dart';
import 'package:app_logging/app_logging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/core/app_isolates.dart';
import 'package:logging/logging.dart' as logging;

UsageEvent _usage(String screen) => UsageEvent(
  ts: DateTime.now(),
  sessionId: 's1',
  eventType: 'screen_view',
  screenName: screen,
);

/// Polls [condition] until it holds or [timeout] passes.
Future<void> _until(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) fail('condition not met');
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

void main() {
  group('AppIsolates with a running logstore', () {
    late AppIsolates isolates;

    setUp(() async {
      isolates = await AppIsolates.start(dbPath: ':memory:');
    });

    tearDown(() => isolates.stop());

    test('routes LogCapture and Logger.root records into the store', () async {
      expect(LogCapture.instance.apiActive, isTrue);
      LogCapture.instance.usage(_usage('/home'));
      logging.Logger('WiringTest').warning('root record');

      await isolates.flush();

      expect(await isolates.logStore.countLogs(tableOrView: 'usage_events'), 1);
      final system = await isolates.logStore.queryLogs(
        tableOrView: 'system_logs',
        filter: const LogFilter(keyword: 'root record'),
      );
      expect(system, hasLength(1));
      expect(system.single.loggerName, 'WiringTest');
    });

    test('records written after a logstore restart are persisted', () async {
      final before = isolates.forwarder.ingestPort;
      expect(before, isNotNull);

      await isolates.hub.restartNode('logstore');
      await _until(
        () =>
            isolates.forwarder.ingestPort != null &&
            isolates.forwarder.ingestPort != before,
      );

      LogCapture.instance.usage(_usage('/after-restart'));
      logging.Logger('WiringTest').warning('after restart');
      await isolates.flush();

      expect(await isolates.logStore.countLogs(tableOrView: 'usage_events'), 1);
      expect(
        await isolates.logStore.countLogs(
          tableOrView: 'system_logs',
          filter: const LogFilter(keyword: 'after restart'),
        ),
        1,
      );
    });

    test('stop detaches the sink and the root forwarder', () async {
      await isolates.stop();
      expect(LogCapture.instance.apiActive, isFalse);
      // Producers keep working after the hub is gone.
      LogCapture.instance.usage(_usage('/gone'));
      logging.Logger('WiringTest').warning('after stop');
    });
  });

  test('a failing logstore leaves no sink and does not throw', () async {
    // An empty dbPath makes the logstore worker's onInit fail.
    final isolates = await AppIsolates.start(dbPath: '');
    addTearDown(isolates.stop);

    expect(LogCapture.instance.apiActive, isFalse);
    expect(isolates.forwarder.ingestPort, isNull);
    LogCapture.instance.usage(_usage('/x'));
    logging.Logger('WiringTest').warning('no store');
    await expectLater(
      isolates.logStore.countLogs(tableOrView: 'usage_events'),
      throwsA(anything),
    );
  });

  test('forwarding to a closed port never throws', () async {
    final port = ReceivePort()..close();
    final forwarder = LogStoreForwarder(() async => port.sendPort);
    addTearDown(forwarder.close);
    await forwarder.connect();
    expect(forwarder.ingestPort, port.sendPort);

    forwarder.writeUsage(_usage('/closed'));
    forwarder.writeRoot(
      logging.LogRecord(logging.Level.INFO, 'closed', 'WiringTest'),
    );
    PortLogSink(port.sendPort).writeUsage(_usage('/closed'));
  });
}
