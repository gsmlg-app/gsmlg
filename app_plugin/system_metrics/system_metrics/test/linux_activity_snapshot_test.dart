import 'package:app_system_metrics/app_system_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

const _gib = 1024 * 1024 * 1024;

void main() {
  for (final architecture in ['x86_64', 'arm64']) {
    test('Linux $architecture starts with generic cores and nullable rates',
        () {
      final current = ActivitySnapshot.fromSamples(_sample(0, architecture));
      expect(current.architecture, architecture);
      expect(current.cores.map((core) => core.id), [1, 2]);
      expect(current.cores.map((core) => core.type), everyElement(isNull));
      expect(current.cores.map((core) => core.usage), everyElement(isNull));
      expect(current.cpuUsage, isNull);
      expect(current.disk.readBytesPerSecond, isNull);
      expect(current.network.receivedBytesPerSecond, isNull);
      expect(current.memory.usedBytes, 6 * _gib);
      expect(current.memory.usage, 37.5);
      expect(current.memory.freeBytes, 2 * _gib);
      expect(current.memory.swapUsedBytes, _gib ~/ 2);
      expect(current.memory.wiredBytes, isNull);
      expect(current.memory.compressedBytes, isNull);
      expect(current.memory.purgeableBytes, isNull);
      expect(current.memory.pressure, isNull);
      expect(current.gpus, isEmpty);
    });

    test('Linux $architecture calculates intervals and rejects counter resets',
        () {
      final previous = _sample(0, architecture);
      final raw = _sample(1, architecture);
      final current = ActivitySnapshot.fromSamples(raw, previous: previous);
      expect(current.cpuUsage, 30);
      expect(current.cores.map((core) => core.usage), everyElement(30));
      expect(current.disk.readBytesPerSecond, 4096);
      expect(current.disk.writeBytesPerSecond, 2048);
      expect(current.network.receivedBytesPerSecond, 8192);
      expect(current.network.sentBytesPerSecond, 1024);

      final reset = _sample(2, architecture);
      (reset['cores'] as List).first['user'] = 0;
      (reset['disk'] as Map)['read_bytes'] = 0;
      ((reset['network'] as Map)['interfaces'] as List).first['rx_bytes'] = 0;
      final unavailable = ActivitySnapshot.fromSamples(reset, previous: raw);
      expect(unavailable.cpuUsage, isNull);
      expect(unavailable.cores.first.usage, isNull);
      expect(unavailable.disk.readBytesPerSecond, isNull);
      expect(unavailable.network.receivedBytesPerSecond, isNull);
      expect(unavailable.memory.usedBytes, 6 * _gib);
    });
  }

  test('Linux MemAvailable boundaries retain real zero and reject invalid data',
      () {
    for (final available in [0, 16 * _gib]) {
      final raw = _sample(0, 'x86_64');
      (raw['memory'] as Map)['available'] = available;
      final current = ActivitySnapshot.fromSamples(raw);
      expect(current.memory.usedBytes, 16 * _gib - available);
      expect(current.memory.usage, available == 0 ? 100 : 0);
    }
    for (final available in [null, -1, 17 * _gib]) {
      final raw = _sample(0, 'x86_64');
      (raw['memory'] as Map)['available'] = available;
      final current = ActivitySnapshot.fromSamples(raw);
      expect(current.memory.usedBytes, isNull, reason: '$available');
      expect(current.memory.usage, isNull, reason: '$available');
    }
  });

  test(
      'Linux missing MemAvailable or invalid physical memory stays unavailable',
      () {
    final missing = _sample(0, 'arm64');
    (missing['memory'] as Map).remove('available');
    expect(ActivitySnapshot.fromSamples(missing).memory.usedBytes, isNull);
    for (final physical in [null, -1, 0]) {
      final raw = _sample(0, 'arm64');
      (raw['memory'] as Map)['physical'] = physical;
      final current = ActivitySnapshot.fromSamples(raw);
      expect(current.memory.usedBytes, isNull);
      expect(current.memory.usage, isNull);
    }
  });
}

Map<String, dynamic> _sample(int tick, String architecture) => {
      'timestamp_ms': 1792886400000 + tick * 1000,
      'monotonic_ms': 1000 + tick * 1000,
      'architecture': architecture,
      'model': 'Linux workstation',
      'cpu_brand': architecture == 'x86_64' ? 'AMD Ryzen' : 'ARMv8 Processor',
      'cores': [
        for (var id = 1; id <= 2; id++)
          {
            'id': id,
            'type': null,
            'user': 100 + tick * 20,
            'system': 30 + tick * 10,
            'nice': 0,
            'idle': 870 + tick * 70,
          },
      ],
      'processes': 400,
      'threads': 1000,
      'threads_complete': false,
      'processes_readable': 399,
      'memory': <String, dynamic>{
        'physical': 16 * _gib,
        'available': 10 * _gib,
        'free': 2 * _gib,
        'active': 5 * _gib,
        'inactive': 6 * _gib,
        'swap_used': _gib ~/ 2,
        'swap_total': 2 * _gib,
      },
      'disk': {
        'available': true,
        'devices': ['nvme0n1'],
        'read_bytes': 5000000000 + tick * 4096,
        'write_bytes': 4000000000 + tick * 2048,
        'read_ops': 1000 + tick,
        'write_ops': 2000 + tick,
      },
      'network': {
        'available': true,
        'interfaces': [
          {
            'name': 'enp1s0',
            'rx_bytes': 10000000000 + tick * 8192,
            'tx_bytes': 5000000000 + tick * 1024,
            'rx_packets': 1000 + tick,
            'tx_packets': 500 + tick,
          },
        ],
      },
      'gpu': [],
    };
