import 'dart:async';
import 'dart:io';

import 'package:app_chat/app_chat.dart';
import 'package:lib_llama_cpp/lib_llama_cpp.dart' as llama;
import 'package:lib_llama_cpp_platform_interface/lib_llama_cpp_platform_interface.dart'
    as llama_platform;
import 'package:test/test.dart';

void main() {
  test('local generation requests a supported llama.cpp backend', () async {
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
      final request = engine.libraryRequest;
      expect(request, isNotNull);
      expect(request!.requiredCapabilities, {
        _capabilityForBackend(effectiveBackend),
      });
      final loadCommand = engine.commands
          .whereType<llama.LlamaLoadModelCommand>()
          .single;
      expect(
        loadCommand.gpuLayerCount,
        effectiveBackend.usesGpuLayers ? 99 : 0,
      );
    }
  });

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

      final request = engine.libraryRequest;
      expect(request, isNotNull);
      expect(request!.requiredCapabilities, {
        llama_platform.LlamaCppLibraryCapability.cpu,
      });
      final loadCommand = engine.commands
          .whereType<llama.LlamaLoadModelCommand>()
          .single;
      expect(loadCommand.gpuLayerCount, 0);
    },
  );
}

class _BackendCase {
  const _BackendCase(this.backend);

  final GemmaBackend backend;
}

llama_platform.LlamaCppLibraryCapability _capabilityForBackend(
  GemmaBackend backend,
) {
  return switch (backend) {
    GemmaBackend.cpu => llama_platform.LlamaCppLibraryCapability.cpu,
    GemmaBackend.metal => llama_platform.LlamaCppLibraryCapability.metal,
    GemmaBackend.cuda => llama_platform.LlamaCppLibraryCapability.cuda,
    GemmaBackend.vulkan => llama_platform.LlamaCppLibraryCapability.vulkan,
  };
}

class _CapturingLlamaEngine implements llama.LlamaEngine {
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
    yield const llama.LlamaTokenResponse(text: 'ok', index: 0);
    yield const llama.LlamaDoneResponse();
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
