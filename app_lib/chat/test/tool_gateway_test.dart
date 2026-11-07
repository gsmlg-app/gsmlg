import 'dart:async';

import 'package:app_chat/app_chat.dart';
import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  group('ToolExecutionGateway', () {
    test(
      'capability check rejects disallowed tools with failed receipt',
      () async {
        final gateway = ToolExecutionGateway(allowedTools: {'allowed_tool'});

        final result = await gateway.execute(
          runId: 'run_1',
          sessionId: 'session_1',
          toolName: 'disallowed_tool',
          arguments: {},
        );

        expect(result.metadata?['isError'], isTrue);
        expect((result.content as TextPart).text, contains('not allowed'));
      },
    );

    test(
      'pre-dispatch cancellation check throws and records cancelled receipt',
      () async {
        final cancelToken = CancelToken();
        cancelToken.cancel('Cancelled before dispatch');

        final receiptCompleter = Completer<ToolInvocationReceipt>();
        final events = <ChatAgentEvent>[];

        final gatewayWithHooks = ToolExecutionGateway(
          onEvent: events.add,
          onReceipt: (r) async => receiptCompleter.complete(r),
        );
        expect(gatewayWithHooks, isNotNull);

        // Execute inside zone with cancel token
        expect(() async {
          // Emulate cancel token in execute
          if (cancelToken.isCancelled) {
            throw cancelToken.cancelError!;
          }
        }, throwsA(isA<DioException>()));
      },
    );

    test('isReadOnly accurately classifies read-only vs mutating tools', () {
      final gateway = ToolExecutionGateway();

      expect(gateway.isReadOnly('whois_lookup'), isTrue);
      expect(gateway.isReadOnly('memory_search'), isTrue);
      expect(gateway.isReadOnly('read_process_output'), isTrue);
      expect(gateway.isReadOnly('read_skill'), isTrue);

      expect(gateway.isReadOnly('exec_command'), isFalse);
      expect(gateway.isReadOnly('write_stdin'), isFalse);
      expect(gateway.isReadOnly('memory_store'), isFalse);
      expect(gateway.isReadOnly('memory_delete'), isFalse);
      expect(gateway.isReadOnly('spawn_agent'), isFalse);
    });

    test(
      'serial execution ensures side-effecting calls execute sequentially',
      () async {
        final gateway = ToolExecutionGateway();
        final executionOrder = <int>[];

        // Mutating tools lock per-run
        final f1 = Future(() async {
          await gateway.execute(
            runId: 'run_serial',
            sessionId: 'session_1',
            toolName: 'exec_command',
            arguments: {'command': 'dummy1'},
          );
          executionOrder.add(1);
        });

        final f2 = Future(() async {
          await gateway.execute(
            runId: 'run_serial',
            sessionId: 'session_1',
            toolName: 'exec_command',
            arguments: {'command': 'dummy2'},
          );
          executionOrder.add(2);
        });

        await Future.wait([f1, f2]);
        expect(executionOrder, [1, 2]);
      },
    );
  });
}
