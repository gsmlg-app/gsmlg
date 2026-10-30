import 'dart:io';

import 'package:monitor_agent/src/collectors/raw_collector.dart';

class WindowsRawCollector implements RawCollector {
  @override
  Future<Map<String, dynamic>> collectRaw() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final arch = Platform.version.contains('arm64') ? 'arm64' : 'x86_64';
    final cpuBrand = Platform.environment['PROCESSOR_IDENTIFIER'] ?? 'Windows Processor';
    final coreCount = Platform.numberOfProcessors;

    final cores = <Map<String, dynamic>>[];
    for (var i = 0; i < coreCount; i++) {
      cores.add({
        'id': i + 1,
        'type': null,
        'user': 0,
        'system': 0,
        'nice': 0,
        'idle': 100,
      });
    }

    return {
      'timestamp_ms': now,
      'monotonic_ms': now,
      'architecture': arch,
      'model': 'Windows PC',
      'cpu_brand': cpuBrand,
      'cores': cores,
      'memory': {
        'physical': 16 * 1024 * 1024 * 1024,
      },
      'disk': {
        'available': false,
        'devices': <String>[],
      },
      'network': {
        'available': false,
        'interfaces': <Map<String, dynamic>>[],
      },
      'gpu': <Map<String, dynamic>>[],
    };
  }
}
