import 'dart:convert';
import 'dart:typed_data';

import 'package:app_chat/app_chat.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('RemoteLlmRepository', () {
    test('uses Responses API for OpenAI requests', () async {
      Uri? uri;
      Map<String, dynamic>? body;
      final repository = RemoteLlmRepository(
        vault: _MemoryVaultRepository(),
        client: MockClient((request) async {
          uri = request.url;
          body = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'output': [
                {
                  'type': 'message',
                  'role': 'assistant',
                  'content': [
                    {'type': 'output_text', 'text': 'hello from responses'},
                  ],
                },
              ],
            }),
            200,
          );
        }),
      );

      final chunks = await repository
          .generateResponse(
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
              remoteProvider: RemoteLlmProvider.openAi,
              remoteAccountId: ModelConfig.dummyRemoteAccountId,
              remoteBaseUrl: 'https://api.openai.com/v1',
              remoteModel: 'gpt-5',
              remoteStreamingEnabled: false,
            ),
            tools: [
              {
                'type': 'function',
                'function': {
                  'name': 'lookup',
                  'description': 'Lookup data',
                  'parameters': {
                    'type': 'object',
                    'properties': {
                      'query': {'type': 'string'},
                    },
                    'required': ['query'],
                  },
                },
              },
            ],
          )
          .toList();

      expect(uri, Uri.parse('https://api.openai.com/v1/responses'));
      expect(body!['input'], [
        {'role': 'user', 'content': 'hello'},
      ]);
      expect(body!.containsKey('messages'), isFalse);
      expect(body!['store'], isFalse);
      expect(body!['tools'], [
        {
          'type': 'function',
          'name': 'lookup',
          'description': 'Lookup data',
          'parameters': {
            'type': 'object',
            'properties': {
              'query': {'type': 'string'},
            },
            'required': ['query'],
          },
          'strict': false,
        },
      ]);
      expect(chunks, const [ChatTextChunk('hello from responses')]);
    });

    test('keeps Chat Completions for OpenAI-compatible providers', () async {
      Uri? uri;
      Map<String, dynamic>? body;
      final repository = RemoteLlmRepository(
        vault: _MemoryVaultRepository(),
        client: MockClient((request) async {
          uri = request.url;
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
        ),
      ).toList();

      expect(uri, Uri.parse('http://localhost:11434/v1/chat/completions'));
      expect(body!.containsKey('messages'), isTrue);
      expect(body!.containsKey('input'), isFalse);
    });

    test('parses OpenAI Responses function calls', () async {
      final repository = RemoteLlmRepository(
        vault: _MemoryVaultRepository(),
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'output': [
                {
                  'type': 'function_call',
                  'name': 'lookup',
                  'arguments': '{"query":"dart"}',
                  'call_id': 'call_123',
                  'status': 'completed',
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
            content: 'search',
            conversationId: 'conversation',
            timestamp: DateTime(2026),
          ),
        ],
        const ModelConfig(
          inferenceMode: ChatInferenceMode.remote,
          remoteProvider: RemoteLlmProvider.openAi,
          remoteAccountId: ModelConfig.dummyRemoteAccountId,
          remoteBaseUrl: 'https://api.openai.com/v1',
          remoteModel: 'gpt-5',
          remoteStreamingEnabled: false,
        ),
      ).toList();

      expect(chunks, [
        const ChatFunctionCallChunk(name: 'lookup', args: {'query': 'dart'}),
      ]);
    });

    test('parses streaming OpenAI Responses events', () async {
      final repository = RemoteLlmRepository(
        vault: _MemoryVaultRepository(),
        client: MockClient((request) async {
          return http.Response(
            [
              'data: ${jsonEncode({
                    'type': 'response.output_text.delta',
                    'delta': '<think>planning</think>',
                  })}',
              'data: ${jsonEncode({
                    'type': 'response.output_text.delta',
                    'delta': 'final answer',
                  })}',
              'data: ${jsonEncode({'type': 'response.completed'})}',
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
          remoteProvider: RemoteLlmProvider.openAi,
          remoteAccountId: ModelConfig.dummyRemoteAccountId,
          remoteBaseUrl: 'https://api.openai.com/v1',
          remoteModel: 'gpt-5',
        ),
      ).toList();

      expect(chunks, [
        const ChatThinkingChunk('planning'),
        const ChatTextChunk('final answer'),
      ]);
    });

    test('parses streaming OpenAI Responses function calls', () async {
      final repository = RemoteLlmRepository(
        vault: _MemoryVaultRepository(),
        client: MockClient((request) async {
          return http.Response(
            [
              'data: ${jsonEncode({
                    'type': 'response.output_item.added',
                    'output_index': 0,
                    'item': {
                      'type': 'function_call',
                      'name': 'lookup',
                      'arguments': '',
                    },
                  })}',
              'data: ${jsonEncode({
                    'type': 'response.function_call_arguments.delta',
                    'output_index': 0,
                    'delta': '{"query"',
                  })}',
              'data: ${jsonEncode({
                    'type': 'response.function_call_arguments.delta',
                    'output_index': 0,
                    'delta': ':"dart"}',
                  })}',
              'data: ${jsonEncode({'type': 'response.completed'})}',
            ].join('\n\n'),
            200,
          );
        }),
      );

      final chunks = await repository.generateResponse(
        [
          UserMessage(
            id: 'user',
            content: 'search',
            conversationId: 'conversation',
            timestamp: DateTime(2026),
          ),
        ],
        const ModelConfig(
          inferenceMode: ChatInferenceMode.remote,
          remoteProvider: RemoteLlmProvider.openAi,
          remoteAccountId: ModelConfig.dummyRemoteAccountId,
          remoteBaseUrl: 'https://api.openai.com/v1',
          remoteModel: 'gpt-5',
        ),
      ).toList();

      expect(chunks, [
        const ChatFunctionCallChunk(name: 'lookup', args: {'query': 'dart'}),
      ]);
    });

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

    test('includes text attachments in remote user messages', () async {
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
            content: 'summarize',
            conversationId: 'conversation',
            timestamp: DateTime(2026),
            attachments: [
              ChatAttachment(
                id: 'notes',
                name: 'notes.txt',
                sizeBytes: 15,
                mimeType: 'text/plain',
                bytes: Uint8List.fromList(utf8.encode('hello from file')),
              ),
            ],
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

      final messages = body!['messages'] as List<dynamic>;
      final content = (messages.single as Map<String, dynamic>)['content'];
      expect(content, contains('summarize'));
      expect(content, contains('Attached file: notes.txt'));
      expect(content, contains('hello from file'));
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
