import 'dart:async';
import 'dart:convert';

import 'package:app_system_metrics/app_system_metrics.dart';
import 'package:app_system_metrics_platform_interface/app_system_metrics_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> sample({int time = 1000, int tick = 0}) => {
      'timestamp_ms': 1792886400000 + time,
      'monotonic_ms': time,
      'architecture': 'arm64',
      'model': 'MacBookPro18,2',
      'cpu_brand': 'Apple M1 Max',
      'cores': [
        {
          'id': 1,
          'type': 'efficiency',
          'user': 100 + tick,
          'system': 50,
          'nice': 0,
          'idle': 850 + tick
        },
        {
          'id': 2,
          'type': 'performance',
          'user': 200 + tick,
          'system': 50,
          'nice': 0,
          'idle': 750 + tick * 3
        },
      ],
      'processes': 300,
      'threads': 1000,
      'threads_complete': false,
      'processes_readable': 200,
      'memory': {
        'physical': 10000,
        'free': 1000,
        'active': 4000,
        'anonymous': 3000,
        'file_backed': 2000,
        'inactive': 2000,
        'wired': 1000,
        'compressed': 500,
        'purgeable': 200,
        'swap_used': 300,
        'swap_total': 1000,
        'pressure': 1
      },
      'disk': {
        'available': true,
        'devices': ['disk0'],
        'read_bytes': 1000 + tick * 20,
        'write_bytes': 2000 + tick * 10,
        'read_ops': 100 + tick,
        'write_ops': 200 + tick
      },
      'network': {
        'available': true,
        'interfaces': [
          {
            'name': 'en0',
            'rx_bytes': 10000000000 + tick * 30,
            'tx_bytes': 5000000000 + tick * 5,
            'rx_packets': 100,
            'tx_packets': 100
          },
        ]
      },
      'gpu': [
        {'name': 'Apple M1 Max', 'utilization': null}
      ],
    };

