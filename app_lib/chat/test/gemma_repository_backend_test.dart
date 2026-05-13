import 'dart:async';
import 'dart:io';

import 'package:app_chat/app_chat.dart';
import 'package:lib_llama_cpp/lib_llama_cpp.dart' as llama;
import 'package:lib_llama_cpp_platform_interface/lib_llama_cpp_platform_interface.dart'
    as llama_platform;
import 'package:test/test.dart';

void main() {
  test('local generation requests the selected llama.cpp backend', () async {
    final cases = [
      _BackendCase(
        GemmaBackend.cpu,
        llama_platform.LlamaCppLibraryCapability.cpu,
        0,
      ),
      _BackendCase(
        GemmaBackend.metal,
        llama_platform.LlamaCppLibraryCapability.metal,
        99,
      ),
      _BackendCase(
        GemmaBackend.cuda,
        llama_platform.LlamaCppLibraryCapability.cuda,
        99,
      ),
      _BackendCase(
        GemmaBackend.vulkan,
        llama_platform.LlamaCppLibraryCapability.vulkan,
        99,
      ),
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

      final request = engine.libraryRequest;
      expect(request, isNotNull);
      expect(request!.requiredCapabilities, {testCase.capability});
      final loadCommand = engine.commands
          .whereType<llama.LlamaLoadModelCommand>()
          .single;
      expect(loadCommand.gpuLayerCount, testCase.gpuLayerCount);
    }
  });
}

class _BackendCase {
  const _BackendCase(this.backend, this.capability, this.gpuLayerCount);

  final GemmaBackend backend;
  final llama_platform.LlamaCppLibraryCapability capability;
  final int gpuLayerCount;
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
