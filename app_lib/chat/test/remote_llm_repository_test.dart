import 'dart:convert';

import 'package:app_chat/app_chat.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('RemoteLlmRepository', () {
    test('sends DeepSeek thinking effort request fields', () async {
      final bodies = <Map<String, dynamic>>[];
      final repository = RemoteLlmRepository(
        vault: _MemoryVaultRepository(),
        client: MockClient((request) async {
          bodies.add(jsonDecode(request.body) as Map<String, dynamic>);
          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {'content': 'ok'},
                },
              ],
            }),
            200,
          );
        }),
      );

      for (final effort in RemoteThinkingEffort.values) {
        await repository.generateResponse(
          [
            UserMessage(
              id: 'user',
              content: 'hello',
              conversationId: 'conversation',
              timestamp: DateTime(2026),
            ),
          ],
          ModelConfig(
            inferenceMode: ChatInferenceMode.remote,
            remoteProvider: RemoteLlmProvider.deepSeek,
            remoteAccountId: ModelConfig.dummyRemoteAccountId,
            remoteBaseUrl: 'https://api.deepseek.com/v1',
            remoteModel: 'deepseek-v4-pro',
            remoteStreamingEnabled: false,
            remoteThinkingEffort: effort,
          ),
        ).toList();
      }

      expect(bodies, hasLength(3));
      expect(bodies[0]['thinking'], {'type': 'disabled'});
      expect(bodies[0].containsKey('reasoning_effort'), isFalse);
      expect(bodies[0].containsKey('temperature'), isTrue);
      expect(bodies[1]['thinking'], {'type': 'enabled'});
      expect(bodies[1]['reasoning_effort'], 'high');
      expect(bodies[1].containsKey('temperature'), isFalse);
      expect(bodies[2]['thinking'], {'type': 'enabled'});
      expect(bodies[2]['reasoning_effort'], 'max');
      expect(bodies[2].containsKey('temperature'), isFalse);
    });

    test('does not send thinking fields to non-DeepSeek providers', () async {
      Map<String, dynamic>? body;
      final repository = RemoteLlmRepository(
        vault: _MemoryVaultRepository(),
        client: MockClient((request) async {
          body = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {'content': 'ok'},
                },
              ],
            }),
            200,
          );
        }),
      );

      await repository.generateResponse(
        [
          UserMessage(
            id: 'user',
            content: 'hello',
            conversationId: 'conversation',
            timestamp: DateTime(2026),
          ),
        ],
        const ModelConfig(
          inferenceMode: ChatInferenceMode.remote,
          remoteProvider: RemoteLlmProvider.openAiCompatible,
          remoteAccountId: ModelConfig.dummyRemoteAccountId,
          remoteBaseUrl: 'http://localhost:11434/v1',
          remoteModel: 'local-model',
          remoteStreamingEnabled: false,
          remoteThinkingEffort: RemoteThinkingEffort.max,
        ),
      ).toList();

      expect(body!.containsKey('thinking'), isFalse);
      expect(body!.containsKey('reasoning_effort'), isFalse);
    });

    test('parses non-streaming think tags into thinking chunks', () async {
      final repository = RemoteLlmRepository(
        vault: _MemoryVaultRepository(),
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {
                    'content': '<think>planning</think>final answer',
                  },
                },
              ],
            }),
            200,
          );
        }),
      );

      final chunks = await repository.generateResponse(
        [
          UserMessage(
            id: 'user',
            content: 'hello',
            conversationId: 'conversation',
            timestamp: DateTime(2026),
          ),
        ],
        const ModelConfig(
          inferenceMode: ChatInferenceMode.remote,
          remoteProvider: RemoteLlmProvider.openAiCompatible,
          remoteAccountId: ModelConfig.dummyRemoteAccountId,
          remoteBaseUrl: 'http://localhost:11434/v1',
          remoteModel: 'local-model',
          remoteStreamingEnabled: false,
        ),
      ).toList();

      expect(chunks, [
        const ChatThinkingChunk('planning'),
        const ChatTextChunk('final answer'),
      ]);
    });

    test('parses streaming think tags split across deltas', () async {
      final repository = RemoteLlmRepository(
        vault: _MemoryVaultRepository(),
        client: MockClient((request) async {
          return http.Response(
            [
              'data: ${jsonEncode({
                    'choices': [
                      {
                        'delta': {'content': '<thi'},
                      },
                    ],
                  })}',
              'data: ${jsonEncode({
                    'choices': [
                      {
                        'delta': {'content': 'nk>planning</thi'},
                      },
                    ],
                  })}',
              'data: ${jsonEncode({
                    'choices': [
                      {
                        'delta': {'content': 'nk>final answer'},
                      },
                    ],
                  })}',
              'data: [DONE]',
            ].join('\n\n'),
            200,
          );
        }),
      );

      final chunks = await repository.generateResponse(
        [
          UserMessage(
            id: 'user',
            content: 'hello',
            conversationId: 'conversation',
            timestamp: DateTime(2026),
          ),
        ],
        const ModelConfig(
          inferenceMode: ChatInferenceMode.remote,
          remoteProvider: RemoteLlmProvider.openAiCompatible,
          remoteAccountId: ModelConfig.dummyRemoteAccountId,
          remoteBaseUrl: 'http://localhost:11434/v1',
          remoteModel: 'local-model',
        ),
      ).toList();

      expect(chunks, [
        const ChatThinkingChunk('planning'),
        const ChatTextChunk('final answer'),
      ]);
    });
  });
}

class _MemoryVaultRepository implements VaultRepository {
  @override
  Future<bool> containsKey({required String key}) async => false;

  @override
  Future<void> delete({required String key}) async {}

  @override
  Future<void> deleteAll() async {}

  @override
  Future<String?> read({required String key}) async => null;

  @override
  Future<Map<String, String>> readAll() async => const {};

  @override
  Future<void> write({required String key, required String value}) async {}
}
