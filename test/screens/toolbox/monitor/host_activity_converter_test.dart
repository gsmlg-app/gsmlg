import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/host_activity_converter.dart';
import 'package:monitor_models/monitor_models.dart' as m;

void main() {
  group('HostActivityConverter', () {
    test('systemMetricsToActivitySnapshot converts SystemMetrics accurately', () {
      final metrics = m.SystemMetrics(
        cpu: const m.CpuMetrics(
          usagePercent: 42.5,
          perCore: [40.0, 45.0],
        ),
        memory: const m.MemoryMetrics(
          totalBytes: 16000000000,
          usedBytes: 8000000000,
          swapTotalBytes: 4000000000,
          swapUsedBytes: 1000000000,
        ),
        disks: const [
          m.DiskMetrics(
            device: '/dev/disk1s1',
            readBytesPerSec: 1024,
            writeBytesPerSec: 2048,
            usedBytes: 500000000,
            totalBytes: 1000000000,
          ),
        ],
        networks: const [
          m.NetworkMetrics(
            interface_: 'en0',
            rxBytesPerSec: 5000,
            txBytesPerSec: 3000,
          ),
        ],
        gpus: const [
          m.GpuMetrics(
            index: 0,
            name: 'Apple M1',
            usagePercent: 12.0,
            memoryUsedBytes: 1024,
            memoryTotalBytes: 2048,
          ),
        ],
      );

      final hostInfo = const m.HostInfo(
        hostname: 'test-mac',
        os: 'macOS',
        osVersion: '15.0',
        agentVersion: '0.1.0',
        cpuModel: 'Apple M1 Pro',
        cpuCores: 8,
        totalMemory: 16000000000,
      );

      final snapshot = systemMetricsToActivitySnapshot(metrics, hostInfo);

      expect(snapshot.model, equals('test-mac'));
      expect(snapshot.architecture, equals('macOS'));
      expect(snapshot.cpuBrand, equals('Apple M1 Pro'));
      expect(snapshot.cpuUsage, equals(42.5));
      expect(snapshot.cores.length, equals(2));
      expect(snapshot.cores[0].usage, equals(40.0));
      expect(snapshot.cores[1].usage, equals(45.0));

      expect(snapshot.memory.totalBytes, equals(16000000000));
      expect(snapshot.memory.usedBytes, equals(8000000000));
      expect(snapshot.memory.freeBytes, equals(8000000000));
      expect(snapshot.memory.usage, equals(50.0));

      expect(snapshot.disk.available, isTrue);
      expect(snapshot.disk.devices, contains('/dev/disk1s1'));
      expect(snapshot.disk.readBytes, equals(1024));
      expect(snapshot.disk.writeBytes, equals(2048));

      expect(snapshot.network.available, isTrue);
      expect(snapshot.network.interfaces.length, equals(1));
      expect(snapshot.network.interfaces.first.name, equals('en0'));
      expect(snapshot.network.receivedBytes, equals(5000));
      expect(snapshot.network.sentBytes, equals(3000));

      expect(snapshot.gpus.length, equals(1));
      expect(snapshot.gpus.first.name, equals('Apple M1'));
      expect(snapshot.gpus.first.usage, equals(12.0));
    });

    test('toAppMetricsSnapshot converts monitor_models ActivitySnapshot', () {
      final now = DateTime.now();
      final modelSnapshot = m.ActivitySnapshot(
        timestamp: now,
        architecture: 'arm64',
        model: 'MacBookPro18,1',
        cpuBrand: 'Apple M1 Pro',
        cpuUsage: 15.2,
        cpuUserUsage: 10.0,
        cpuSystemUsage: 5.2,
        cores: const [
          m.ActivityCpuCore(id: 1, type: 'performance', usage: 15.0),
        ],
        memory: const m.ActivityMemory(
          totalBytes: 34359738368,
          usedBytes: 17179869184,
          pressure: 1,
          usage: 50.0,
        ),
        disk: const m.ActivityDisk(
          available: true,
          devices: ['disk0'],
          readBytesPerSecond: 1000.0,
          writeBytesPerSecond: 500.0,
        ),
        network: const m.ActivityNetwork(
          available: true,
          interfaces: [
            m.ActivityNetworkInterface(
              name: 'en0',
              receivedBytesPerSecond: 2000.0,
              sentBytesPerSecond: 1000.0,
            ),
          ],
          receivedBytesPerSecond: 2000.0,
          sentBytesPerSecond: 1000.0,
        ),
        gpus: const [
          m.ActivityGpu(name: 'Apple M1 Pro', usage: 5.0),
        ],
      );

      final converted = toAppMetricsSnapshot(modelSnapshot);

      expect(converted.timestamp, equals(now));
      expect(converted.architecture, equals('arm64'));
      expect(converted.cpuUsage, equals(15.2));
      expect(converted.cores.first.id, equals(1));
      expect(converted.memory.usage, equals(50.0));
      expect(converted.disk.devices, equals(['disk0']));
      expect(converted.network.interfaces.first.name, equals('en0'));
      expect(converted.gpus.first.name, equals('Apple M1 Pro'));
    });
  });
}
