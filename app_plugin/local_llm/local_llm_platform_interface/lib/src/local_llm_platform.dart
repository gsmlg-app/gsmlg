import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that platform-specific implementations of
/// `app_local_llm` must extend.
abstract class LocalLlmPlatform extends PlatformInterface {
  /// Constructs a LocalLlmPlatform.
  LocalLlmPlatform() : super(token: _token);

  static final Object _token = Object();

  static LocalLlmPlatform _instance = _PlaceholderLocalLlmPlatform();

  /// The default instance of [LocalLlmPlatform] to use.
  static LocalLlmPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own
  /// platform-specific class that extends [LocalLlmPlatform] when
  /// they register themselves.
  static set instance(LocalLlmPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Loads the local model into memory.
  Future<void> loadModel(String modelPath) {
    throw UnimplementedError('loadModel() has not been implemented.');
  }

  /// Generates response tokens streaming from the loaded model.
  Stream<String> generateResponse(
    String prompt, {
    int? maxTokens,
    double? temperature,
    List<String>? stopSequences,
  }) {
    throw UnimplementedError('generateResponse() has not been implemented.');
  }

  /// Unloads the model from memory.
  Future<void> unloadModel() {
    throw UnimplementedError('unloadModel() has not been implemented.');
  }
}

class _PlaceholderLocalLlmPlatform extends LocalLlmPlatform {
  @override
  Future<void> loadModel(String modelPath) async {
    throw UnimplementedError('Local LLM is not supported on this platform.');
  }

  @override
  Stream<String> generateResponse(
    String prompt, {
    int? maxTokens,
    double? temperature,
    List<String>? stopSequences,
  }) {
    return Stream.error(
      UnimplementedError('Local LLM is not supported on this platform.'),
    );
  }

  @override
  Future<void> unloadModel() async {
    throw UnimplementedError('Local LLM is not supported on this platform.');
  }
}
