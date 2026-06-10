import 'dart:typed_data';
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
  Future<void> loadModel(
    String modelPath, {
    String? backend,
    String? litertDispatchLibDir,
    bool supportImage = false,
    bool supportAudio = false,
  }) {
    throw UnimplementedError('loadModel() has not been implemented.');
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
    return streamChatCompletion(
      model: 'local',
      messages: [
        {'role': 'user', 'content': prompt},
      ],
      maxTokens: maxTokens,
      temperature: temperature,
      topK: topK,
      stop: stopSequences ?? const [],
    ).map(_deltaContent).where((content) => content != null).cast<String>();
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
    throw UnimplementedError(
      'streamChatCompletion() has not been implemented.',
    );
  }

  /// Unloads the model from memory.
  Future<void> unloadModel() {
    throw UnimplementedError('unloadModel() has not been implemented.');
  }
}

class _PlaceholderLocalLlmPlatform extends LocalLlmPlatform {
  @override
  Future<void> loadModel(
    String modelPath, {
    String? backend,
    String? litertDispatchLibDir,
    bool supportImage = false,
    bool supportAudio = false,
  }) async {
    throw UnimplementedError('Local LLM is not supported on this platform.');
  }

  @override
  Stream<String> generateResponse(
    String prompt, {
    int? maxTokens,
    double? temperature,
    int? topK,
    List<String>? stopSequences,
    Uint8List? imageBytes,
    Uint8List? audioBytes,
  }) {
    return Stream.error(
      UnimplementedError('Local LLM is not supported on this platform.'),
    );
  }

  @override
  Stream<Map<String, Object?>> streamChatCompletion({
    required String model,
    required List<Map<String, Object?>> messages,
    int? maxTokens,
    double? temperature,
    double? topP,
    int? topK,
    List<String> stop = const [],
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

String? _deltaContent(Map<String, Object?> event) {
  final choices = event['choices'];
  if (choices is! List || choices.isEmpty) return null;

  final firstChoice = choices.first;
  if (firstChoice is! Map) return null;

  final delta = firstChoice['delta'];
  if (delta is Map) {
    final content = delta['content'];
    if (content is String) return content;
  }

  final message = firstChoice['message'];
  if (message is Map) {
    final content = message['content'];
    if (content is String) return content;
  }

  return null;
}
