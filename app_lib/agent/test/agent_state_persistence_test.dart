import 'dart:convert';

import 'package:app_agent/app_agent.dart';
import 'package:app_database/app_database.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

class _RecordingRemoteLlm extends RemoteLlmRepository {
  _RecordingRemoteLlm(this.onTurn) : super(secrets: _DummySecrets());

  final Stream<ChatGenerationChunk> Function(int turn, List<Message> messages)
  onTurn;
  final recordedRequests = <List<Message>>[];
  var _turn = 0;

  @override
  Stream<ChatGenerationChunk> generateResponse(
    List<Message> messages,
    ModelConfig config, {
    List<Map<String, dynamic>> tools = const [],
    String? generationId,
    LogContext? logContext,
  }) {
    recordedRequests.add(List<Message>.from(messages));
    return onTurn(++_turn, messages);
  }
}

class _DummySecrets implements SecretReader {
  @override
  Future<String?> read(String key) async => 'sk-test';
}

void main() {
  group('Agent-owned state & persistence', () {
    test(
      'persists distinct turns, toolCallIds, and AgentState across multi-turn runs',
      () async {
        final db = AppDatabase.forTesting();
        final storage = ChatStorageRepository(db);
        addTearDown(db.close);

        const sessionId = 'conv-multi-turn';
        await storage.saveConversation(
          Conversation.create(id: sessionId, title: 'Realtime'),
        );
        final u1 = UserMessage(
          id: 'u1',
          conversationId: sessionId,
          timestamp: DateTime.utc(2026, 11, 27, 10, 0, 0),
          content: 'Check realtime APIs',
        );
        await storage.saveMessage(u1);

        final remote = _RecordingRemoteLlm((turn, messages) async* {
          if (turn == 1) {
            yield const ChatFunctionCallChunk(
              name: 'memory_search',
              args: {'query': 'realtime'},
              id: 'call_real_1',
              index: 0,
            );
            yield const ChatFunctionCallChunk(
              name: 'memory_search',
              args: {'query': 'qwen'},
              id: 'call_real_2',
              index: 1,
            );
          } else if (turn == 2) {
            yield const ChatTextChunk('Here are the realtime APIs.');
          } else {
            yield const ChatTextChunk('Open source models include Qwen.');
          }
        });

        final memory = ScopedMemoryProvider(
          initialEntries: [
            MemoryEntry.create(scope: 'global', content: 'realtime voice API'),
            MemoryEntry.create(scope: 'global', content: 'qwen omni realtime'),
          ],
        );

        final runtime = ChatAgentRuntime(
          toolExecutor: ToolExecutor(),
          remoteRepository: remote,
          sessionStore: storage,
          memoryProvider: memory,
        );

        const config = ModelConfig(
          inferenceMode: ChatInferenceMode.remote,
          remoteModel: 'gpt-6.1-terra',
          remoteApiType: RemoteLlmApiType.openAiResponses,
        );

        final run1Events = await runtime
            .runStream(
              runId: 'run-1',
              sessionId: sessionId,
              modelConfig: config,
              historyMessages: [u1],
              userPrompt: u1.content,
            )
            .toList();

        expect(run1Events.whereType<AgentRunFailedEvent>(), isEmpty);
        expect(run1Events.whereType<AgentRunCompletedEvent>(), hasLength(1));

        // Verify persisted SQLite messages preserve both assistant turns AND
        // both tool_response rows with their real toolCallIds in order.
        final savedMessages = await storage.loadMessages(sessionId);
        final assistants = savedMessages.whereType<AssistantMessage>().toList();
        final tools = savedMessages.whereType<ToolResponseMessage>().toList();
        expect(assistants, hasLength(2));
        expect(tools, hasLength(2));

        final turn0Meta = AgentMessageMetadata.decode(
          assistants[0].agentMetadata,
        );
        expect(
          turn0Meta?.toolCalls.map((c) => c['id']),
          containsAll(['call_real_1', 'call_real_2']),
        );
        expect(assistants[1].content, 'Here are the realtime APIs.');
        expect(
          tools.map((t) => t.toolCallId),
          containsAll(['call_real_1', 'call_real_2']),
        );

        // Verify canonical AgentState was persisted by the agent.
        final savedStateJson = await storage.loadAgentState(sessionId);
        expect(savedStateJson, isNotNull);

        // Run 2: follow-up user turn reloads persisted AgentState and sends
        // properly paired function_call + function_call_output items.
        final u2 = UserMessage(
          id: 'u2',
          conversationId: sessionId,
          timestamp: DateTime.utc(2026, 11, 27, 10, 1, 0),
          content: '开源模型',
        );
        await storage.saveMessage(u2);

        final run2Events = await runtime
            .runStream(
              runId: 'run-2',
              sessionId: sessionId,
              modelConfig: config,
              historyMessages: [...savedMessages, u2],
              userPrompt: u2.content,
            )
            .toList();

        expect(run2Events.whereType<AgentRunFailedEvent>(), isEmpty);
        expect(remote.recordedRequests, hasLength(3));
        final run2Sent = remote.recordedRequests[2];
        final sentTurn0 = run2Sent.whereType<AssistantMessage>().first;
        final sentTurn0Meta = AgentMessageMetadata.decode(
          sentTurn0.agentMetadata,
        );
        expect(
          sentTurn0Meta?.toolCalls.map((c) => c['id']),
          containsAll(['call_real_1', 'call_real_2']),
        );
        final sentTools = run2Sent.whereType<ToolResponseMessage>().toList();
        expect(
          sentTools.map((t) => t.toolCallId),
          containsAll(['call_real_1', 'call_real_2']),
        );
      },
    );

    test(
      'recovers legacy corrupted conversation with orphaned tool_response rows',
      () async {
        final db = AppDatabase.forTesting();
        final storage = ChatStorageRepository(db);
        addTearDown(db.close);

        const sessionId = 'conv-legacy-corrupted';
        await storage.saveConversation(
          Conversation.create(id: sessionId, title: 'Legacy'),
        );

        // Simulate the exact corrupted DB layout from pre-fix sessions:
        // assistant with empty toolCalls metadata followed by two orphaned
        // tool_response rows and a failed API error assistant row.
        final legacyHistory = <Message>[
          UserMessage(
            id: 'u1',
            conversationId: sessionId,
            timestamp: DateTime.utc(2026, 11, 14, 0, 58, 34),
            content: 'realtime API?',
          ),
          AssistantMessage(
            id: 'a1',
            conversationId: sessionId,
            timestamp: DateTime.utc(2026, 11, 14, 0, 58, 34),
            content: 'Qwen-Omni-Realtime and OpenAI Realtime.',
            completedSuccessfully: true,
            agentMetadata: '{"version":1}',
          ),
          ToolResponseMessage(
            id: '559f0b16-082e-4798-9e89-01046d5c8647',
            conversationId: sessionId,
            timestamp: DateTime.utc(2026, 11, 14, 0, 58, 50),
            toolName: 'mcp_backplane_web_search',
            content: '{"results":[]}',
          ),
          UserMessage(
            id: 'u2',
            conversationId: sessionId,
            timestamp: DateTime.utc(2026, 11, 14, 14, 20, 1),
            content: '开源模型',
          ),
          AssistantMessage(
            id: 'err1',
            conversationId: sessionId,
            timestamp: DateTime.utc(2026, 11, 25, 7, 7, 4),
            content: 'API error: OpenAI Responses stream failed.',
            completedSuccessfully: false,
          ),
          UserMessage(
            id: 'u3',
            conversationId: sessionId,
            timestamp: DateTime.utc(2026, 11, 27, 23, 0, 0),
            content: '再试一次',
          ),
        ];

        final remote = _RecordingRemoteLlm((turn, messages) async* {
          yield const ChatTextChunk('Recovered successfully!');
        });

        final runtime = ChatAgentRuntime(
          toolExecutor: ToolExecutor(),
          remoteRepository: remote,
          sessionStore: storage,
        );

        final events = await runtime
            .runStream(
              runId: 'run-recover',
              sessionId: sessionId,
              modelConfig: const ModelConfig(
                inferenceMode: ChatInferenceMode.remote,
                remoteModel: 'gpt-6.1-terra',
                remoteApiType: RemoteLlmApiType.openAiResponses,
              ),
              historyMessages: legacyHistory,
              userPrompt: '再试一次',
            )
            .toList();

        expect(events.whereType<AgentRunFailedEvent>(), isEmpty);
        expect(events.whereType<AgentRunCompletedEvent>(), hasLength(1));

        final sent = remote.recordedRequests.single;
        expect(sent.whereType<ToolResponseMessage>(), isEmpty);
        expect(
          sent.whereType<AssistantMessage>().any(
            (m) => m.content.startsWith('API error:'),
          ),
          isFalse,
        );
      },
    );

    test(
      'surfaces nested OpenAI Responses SSE error.message instead of generic text',
      () async {
        final sseBody =
            'event: error\n'
            'data: {"type":"error","error":{"message":"No tool call found for function call output with call_id 559f.","type":"invalid_request_error","param":"input","code":null}}\n\n';
        final mockClient = MockClient.streaming((request, bodyStream) async {
          return http.StreamedResponse(
            Stream.value(utf8.encode(sseBody)),
            200,
            headers: {'content-type': 'text/event-stream'},
          );
        });

        final repo = RemoteLlmRepository(
          secrets: _DummySecrets(),
          client: mockClient,
        );

        final stream = repo.generateResponse(
          [
            UserMessage(
              id: 'u1',
              conversationId: 'c1',
              timestamp: DateTime.utc(2026),
              content: 'hello',
            ),
          ],
          const ModelConfig(
            inferenceMode: ChatInferenceMode.remote,
            remoteProvider: RemoteLlmProvider.openAi,
            remoteApiType: RemoteLlmApiType.openAiResponses,
            remoteBaseUrl: 'https://backplane.gsmlg.net/v1',
            remoteModel: 'gpt-6.1-terra',
            remoteAccountId: 1,
          ),
        );

        await expectLater(
          stream.toList(),
          throwsA(
            isA<RemoteLlmException>().having(
              (e) => e.message,
              'message',
              contains('No tool call found for function call output'),
            ),
          ),
        );
      },
    );
  });
}
