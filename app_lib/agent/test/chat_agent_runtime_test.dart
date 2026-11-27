import 'dart:async';

import 'package:app_agent/app_agent.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:agent_runtime/agent_runtime.dart' as dac;
import 'package:test/test.dart';

class _FakeRemoteLlmRepository extends RemoteLlmRepository {
  _FakeRemoteLlmRepository() : super(vault: _FakeVault());

  var turnCount = 0;

  @override
  Stream<ChatGenerationChunk> generateResponse(
    List<Message> messages,
    ModelConfig config, {
    List<Map<String, dynamic>> tools = const [],
    String? generationId,
    LogContext? logContext,
  }) async* {
    turnCount++;
    if (turnCount == 1) {
      // First turn: think, output some text, and request a tool call
      yield const ChatThinkingChunk('I need to search memory');
      yield const ChatTextChunk('Searching...');
      yield const ChatFunctionCallChunk(
        name: 'memory_search',
        args: {'query': 'test query'},
        id: 'call_test_1',
      );
    } else {
      // Second turn: final answer
      yield const ChatTextChunk('I found the information: all clear.');
    }
  }
}

class _MultiToolRemoteLlmRepository extends RemoteLlmRepository {
  _MultiToolRemoteLlmRepository() : super(vault: _FakeVault());

  var turnCount = 0;

  @override
  Stream<ChatGenerationChunk> generateResponse(
    List<Message> messages,
    ModelConfig config, {
    List<Map<String, dynamic>> tools = const [],
    String? generationId,
    LogContext? logContext,
  }) async* {
    turnCount++;
    if (turnCount == 1) {
      yield const ChatThinkingChunk('Calling two tools in parallel');
      yield const ChatFunctionCallChunk(
        name: 'memory_search',
        args: {'query': 'alpha'},
        id: 'call_parallel_1',
        index: 0,
      );
      yield const ChatFunctionCallChunk(
        name: 'memory_search',
        args: {'query': 'beta'},
        id: 'call_parallel_2',
        index: 1,
      );
    } else {
      yield const ChatTextChunk('Found both alpha and beta.');
    }
  }
}

class _FakeVault implements VaultRepository {
  final Map<String, String> _storage = {};

  @override
  Future<void> write({required String key, required String value}) async =>
      _storage[key] = value;

  @override
  Future<String?> read({required String key}) async => _storage[key];

  @override
  Future<void> delete({required String key}) async => _storage.remove(key);

  @override
  Future<bool> containsKey({required String key}) async =>
      _storage.containsKey(key);

  @override
  Future<void> deleteAll() async => _storage.clear();

  @override
  Future<Map<String, String>> readAll() async => Map.unmodifiable(_storage);
}

