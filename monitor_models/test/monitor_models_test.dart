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
      const mem = MemoryMetrics(
        usedBytes: 8589934592,
        totalBytes: 17179869184,
      );
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
        memory: MemoryMetrics(
          usedBytes: 8589934592,
          totalBytes: 17179869184,
        ),
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
      final decoded =
          MonitorMessage.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
      expect(decoded.type, MonitorMessageType.metrics);
      expect(decoded.systemMetrics.cpu?.usagePercent, 50.0);
    });

    test('ping/pong messages', () {
      const ping =
          MonitorMessage(type: MonitorMessageType.ping, payload: {});
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
}
