import 'dart:async';
import 'package:app_local_llm_platform_interface/app_local_llm_platform_interface.dart';
import 'package:flutter_litert_lm/flutter_litert_lm.dart';

/// The Android implementation of [LocalLlmPlatform] using `flutter_litert_lm`.
class LocalLlmAndroid extends LocalLlmPlatform {
  /// Registers this class as the default instance of [LocalLlmPlatform].
  static void registerWith() {
    LocalLlmPlatform.instance = LocalLlmAndroid();
  }

  LiteLmEngine? _engine;
  LiteLmConversation? _conversation;

  @override
  Future<void> loadModel(String modelPath) async {
    await unloadModel();
    try {
      // By default we use the CPU backend for safety, but can be configured otherwise if needed.
      final config = LiteLmEngineConfig(
        modelPath: modelPath,
        backend: LiteLmBackend.cpu,
      );
      _engine = await LiteLmEngine.create(config);
      _conversation = await _engine!.createConversation();
    } catch (e) {
      await unloadModel();
      rethrow;
    }
  }

  @override
  Stream<String> generateResponse(
    String prompt, {
    int? maxTokens,
    double? temperature,
    List<String>? stopSequences,
  }) {
    final conversation = _conversation;
    if (conversation == null) {
      return Stream.error(
          StateError('No model loaded. Call loadModel() first.'));
    }

    // We can also configure LiteLmConversation settings if needed, but standard sendMessageStream
    // is sufficient for basic generation.
    return conversation.sendMessageStream(prompt).map((msg) => msg.text);
  }

  @override
  Future<void> unloadModel() async {
    if (_conversation != null) {
      try {
        await _conversation!.dispose();
      } catch (_) {}
      _conversation = null;
    }
    if (_engine != null) {
      try {
        await _engine!.dispose();
      } catch (_) {}
      _engine = null;
    }
  }
}
