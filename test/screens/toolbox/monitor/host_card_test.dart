import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/host_card.dart';
import 'package:monitor_bloc/monitor_bloc.dart';

void main() {
  group('HostCard', () {
    testWidgets('renders online host with CPU, memory and network metrics', (
      tester,
    ) async {
      final host = MonitorHost(
        id: 'host-1',
        ip: '192.168.1.50',
        port: 4665,
        status: ConnectionStatus.connected,
        label: 'Primary Server',
        hostInfo: const HostInfo(
          hostname: 'srv-primary',
          os: 'Linux',
          osVersion: '6.8',
          agentVersion: '0.1.0',
          cpuModel: 'AMD EPYC',
          cpuCores: 16,
          totalMemory: 64000000000,
        ),
        metrics: const SystemMetrics(
          cpu: CpuMetrics(usagePercent: 35.0),
          memory: MemoryMetrics(
            totalBytes: 64000000000,
            usedBytes: 16000000000,
          ),
          networks: [
            NetworkMetrics(
              interface_: 'eth0',
              rxBytesPerSec: 1048576,
              txBytesPerSec: 524288,
            ),
          ],
        ),
      );

      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HostCard(
              host: host,
              onTap: () => tapped = true,
              onRemove: () {},
            ),
          ),
        ),
      );

      expect(find.text('Primary Server'), findsOneWidget);
      expect(find.text('192.168.1.50:4665'), findsOneWidget);
      expect(find.text(' • Linux'), findsOneWidget);
      expect(find.text('Online'), findsOneWidget);
      expect(find.text('CPU'), findsOneWidget);
      expect(find.text('35.0%'), findsOneWidget);
      expect(find.text('Memory'), findsOneWidget);
      expect(find.text('↓ 1.00 MB/s  ↑ 512.0 KB/s'), findsOneWidget);

      await tester.tap(find.byType(HostCard));
      expect(tapped, isTrue);
    });

    testWidgets('renders disconnected host with connect button', (
      tester,
    ) async {
      final host = MonitorHost(
        id: 'host-2',
        ip: '192.168.1.51',
        port: 4665,
        status: ConnectionStatus.disconnected,
        label: 'Backup Server',
      );

      var connectTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HostCard(
              host: host,
              onTap: () {},
              onRemove: () {},
              onConnect: () => connectTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Backup Server'), findsOneWidget);
      expect(find.text('Offline'), findsOneWidget);
      expect(find.text('Host offline. Tap to connect.'), findsOneWidget);

      await tester.tap(find.text('Connect'));
      expect(connectTapped, isTrue);
    });
  });
}
