import 'dart:io';
import 'dart:typed_data';
import 'package:app_local_llm_platform_interface/app_local_llm_platform_interface.dart';
import 'package:app_local_llm_android/local_llm_android.dart';
import 'package:app_local_llm_ios/local_llm_ios.dart';

/// Main class for LocalLlm plugin.
///
/// Provides a unified API for accessing local LLM operations
/// across supported platforms.
class LocalLlm {
  LocalLlm._() {
    // Manually register platform-specific implementations.
    if (Platform.isAndroid) {
      LocalLlmAndroid.registerWith();
    } else if (Platform.isIOS) {
      LocalLlmIos.registerWith();
    }
  }

  /// Get the singleton instance of LocalLlm.
  static final LocalLlm instance = LocalLlm._();

  /// Loads the local model into memory.
  Future<void> loadModel(
    String modelPath, {
    String? backend,
    String? litertDispatchLibDir,
    bool supportImage = false,
    bool supportAudio = false,
  }) {
    return LocalLlmPlatform.instance.loadModel(
      modelPath,
      backend: backend,
      litertDispatchLibDir: litertDispatchLibDir,
      supportImage: supportImage,
      supportAudio: supportAudio,
    );
  }

  /// Generates response tokens streaming from the loaded model.
  Stream<String> generateResponse(
    String prompt, {
    int? maxTokens,
    double? temperature,
    int? topK,
    List<String>? stopSequences,
    Uint8List? imageBytes,
    Uint8List? audioBytes,
  }) {
    return LocalLlmPlatform.instance.generateResponse(
      prompt,
      maxTokens: maxTokens,
      temperature: temperature,
      topK: topK,
      stopSequences: stopSequences,
      imageBytes: imageBytes,
      audioBytes: audioBytes,
    );
  }

  /// Streams OpenAI-compatible chat completion events from the loaded model.
  Stream<Map<String, Object?>> streamChatCompletion({
    required String model,
    required List<Map<String, Object?>> messages,
    int? maxTokens,
    double? temperature,
    double? topP,
    int? topK,
    List<String> stop = const [],
  }) {
    return LocalLlmPlatform.instance.streamChatCompletion(
      model: model,
      messages: messages,
      maxTokens: maxTokens,
      temperature: temperature,
      topP: topP,
      topK: topK,
      stop: stop,
    );
  }

  /// Unloads the model from memory.
  Future<void> unloadModel() {
    return LocalLlmPlatform.instance.unloadModel();
  }
}
