import 'dart:async';
import 'dart:typed_data';
import 'package:app_local_llm_platform_interface/app_local_llm_platform_interface.dart';
import 'package:lib_litert_lm/lib_litert_lm.dart';

const _defaultMaxNumTokens = 4096;
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
  LiteRtLmSession? _activeSession;

  @override
  Future<void> loadModel(
    String modelPath, {
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
            backend: 'cpu',
            maxNumTokens: _defaultMaxNumTokens,
          ),
        ),
      );

      _client = client;
      _engine = engine;
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

    await _activeSession?.cancel();
    await _activeSession?.dispose();
    _activeSession = null;

    final session = _requireOk(
      await engine.createSession(
        params: LiteRtLmGenerationParams(
          maxTokens: maxTokens ?? _defaultMaxOutputTokens,
          temperature: temperature ?? _defaultTemperature,
          topK: topK ?? _defaultTopK,
        ),
      ),
    );
    _activeSession = session;

    try {
      await for (final event in session.generateStream(prompt)) {
        switch (event) {
          case LiteRtLmToken(:final text):
            yield text;
          case LiteRtLmCompleted():
            return;
          case LiteRtLmFailed(:final error):
            throw StateError(_formatFailure(error));
          case LiteRtLmCancelledEvent():
            return;
        }
      }
    } finally {
      if (identical(_activeSession, session)) {
        _activeSession = null;
      }
      await session.dispose();
    }
  }

  @override
  Future<void> unloadModel() async {
    final session = _activeSession;
    final engine = _engine;
    final client = _client;
    _activeSession = null;
    _engine = null;
    _client = null;

    await session?.cancel();
    await session?.dispose();
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
