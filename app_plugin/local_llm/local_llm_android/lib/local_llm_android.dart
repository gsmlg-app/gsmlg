import 'dart:async';
import 'dart:typed_data';
import 'package:app_local_llm_platform_interface/app_local_llm_platform_interface.dart';
import 'package:lib_litert_lm/lib_litert_lm.dart';

const _localModelId = 'local';
const _defaultMaxNumTokens = 2048;
const _defaultMaxOutputTokens = 256;
const _defaultTemperature = 0.8;
const _defaultTopK = 40;

/// The Android implementation of [LocalLlmPlatform] using `lib_litert_lm`.
class LocalLlmAndroid extends LocalLlmPlatform {
  /// Registers this class as the default instance of [LocalLlmPlatform].
  static void registerWith() {
    LocalLlmPlatform.instance = LocalLlmAndroid();
  }

  LiteRtLm? _client;
  LiteRtLmEngine? _engine;
  LiteRtLmOpenAiServer? _server;
  LocalOpenAiChatCompletionsClient? _openAiClient;

  @override
  Future<void> loadModel(
    String modelPath, {
    String? backend,
    String? litertDispatchLibDir,
    bool supportImage = false,
    bool supportAudio = false,
  }) async {
    await unloadModel();
    try {
      final client = _requireOk(await LiteRtLm.create());
      final engine = _requireOk(
        await client.loadEngine(
          LiteRtLmEngineConfig(
            modelPath: modelPath,
            backend: backend ?? 'cpu',
            litertDispatchLibDir: litertDispatchLibDir,
            maxNumTokens: _defaultMaxNumTokens,
          ),
        ),
      );
      final server = LiteRtLmOpenAiServer(
        engine: engine,
        config: const LiteRtLmOpenAiServerConfig(modelId: _localModelId),
      );
      _requireOk(await server.bind(port: 0));
      final serverUri = server.uri;
      if (serverUri == null) {
        throw StateError('LiteRT-LM OpenAI server did not return a URI.');
      }

      _client = client;
      _engine = engine;
      _server = server;
      _openAiClient = LocalOpenAiChatCompletionsClient(baseUri: serverUri);
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
    int? topK,
    List<String>? stopSequences,
    Uint8List? imageBytes,
    Uint8List? audioBytes,
  }) async* {
    final engine = _engine;
    if (engine == null) {
      throw StateError('No model loaded. Call loadModel() first.');
    }
    if (imageBytes != null || audioBytes != null) {
      // WORKAROUND(upstream): gsmlg-app/lib_litert_lm#1
      throw UnsupportedError(
        'lib_litert_lm does not support multimodal input yet.',
      );
    }

    await for (final event in streamChatCompletion(
      model: _localModelId,
      messages: [
        {'role': 'user', 'content': prompt},
      ],
      maxTokens: maxTokens ?? _defaultMaxOutputTokens,
      temperature: temperature ?? _defaultTemperature,
      topK: topK ?? _defaultTopK,
      stop: stopSequences ?? const [],
    )) {
      final content = _deltaContent(event);
      if (content != null && content.isNotEmpty) {
        yield content;
      }
    }
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
    final client = _openAiClient;
    if (_engine == null || client == null) {
      return Stream.error(
        StateError('No model loaded. Call loadModel() first.'),
      );
    }
    return client.streamChatCompletion(
      model: model,
      messages: messages,
      maxTokens: maxTokens,
      temperature: temperature,
      topP: topP,
      topK: topK,
      stop: stop,
    );
  }

  @override
  Future<void> unloadModel() async {
    final openAiClient = _openAiClient;
    final server = _server;
    final engine = _engine;
    final client = _client;
    _openAiClient = null;
    _server = null;
    _engine = null;
    _client = null;

    openAiClient?.close(force: true);
    await server?.close();
    await engine?.dispose();
    await client?.dispose();
  }
}

T _requireOk<T>(LiteRtLmResult<T> result) {
  final value = result.valueOrNull;
  if (value != null) return value;
  throw StateError(_formatFailure(result.errorOrNull));
}

String _formatFailure(LiteRtLmFailure? failure) {
  if (failure == null) return 'LiteRT-LM operation failed.';
  return '${failure.code}: ${failure.message}';
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
