import 'dart:async';

import 'package:app_local_llm_platform_interface/app_local_llm_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:lib_mlx/lib_mlx.dart';

const _localModelId = 'local';
const _defaultMaxOutputTokens = 256;
const _defaultTemperature = 0.8;
const _defaultTopK = 40;
const _serviceChannel = MethodChannel('app_local_llm_ios/service');

/// The iOS implementation of [LocalLlmPlatform] using `lib_mlx`.
class LocalLlmIos extends LocalLlmPlatform {
  LocalLlmIos();

  /// Registers this class as the default instance of [LocalLlmPlatform].
  static void registerWith() {
    LocalLlmPlatform.instance = LocalLlmIos();
  }

  final LibMlxRuntime _runtime = const LibMlxRuntime();
  MlxModelHandle? _handle;
  LibMlxOpenAiClient? _openAiClient;

  @override
  Future<void> startService({
    String title = 'Local LLM',
    String message = 'Local model is running.',
  }) {
    return _serviceChannel.invokeMethod<void>('startService', {
      'title': title,
      'message': message,
    });
  }

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
      final handle = await _runtime.loadModel(
        MlxModelConfig(modelPath: modelPath, modelId: _localModelId),
      );
      final server = await _runtime.startServer(
        handle,
        config: const MlxServerConfig(modelId: _localModelId),
      );
      _handle = handle;
      _openAiClient = LibMlxOpenAiClient(baseUri: server.uri);
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
    if (imageBytes != null || audioBytes != null) {
      throw UnsupportedError(
        'lib_mlx OpenAI server multimodal input is not wired yet.',
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
  }) async* {
    final client = _openAiClient;
    if (_handle == null || client == null) {
      throw StateError('No model loaded. Call loadModel() first.');
    }

    final request = <String, Object?>{'model': model, 'messages': messages};
    if (maxTokens != null) request['max_tokens'] = maxTokens;
    if (temperature != null) request['temperature'] = temperature;
    if (topP != null) request['top_p'] = topP;
    if (topK != null) request['top_k'] = topK;
    if (stop.isNotEmpty) request['stop'] = stop;

    await for (final event in client.chatCompletionsStream(request)) {
      if (!event.done && event.data != null) {
        yield event.data!;
      }
    }
  }

  @override
  Future<void> unloadModel() async {
    final handle = _handle;
    final client = _openAiClient;
    _handle = null;
    _openAiClient = null;

    client?.close(force: true);
    if (handle == null) return;

    try {
      await _runtime.stopServer(handle);
    } finally {
      await _runtime.unloadModel(handle);
    }
  }

  @override
  Future<void> stopService() {
    return _serviceChannel.invokeMethod<void>('stopService');
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
