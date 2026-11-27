import 'dart:async';
import 'dart:convert';

import 'package:agent_runtime/agent_runtime.dart';
import 'package:dio/dio.dart' show CancelToken;
import 'package:test/test.dart';

class _ScriptedClient implements LLMClient {
  _ScriptedClient(this.turns);

  final List<List<ModelMessage>> turns;
  final recordedRequests = <List<LLMMessage>>[];
  var _callIndex = 0;

  @override
  Future<ModelMessage> generate(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    final frames = await stream(
      messages,
      tools: tools,
      toolChoice: toolChoice,
      modelConfig: modelConfig,
      jsonOutput: jsonOutput,
      cancelToken: cancelToken,
    );
    final list = await frames.toList();
    return list.last.modelMessage!;
  }

  @override
  Future<Stream<StreamingMessage>> stream(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    recordedRequests.add(List<LLMMessage>.from(messages));
    final chunks = turns[_callIndex++];
    return Stream<StreamingMessage>.fromIterable([
      for (final c in chunks) StreamingMessage(modelMessage: c),
    ]);
  }
}

void main() {
  group('MessageTransformer', () {
    test('drops orphaned tool results and strips unanswered tool calls', () {
      final raw = <LLMMessage>[
        const UserMessage([TextPart('q1')]),
        const ModelMessage(model: 'm', textOutput: 'a1'),
        const FunctionExecutionResultMessage(
          results: [
            FunctionExecutionResult(
              id: 'orphan_1',
              name: 'web_search',
              content: [TextPart('orphan result')],
            ),
          ],
        ),
        const ModelMessage(
          model: 'm',
          textOutput: 'calling two tools',
          functionCalls: [
            FunctionCall(id: 'c1', name: 't1', arguments: '{}'),
            FunctionCall(id: 'c2', name: 't2', arguments: '{}'),
          ],
        ),
        const FunctionExecutionResultMessage(
          results: [
            FunctionExecutionResult(
              id: 'c1',
              name: 't1',
              content: [TextPart('ok')],
            ),
          ],
        ),
        const ModelMessage(
          model: 'm',
          functionCalls: [
            FunctionCall(id: 'unanswered', name: 't3', arguments: '{}'),
          ],
        ),
        const UserMessage([TextPart('q2')]),
      ];

      final sanitized = MessageTransformer.sanitize(raw);
      expect(sanitized, hasLength(5));
      expect(sanitized[0], isA<UserMessage>());
      expect(sanitized[1], isA<ModelMessage>());
      final pairedModel = sanitized[2] as ModelMessage;
      expect(pairedModel.functionCalls.map((c) => c.id), ['c1']);
      final pairedResult = sanitized[3] as FunctionExecutionResultMessage;
      expect(pairedResult.results.map((r) => r.id), ['c1']);
      expect(sanitized[4], isA<UserMessage>());
    });

    test('completeToolResults fills unknown outcome for unanswered calls', () {
      final raw = <LLMMessage>[
        const UserMessage([TextPart('q')]),
        const ModelMessage(
          model: 'm',
          functionCalls: [
            FunctionCall(id: 'c1', name: 'shell', arguments: '{}'),
          ],
        ),
        const UserMessage([TextPart('continue')]),
      ];

      final projected = MessageTransformer.completeToolResults(raw);
      expect(projected, hasLength(4));
      final synthetic = projected[2] as FunctionExecutionResultMessage;
      expect(synthetic.results.single.id, 'c1');
      expect(synthetic.results.single.isError, isTrue);
    });
  });

  group('AgentRuntime', () {
    test(
      'executes multi-turn tool loop, preserves paired state, and persists JSON',
      () async {
        final client = _ScriptedClient([
          const [
            ModelMessage(
              model: 'gpt-6.1-terra',
              thought: 'Need search',
              functionCalls: [
                FunctionCall(
                  id: 'call_real_1',
                  name: 'web_search',
                  arguments: '{"q":"realtime"}',
                ),
              ],
            ),
          ],
          const [
            ModelMessage(
              model: 'gpt-6.1-terra',
              textOutput: 'Answer from search',
            ),
          ],
        ]);

        final savedSnapshots = <String>[];
        final state = AgentState(sessionId: 'sess-1');
        final runtime = AgentRuntime(
          name: 'test-agent',
          client: client,
          modelConfig: const ModelConfig(model: 'gpt-6.1-terra'),
          state: state,
          tools: [
            Tool(
              name: 'web_search',
              description: 'search web',
              parameters: const {'type': 'object'},
              executable: (args) async =>
                  AgentToolResult(content: TextPart('found:${args['q']}')),
            ),
          ],
          autoSaveState: (s) {
            savedSnapshots.add(jsonEncode(s.toJson()));
          },
        );

        final events = await runtime.runStream([
          const UserMessage([TextPart('hello')]),
        ]).toList();

        expect(runtime.turnState.phase, TurnPhase.completed);
        expect(savedSnapshots, hasLength(2));
        expect(
          events.any(
            (e) => e.eventType == StreamingEventType.functionCallResult,
          ),
          isTrue,
        );

        // Reload state from JSON and run a second prompt: provider must see
        // paired function_call + function_call_output from turn 1.
        final restored = AgentState.fromJson(
          jsonDecode(savedSnapshots.last) as Map<String, dynamic>,
        );
        expect(restored.history.messages, hasLength(4));

        final followUpClient = _ScriptedClient([
          const [
            ModelMessage(model: 'gpt-6.1-terra', textOutput: 'Follow up ok'),
          ],
        ]);
        final runtime2 = AgentRuntime(
          name: 'test-agent',
          client: followUpClient,
          modelConfig: const ModelConfig(model: 'gpt-6.1-terra'),
          state: restored,
        );
        await runtime2.runStream([
          const UserMessage([TextPart('开源模型')]),
        ]).toList();

        final sent = followUpClient.recordedRequests.single;
        expect(sent, hasLength(5));
        expect(
          (sent[1] as ModelMessage).functionCalls.single.id,
          'call_real_1',
        );
        expect(
          (sent[2] as FunctionExecutionResultMessage).results.single.id,
          'call_real_1',
        );
        expect((sent[3] as ModelMessage).textOutput, 'Answer from search');
      },
    );
  });
}
