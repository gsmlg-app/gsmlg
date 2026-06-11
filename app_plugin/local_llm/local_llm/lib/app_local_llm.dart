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
  }) async {
    var serviceStarted = false;
    try {
      await LocalLlmPlatform.instance.startService();
      serviceStarted = true;
      await LocalLlmPlatform.instance.loadModel(
        modelPath,
        backend: backend,
        litertDispatchLibDir: litertDispatchLibDir,
        supportImage: supportImage,
        supportAudio: supportAudio,
      );
    } catch (_) {
      if (serviceStarted) {
        await LocalLlmPlatform.instance.stopService();
      }
      rethrow;
    }
  }

  /// Starts the platform service that keeps local inference user-visible.
  Future<void> startService({
    String title = 'Local LLM',
    String message = 'Local model is running.',
  }) {
    return LocalLlmPlatform.instance.startService(
      title: title,
      message: message,
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
  Future<void> unloadModel() async {
    try {
      await LocalLlmPlatform.instance.unloadModel();
    } finally {
      await LocalLlmPlatform.instance.stopService();
    }
  }

  /// Stops the platform service that keeps local inference user-visible.
  Future<void> stopService() {
    return LocalLlmPlatform.instance.stopService();
  }
}
