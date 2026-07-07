import 'dart:convert';
import 'dart:typed_data';

import 'package:app_chat/src/models/inference.dart';
import 'package:app_chat/src/models/message.dart';
import 'package:app_chat/src/models/model_config.dart';
import 'package:app_chat/src/repositories/remote_llm_repository.dart';
import 'package:app_secure_storage/vault_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

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

    test(
      'uses selected Chat Completions API type for OpenAI requests',
      () async {
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
            remoteProvider: RemoteLlmProvider.openAi,
            remoteApiType: RemoteLlmApiType.openAiChatCompletions,
            remoteAccountId: ModelConfig.dummyRemoteAccountId,
            remoteBaseUrl: 'https://api.openai.com/v1',
            remoteModel: 'gpt-5',
            remoteStreamingEnabled: false,
          ),
        ).toList();

        expect(uri, Uri.parse('https://api.openai.com/v1/chat/completions'));
        expect(body!['messages'], [
          {'role': 'user', 'content': 'hello'},
        ]);
        expect(body!.containsKey('input'), isFalse);
      },
    );

    test('uses Anthropic Messages request and response format', () async {
      Uri? uri;
      Map<String, String>? headers;
      Map<String, dynamic>? body;
      final repository = RemoteLlmRepository(
        vault: _MemoryVaultRepository(),
        client: MockClient((request) async {
          uri = request.url;
          headers = request.headers;
          body = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'id': 'msg_123',
              'type': 'message',
              'role': 'assistant',
              'content': [
                {'type': 'text', 'text': 'hello from claude'},
                {
                  'type': 'tool_use',
                  'id': 'toolu_123',
                  'name': 'lookup',
                  'input': {'query': 'dart'},
                },
              ],
              'model': 'claude-sonnet-4-5',
              'stop_reason': 'tool_use',
            }),
            200,
          );
        }),
      );

      final chunks = await repository
          .generateResponse(
            [
              SystemMessage(
                id: 'system',
                content: 'Be brief.',
                conversationId: 'conversation',
                timestamp: DateTime(2026),
              ),
              UserMessage(
                id: 'user',
                content: 'hello',
                conversationId: 'conversation',
                timestamp: DateTime(2026),
              ),
            ],
            const ModelConfig(
              inferenceMode: ChatInferenceMode.remote,
              remoteProvider: RemoteLlmProvider.anthropic,
              remoteApiType: RemoteLlmApiType.anthropicMessages,
              remoteAccountId: ModelConfig.dummyRemoteAccountId,
              remoteBaseUrl: 'https://api.anthropic.com/v1',
              remoteModel: 'claude-sonnet-4-5',
              maxTokens: 1024,
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

      expect(uri, Uri.parse('https://api.anthropic.com/v1/messages'));
      expect(headers!['x-api-key'], 'dummy');
      expect(headers!['anthropic-version'], '2023-06-01');
      expect(headers!['Authorization'], isNull);
      expect(body!['system'], 'Be brief.');
      expect(body!['max_tokens'], 1024);
      expect(body!['messages'], [
        {'role': 'user', 'content': 'hello'},
      ]);
      expect(body!['tools'], [
        {
          'name': 'lookup',
          'description': 'Lookup data',
          'input_schema': {
            'type': 'object',
            'properties': {
              'query': {'type': 'string'},
            },
            'required': ['query'],
          },
        },
      ]);
      expect(chunks, [
        const ChatTextChunk('hello from claude'),
        const ChatFunctionCallChunk(name: 'lookup', args: {'query': 'dart'}),
      ]);
    });

    test(
      'uses configured x-api-key auth for OpenAI-compatible requests',
      () async {
        Map<String, String>? headers;
        final repository = RemoteLlmRepository(
          vault: _MemoryVaultRepository(),
          client: MockClient((request) async {
            headers = request.headers;
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
            remoteBaseUrl: 'https://api.example.com/v1',
            remoteModel: 'custom-model',
            remoteAuthType: RemoteAuthType.xApiKey,
            remoteStreamingEnabled: false,
          ),
        ).toList();

        expect(headers!['x-api-key'], 'dummy');
        expect(headers!['Authorization'], isNull);
      },
    );

    test('listModels uses selected account secret and auth type', () async {
      Uri? uri;
      Map<String, String>? headers;
      final repository = RemoteLlmRepository(
        vault: _MemoryVaultRepository({'service_account_8': 'backplane-token'}),
        client: MockClient((request) async {
          uri = request.url;
          headers = request.headers;
          return http.Response(
            jsonEncode({
              'data': [
                {'id': 'zeta'},
                {'id': 'alpha'},
              ],
            }),
            200,
          );
        }),
      );

      final models = await repository.listModels(
        const ModelConfig(
          inferenceMode: ChatInferenceMode.remote,
          remoteProvider: RemoteLlmProvider.openAi,
          remoteApiType: RemoteLlmApiType.openAiResponses,
          remoteAccountId: 8,
          remoteBaseUrl: 'https://backplane.gsmlg.net/v1',
          remoteModel: 'gpt-4.1-mini',
          remoteAuthType: RemoteAuthType.xApiKey,
        ),
      );

      expect(uri, Uri.parse('https://backplane.gsmlg.net/v1/models'));
      expect(headers!['x-api-key'], 'backplane-token');
      expect(headers!['Authorization'], isNull);
      expect(models, ['alpha', 'zeta']);
    });

    test('uses configured custom auth header for remote requests', () async {
      Map<String, String>? headers;
      final repository = RemoteLlmRepository(
        vault: _MemoryVaultRepository(),
        client: MockClient((request) async {
          headers = request.headers;
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
          remoteBaseUrl: 'https://api.example.com/v1',
          remoteModel: 'custom-model',
          remoteAuthType: RemoteAuthType.customHeader,
          remoteAuthHeaderName: 'X-Model-Key',
          remoteStreamingEnabled: false,
        ),
      ).toList();

      expect(headers!['X-Model-Key'], 'dummy');
      expect(headers!['Authorization'], isNull);
      expect(headers!['x-api-key'], isNull);
    });

    test('parses streaming Anthropic Messages events', () async {
      final repository = RemoteLlmRepository(
        vault: _MemoryVaultRepository(),
        client: MockClient((request) async {
          return http.Response(
            [
              'event: content_block_start',
              'data: ${jsonEncode({
                'type': 'content_block_start',
                'index': 0,
                'content_block': {'type': 'text', 'text': ''},
              })}',
              '',
              'event: content_block_delta',
              'data: ${jsonEncode({
                'type': 'content_block_delta',
                'index': 0,
                'delta': {'type': 'text_delta', 'text': 'hello'},
              })}',
              '',
              'event: content_block_start',
              'data: ${jsonEncode({
                'type': 'content_block_start',
                'index': 1,
                'content_block': {'type': 'tool_use', 'id': 'toolu_123', 'name': 'lookup', 'input': {}},
              })}',
              '',
              'event: content_block_delta',
              'data: ${jsonEncode({
                'type': 'content_block_delta',
                'index': 1,
                'delta': {'type': 'input_json_delta', 'partial_json': '{"query":"dart"}'},
              })}',
              '',
              'event: message_stop',
              'data: ${jsonEncode({'type': 'message_stop'})}',
            ].join('\n'),
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
          remoteProvider: RemoteLlmProvider.anthropic,
          remoteApiType: RemoteLlmApiType.anthropicMessages,
          remoteAccountId: ModelConfig.dummyRemoteAccountId,
          remoteBaseUrl: 'https://api.anthropic.com/v1',
          remoteModel: 'claude-sonnet-4-5',
        ),
      ).toList();

      expect(chunks, [
        const ChatTextChunk('hello'),
        const ChatFunctionCallChunk(name: 'lookup', args: {'query': 'dart'}),
      ]);
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
              'data: ${jsonEncode({'type': 'response.output_text.delta', 'delta': '<think>planning</think>'})}',
              'data: ${jsonEncode({'type': 'response.output_text.delta', 'delta': 'final answer'})}',
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
                'item': {'type': 'function_call', 'name': 'lookup', 'arguments': ''},
              })}',
              'data: ${jsonEncode({'type': 'response.function_call_arguments.delta', 'output_index': 0, 'delta': '{"query"'})}',
              'data: ${jsonEncode({'type': 'response.function_call_arguments.delta', 'output_index': 0, 'delta': ':"dart"}'})}',
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
      expect(bodies[0].containsKey('temperature'), isFalse);
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

    test(
      'omits sampling parameters for managed cloud remote providers',
      () async {
        final bodies = <Map<String, dynamic>>[];
        final repository = RemoteLlmRepository(
          vault: _MemoryVaultRepository(),
          client: MockClient((request) async {
            bodies.add(jsonDecode(request.body) as Map<String, dynamic>);
            if (request.url.path.endsWith('/messages')) {
              return http.Response(
                jsonEncode({
                  'content': [
                    {'type': 'text', 'text': 'ok'},
                  ],
                }),
                200,
              );
            }
            if (request.url.path.endsWith('/responses')) {
              return http.Response(
                jsonEncode({
                  'output': [
                    {
                      'type': 'message',
                      'role': 'assistant',
                      'content': [
                        {'type': 'output_text', 'text': 'ok'},
                      ],
                    },
                  ],
                }),
                200,
              );
            }
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

        final messages = [
          UserMessage(
            id: 'user',
            content: 'hello',
            conversationId: 'conversation',
            timestamp: DateTime(2026),
          ),
        ];

        await repository
            .generateResponse(
              messages,
              const ModelConfig(
                inferenceMode: ChatInferenceMode.remote,
                remoteProvider: RemoteLlmProvider.openAi,
                remoteApiType: RemoteLlmApiType.openAiResponses,
                remoteAccountId: ModelConfig.dummyRemoteAccountId,
                remoteBaseUrl: 'https://api.openai.com/v1',
                remoteModel: 'gpt-5',
                remoteStreamingEnabled: false,
                temperature: 1.3,
                topK: 8,
              ),
            )
            .toList();
        await repository
            .generateResponse(
              messages,
              const ModelConfig(
                inferenceMode: ChatInferenceMode.remote,
                remoteProvider: RemoteLlmProvider.anthropic,
                remoteApiType: RemoteLlmApiType.anthropicMessages,
                remoteAccountId: ModelConfig.dummyRemoteAccountId,
                remoteBaseUrl: 'https://api.anthropic.com/v1',
                remoteModel: 'claude-sonnet-4-5',
                remoteStreamingEnabled: false,
                temperature: 1.3,
                topK: 8,
              ),
            )
            .toList();
        await repository
            .generateResponse(
              messages,
              const ModelConfig(
                inferenceMode: ChatInferenceMode.remote,
                remoteProvider: RemoteLlmProvider.openRouter,
                remoteApiType: RemoteLlmApiType.openAiChatCompletions,
                remoteAccountId: ModelConfig.dummyRemoteAccountId,
                remoteBaseUrl: 'https://openrouter.ai/api/v1',
                remoteModel: 'openai/gpt-4.1-mini',
                remoteStreamingEnabled: false,
                temperature: 1.3,
                topK: 8,
              ),
            )
            .toList();

        expect(bodies, hasLength(3));
        for (final body in bodies) {
          expect(body.containsKey('temperature'), isFalse);
          expect(body.containsKey('top_k'), isFalse);
          expect(body.containsKey('topK'), isFalse);
        }
      },
    );

    test(
      'keeps temperature for self-hosted OpenAI-compatible providers',
      () async {
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
            temperature: 1.3,
            topK: 8,
          ),
        ).toList();

        expect(body!['temperature'], 1.3);
        expect(body!.containsKey('top_k'), isFalse);
        expect(body!.containsKey('topK'), isFalse);
      },
    );

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
                  'message': {'content': '<think>planning</think>final answer'},
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
  _MemoryVaultRepository([Map<String, String>? values])
    : _values = {...?values};

  final Map<String, String> _values;

  @override
  Future<bool> containsKey({required String key}) async {
    return _values.containsKey(key);
  }

  @override
  Future<void> delete({required String key}) async {
    _values.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _values.clear();
  }

  @override
  Future<String?> read({required String key}) async {
    return _values[key];
  }

  @override
  Future<Map<String, String>> readAll() async {
    return Map.unmodifiable(_values);
  }

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }
}
