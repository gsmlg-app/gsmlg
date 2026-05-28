import 'dart:async';
import 'dart:typed_data';
import 'package:app_local_llm_platform_interface/app_local_llm_platform_interface.dart';
import 'package:flutter_litert_lm/flutter_litert_lm.dart';
import 'package:flutter_litert_lm/flutter_litert_lm_platform_interface.dart';

/// The Android implementation of [LocalLlmPlatform] using `flutter_litert_lm`.
class LocalLlmAndroid extends LocalLlmPlatform {
  /// Registers this class as the default instance of [LocalLlmPlatform].
  static void registerWith() {
    LocalLlmPlatform.instance = LocalLlmAndroid();
  }

  LiteLmEngine? _engine;
  LiteLmConversation? _conversation;

  @override
  Future<void> loadModel(
    String modelPath, {
    bool supportImage = false,
    bool supportAudio = false,
  }) async {
    await unloadModel();
    try {
      // By default we use the CPU backend for safety, but can be configured otherwise if needed.
      final config = LiteLmEngineConfig(
        modelPath: modelPath,
        backend: LiteLmBackend.cpu,
        visionBackend: supportImage ? LiteLmBackend.cpu : null,
        audioBackend: supportAudio ? LiteLmBackend.cpu : null,
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
    Uint8List? imageBytes,
    Uint8List? audioBytes,
  }) {
    final conversation = _conversation;
    if (conversation == null) {
      return Stream.error(
          StateError('No model loaded. Call loadModel() first.'));
    }

    final contents = <Map<String, dynamic>>[
      LiteLmContent.text(prompt).toMap(),
      if (imageBytes != null) LiteLmContent.imageBytes(imageBytes).toMap(),
      if (audioBytes != null) LiteLmContent.audioBytes(audioBytes).toMap(),
    ];

    return FlutterLitertLmPlatform.instance
        .sendMessageStream(conversation.id, contents, null)
        .map((map) => LiteLmMessage.fromMap(map).text);
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
