import 'dart:io';

import 'package:app_chat/app_chat.dart';
import 'package:test/test.dart';

const _enabled = bool.fromEnvironment(
  'GSMLG_ENABLE_LOCAL_LLM',
  defaultValue: true,
);

void main() {
  test('local model availability follows the build flag', () {
    if (_enabled) {
      expect(GemmaModelInfo.platformModels, GemmaModelInfo.availableModels);
      expect(GemmaModelInfo.smallestFreeModel?.id, 'gemma-4-E2B-it');
      expect(GemmaModelInfo.defaultModel.isCurrentPlatformCompatible, isTrue);
    } else {
      expect(GemmaModelInfo.platformModels, isEmpty);
      expect(GemmaModelInfo.smallestFreeModel, isNull);
      expect(GemmaModelInfo.defaultModel.isCurrentPlatformCompatible, isFalse);
    }
  });

  test('saved model IDs remain identifiable in builds without local LLMs', () {
    expect(
      GemmaModelInfo.findById('gemma-4-E2B-it'),
      GemmaModelInfo.defaultModel,
    );
  });

  test(
    'a disabled build refuses an installed model before native loading',
    () async {
      final directory = await Directory.systemTemp.createTemp('gsmlg_no_llm_');
      addTearDown(() => directory.delete(recursive: true));
      final model = File('${directory.path}/model.gguf')
        ..writeAsStringSync('model');
      var nativeStarted = false;
      final repository = GemmaRepository(
        initialModelPath: model.path,
        llamaLibraryResolver: (_, {String? proxyUrl}) async {
          nativeStarted = true;
          return null;
        },
        llamaServerFactory: (_) async {
          nativeStarted = true;
          throw StateError('Native inference must not start in this build.');
        },
      );
      addTearDown(repository.dispose);

      await repository.loadModel(const ModelConfig());

      expect(nativeStarted, isFalse);
      expect(repository.status, GemmaModelStatus.error);
      expect(repository.isReady, isFalse);
      expect(repository.lastError, contains('not included in this build'));
    },
    skip: _enabled
        ? 'Run with --dart-define=GSMLG_ENABLE_LOCAL_LLM=false'
        : false,
  );
}
