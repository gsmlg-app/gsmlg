import 'package:app_agent/app_agent.dart';
import 'package:dart_agent_core/dart_agent_core.dart' as dac;
import 'package:test/test.dart';

ToolInvocationReceipt _receipt({
  InvocationStatus status = InvocationStatus.succeeded,
  bool isError = false,
  dynamic result = 'ok',
  String? errorType,
  String? stackTrace,
}) => ToolInvocationReceipt(
  runId: 'r1',
  callId: 'c1',
  invocationId: 'c1',
  toolName: 'web_fetch',
  arguments: '{"url":"x"}',
  status: status,
  isError: isError,
  result: result,
  timestamp: DateTime.now(),
  backend: 'tool_executor',
  durationMs: 7,
  errorType: errorType,
  stackTrace: stackTrace,
);

void main() {
  group('agentLogEventFrom', () {
    test('chunks are not logged', () {
      expect(
        agentLogEventFrom(
          const ModelChunkReceivedEvent(
            runId: 'r1',
            sessionId: 's1',
            turnIndex: 0,
            textChunk: 'hi',
          ),
        ),
        isNull,
      );
    });

    test('run lifecycle events', () {
      final started = agentLogEventFrom(
        const AgentRunStartedEvent(
          runId: 'r1',
          sessionId: 's1',
          inputMessages: [],
        ),
      )!;
      expect(started.eventType, 'agent_run_started');
      expect(started.context.conversationId, 's1');
      expect(started.context.runId, 'r1');
      expect(started.summary, 'run started');

      final completed = agentLogEventFrom(
        const AgentRunCompletedEvent(
          runId: 'r1',
          sessionId: 's1',
          finalResponse: null,
        ),
      )!;
      expect(completed.eventType, 'agent_run_completed');
      expect(completed.isError, isFalse);

      final failed = agentLogEventFrom(
        AgentRunFailedEvent(
          runId: 'r1',
          sessionId: 's1',
          error: StateError('boom'),
          stackTrace: StackTrace.current,
        ),
      )!;
      expect(failed.eventType, 'agent_run_failed');
      expect(failed.level, 'SEVERE');
      expect(failed.isError, isTrue);
      expect(failed.summary, contains('run failed'));
      expect(failed.payload!['error'], contains('boom'));
      expect(failed.payload!['error_type'], 'StateError');
      expect(failed.payload!['stack_trace'], isNotEmpty);

      final cancelled = agentLogEventFrom(
        const AgentRunCancelledEvent(
          runId: 'r1',
          sessionId: 's1',
          reason: 'user',
        ),
      )!;
      expect(cancelled.eventType, 'agent_run_cancelled');
      expect(cancelled.level, 'WARNING');
    });

    test('model turn events carry turn', () {
      final e = agentLogEventFrom(
        const ModelTurnStartedEvent(
          runId: 'r1',
          sessionId: 's1',
          turnIndex: 1,
          model: 'm',
        ),
        turn: 2,
      )!;
      expect(e.eventType, 'model_turn_started');
      expect(e.context.turn, 2);
      expect(e.payload!['model'], 'm');
      expect(e.requestId, isNull);

      final done = agentLogEventFrom(
        ModelTurnCompletedEvent(
          runId: 'r1',
          sessionId: 's1',
          turnIndex: 1,
          modelMessage: dac.ModelMessage(
            textOutput: 'hello',
            functionCalls: [
              dac.FunctionCall(id: 'c1', name: 't', arguments: '{"a":1}'),
            ],
            model: 'm',
          ),
        ),
        turn: 2,
      )!;
      expect(done.eventType, 'model_turn_completed');
      expect(done.summary, 'turn 2 completed');
      expect(done.payload!['text_output'], 'hello');
      expect((done.payload!['function_calls'] as List).single, {
        'id': 'c1',
        'name': 't',
        'arguments': '{"a":1}',
      });
    });

    test('tool events keep full arguments', () {
      const args = '{"url":"https://example.com/very/long"}';
      for (final (e, type) in [
        (
          const ToolCallPreparedEvent(
            runId: 'r1',
            sessionId: 's1',
            callId: 'c1',
            toolName: 'web_fetch',
            arguments: args,
          ),
          'tool_call_prepared',
        ),
        (
          const ToolCallStartedEvent(
            runId: 'r1',
            sessionId: 's1',
            callId: 'c1',
            toolName: 'web_fetch',
            arguments: args,
          ),
          'tool_call_started',
        ),
      ]) {
        final l = agentLogEventFrom(e, turn: 1)!;
        expect(l.eventType, type);
        expect(l.toolName, 'web_fetch');
        expect(l.context.toolCallId, 'c1');
        expect(l.context.turn, 1);
        expect(l.payload!['arguments'], args);
      }
    });

    test('tool completed success and error', () {
      final ok = agentLogEventFrom(
        ToolCallCompletedEvent(
          runId: 'r1',
          sessionId: 's1',
          callId: 'c1',
          toolName: 'web_fetch',
          arguments: '{}',
          receipt: _receipt(result: {'body': 'x' * 500}),
        ),
      )!;
      expect(ok.eventType, 'tool_call_completed');
      expect(ok.backend, 'tool_executor');
      expect(ok.durationMs, 7);
      expect(ok.level, 'INFO');
      expect((ok.payload!['result'] as Map)['body'], 'x' * 500);

      final err = agentLogEventFrom(
        ToolCallCompletedEvent(
          runId: 'r1',
          sessionId: 's1',
          callId: 'c1',
          toolName: 'web_fetch',
          arguments: '{}',
          receipt: _receipt(
            status: InvocationStatus.failed,
            isError: true,
            result: 'boom',
            errorType: 'StateError',
            stackTrace: 'trace',
          ),
        ),
      )!;
      expect(err.isError, isTrue);
      expect(err.level, 'SEVERE');
      expect(err.summary, 'tool web_fetch → error: StateError: boom');
      expect(err.payload!['stack_trace'], 'trace');
      expect(err.payload!['error_type'], 'StateError');
    });
  });
}
