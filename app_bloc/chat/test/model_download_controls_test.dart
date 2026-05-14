import 'dart:async';
import 'dart:collection';

import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GemmaModelBloc download controls', () {
    late SharedPreferences preferences;
    late _FakeGemmaRepository repository;
    late GemmaModelBloc bloc;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferences = await SharedPreferences.getInstance();
      repository = _FakeGemmaRepository();
      bloc = GemmaModelBloc(repository: repository, preferences: preferences);
    });

    tearDown(() async {
      await bloc.close();
    });

    test('pauses an active download and keeps its progress', () async {
      bloc.add(
        const GemmaModelInstall(
          url: _e2bUrl,
          modelId: _e2bModelId,
        ),
      );
      await _flushBloc();

      repository.sendProgress(
        _e2bUrl,
        const DownloadProgress(
          percentage: 25,
          receivedBytes: 256,
          totalBytes: 1024,
          bytesPerSecond: 128,
        ),
      );
      await _flushBloc();

      bloc.add(
        const GemmaModelPauseDownload(
          url: _e2bUrl,
          modelId: _e2bModelId,
        ),
      );
      await _flushBloc();

      expect(repository.pausedUrls, [_e2bUrl]);
      expect(bloc.state.activeDownloads, isEmpty);
      expect(bloc.state.failedDownloads, isEmpty);
      expect(bloc.state.pausedDownloads, hasLength(1));
      expect(bloc.state.pausedDownloads.single.modelId, _e2bModelId);
      expect(bloc.state.pausedDownloads.single.progress, 25);
      expect(bloc.state.pausedDownloads.single.receivedBytes, 256);
    });

    test('resumes a paused download through the normal install path', () async {
      bloc.add(
        const GemmaModelInstall(
          url: _e2bUrl,
          modelId: _e2bModelId,
        ),
      );
      await _flushBloc();
      bloc.add(
        const GemmaModelPauseDownload(
          url: _e2bUrl,
          modelId: _e2bModelId,
        ),
      );
      await _flushBloc();

      bloc.add(
        const GemmaModelInstall(
          url: _e2bUrl,
          modelId: _e2bModelId,
        ),
      );
      await _flushBloc();

      expect(repository.installedUrls, [_e2bUrl, _e2bUrl]);
      expect(bloc.state.pausedDownloads, isEmpty);
      expect(bloc.state.activeDownloads.single.modelId, _e2bModelId);

      repository.completeSuccess(_e2bUrl);
      await _flushBloc();
    });

    test('cancels a paused download and deletes its partial file', () async {
      bloc.add(
        const GemmaModelInstall(
          url: _e2bUrl,
          modelId: _e2bModelId,
        ),
      );
      await _flushBloc();
      bloc.add(
        const GemmaModelPauseDownload(
          url: _e2bUrl,
          modelId: _e2bModelId,
        ),
      );
      await _flushBloc();

      bloc.add(
        const GemmaModelCancelDownload(
          url: _e2bUrl,
          modelId: _e2bModelId,
        ),
      );
      await _flushBloc();

      expect(repository.deletedUrls, [_e2bUrl]);
      expect(bloc.state.activeDownloads, isEmpty);
      expect(bloc.state.pausedDownloads, isEmpty);
      expect(bloc.state.failedDownloads, isEmpty);
    });

    test('cancels an active download without marking it failed', () async {
      bloc.add(
        const GemmaModelInstall(
          url: _e2bUrl,
          modelId: _e2bModelId,
        ),
      );
      await _flushBloc();

      bloc.add(
        const GemmaModelCancelDownload(
          url: _e2bUrl,
          modelId: _e2bModelId,
        ),
      );
      await _flushBloc();

      expect(repository.canceledUrls, [_e2bUrl]);
      expect(bloc.state.activeDownloads, isEmpty);
      expect(bloc.state.pausedDownloads, isEmpty);
      expect(bloc.state.failedDownloads, isEmpty);
    });

    test('imports a picked local model and refreshes installed models',
        () async {
      repository.installedModelsAfterImport = const [_e2bModelId];

      bloc.add(
        const GemmaModelImportFromFile(
          modelId: _e2bModelId,
          filePath: '/downloads/gemma-4-e2b-Q4_K_M.gguf',
        ),
      );
      await _flushBloc();

      expect(repository.importedFiles, [
        (_e2bModelId, '/downloads/gemma-4-e2b-Q4_K_M.gguf'),
      ]);
      expect(bloc.state.installedModels, [_e2bModelId]);
      expect(bloc.state.status, GemmaModelStatus.installed);
    });

    test('removes a selected local model that is no longer installed',
        () async {
      await bloc.close();
      await preferences.setString('gemma_selected_model_id', _e4bModelId);
      repository = _FakeGemmaRepository()
        ..installedModelsAfterImport = const [_e2bModelId];
      bloc = GemmaModelBloc(repository: repository, preferences: preferences);

      bloc.add(const GemmaModelListInstalled());
      await _flushBloc();

      expect(preferences.getString('gemma_selected_model_id'), isNull);
      expect(bloc.state.selectedModelId, isNull);
      expect(bloc.state.installedModels, [_e2bModelId]);
    });

    test('selects Gemma 4 E4B without a large-memory block', () async {
      bloc.add(const GemmaModelSelect(modelId: _e4bModelId));
      await _flushBloc();

      expect(repository.activatedModels, [_e4bModelId]);
      expect(repository.unloadCount, 1);
      expect(repository.loadCount, 1);
      expect(preferences.getString('gemma_selected_model_id'), _e4bModelId);
      expect(bloc.state.selectedModelId, _e4bModelId);
      expect(bloc.state.status, GemmaModelStatus.ready);
      expect(bloc.state.errorMessage, isNull);
    });

    test('loads a persisted Gemma 4 E4B model on startup', () async {
      await bloc.close();
      await preferences.setString('gemma_selected_model_id', _e4bModelId);
      repository = _FakeGemmaRepository()
        ..installedModelsAfterImport = const [_e4bModelId];
      bloc = GemmaModelBloc(repository: repository, preferences: preferences);

      bloc.add(const GemmaModelInitialize());
      await _flushBloc();

      expect(repository.activatedModels, [_e4bModelId]);
      expect(repository.loadCount, 1);
      expect(preferences.getString('gemma_selected_model_id'), _e4bModelId);
      expect(bloc.state.selectedModelId, _e4bModelId);
      expect(bloc.state.installedModels, [_e4bModelId]);
      expect(bloc.state.status, GemmaModelStatus.ready);
      expect(bloc.state.errorMessage, isNull);
    });
  });
}