void main() {
  for (final firstChunk in [
    const ChatTextChunk('first'),
    const ChatThinkingChunk('reasoning'),
    const ChatTextChunk(' '),
  ]) {
    test(
      'records primed $firstChunk before buffered delivery exactly once',
      () async {
        final remote = _ControlledRemoteLlmRepository();
        var firstTokenCalls = 0;
        final client = RepositoryAgentLlmClient(
          config: const ModelConfig(inferenceMode: ChatInferenceMode.remote),
          remoteRepository: remote,
          initialMessages: [
            UserMessage(
              id: 'user',
              conversationId: 'conversation',
              timestamp: DateTime(2026),
              content: 'hello',
            ),
          ],
          onFirstToken: () => firstTokenCalls++,
        );
        remote.controller.add(const ChatTextChunk(''));
        remote.controller.add(const ChatThinkingChunk(''));
        expect(firstTokenCalls, 0);

        remote.controller.add(firstChunk);
        // No event-loop turn has allowed the primed buffer to deliver anything.
        expect(firstTokenCalls, 1);
        remote.controller.add(const ChatTextChunk('later'));
        remote.controller.add(const ChatThinkingChunk('later reasoning'));
        expect(firstTokenCalls, 1);

        final stream = await client.stream(
          const [],
          modelConfig: dac.ModelConfig(model: 'test-model'),
        );
        final drained = stream.toList();
        await remote.controller.close();
        await drained;
        expect(firstTokenCalls, 1);
      },
    );
  }

  group('ChatAgentRuntime', () {
    test(
      'executes multi-turn agent loop with tool calls and emits typed events',
      () async {
        final fakeRemote = _FakeRemoteLlmRepository();
        final memoryProvider = ScopedMemoryProvider(
          initialEntries: [
            MemoryEntry.create(
              scope: 'global',
              content: 'test query information is all clear',
            ),
          ],
        );

        final runtime = ChatAgentRuntime(
          toolExecutor: ToolExecutor(),
          remoteRepository: fakeRemote,
          memoryProvider: memoryProvider,
        );

        final events = <ChatAgentEvent>[];
        final stream = runtime.runStream(
          runId: 'test_run_1',
          sessionId: 'session_1',
          modelConfig: const ModelConfig(
            inferenceMode: ChatInferenceMode.remote,
            remoteModel: 'test-model',
          ),
          historyMessages: [],
          userPrompt: 'Please test the memory search',
        );

        await for (final event in stream) {
          events.add(event);
        }

        // Verify event sequence
        expect(events.any((e) => e is AgentRunStartedEvent), isTrue);
        expect(events.any((e) => e is ModelChunkReceivedEvent), isTrue);
        expect(events.any((e) => e is ToolCallPreparedEvent), isTrue);
        expect(events.any((e) => e is ToolCallStartedEvent), isTrue);
        expect(events.any((e) => e is ToolCallCompletedEvent), isTrue);
        expect(events.any((e) => e is ModelTurnCompletedEvent), isTrue);
        expect(events.any((e) => e is AgentRunCompletedEvent), isTrue);

        final toolEvent = events.whereType<ToolCallCompletedEvent>().first;
        expect(toolEvent.toolName, equals('memory_search'));
        expect(toolEvent.receipt.isError, isFalse);
      },
    );

    test(
      'collects multiple parallel function calls in one turn without closing early',
      () async {
        final multiToolRemote = _MultiToolRemoteLlmRepository();
        final memoryProvider = ScopedMemoryProvider(
          initialEntries: [
            MemoryEntry.create(scope: 'global', content: 'alpha fact'),
            MemoryEntry.create(scope: 'global', content: 'beta fact'),
          ],
        );

        final runtime = ChatAgentRuntime(
          toolExecutor: ToolExecutor(),
          remoteRepository: multiToolRemote,
          memoryProvider: memoryProvider,
        );

        final events = await runtime
            .runStream(
              runId: 'test_multi_tool_run',
              sessionId: 'session_multi',
              modelConfig: const ModelConfig(
                inferenceMode: ChatInferenceMode.remote,
                remoteModel: 'test-model',
              ),
              historyMessages: const [],
              userPrompt: 'Search both facts',
            )
            .toList();

        expect(events.whereType<AgentRunFailedEvent>(), isEmpty);
        expect(events.whereType<AgentRunCompletedEvent>(), hasLength(1));
        final toolEvents = events.whereType<ToolCallCompletedEvent>().toList();
        expect(toolEvents, hasLength(2));
        expect(
          toolEvents.map((e) => e.callId),
          containsAll(['call_parallel_1', 'call_parallel_2']),
        );
      },
    );

    test('respects cancelToken and terminates run cleanly', () async {
      final fakeRemote = _FakeRemoteLlmRepository();
      final cancelToken = CancelToken();

      final runtime = ChatAgentRuntime(
        toolExecutor: ToolExecutor(),
        remoteRepository: fakeRemote,
      );

      final events = <ChatAgentEvent>[];
      final stream = runtime.runStream(
        runId: 'test_cancel_run',
        sessionId: 'session_1',
        modelConfig: const ModelConfig(
          inferenceMode: ChatInferenceMode.remote,
          remoteModel: 'test-model',
        ),
        historyMessages: [],
        userPrompt: 'Cancel me',
        cancelToken: cancelToken,
      );

      // Cancel immediately
      cancelToken.cancel('User requested cancellation');

      try {
        await for (final event in stream) {
          events.add(event);
        }
      } catch (_) {
        // Cancelled stream error expected
      }

      expect(events.any((e) => e is AgentRunStartedEvent), isTrue);
    });
  });

  group('InProcessAgentRunner', () {
    test('runs the runtime and stop(runId) cancels the run', () async {
      final runner = InProcessAgentRunner(
        ChatAgentRuntime(
          toolExecutor: ToolExecutor(),
          remoteRepository: _HangingRemoteLlmRepository(),
        ),
      );
      final events = <ChatAgentEvent>[];
      final done = Completer<void>();
      runner
          .runStream(
            agentId: 'a',
            runId: 'r1',
            sessionId: 's',
            modelConfig: const ModelConfig(
              inferenceMode: ChatInferenceMode.remote,
              remoteModel: 'test-model',
            ),
            historyMessages: const [],
            userPrompt: 'hi',
          )
          .listen(events.add, onDone: done.complete, onError: (_) {});
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await runner.stop('r1');
      await done.future.timeout(const Duration(seconds: 5));
      expect(events.first, isA<AgentRunStartedEvent>());
      expect(events.last, isA<AgentRunCancelledEvent>());
    });
  });
}

class _HangingRemoteLlmRepository extends RemoteLlmRepository {
  _HangingRemoteLlmRepository() : super(vault: _FakeVault());

  @override
  Stream<ChatGenerationChunk> generateResponse(
    List<Message> messages,
    ModelConfig config, {
    List<Map<String, dynamic>> tools = const [],
    String? generationId,
    LogContext? logContext,
  }) => StreamController<ChatGenerationChunk>().stream;
}

class _ControlledRemoteLlmRepository extends RemoteLlmRepository {
  _ControlledRemoteLlmRepository() : super(vault: _FakeVault());

  final controller = StreamController<ChatGenerationChunk>(sync: true);

  @override
  Stream<ChatGenerationChunk> generateResponse(
    List<Message> messages,
    ModelConfig config, {
    List<Map<String, dynamic>> tools = const [],
    String? generationId,
    LogContext? logContext,
  }) => controller.stream;
}
