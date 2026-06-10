import 'dart:async';
import 'dart:io';

import 'package:app_chat/app_chat.dart';
import 'package:test/test.dart';

void main() {
  test('local generation configures gpu layers per backend', () async {
    final cases = [
      _BackendCase(GemmaBackend.cpu),
      _BackendCase(GemmaBackend.metal),
      _BackendCase(GemmaBackend.cuda),
      _BackendCase(GemmaBackend.vulkan),
    ];

    for (final testCase in cases) {
      final tempDir = await Directory.systemTemp.createTemp('gsmlg_llama_');
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });
      final modelFile = File('${tempDir.path}/model.gguf')
        ..writeAsStringSync('model');
      final serverFactory = _CapturingLlamaServerFactory();
      final repository = GemmaRepository(
        initialModelPath: modelFile.path,
        llamaServerFactory: serverFactory.call,
      );
      addTearDown(repository.dispose);

      await repository.loadModel(ModelConfig(backend: testCase.backend));
      await repository.generateResponse([
        UserMessage(
          id: 'user',
          content: 'Hello',
          conversationId: 'conversation',
          timestamp: DateTime(2026),
        ),
      ]).toList();

      final effectiveBackend = ModelConfig(
        backend: testCase.backend,
      ).withSupportedBackendForCurrentPlatform().backend;
      final serverConfig = serverFactory.configs.single;
      expect(serverConfig.contextSize, 4096);
      expect(
        serverConfig.gpuLayerCount,
        effectiveBackend.usesGpuLayers ? 99 : 0,
      );
    }
  });

  test(
    'local generation sizes context from configured output tokens',
    () async {
      final serverFactory = _CapturingLlamaServerFactory();
      final repository = await _repositoryWithServerFactory(serverFactory);

      await repository.loadModel(
        const ModelConfig(maxTokens: 8192, backend: GemmaBackend.metal),
      );
      await repository.generateResponse([_userMessage()]).toList();

      expect(serverFactory.configs.single.contextSize, 9216);
    },
  );

  test(
    'local generation uses the current config over the loaded config',
    () async {
      final serverFactory = _CapturingLlamaServerFactory();
      final repository = await _repositoryWithServerFactory(serverFactory);

      await repository.loadModel(
        const ModelConfig(backend: GemmaBackend.metal),
      );
      await repository.generateResponse([
        _userMessage(),
      ], config: const ModelConfig(backend: GemmaBackend.cpu)).toList();

      expect(serverFactory.configs, hasLength(2));
      expect(serverFactory.configs.last.gpuLayerCount, 0);
      expect(serverFactory.sessions.first.isClosed, isTrue);
    },
  );

  test('local generation passes tools to the client stream', () async {
    final serverFactory = _CapturingLlamaServerFactory(
      events: [
        _streamContent('<|tool_'),
        _streamContent('call>call:domain_list_zones{}<tool_call>'),
      ],
    );
    final repository = await _repositoryWithServerFactory(serverFactory);

    await repository.loadModel(const ModelConfig(backend: GemmaBackend.metal));
    final chunks = await repository
        .generateResponse(
          [_userMessage()],
          tools: const [
            {
              'type': 'function',
              'function': {
                'name': 'domain_list_zones',
                'description': 'List configured DNS zones',
                'parameters': {'type': 'object', 'properties': {}},
              },
            },
          ],
        )
        .toList();

    expect(chunks, [
      const ChatFunctionCallChunk(name: 'domain_list_zones', args: {}),
    ]);
  });

  test(
    'local generation consumes OpenAI tool calls from server stream',
    () async {
      final serverFactory = _CapturingLlamaServerFactory(
        events: const [
          {
            'choices': [
              {
                'delta': {
                  'tool_calls': [
                    {
                      'index': 0,
                      'type': 'function',
                      'function': {
                        'name': 'domain_list_zones',
                        'arguments': '{}',
                      },
                    },
                  ],
                },
                'finish_reason': 'tool_calls',
              },
            ],
          },
        ],
      );
      final repository = await _repositoryWithServerFactory(serverFactory);

      await repository.loadModel(
        const ModelConfig(backend: GemmaBackend.metal),
      );
      final chunks = await repository.generateResponse([
        _userMessage(),
      ]).toList();

      expect(chunks, [
        const ChatFunctionCallChunk(name: 'domain_list_zones', args: {}),
      ]);
    },
  );

  test('local generation parses Gemma thinking tags', () async {
    final serverFactory = _CapturingLlamaServerFactory(
      events: [
        _streamContent('<|think|>plan'),
        _streamContent('ning</think>final answer'),
      ],
    );
    final repository = await _repositoryWithServerFactory(serverFactory);

    await repository.loadModel(const ModelConfig(backend: GemmaBackend.metal));
    final chunks = await repository.generateResponse([_userMessage()]).toList();

    expect(
      chunks
          .whereType<ChatThinkingChunk>()
          .map((chunk) => chunk.content)
          .join(),
      'planning',
    );
    expect(chunks.whereType<ChatTextChunk>().single.text, 'final answer');
  });

  test('unloadModel closes the active local llama server', () async {
    final serverFactory = _CapturingLlamaServerFactory();
    final repository = await _repositoryWithServerFactory(serverFactory);

    await repository.loadModel(const ModelConfig(backend: GemmaBackend.cpu));
    expect(serverFactory.sessions.single.isClosed, isFalse);

    await repository.unloadModel();

    expect(serverFactory.sessions.single.isClosed, isTrue);
  });
}

