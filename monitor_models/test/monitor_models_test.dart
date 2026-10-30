import 'dart:convert';

import 'package:monitor_models/monitor_models.dart';
import 'package:test/test.dart';

void main() {
  group('HostInfo', () {
    test('serialization round-trip', () {
      const info = HostInfo(
        hostname: 'workstation',
        os: 'linux',
        osVersion: '6.1.0',
        cpuModel: 'Intel i7-12700K',
        cpuCores: 12,
        totalMemory: 34359738368,
        agentVersion: '1.0.0',
        gpus: [
          GpuInfo(index: 0, name: 'RTX 3080', memoryTotalBytes: 10737418240),
        ],
      );

      final json = info.toJson();
      final decoded = HostInfo.fromJson(json);
      expect(decoded, equals(info));

      // Also test JSON string round-trip
      final jsonStr = jsonEncode(json);
      final fromStr = HostInfo.fromJson(jsonDecode(jsonStr));
      expect(fromStr, equals(info));
    });

    test('empty gpus list', () {
      const info = HostInfo(
        hostname: 'server',
        os: 'linux',
        osVersion: '5.15.0',
        cpuModel: 'Xeon E5',
        cpuCores: 8,
        totalMemory: 17179869184,
        agentVersion: '1.0.0',
      );

      final json = info.toJson();
      final decoded = HostInfo.fromJson(json);
      expect(decoded.gpus, isEmpty);
    });
  });

  group('CpuMetrics', () {
    test('serialization round-trip', () {
      const cpu = CpuMetrics(
        usagePercent: 45.5,
        perCore: [30.0, 60.0, 40.0, 50.0],
        loadAvg: [1.5, 2.0, 1.8],
      );

      final json = cpu.toJson();
      final decoded = CpuMetrics.fromJson(json);
      expect(decoded, equals(cpu));
    });
  });

  group('MemoryMetrics', () {
    test('serialization round-trip', () {
      const mem = MemoryMetrics(
        usedBytes: 8589934592,
        totalBytes: 17179869184,
        swapUsedBytes: 1073741824,
        swapTotalBytes: 4294967296,
      );

      final json = mem.toJson();
      final decoded = MemoryMetrics.fromJson(json);
      expect(decoded, equals(mem));
    });

    test('usage percent calculation', () {
      const mem = MemoryMetrics(usedBytes: 8589934592, totalBytes: 17179869184);
      expect(mem.usagePercent, closeTo(50.0, 0.01));
    });
  });

  group('GpuMetrics', () {
    test('serialization round-trip', () {
      const gpu = GpuMetrics(
        index: 0,
        name: 'RTX 3080',
        usagePercent: 75.0,
        memoryUsedBytes: 5368709120,
        memoryTotalBytes: 10737418240,
        temperatureCelsius: 72.0,
      );

      final json = gpu.toJson();
      final decoded = GpuMetrics.fromJson(json);
      expect(decoded, equals(gpu));
    });

    test('null temperature', () {
      const gpu = GpuMetrics(
        index: 0,
        name: 'Intel UHD',
        usagePercent: 10.0,
        memoryUsedBytes: 0,
        memoryTotalBytes: 0,
      );

      final json = gpu.toJson();
      expect(json.containsKey(Protocol.temperatureCelsius), isFalse);

      final decoded = GpuMetrics.fromJson(json);
      expect(decoded.temperatureCelsius, isNull);
    });
  });

  group('NetworkMetrics', () {
    test('serialization round-trip', () {
      const net = NetworkMetrics(
        interface_: 'eth0',
        txBytesPerSec: 1048576,
        rxBytesPerSec: 2097152,
      );

      final json = net.toJson();
      final decoded = NetworkMetrics.fromJson(json);
      expect(decoded, equals(net));
    });
  });

  group('DiskMetrics', () {
    test('serialization round-trip', () {
      const disk = DiskMetrics(
        device: 'sda',
        readBytesPerSec: 524288,
        writeBytesPerSec: 262144,
        usedBytes: 107374182400,
        totalBytes: 500107862016,
      );

      final json = disk.toJson();
      final decoded = DiskMetrics.fromJson(json);
      expect(decoded, equals(disk));
    });
  });

  group('SystemMetrics', () {
    test('serialization round-trip', () {
      const metrics = SystemMetrics(
        cpu: CpuMetrics(usagePercent: 45.5, perCore: [30.0, 60.0]),
        memory: MemoryMetrics(usedBytes: 8589934592, totalBytes: 17179869184),
        gpus: [
          GpuMetrics(
            index: 0,
            name: 'RTX 3080',
            usagePercent: 75.0,
            memoryUsedBytes: 5368709120,
            memoryTotalBytes: 10737418240,
          ),
        ],
        networks: [
          NetworkMetrics(
            interface_: 'eth0',
            txBytesPerSec: 1048576,
            rxBytesPerSec: 2097152,
          ),
        ],
        disks: [
          DiskMetrics(
            device: 'sda',
            readBytesPerSec: 524288,
            writeBytesPerSec: 262144,
            usedBytes: 107374182400,
            totalBytes: 500107862016,
          ),
        ],
      );

      final json = metrics.toJson();
      final decoded = SystemMetrics.fromJson(json);
      expect(decoded, equals(metrics));
    });
  });

  group('MonitorMessage', () {
    test('host_info message round-trip', () {
      const hostInfo = HostInfo(
        hostname: 'test',
        os: 'linux',
        osVersion: '6.1.0',
        cpuModel: 'i7',
        cpuCores: 8,
        totalMemory: 17179869184,
        agentVersion: '1.0.0',
      );

      final msg = MonitorMessage(
        type: MonitorMessageType.hostInfo,
        payload: hostInfo.toJson(),
      );

      final json = msg.toJson();
      final decoded = MonitorMessage.fromJson(json);
      expect(decoded.type, MonitorMessageType.hostInfo);
      expect(decoded.hostInfo, equals(hostInfo));
    });

    test('metrics message round-trip', () {
      const metrics = SystemMetrics(
        cpu: CpuMetrics(usagePercent: 50.0),
        memory: MemoryMetrics(usedBytes: 4294967296, totalBytes: 8589934592),
      );

      final msg = MonitorMessage(
        type: MonitorMessageType.metrics,
        payload: metrics.toJson(),
      );

      final json = msg.toJson();
      final jsonStr = jsonEncode(json);
      final decoded = MonitorMessage.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );
      expect(decoded.type, MonitorMessageType.metrics);
      expect(decoded.systemMetrics.cpu?.usagePercent, 50.0);
    });

    test('ping/pong messages', () {
      const ping = MonitorMessage(type: MonitorMessageType.ping, payload: {});
      final json = ping.toJson();
      final decoded = MonitorMessage.fromJson(json);
      expect(decoded.type, MonitorMessageType.ping);
    });

    test('MonitorMessageType fromString', () {
      expect(
        MonitorMessageType.fromString('host_info'),
        MonitorMessageType.hostInfo,
      );
      expect(
        MonitorMessageType.fromString('metrics'),
        MonitorMessageType.metrics,
      );
      expect(
        () => MonitorMessageType.fromString('unknown'),
        throwsArgumentError,
      );
    });
  });

  group('ActivitySnapshot', () {
    test('serialization round-trip and delta calculation', () {
      final sample1 = <String, dynamic>{
        'timestamp_ms': 1700000000000,
        'monotonic_ms': 1000,
        'architecture': 'arm64',
        'model': 'MacBookPro18,2',
        'cpu_brand': 'Apple M1 Max',
        'cores': [
          {'id': 1, 'type': 'efficiency', 'user': 100, 'system': 50, 'nice': 0, 'idle': 850},
          {'id': 2, 'type': 'performance', 'user': 200, 'system': 50, 'nice': 0, 'idle': 750},
        ],
        'memory': {
          'physical': 16000000000,
          'free': 2000000000,
          'available': 10000000000,
          'active': 4000000000,
          'anonymous': 3000000000,
          'purgeable': 500000000,
          'wired': 1500000000,
          'compressed': 500000000,
          'pressure': 1,
        },
        'disk': {
          'available': true,
          'devices': ['disk0'],
          'read_bytes': 1000,
          'write_bytes': 2000,
          'read_ops': 10,
          'write_ops': 20,
        },
        'network': {
          'available': true,
          'interfaces': [
            {'name': 'en0', 'rx_bytes': 50000, 'tx_bytes': 25000, 'rx_packets': 50, 'tx_packets': 25},
          ],
        },
        'gpu': [
          {'name': 'Apple M1 Max', 'utilization': 15.0},
        ],
        'processes': 250,
        'threads': 800,
      };

      final sample2 = <String, dynamic>{
        'timestamp_ms': 1700000001000,
        'monotonic_ms': 2000,
        'architecture': 'arm64',
        'model': 'MacBookPro18,2',
        'cpu_brand': 'Apple M1 Max',
        'cores': [
          {'id': 1, 'type': 'efficiency', 'user': 120, 'system': 60, 'nice': 0, 'idle': 920},
          {'id': 2, 'type': 'performance', 'user': 250, 'system': 70, 'nice': 0, 'idle': 780},
        ],
        'memory': {
          'physical': 16000000000,
          'free': 1900000000,
          'available': 9900000000,
          'active': 4100000000,
          'anonymous': 3100000000,
          'purgeable': 500000000,
          'wired': 1500000000,
          'compressed': 500000000,
          'pressure': 1,
        },
        'disk': {
          'available': true,
          'devices': ['disk0'],
          'read_bytes': 3000,
          'write_bytes': 4000,
          'read_ops': 15,
          'write_ops': 30,
        },
        'network': {
          'available': true,
          'interfaces': [
            {'name': 'en0', 'rx_bytes': 60000, 'tx_bytes': 30000, 'rx_packets': 60, 'tx_packets': 30},
          ],
        },
        'gpu': [
          {'name': 'Apple M1 Max', 'utilization': 25.0},
        ],
        'processes': 252,
        'threads': 810,
      };

      final snapshot = ActivitySnapshot.fromSamples(sample2, previous: sample1);
      expect(snapshot.architecture, 'arm64');
      expect(snapshot.model, 'MacBookPro18,2');
      expect(snapshot.cpuUsage, isNotNull);
      expect(snapshot.cores.length, 2);
      expect(snapshot.cores[0].type, 'efficiency');
      expect(snapshot.cores[1].type, 'performance');
      expect(snapshot.disk.readBytesPerSecond, 2000.0);
      expect(snapshot.network.receivedBytesPerSecond, 10000.0);
      expect(snapshot.gpus.first.usage, 25.0);

      final json = snapshot.toJson();
      final decoded = ActivitySnapshot.fromJson(json);

      expect(decoded.architecture, snapshot.architecture);
      expect(decoded.model, snapshot.model);
      expect(decoded.cpuBrand, snapshot.cpuBrand);
      expect(decoded.cpuUsage, snapshot.cpuUsage);
      expect(decoded.cores.length, snapshot.cores.length);
      expect(decoded.cores[0].id, snapshot.cores[0].id);
      expect(decoded.cores[0].type, snapshot.cores[0].type);
      expect(decoded.cores[0].usage, snapshot.cores[0].usage);
      expect(decoded.disk.readBytesPerSecond, snapshot.disk.readBytesPerSecond);
      expect(decoded.network.receivedBytesPerSecond, snapshot.network.receivedBytesPerSecond);
      expect(decoded.gpus.first.name, snapshot.gpus.first.name);
      expect(decoded.gpus.first.usage, snapshot.gpus.first.usage);
      expect(decoded.processCount, snapshot.processCount);

      // Verify MonitorMessage integration
      final msg = MonitorMessage(
        type: MonitorMessageType.metrics,
        payload: snapshot.toJson(),
      );
      final msgDecoded = MonitorMessage.fromJson(msg.toJson());
      expect(msgDecoded.activitySnapshot.model, 'MacBookPro18,2');
    });
  });
}
