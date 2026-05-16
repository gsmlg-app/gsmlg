import 'dart:async';
import 'dart:io';

import 'package:app_chat/app_chat.dart';
import 'package:lib_llama_cpp/lib_llama_cpp.dart' as llama;
import 'package:lib_llama_cpp_platform_interface/lib_llama_cpp_platform_interface.dart'
    as llama_platform;
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
      final engine = _CapturingLlamaEngine();
      final repository = GemmaRepository(
        llamaEngine: engine,
        initialModelPath: modelFile.path,
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
      final loadCommand = engine.commands
          .whereType<llama.LlamaLoadModelCommand>()
          .single;
      expect(loadCommand.contextSize, 4096);
      expect(
        loadCommand.gpuLayerCount,
        effectiveBackend.usesGpuLayers ? 99 : 0,
      );
    }
  });

  test(
    'local generation sizes context from configured output tokens',
    () async {
      final engine = _CapturingLlamaEngine();
      final repository = await _repositoryWithEngine(engine);

      await repository.loadModel(
        const ModelConfig(maxTokens: 8192, backend: GemmaBackend.metal),
      );
      await repository.generateResponse([_userMessage()]).toList();

      final loadCommand = engine.commands
          .whereType<llama.LlamaLoadModelCommand>()
          .single;
      expect(loadCommand.contextSize, 9216);
    },
  );

  test(
    'local generation uses the current config over the loaded config',
    () async {
      final engine = _CapturingLlamaEngine();
      final repository = await _repositoryWithEngine(engine);

      await repository.loadModel(
        const ModelConfig(backend: GemmaBackend.metal),
      );
      await repository.generateResponse([
        _userMessage(),
      ], config: const ModelConfig(backend: GemmaBackend.cpu)).toList();

      final loadCommand = engine.commands
          .whereType<llama.LlamaLoadModelCommand>()
          .single;
      expect(loadCommand.gpuLayerCount, 0);
    },
  );

  test('local generation passes tools to the client stream', () async {
    final engine = _CapturingLlamaEngine(
      responses: const [
        llama.LlamaTokenResponse(text: '<|tool_', index: 0),
        llama.LlamaTokenResponse(
          text: 'call>call:domain_list_zones{}<tool_call>',
          index: 1,
        ),
        llama.LlamaDoneResponse(),
      ],
    );
    final repository = await _repositoryWithEngine(engine);

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

  test('local generation parses Gemma thinking tags', () async {
    final engine = _CapturingLlamaEngine(
      responses: const [
        llama.LlamaTokenResponse(text: '<|think|>plan', index: 0),
        llama.LlamaTokenResponse(text: 'ning</think>final answer', index: 1),
        llama.LlamaDoneResponse(),
      ],
    );
    final repository = await _repositoryWithEngine(engine);

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
}

class _BackendCase {
  const _BackendCase(this.backend);

  final GemmaBackend backend;
}

class _CapturingLlamaEngine implements llama.LlamaEngine {
  _CapturingLlamaEngine({
    this.responses = const [
      llama.LlamaTokenResponse(text: 'ok', index: 0),
      llama.LlamaDoneResponse(),
    ],
  });

  final List<llama.LlamaResponse> responses;
  llama_platform.LlamaCppLibraryRequest? libraryRequest;
  List<llama.LlamaCommand> commands = const [];

  @override
  Stream<llama.LlamaResponse> transform(
    Stream<llama.LlamaCommand> commands, {
    llama.LlamaState initialState = const llama.LlamaState.empty(),
    llama_platform.LlamaCppLibraryRequest libraryRequest =
        const llama_platform.LlamaCppLibraryRequest(),
  }) async* {
    this.libraryRequest = libraryRequest;
    this.commands = await commands.toList();
    yield* Stream<llama.LlamaResponse>.fromIterable(responses);
  }
}

Future<GemmaRepository> _repositoryWithEngine(llama.LlamaEngine engine) async {
  final tempDir = await Directory.systemTemp.createTemp('gsmlg_llama_');
  final modelFile = File('${tempDir.path}/model.gguf')
    ..writeAsStringSync('model');
  final repository = GemmaRepository(
    llamaEngine: engine,
    initialModelPath: modelFile.path,
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
