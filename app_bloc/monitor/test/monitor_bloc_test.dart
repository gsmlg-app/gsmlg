import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:monitor_bloc/monitor_bloc.dart';
import 'package:monitor_models/monitor_models.dart';

void main() {
  group('MonitorBloc', () {
    late _FakeMonitorRepository repository;
    late MonitorBloc bloc;

    setUp(() {
      repository = _FakeMonitorRepository();
      bloc = MonitorBloc(
        repository: repository,
        trustStore: InMemoryTrustStore(),
      );
    });

    tearDown(() async {
      await bloc.close();
      await repository.close();
    });

    test('marks host error instead of throwing on malformed metrics', () async {
      final uncaughtErrors = <Object>[];

      await runZonedGuarded(
        () async {
          bloc.add(const MonitorAddManualHost(ip: '192.0.2.10', port: 9723));
          await _waitForHost(bloc, _hostId);

          repository.add(
            const MonitorConnectionStatusChanged(ConnectionStatus.connected),
          );
          repository.add(
            const MonitorMessageReceived(
              MonitorMessage(
                type: MonitorMessageType.metrics,
                payload: {
                  Protocol.cpu: {Protocol.usagePercent: 'not-a-number'},
                },
              ),
            ),
          );

          final host = await _waitForHost(
            bloc,
            _hostId,
            status: ConnectionStatus.error,
          );

          expect(host.metrics, isNull);
        },
        (error, _) {
          uncaughtErrors.add(error);
        },
      );

      expect(uncaughtErrors, isEmpty);
    });

    test('disconnects all active hosts when requested', () async {
      bloc.add(const MonitorAddManualHost(ip: '192.0.2.10', port: 9723));
      bloc.add(const MonitorAddManualHost(ip: '192.0.2.11', port: 9723));
      await _waitForHost(bloc, '192.0.2.10:9723');
      await _waitForHost(bloc, '192.0.2.11:9723');

      bloc.add(const MonitorDisconnectAllHosts());

      await _waitUntil(() => repository.disconnectAllCallCount == 1);

      final state = bloc.state as MonitorLoaded;
      expect(
        state.hosts.values.map((host) => host.status),
        everyElement(ConnectionStatus.disconnected),
      );
    });

    test('disconnecting a host clears its retained metrics snapshot', () async {
      bloc.add(const MonitorAddManualHost(ip: '192.0.2.10', port: 9723));
      await _waitForHost(bloc, _hostId);

      repository.add(
        const MonitorMessageReceived(
          MonitorMessage(
            type: MonitorMessageType.metrics,
            payload: {
              Protocol.cpu: {Protocol.usagePercent: 42},
            },
          ),
        ),
      );
      var host = await _waitForHostWithMetrics(bloc, _hostId);
      expect(host.metrics, isNotNull);

      bloc.add(const MonitorDisconnectHost(hostId: _hostId));
      await _waitUntil(() => repository.disconnectedHostIds.contains(_hostId));
      host = (bloc.state as MonitorLoaded).hosts[_hostId]!;

      expect(host.metrics, isNull);
    });

    test('receiving ActivitySnapshot updates snapshot and history', () async {
      bloc.add(const MonitorAddManualHost(ip: '192.0.2.10', port: 9723));
      await _waitForHost(bloc, _hostId);

      final snapshot = ActivitySnapshot(
        timestamp: DateTime.now(),
        architecture: 'arm64',
        model: 'MacBookPro',
        cpuBrand: 'Apple M1',
        cpuUsage: 15.5,
        cores: const [
          ActivityCpuCore(id: 1, type: 'performance', usage: 20.0),
        ],
        memory: const ActivityMemory(
          totalBytes: 16000000000,
          usedBytes: 8000000000,
          usage: 50.0,
        ),
        disk: const ActivityDisk(),
        network: const ActivityNetwork(),
        gpus: const [],
      );

      repository.add(
        MonitorMessageReceived(
          MonitorMessage(
            type: MonitorMessageType.metrics,
            payload: snapshot.toJson(),
          ),
        ),
      );

      await _waitUntil(() {
        final state = bloc.state;
        return state is MonitorLoaded && state.hosts[_hostId]?.snapshot != null;
      });

      final host = (bloc.state as MonitorLoaded).hosts[_hostId]!;
      expect(host.snapshot?.model, 'MacBookPro');
      expect(host.snapshot?.cpuUsage, 15.5);
      expect(host.history.length, 1);
      expect(host.cpuHistory.items, [15.5]);
    });

    test('receiving history and metricsDelta updates host state', () async {
      bloc.add(const MonitorAddManualHost(ip: '192.0.2.10', port: 9723));
      await _waitForHost(bloc, _hostId);

      final snapshot1 = ActivitySnapshot(
        timestamp: DateTime.now().subtract(const Duration(seconds: 1)),
        architecture: 'arm64',
        model: 'MacBookPro',
        cpuBrand: 'Apple M1',
        cpuUsage: 10.0,
        cores: const [
          ActivityCpuCore(id: 1, type: 'performance', usage: 10.0),
        ],
        memory: const ActivityMemory(totalBytes: 16000000000, usage: 40.0),
        disk: const ActivityDisk(),
        network: const ActivityNetwork(),
        gpus: const [],
      );

      final snapshot2 = ActivitySnapshot(
        timestamp: DateTime.now(),
        architecture: 'arm64',
        model: 'MacBookPro',
        cpuBrand: 'Apple M1',
        cpuUsage: 20.0,
        cores: const [
          ActivityCpuCore(id: 1, type: 'performance', usage: 20.0),
        ],
        memory: const ActivityMemory(totalBytes: 16000000000, usage: 42.0),
        disk: const ActivityDisk(),
        network: const ActivityNetwork(),
        gpus: const [],
      );

      // 1. Receive history with 2 snapshots
      repository.add(
        MonitorMessageReceived(
          MonitorMessage(
            type: MonitorMessageType.history,
            payload: {
              Protocol.snapshots: [snapshot1.toJson(), snapshot2.toJson()],
            },
          ),
        ),
      );

      await _waitUntil(() {
        final state = bloc.state;
        return state is MonitorLoaded &&
            (state.hosts[_hostId]?.history.length ?? 0) == 2;
      });

      var host = (bloc.state as MonitorLoaded).hosts[_hostId]!;
      expect(host.history.length, 2);
      expect(host.snapshot?.cpuUsage, 20.0);
      expect(host.cpuHistory.items, [10.0, 20.0]);

      // 2. Receive metricsDelta
      final delta = snapshot2.toDeltaJson();
      delta['cpu_usage'] = 35.0;

      repository.add(
        MonitorMessageReceived(
          MonitorMessage(
            type: MonitorMessageType.metricsDelta,
            payload: delta,
          ),
        ),
      );

      await _waitUntil(() {
        final state = bloc.state;
        return state is MonitorLoaded &&
            state.hosts[_hostId]?.snapshot?.cpuUsage == 35.0;
      });

      host = (bloc.state as MonitorLoaded).hosts[_hostId]!;
      expect(host.history.length, 3);
      expect(host.snapshot?.cpuUsage, 35.0);
      // Architecture and core types are preserved from base
      expect(host.snapshot?.architecture, 'arm64');
      expect(host.snapshot?.cores.first.type, 'performance');
      expect(host.cpuHistory.items, [10.0, 20.0, 35.0]);
    });
  });
}