class _BackendCase {
  const _BackendCase(this.backend);

  final GemmaBackend backend;
}

class _CapturingLlamaServerFactory {
  _CapturingLlamaServerFactory({List<Map<String, Object?>>? events})
    : events = events ?? [_streamContent('ok')];

  final List<Map<String, Object?>> events;
  final configs = <LocalLlamaServerConfig>[];
  final sessions = <_CapturingLlamaServerSession>[];

  Future<LocalLlamaServerSession> call(LocalLlamaServerConfig config) async {
    configs.add(config);
    final session = _CapturingLlamaServerSession(events);
    sessions.add(session);
    return session;
  }
}

class _CapturingLlamaServerSession implements LocalLlamaServerSession {
  _CapturingLlamaServerSession(this.events);

  final List<Map<String, Object?>> events;
  var isClosed = false;
  List<Map<String, Object?>>? messages;
  int? maxTokens;
  double? temperature;
  List<String>? stop;

  @override
  Future<void> close() async {
    isClosed = true;
  }

  @override
  Stream<Map<String, Object?>> streamChatCompletion({
    required String model,
    required List<Map<String, Object?>> messages,
    int? maxTokens,
    double? temperature,
    double? topP,
    List<String> stop = const [],
  }) async* {
    this.messages = messages;
    this.maxTokens = maxTokens;
    this.temperature = temperature;
    this.stop = stop;
    yield* Stream<Map<String, Object?>>.fromIterable(events);
  }
}

Future<GemmaRepository> _repositoryWithServerFactory(
  _CapturingLlamaServerFactory serverFactory,
) async {
  final tempDir = await Directory.systemTemp.createTemp('gsmlg_llama_');
  final modelFile = File('${tempDir.path}/model.gguf')
    ..writeAsStringSync('model');
  final repository = GemmaRepository(
    initialModelPath: modelFile.path,
    llamaServerFactory: serverFactory.call,
  );
  addTearDown(() async {
    await repository.dispose();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });
  return repository;
}

UserMessage _userMessage() {
  return UserMessage(
    id: 'user',
    content: 'Hello',
    conversationId: 'conversation',
    timestamp: DateTime(2026),
  );
}

Map<String, Object?> _streamContent(String content) {
  return {
    'choices': [
      {
        'delta': {'content': content},
      },
    ],
  };
}
