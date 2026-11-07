import 'dart:async';

import 'package:app_chat/app_chat.dart';
import 'package:test/test.dart';

void main() {
  group('TreeBudget', () {
    test('enforces maxConcurrency and maxDepth atomically', () {
      final budget = TreeBudget(maxDepth: 2, maxConcurrency: 2);

      // Depth 0 -> allowed
      expect(budget.tryAcquireWorker(0), isTrue);
      expect(budget.activeConcurrency, equals(1));

      // Depth 1 -> allowed (concurrency becomes 2)
      expect(budget.tryAcquireWorker(1), isTrue);
      expect(budget.activeConcurrency, equals(2));

      // Exceed concurrency -> rejected
      expect(budget.tryAcquireWorker(1), isFalse);

      // Release one
      budget.releaseWorker();
      expect(budget.activeConcurrency, equals(1));

      // Depth >= maxDepth -> rejected
      expect(budget.tryAcquireWorker(2), isFalse);
    });

    test('enforces maxTurns and maxToolCalls limits', () {
      final budget = TreeBudget(maxTurns: 2, maxToolCalls: 2);

      expect(budget.recordTurn(), isTrue);
      expect(budget.recordTurn(), isTrue);
      expect(budget.recordTurn(), isFalse);

      expect(budget.recordToolCall(), isTrue);
      expect(budget.recordToolCall(), isTrue);
      expect(budget.recordToolCall(), isFalse);
    });
  });

  group('AgentSupervisor', () {
    test('spawns child worker, executes runner, and waits for result', () async {
      final supervisor = AgentSupervisor(
        childRunner: ({
          required String childRunId,
          required String role,
          required String prompt,
          required Set<String>? allowedTools,
          required CancelToken cancelToken,
          required TreeBudget budget,
          required int depth,
        }) async {
          return 'Result for $role: done $prompt';
        },
      );

      final spawnRes = await supervisor.executeTool(
        toolName: 'spawn_agent',
        arguments: {
          'name': 'researcher',
          'goal': 'investigate protocol',
        },
        parentRunId: 'parent_1',
        sessionId: 'session_1',
      );

      expect(spawnRes['status'], equals('spawned'));
      final taskId = spawnRes['taskId'] as String;

      final waitRes = await supervisor.executeTool(
        toolName: 'wait_agent',
        arguments: {'taskId': taskId, 'timeout': 5000},
        parentRunId: 'parent_1',
        sessionId: 'session_1',
      );

      expect(waitRes['status'], equals('succeeded'));
      expect(waitRes['result'], contains('Result for researcher'));
    });

    test('propagates parent cancellation to child worker', () async {
      final parentCancelToken = CancelToken();

      final supervisor = AgentSupervisor(
        childRunner: ({
          required String childRunId,
          required String role,
          required String prompt,
          required Set<String>? allowedTools,
          required CancelToken cancelToken,
          required TreeBudget budget,
          required int depth,
        }) async {
          final completer = Completer<String>();
          if (cancelToken.isCancelled) {
            throw cancelToken.cancelError!;
          }
          cancelToken.whenCancel.then((_) {
            if (!completer.isCompleted) {
              completer.completeError(cancelToken.cancelError!);
            }
          });
          return completer.future;
        },
      );

      final spawnRes = await supervisor.executeTool(
        toolName: 'spawn_agent',
        arguments: {
          'name': 'worker',
          'goal': 'long task',
        },
        parentRunId: 'parent_cancel',
        sessionId: 'session_1',
        cancelToken: parentCancelToken,
      );

      final taskId = spawnRes['taskId'] as String;

      // Cancel parent
      parentCancelToken.cancel('Parent requested stop');

      final waitRes = await supervisor.executeTool(
        toolName: 'wait_agent',
        arguments: {'taskId': taskId, 'timeout': 500},
        parentRunId: 'parent_cancel',
        sessionId: 'session_1',
      );

      expect(waitRes['status'], isIn(['cancelled', 'failed']));
    });
  });
}
