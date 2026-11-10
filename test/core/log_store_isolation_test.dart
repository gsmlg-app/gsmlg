import 'dart:async';
import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/core/app_isolates.dart';
import 'package:isolate_orchestrator/isolate_orchestrator.dart';

/// Worker that exits abnormally on the `crash` cast.
class _CrashWorker extends Worker<Object?> with WorkerMetricsMixin<Object?> {
  _CrashWorker(this.context);

  @override
  final WorkerContext context;

  @override
  Future<void> onInit(Map<String, dynamic> config) async => initMetrics();

  @override
  Future<Object?> onTask(
    Object? data, {
    String? taskType,
    Map<String, dynamic>? metadata,
  }) async => null;

  @override
  Future<Object?> onCall(
    Object? request, {
    required IsolateAddress sender,
    Map<String, dynamic>? metadata,
  }) async => request;

  @override
  Future<void> onCast(
    Object? message, {
    required IsolateAddress sender,
    Map<String, dynamic>? metadata,
  }) async {
    if (message == 'crash') Isolate.exit();
  }

  @override
  Future<void> onShutdown() async {}
}

void _crashEntryPoint(SendPort hubPort) {
  runWorker<Object?>(hubPort, _CrashWorker.new);
}

Future<void> _until(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition() && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

void main() {
  test('a logstore exceeding its restart intensity does not stop /agents '
      'children', () async {
    const intensity = RestartIntensity(
      maxRestarts: 2,
      withinDuration: Duration(minutes: 1),
    );
    final hub = IsolateHub(config: const HubConfig(rootIntensity: intensity));
    await hub.start();
    addTearDown(() => hub.stop(timeout: const Duration(seconds: 2)));
    final escalations = <SupervisorEscalated>[];
    final sub = hub.events.listen((event) {
      if (event is SupervisorEscalated) escalations.add(event);
    });
    addTearDown(sub.cancel);

    await AppIsolates.registerLogStore(
      hub,
      dbPath: ':memory:',
      entryPoint: _crashEntryPoint,
      intensity: intensity,
    );
    await hub.createGroup(
      name: 'agents',
      restartType: ChildRestartType.temporary,
    );
    final agent = await hub.spawn<Object?>(
      role: 'agent',
      name: 'agent:a',
      entryPoint: _crashEntryPoint,
      parentPath: '/agents',
      restartType: ChildRestartType.transient,
    );

    // Crash the logstore until its supervisor gives up on it.
    for (var i = 0; i < 10 && escalations.isEmpty; i++) {
      final current = hub.getByName(AppIsolates.logStoreName);
      if (current == null || current.state != IsolateState.running) {
        await _until(() {
          final next = hub.getByName(AppIsolates.logStoreName);
          return escalations.isNotEmpty ||
              (next != null && next.state == IsolateState.running);
        });
        continue;
      }
      hub.cast(current.id, 'crash');
      await _until(
        () =>
            escalations.isNotEmpty ||
            hub.getByName(AppIsolates.logStoreName)?.id != current.id,
      );
    }
    expect(escalations, isNotEmpty, reason: 'logstore never gave up');
    await Future<void>.delayed(const Duration(milliseconds: 300));

    expect(escalations.map((e) => e.supervisorPath), isNot(contains('/')));
    expect(hub.getByName('agent:a')?.id, agent.id);
    expect(hub.getByName('agent:a')?.state, IsolateState.running);
  });
}