const _hostId = '192.0.2.10:9723';

Future<MonitorHost> _waitForHost(
  MonitorBloc bloc,
  String hostId, {
  ConnectionStatus? status,
}) async {
  await _waitUntil(() {
    final state = bloc.state;
    if (state is! MonitorLoaded) return false;
    final host = state.hosts[hostId];
    if (host == null) return false;
    return status == null || host.status == status;
  });

  return (bloc.state as MonitorLoaded).hosts[hostId]!;
}

Future<MonitorHost> _waitForHostWithMetrics(
  MonitorBloc bloc,
  String hostId,
) async {
  await _waitUntil(() {
    final state = bloc.state;
    return state is MonitorLoaded && state.hosts[hostId]?.metrics != null;
  });

  return (bloc.state as MonitorLoaded).hosts[hostId]!;
}

Future<void> _waitUntil(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 1));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Timed out waiting for monitor bloc condition');
    }
    await Future<void>.delayed(Duration.zero);
  }
}

final class _FakeMonitorRepository extends MonitorRepository {
  final _controller = StreamController<MonitorConnectionEvent>.broadcast();
  final disconnectedHostIds = <String>[];
  var disconnectAllCallCount = 0;

  void add(MonitorConnectionEvent event) {
    _controller.add(event);
  }

  @override
  Stream<MonitorConnectionEvent> connect(
    String hostId,
    String ip,
    int port, {
    bool useTls = true,
    String? pinnedFingerprint,
  }) => _controller.stream;

  @override
  Future<void> disconnect(String hostId) async {
    disconnectedHostIds.add(hostId);
  }

  @override
  Future<void> disconnectAll() async {
    disconnectAllCallCount++;
  }

  Future<void> close() => _controller.close();
}