const _e2bModelId = 'gemma-4-E2B-it';
const _e4bModelId = 'gemma-4-E4B-it';
const _e2bUrl =
    'https://huggingface.co/dahus/gemma-4-e2b-it-Q4_K_M-GGUF/resolve/main/gemma-4-e2b-Q4_K_M.gguf';

Future<void> _flushBloc() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

class _FakeGemmaRepository extends GemmaRepository {
  final installedUrls = <String>[];
  final pausedUrls = <String>[];
  final canceledUrls = <String>[];
  final deletedUrls = <String>[];
  final importedFiles = <(String, String)>[];
  final activatedModels = <String>[];
  int unloadCount = 0;
  int loadCount = 0;
  GemmaModelStatus repoStatus = GemmaModelStatus.initial;
  List<String> installedModelsAfterImport = const [];
  final _progressCallbacks = <String, void Function(DownloadProgress)>{};
  final _installCompleters = <String, Queue<Completer<void>>>{};

  @override
  GemmaModelStatus get status => repoStatus;

  @override
  Future<void> installModel({
    required String url,
    String? token,
    void Function(DownloadProgress progress)? onProgress,
  }) {
    installedUrls.add(url);
    if (onProgress != null) {
      _progressCallbacks[url] = onProgress;
    }
    final completer = Completer<void>();
    (_installCompleters[url] ??= Queue<Completer<void>>()).add(completer);
    return completer.future;
  }

  @override
  Future<void> installModelWithProxy({
    required String url,
    required String proxyUrl,
    String? token,
    void Function(DownloadProgress progress)? onProgress,
  }) {
    return installModel(url: url, token: token, onProgress: onProgress);
  }

  @override
  Future<void> pauseModelDownload(String url) async {
    pausedUrls.add(url);
    _completeCurrent(url, const ModelDownloadPausedException());
  }

  @override
  Future<void> cancelModelDownload(String url) async {
    canceledUrls.add(url);
    _completeCurrent(url, const ModelDownloadCanceledException());
  }

  @override
  Future<void> deleteDownloadForUrl(String url) async {
    deletedUrls.add(url);
  }

  @override
  Future<void> importModelFromFile({
    required GemmaModelInfo info,
    required String sourcePath,
  }) async {
    importedFiles.add((info.id, sourcePath));
  }

  @override
  Future<List<String>> listInstalledModels() async =>
      installedModelsAfterImport;

  @override
  Future<void> activateModel(GemmaModelInfo info) async {
    activatedModels.add(info.id);
    repoStatus = GemmaModelStatus.installed;
  }

  @override
  Future<void> unloadModel() async {
    unloadCount += 1;
    if (repoStatus == GemmaModelStatus.ready) {
      repoStatus = GemmaModelStatus.installed;
    }
  }

  @override
  Future<void> loadModel(
    ModelConfig config, {
    bool supportImage = false,
    bool supportAudio = false,
    bool isThinking = false,
    bool supportsFunctionCalls = false,
  }) async {
    loadCount += 1;
    repoStatus = GemmaModelStatus.ready;
  }

  void sendProgress(String url, DownloadProgress progress) {
    _progressCallbacks[url]?.call(progress);
  }

  void completeSuccess(String url) {
    final queue = _installCompleters[url];
    if (queue == null || queue.isEmpty) return;
    final completer = queue.removeFirst();
    if (!completer.isCompleted) {
      completer.complete();
    }
  }

  void _completeCurrent(String url, Object error) {
    final queue = _installCompleters[url];
    if (queue == null || queue.isEmpty) return;
    final completer = queue.removeFirst();
    if (!completer.isCompleted) {
      completer.completeError(error);
    }
  }
}
