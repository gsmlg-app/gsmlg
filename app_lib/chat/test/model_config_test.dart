import 'package:app_chat/src/models/model_config.dart';
import 'package:test/test.dart';

void main() {
  group('GemmaBackend', () {
    test('exposes selectable llama.cpp backends', () {
      expect(GemmaBackend.values, [
        GemmaBackend.cpu,
        GemmaBackend.metal,
        GemmaBackend.cuda,
        GemmaBackend.vulkan,
      ]);
      expect(ModelConfig.defaultConfig.backend, GemmaBackend.cpu);
      expect(
        defaultGemmaBackendForOperatingSystem('macos'),
        GemmaBackend.metal,
      );
      expect(defaultGemmaBackendForOperatingSystem('linux'), GemmaBackend.cpu);
      expect(GemmaBackend.cpu.displayName, 'CPU');
      expect(GemmaBackend.metal.displayName, 'Metal');
      expect(GemmaBackend.cuda.displayName, 'CUDA');
      expect(GemmaBackend.vulkan.displayName, 'Vulkan');
    });

    test('filters selectable backends by operating system', () {
      expect(supportedGemmaBackendsForOperatingSystem('macos'), [
        GemmaBackend.cpu,
        GemmaBackend.metal,
      ]);
      expect(supportedGemmaBackendsForOperatingSystem('ios'), [
        GemmaBackend.cpu,
        GemmaBackend.metal,
      ]);
      expect(supportedGemmaBackendsForOperatingSystem('linux'), [
        GemmaBackend.cpu,
        GemmaBackend.cuda,
        GemmaBackend.vulkan,
      ]);
      expect(supportedGemmaBackendsForOperatingSystem('windows'), [
        GemmaBackend.cpu,
        GemmaBackend.cuda,
        GemmaBackend.vulkan,
      ]);
      expect(supportedGemmaBackendsForOperatingSystem('android'), [
        GemmaBackend.cpu,
        GemmaBackend.vulkan,
      ]);
      expect(supportedGemmaBackendsForOperatingSystem('fuchsia'), [
        GemmaBackend.cpu,
      ]);
    });

    test('normalizes unsupported backends to the platform default', () {
      expect(
        const ModelConfig(
          backend: GemmaBackend.metal,
        ).withSupportedBackendForOperatingSystem('linux').backend,
        GemmaBackend.cpu,
      );
      expect(
        const ModelConfig(
          backend: GemmaBackend.vulkan,
        ).withSupportedBackendForOperatingSystem('macos').backend,
        GemmaBackend.metal,
      );
      expect(
        const ModelConfig(
          backend: GemmaBackend.cuda,
        ).withSupportedBackendForOperatingSystem('windows').backend,
        GemmaBackend.cuda,
      );
    });
  });

  group('Gemma 4 GGUF catalog', () {
    test('uses Hugging Face GGUF downloads for E4B and E2B', () {
      final e4b = GemmaModelInfo.findById('gemma-4-E4B-it');
      final e2b = GemmaModelInfo.findById('gemma-4-E2B-it');

      expect(e4b, isNotNull);
      expect(e2b, isNotNull);

      expect(
        e4b!.downloadUrl,
        'https://huggingface.co/ggml-org/gemma-4-E4B-it-GGUF/resolve/main/gemma-4-E4B-it-Q4_K_M.gguf',
      );
      expect(e4b.effectiveSizeLabel, '5.34 GB');
      expect(e4b.quantizationLabel, 'Q4_K_M');
      expect(e4b.isFourBitGguf, isTrue);
      expect(e4b.isGguf, isTrue);
      expect(e4b.isHuggingFaceDownload, isTrue);
      expect(e4b.huggingFaceRepoPath, 'ggml-org/gemma-4-E4B-it-GGUF');
      expect(e4b.downloadFileName, 'gemma-4-E4B-it-Q4_K_M.gguf');
      expect(e4b.supportsMultimodal, isFalse);
      expect(e4b.supportsAudio, isFalse);
      expect(e4b.supportsFunctionCalls, isFalse);
      expect(e4b.memoryRequirement, GemmaModelMemoryRequirement.standard);
      expect(e4b.requiresLargeMemory, isFalse);
      expect(e4b.memoryRequirementLabel, 'Uses system memory while loaded');
      expect(e4b.localInferenceBlockReason, isNull);

      expect(
        e2b!.downloadUrl,
        'https://huggingface.co/dahus/gemma-4-e2b-it-Q4_K_M-GGUF/resolve/main/gemma-4-e2b-Q4_K_M.gguf',
      );
      expect(e2b.effectiveSizeLabel, '3.43 GB');
      expect(e2b.quantizationLabel, 'Q4_K_M');
      expect(e2b.isFourBitGguf, isTrue);
      expect(e2b.isGguf, isTrue);
      expect(e2b.isHuggingFaceDownload, isTrue);
      expect(e2b.huggingFaceRepoPath, 'dahus/gemma-4-e2b-it-Q4_K_M-GGUF');
      expect(e2b.downloadFileName, 'gemma-4-e2b-Q4_K_M.gguf');
      expect(e2b.supportsMultimodal, isFalse);
      expect(e2b.supportsAudio, isFalse);
      expect(e2b.supportsFunctionCalls, isFalse);
      expect(e2b.memoryRequirement, GemmaModelMemoryRequirement.standard);
      expect(e2b.requiresLargeMemory, isFalse);
      expect(e2b.memoryRequirementLabel, 'Uses system memory while loaded');
      expect(e2b.localInferenceBlockReason, isNull);
    });

    test('uses Gemma 4 E2B as the safe default local model', () {
      expect(GemmaModelInfo.defaultModel.id, 'gemma-4-E2B-it');
      expect(GemmaModelInfo.smallestFreeModel?.id, 'gemma-4-E2B-it');
    });

    test('exposes only GGUF local models', () {
      expect(GemmaModelInfo.availableModels, isNotEmpty);
      expect(GemmaModelInfo.availableModels.map((model) => model.id).toList(), [
        'gemma-4-E2B-it',
        'gemma-4-E4B-it',
      ]);
      expect(
        GemmaModelInfo.availableModels.every((model) => model.isGguf),
        isTrue,
      );
      expect(
        GemmaModelInfo.availableModels.every((model) => model.isFourBitGguf),
        isTrue,
      );
      expect(
        GemmaModelInfo.platformModels.every((model) => model.isGguf),
        isTrue,
      );
    });

    test('describes preset Hugging Face download source', () {
      final e4b = GemmaModelInfo.findById('gemma-4-E4B-it')!;
      final e2b = GemmaModelInfo.findById('gemma-4-E2B-it')!;

      expect(e4b.downloadSourceName, 'Hugging Face');
      expect(e4b.downloadSourceLabel, 'ggml-org/gemma-4-E4B-it-GGUF');
      expect(e2b.downloadSourceName, 'Hugging Face');
      expect(e2b.downloadSourceLabel, 'dahus/gemma-4-e2b-it-Q4_K_M-GGUF');
    });
  });
}
