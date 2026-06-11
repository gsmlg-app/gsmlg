import 'dart:typed_data';

import 'package:app_local_llm/app_local_llm.dart';
import 'package:app_local_llm_platform_interface/app_local_llm_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalLlmPlatform previousPlatform;

  setUp(() {
    previousPlatform = LocalLlmPlatform.instance;
  });

  tearDown(() {
    LocalLlmPlatform.instance = previousPlatform;
  });

  test('loadModel starts service before loading model', () async {
    final platform = _FakeLocalLlmPlatform();
    LocalLlmPlatform.instance = platform;

    await LocalLlm.instance.loadModel('/models/local.litertlm');

    expect(platform.calls, ['startService', 'loadModel']);
  });

  test('loadModel stops service when model loading fails', () async {
    final platform =
        _FakeLocalLlmPlatform(loadError: StateError('load failed'));
    LocalLlmPlatform.instance = platform;

    await expectLater(
      LocalLlm.instance.loadModel('/models/local.litertlm'),
      throwsStateError,
    );

    expect(platform.calls, ['startService', 'loadModel', 'stopService']);
  });

  test('unloadModel stops service after unloading model', () async {
    final platform = _FakeLocalLlmPlatform();
    LocalLlmPlatform.instance = platform;

    await LocalLlm.instance.unloadModel();

    expect(platform.calls, ['unloadModel', 'stopService']);
  });
}

class _FakeLocalLlmPlatform extends LocalLlmPlatform {
  _FakeLocalLlmPlatform({this.loadError});

  final Object? loadError;
  final List<String> calls = [];

  @override
  Future<void> startService({
    String title = 'Local LLM',
    String message = 'Local model is running.',
  }) async {
    calls.add('startService');
  }

  @override
  Future<void> stopService() async {
    calls.add('stopService');
  }

  @override
  Future<void> loadModel(
    String modelPath, {
    String? backend,
    String? litertDispatchLibDir,
    bool supportImage = false,
    bool supportAudio = false,
  }) async {
    calls.add('loadModel');
    final error = loadError;
    if (error != null) throw error;
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
    return Stream.value('ok');
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
    return Stream.value(const <String, Object?>{});
  }

  @override
  Future<void> unloadModel() async {
    calls.add('unloadModel');
  }
}
