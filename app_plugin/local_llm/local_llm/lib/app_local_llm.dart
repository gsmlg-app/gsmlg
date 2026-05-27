import 'dart:io';
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
  Future<void> loadModel(String modelPath) {
    return LocalLlmPlatform.instance.loadModel(modelPath);
  }

  /// Generates response tokens streaming from the loaded model.
  Stream<String> generateResponse(
    String prompt, {
    int? maxTokens,
    double? temperature,
    List<String>? stopSequences,
  }) {
    return LocalLlmPlatform.instance.generateResponse(
      prompt,
      maxTokens: maxTokens,
      temperature: temperature,
      stopSequences: stopSequences,
    );
  }

  /// Unloads the model from memory.
  Future<void> unloadModel() {
    return LocalLlmPlatform.instance.unloadModel();
  }
}
