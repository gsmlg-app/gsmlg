import 'package:app_system_metrics/app_system_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _raw(int step) => {
      'timestamp_ms': 1000 + step * 2000,
      'monotonic_ms': 1000 + step * 2000,
      'cores': [
        {
          'id': 1,
          'user': 100 + step * 50,
          'nice': step * 10,
          'system': 50 + step * 20,
          'idle': 100 + step * 20
        },
        {
          'id': 2,
          'user': 100 + step * 10,
          'nice': 0,
          'system': 50 + step * 10,
          'idle': 100 + step * 80
        },
      ],
      'memory': {
        'physical': 10000,
        'anonymous': 3000,
        'purgeable': 200,
        'file_backed': 2000,
        'wired': 1000,
        'compressed': 500
      },
      'network': {
        'available': true,
        'interfaces': [
          {
            'name': 'en0',
            'rx_bytes': 1000 + step * 100,
            'tx_bytes': 2000 + step * 200,
            'rx_packets': 100 + step * 30,
            'tx_packets': 200 + step * 20
          },
        ],
      },
    };

void main() {
  test('CPU user and system percentages share the same weighted denominator',
      () {
    final sample = ActivitySnapshot.fromSamples(_raw(1), previous: _raw(0));
    expect(sample.cpuUsage, 50);
    expect(sample.cpuUserUsage, 35);
    expect(sample.cpuSystemUsage, 15);
    expect(sample.cores[0].userUsage, 60);
    expect(sample.cores[0].systemUsage, 20);
    expect(sample.cores[1].userUsage, 10);
    expect(sample.cores[1].systemUsage, 10);
  });

  test('first samples and reset ticks do not fabricate a CPU breakdown', () {
    for (final sample in [
      ActivitySnapshot.fromSamples(_raw(0)),
      ActivitySnapshot.fromSamples(_raw(0), previous: _raw(1)),
    ]) {
      expect(sample.cpuUserUsage, isNull);
      expect(sample.cpuSystemUsage, isNull);
      expect(sample.cores.map((c) => c.userUsage), everyElement(isNull));
      expect(sample.cores.map((c) => c.systemUsage), everyElement(isNull));
    }
  });

  test('macOS application and cached memory retain their native definitions',
      () {
    final sample = ActivitySnapshot.fromSamples(_raw(0));
    expect(sample.memory.appBytes, 2800);
    expect(sample.memory.cachedBytes, 2200);
    final linux = _raw(0)..['memory'] = {'physical': 10000, 'available': 4000};
    final memory = ActivitySnapshot.fromSamples(linux).memory;
    expect(memory.usedBytes, 6000);
    expect(memory.appBytes, isNull);
    expect(memory.cachedBytes, isNull);
  });

  test('network packets use monotonic intervals and preserve cumulative counts',
      () {
    final sample = ActivitySnapshot.fromSamples(_raw(1), previous: _raw(0));
    expect(sample.network.receivedPackets, 130);
    expect(sample.network.sentPackets, 220);
    expect(sample.network.receivedPacketsPerSecond, 15);
    expect(sample.network.sentPacketsPerSecond, 10);
    expect(sample.network.interfaces.single.receivedPacketsPerSecond, 15);
    expect(sample.network.interfaces.single.sentPacketsPerSecond, 10);
    final first = ActivitySnapshot.fromSamples(_raw(0));
    expect(first.network.receivedPacketsPerSecond, isNull);
  });

  test('missing and reset packet counters remain unavailable', () {
    final raw = _raw(1);
    final interface = (raw['network'] as Map)['interfaces'][0] as Map;
    interface.remove('rx_packets');
    interface['tx_packets'] = 1;
    final network =
        ActivitySnapshot.fromSamples(raw, previous: _raw(0)).network;
    expect(network.receivedPackets, isNull);
    expect(network.receivedPacketsPerSecond, isNull);
    expect(network.sentPacketsPerSecond, isNull);
  });
}
