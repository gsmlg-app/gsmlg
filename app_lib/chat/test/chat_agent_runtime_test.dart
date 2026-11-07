import 'dart:async';

import 'package:app_chat/app_chat.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
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
}
