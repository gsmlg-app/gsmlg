import 'dart:async';

import 'package:app_chat/app_chat.dart';
import 'package:app_logging/app_logging.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:test/test.dart';

class _ThrowingExecutor extends ToolExecutor {
  @override
  Future<Map<String, dynamic>> execute(
    String name,
    Map<String, dynamic> args,
  ) async => throw StateError('boom');
}

class _Sink implements LogSink {
  final agent = <AgentLogEvent>[];
  @override
  void writeApi(ApiExchangeRecord r) {}
  @override
  void writeAgent(AgentLogEvent e) => agent.add(e);
  @override
  void writeUsage(UsageEvent e) {}
}

class _FakeVault implements VaultRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Remote extends RemoteLlmRepository {
  _Remote() : super(vault: _FakeVault());
  var turn = 0;
  @override
  Stream<ChatGenerationChunk> generateResponse(
    List<Message> messages,
    ModelConfig config, {
    List<Map<String, dynamic>> tools = const [],
    String? generationId,
    LogContext? logContext,
  }) async* {
    turn++;
    if (turn == 1) {
      yield const ChatTextChunk('Searching...');
      yield const ChatFunctionCallChunk(
        name: 'memory_search',
        args: {'query': 'q'},
        id: 'call_1',
      );
    } else {
      yield const ChatTextChunk('done');
    }
  }
}

void main() {
  tearDown(() => LogCapture.instance.attach(null));

  test('failing tool yields receipt with backend, error type, stack', () async {
    final events = <ChatAgentEvent>[];
    final gateway = ToolExecutionGateway(
      toolExecutor: _ThrowingExecutor(),
      onEvent: events.add,
    );
    await gateway.execute(
      runId: 'r1',
      sessionId: 's1',
      toolName: 'web_fetch',
      arguments: {'url': 'x'},
    );
    final receipt = events.whereType<ToolCallCompletedEvent>().single.receipt;
    expect(receipt.backend, 'tool_executor');
    expect(receipt.errorType, 'StateError');
    expect(receipt.stackTrace, isNotNull);
    expect(receipt.durationMs, greaterThanOrEqualTo(0));
    expect(receipt.isError, isTrue);
    final roundTrip = ToolInvocationReceipt.fromJson(receipt.toJson());
    expect(roundTrip.backend, 'tool_executor');
    expect(roundTrip.errorType, 'StateError');
  });

  test('disallowed tool has backend none', () async {
    final events = <ChatAgentEvent>[];
    final gateway = ToolExecutionGateway(
      allowedTools: {'x'},
      onEvent: events.add,
    );
    await gateway.execute(
      runId: 'r1',
      sessionId: 's1',
      toolName: 'y',
      arguments: {},
    );
    expect(
      events.whereType<ToolCallCompletedEvent>().single.receipt.backend,
      'none',
    );
  });

  test('runStream logs ordered agent events with one run_id', () async {
    final sink = _Sink();
    LogCapture.instance.attach(sink);
    final runtime = ChatAgentRuntime(
      toolExecutor: ToolExecutor(),
      remoteRepository: _Remote(),
      memoryProvider: ScopedMemoryProvider(
        initialEntries: [
          MemoryEntry.create(scope: 'global', content: 'q information'),
        ],
      ),
    );
    await runtime
        .runStream(
          runId: 'run_x',
          sessionId: 'sess',
          modelConfig: const ModelConfig(
            inferenceMode: ChatInferenceMode.remote,
            remoteModel: 'test-model',
          ),
          historyMessages: [],
          userPrompt: 'go',
        )
        .drain<void>();

    expect(sink.agent.map((e) => e.eventType), [
      'agent_run_started',
      'model_turn_started',
      'model_turn_completed',
      'tool_call_prepared',
      'tool_call_started',
      'tool_call_completed',
      'model_turn_started',
      'model_turn_completed',
      'agent_run_completed',
    ]);
    expect(sink.agent.map((e) => e.context.runId).toSet(), {'run_x'});
    expect(sink.agent.map((e) => e.context.conversationId).toSet(), {'sess'});
    expect(
      sink.agent
          .where((e) => e.eventType.startsWith('model_turn'))
          .map((e) => e.context.turn),
      [1, 1, 2, 2],
    );
    final tool = sink.agent.firstWhere(
      (e) => e.eventType == 'tool_call_completed',
    );
    expect(tool.backend, 'memory');
    expect(tool.context.turn, 1);
  });
}