Map<String, dynamic> copy(Map<String, dynamic> raw) =>
    jsonDecode(jsonEncode(raw)) as Map<String, dynamic>;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('first sample has metadata and memory, but no interval measurements',
      () {
    final current = ActivitySnapshot.fromSamples(sample());
    expect(current.architecture, 'arm64');
    expect(current.cpuUsage, isNull);
    expect(current.cores.map((core) => core.usage), everyElement(isNull));
    expect(
        current.cores.map((core) => core.type), ['efficiency', 'performance']);
    expect(current.memory.usedBytes, 4300);
    expect(current.memory.usage, closeTo(43, 0.000001));
    expect(current.memory.swapUsedBytes, 300);
    expect(current.disk.readBytesPerSecond, isNull);
    expect(current.network.receivedBytes, 10000000000);
    expect(current.network.receivedBytesPerSecond, isNull);
    expect(current.gpus.single.usage, isNull);
    expect(current.threadCountComplete, isFalse);
    expect(current.readableProcessCount, 200);
  });

  test('used memory excludes file cache and clamps purgeable anonymous memory',
      () {
    final raw = sample();
    final memory = raw['memory'] as Map;
    memory['active'] = 9000;
    memory['file_backed'] = 8000;
    final current = ActivitySnapshot.fromSamples(raw);
    expect(current.memory.activeBytes, 9000);
    expect(current.memory.usedBytes, 4300);
    memory['purgeable'] = 4000;
    expect(ActivitySnapshot.fromSamples(raw).memory.usedBytes, 1500);
  });

  test('used memory is unavailable if any required term is missing', () {
    for (final term in ['anonymous', 'purgeable', 'wired', 'compressed']) {
      final raw = sample();
      (raw['memory'] as Map).remove(term);
      final current = ActivitySnapshot.fromSamples(raw);
      expect(current.memory.usedBytes, isNull, reason: term);
      expect(current.memory.usage, isNull, reason: term);
    }
    final raw = sample();
    (raw['memory'] as Map).remove('active');
    expect(ActivitySnapshot.fromSamples(raw).memory.usedBytes, 4300);
  });

  test('uses weighted CPU deltas and monotonic seconds for 64-bit I/O rates',
      () {
    final previous = sample();
    final raw = sample(time: 3000, tick: 100);
    // Wall-clock adjustment must not affect rates.
    raw['timestamp_ms'] = 1000;
    final current = ActivitySnapshot.fromSamples(raw, previous: previous);
    expect(current.cores[0].usage, 50);
    expect(current.cores[1].usage, 25);
    expect(current.cpuUsage, closeTo(100 / 3, 0.000001));
    expect(current.disk.readBytesPerSecond, 1000);
    expect(current.disk.writeBytesPerSecond, 500);
    expect(current.disk.readOperationsPerSecond, 50);
    expect(current.network.receivedBytesPerSecond, 1500);
    expect(current.network.sentBytesPerSecond, 250);
  });

  test('rejects non-advancing monotonic time and recovers at the next baseline',
      () {
    for (final time in [0, 1000]) {
      final current = ActivitySnapshot.fromSamples(
          sample(time: time, tick: 100),
          previous: sample());
      expect(current.cpuUsage, isNull);
      expect(current.disk.readBytesPerSecond, isNull);
      expect(current.network.receivedBytesPerSecond, isNull);
    }
  });

  test('CPU topology changes and duplicate IDs invalidate all CPU percentages',
      () {
    for (final ids in [
      [1],
      [1, 1],
      [1, 3]
    ]) {
      final raw = sample(time: 2000, tick: 100);
      raw['cores'] = [
        for (final id in ids) {...(raw['cores'] as List).first as Map, 'id': id}
      ];
      final current = ActivitySnapshot.fromSamples(raw, previous: sample());
      expect(current.cpuUsage, isNull);
      expect(current.cores.map((core) => core.usage), everyElement(isNull));
    }
  });

  test('CPU and I/O counter resets remain unavailable instead of becoming zero',
      () {
    final raw = sample(time: 2000, tick: 100);
    (raw['cores'] as List).first['user'] = 0;
    (raw['disk'] as Map)['read_bytes'] = 0;
    ((raw['network'] as Map)['interfaces'] as List).first['rx_bytes'] = 0;
    final current = ActivitySnapshot.fromSamples(raw, previous: sample());
    expect(current.cpuUsage, isNull);
    expect(current.cores.first.usage, isNull);
    expect(current.cores.last.usage, 25);
    expect(current.disk.readBytesPerSecond, isNull);
    expect(current.network.receivedBytesPerSecond, isNull);
    expect(current.network.sentBytesPerSecond, 500);
  });

  test('disk set changes establish a new baseline rather than creating a spike',
      () {
    final raw = sample(time: 2000, tick: 100);
    (raw['disk'] as Map)['devices'] = ['disk0', 'disk2'];
    final current = ActivitySnapshot.fromSamples(raw, previous: sample());
    expect(current.disk.readBytesPerSecond, isNull);
    expect(current.disk.readBytes, 3000);
  });

  test('network hotplug rates include only interfaces shared with the baseline',
      () {
    final raw = sample(time: 2000, tick: 100);
    ((raw['network'] as Map)['interfaces'] as List).add({
      'name': 'en7',
      'rx_bytes': 999999999999,
      'tx_bytes': 999999999999,
    });
    final current = ActivitySnapshot.fromSamples(raw, previous: sample());
    expect(current.network.receivedBytesPerSecond, 3000);
    expect(current.network.interfaces.last.receivedBytesPerSecond, isNull);
    final disconnected = copy(raw);
    ((disconnected['network'] as Map)['interfaces'] as List).removeAt(0);
    final noShared =
        ActivitySnapshot.fromSamples(disconnected, previous: sample());
    expect(noShared.network.receivedBytesPerSecond, isNull);
  });

  test(
      'unavailable or malformed measurements stay null and unknown cores generic',
      () {
    final raw = sample(time: 2000, tick: 100);
    raw['memory'] = {'physical': 0, 'pressure': 42};
    raw['disk'] = {'available': false, 'read_bytes': 0};
    raw['network'] = {'available': false, 'interfaces': []};
    raw['gpu'] = [
      {'name': 'GPU', 'utilization': -1},
      {'name': 'GPU 2', 'utilization': 101}
    ];
    (raw['cores'] as List).first['type'] = 'guessed';
    final current = ActivitySnapshot.fromSamples(raw, previous: sample());
    expect(current.memory.usedBytes, isNull);
    expect(current.memory.usage, isNull);
    expect(current.memory.pressure, isNull);
    expect(current.disk.readBytes, isNull);
    expect(current.network.receivedBytes, isNull);
    expect(current.network.receivedBytesPerSecond, isNull);
    expect(current.gpus.map((gpu) => gpu.usage), everyElement(isNull));
    expect(current.cores.first.type, isNull);
    expect(() => ActivitySnapshot.fromSamples({}), throwsFormatException);
  });

  group('ActivityMonitor sessions', () {
    late SystemMetricsPlatform original;
    late _FakePlatform platform;

    setUp(() {
      original = SystemMetricsPlatform.instance;
      platform = _FakePlatform();
      SystemMetricsPlatform.instance = platform;
    });
    tearDown(() => SystemMetricsPlatform.instance = original);

    test(
        'sessions keep independent baselines and reset clears interval history',
        () async {
      final first = ActivityMonitor();
      final second = ActivityMonitor();
      platform.next = sample();
      expect((await first.sample()).cpuUsage, isNull);
      platform.next = sample(time: 2000, tick: 100);
      expect((await first.sample()).cpuUsage, isNotNull);
      expect((await second.sample()).cpuUsage, isNull);
      first.reset();
      platform.next = sample(time: 3000, tick: 200);
      expect((await first.sample()).cpuUsage, isNull);
      expect((await second.sample()).cpuUsage, isNotNull);
    });

    test(
        'overlapping requests share sampling and reset rejects an in-flight baseline',
        () async {
      final monitor = ActivityMonitor();
      final completer = Completer<Map<String, dynamic>>();
      platform.pending = completer.future;
      final first = monitor.sample();
      final second = monitor.sample();
      expect(identical(first, second), isTrue);
      expect(platform.calls, 1);
      monitor.reset();
      completer.complete(sample());
      expect((await first).cpuUsage, isNull);
      platform.pending = null;
      platform.next = sample(time: 2000, tick: 100);
      expect((await monitor.sample()).cpuUsage, isNull);
      platform.next = sample(time: 3000, tick: 200);
      expect((await monitor.sample()).cpuUsage, isNotNull);
    });

    test('sampling errors propagate and a later sample can recover', () async {
      final monitor = ActivityMonitor();
      platform.pending = Future.error(PlatformException(code: 'UNAVAILABLE'));
      await expectLater(monitor.sample(), throwsA(isA<PlatformException>()));
      platform.pending = null;
      platform.next = sample();
      expect((await monitor.sample()).cpuUsage, isNull);
    });
  });
}

class _FakePlatform extends SystemMetricsPlatform {
  Map<String, dynamic> next = sample();
  Future<Map<String, dynamic>>? pending;
  int calls = 0;

  @override
  Future<Map<String, dynamic>> getActivityData() {
    calls++;
    return pending ?? Future.value(next);
  }
}
