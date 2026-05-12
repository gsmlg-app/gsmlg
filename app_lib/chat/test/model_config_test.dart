import 'package:app_chat/app_chat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
      expect(e4b.effectiveSizeLabel, '5.0 GB');
      expect(e4b.isGguf, isTrue);
      expect(e4b.isHuggingFaceDownload, isTrue);
      expect(e4b.huggingFaceRepoPath, 'ggml-org/gemma-4-E4B-it-GGUF');
      expect(e4b.downloadFileName, 'gemma-4-E4B-it-Q4_K_M.gguf');
      expect(e4b.supportsMultimodal, isFalse);
      expect(e4b.supportsAudio, isFalse);
      expect(e4b.supportsFunctionCalls, isFalse);

      expect(
        e2b!.downloadUrl,
        'https://huggingface.co/ggml-org/gemma-4-E2B-it-GGUF/resolve/main/gemma-4-E2B-it-Q8_0.gguf',
      );
      expect(e2b.effectiveSizeLabel, '4.6 GB');
      expect(e2b.isGguf, isTrue);
      expect(e2b.isHuggingFaceDownload, isTrue);
      expect(e2b.huggingFaceRepoPath, 'ggml-org/gemma-4-E2B-it-GGUF');
      expect(e2b.downloadFileName, 'gemma-4-E2B-it-Q8_0.gguf');
      expect(e2b.supportsMultimodal, isFalse);
      expect(e2b.supportsAudio, isFalse);
      expect(e2b.supportsFunctionCalls, isFalse);
    });

    test('makes Gemma 4 E4B the default local model', () {
      expect(GemmaModelInfo.defaultModel.id, 'gemma-4-E4B-it');
      expect(GemmaModelInfo.smallestFreeModel?.id, 'gemma-4-E4B-it');
    });
  });
}
