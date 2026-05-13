import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:lib_llama_cpp/lib_llama_cpp.dart' as llama;
import 'package:lib_llama_cpp_platform_interface/lib_llama_cpp_platform_interface.dart'
    as llama_platform;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/inference.dart';
import '../models/message.dart';
import '../models/model_config.dart';
import 'llama_request_adapter.dart';

/// Status of the model lifecycle.
enum GemmaModelStatus {
  /// Model has not been checked yet.
  initial,

  /// Checking if model is installed.
  checking,

  /// Model is not installed.
  notInstalled,

  /// Model is installed but not loaded.
  installed,

  /// Model is being downloaded.
  downloading,

  /// Model is being loaded into memory.
  loading,

  /// Model is ready for inference.
  ready,

  /// An error occurred.
  error,
}

/// Progress information for model downloads.
class DownloadProgress {
  const DownloadProgress({
    required this.percentage,
    this.receivedBytes,
    this.totalBytes,
    this.bytesPerSecond,
  });

  /// Download progress as a percentage (0-100).
  final double percentage;

  /// Bytes present in the destination file after this update.
  final int? receivedBytes;

  /// Total bytes expected for the completed file, when the server reports it.
  final int? totalBytes;

  /// Current average download speed for this request.
  final double? bytesPerSecond;

  @override
  String toString() {
    return 'DownloadProgress('
        '${percentage.toStringAsFixed(1)}%, '
        'received=$receivedBytes, '
        'total=$totalBytes, '
        'speed=$bytesPerSecond)';
  }
}

/// Thrown when a model download is paused and can be resumed later.
class ModelDownloadPausedException implements Exception {
  const ModelDownloadPausedException();

  @override
  String toString() => 'Model download paused';
}

/// Thrown when a model download is canceled and its partial file is removed.
class ModelDownloadCanceledException implements Exception {
  const ModelDownloadCanceledException();

  @override
  String toString() => 'Model download canceled';
}

/// Repository for app-managed GGUF models and local llama.cpp generation.
class GemmaRepository {
  GemmaRepository({
    llama.LlamaEngine llamaEngine = const llama.LibLlamaCpp(),
    String? initialModelPath,
  }) : _llamaEngine = llamaEngine,
       _llamaModelPath = initialModelPath;

  final llama.LlamaEngine _llamaEngine;
  String? _llamaModelPath;
  ModelConfig? _llamaConfig;
  final _activeDownloads = <String, _DownloadControl>{};

  /// Current status of the model.
  GemmaModelStatus get status => _status;
  GemmaModelStatus _status = GemmaModelStatus.initial;

  /// The last error message, if any.
  String? get lastError => _lastError;
  String? _lastError;

  /// Whether a model is currently loaded and ready.
  bool get isReady => _status == GemmaModelStatus.ready;

  /// Stream controller for status changes.
  final _statusController = StreamController<GemmaModelStatus>.broadcast();

  /// Stream controller for download progress.
  final _progressController = StreamController<DownloadProgress>.broadcast();

  /// Stream of model status changes.
  Stream<GemmaModelStatus> get statusStream => _statusController.stream;

  /// Stream of download progress updates.
  Stream<DownloadProgress> get progressStream => _progressController.stream;

  static bool _isGgufPath(String path) => path.toLowerCase().endsWith('.gguf');

  /// Activates an already-installed GGUF model so [loadModel] can use it.
  Future<void> activateModel(GemmaModelInfo info) async {
    debugPrint('[GemmaRepo] activateModel(${info.id})');
    try {
      if (!info.isGguf) {
        _setError('Only GGUF models are supported for local inference.');
        return;
      }

      final filePath = await modelFilePath(info);
      if (!File(filePath).existsSync()) {
        _llamaModelPath = null;
        _setStatus(GemmaModelStatus.notInstalled);
        return;
      }

      _llamaModelPath = filePath;
      debugPrint('[GemmaRepo] activateModel using GGUF file: $filePath');
      _setStatus(GemmaModelStatus.installed);
    } catch (e, st) {
      debugPrint('[GemmaRepo] activateModel FAILED: $e');
      debugPrint('[GemmaRepo] Stack trace: $st');
      _setError('Failed to activate model: $e');
    }
  }

  /// Installs a GGUF model from the network with resume support.
  Future<void> installModel({
    required String url,
    String? token,
    void Function(DownloadProgress progress)? onProgress,
  }) async {
    debugPrint('[GemmaRepo] installModel(url=$url, hasToken=${token != null})');
    if (!_isGgufPath(url)) {
      throw ArgumentError.value(url, 'url', 'Only GGUF models are supported.');
    }

    try {
      final filePath = await _downloadFile(
        url: url,
        token: token,
        onProgress: onProgress,
      );
      debugPrint('[GemmaRepo] GGUF download ready at: $filePath');
      _setStatus(GemmaModelStatus.installed);
    } catch (e, st) {
      debugPrint('[GemmaRepo] installModel FAILED: $e');
      debugPrint('[GemmaRepo] Error type: ${e.runtimeType}');
      debugPrint('[GemmaRepo] Stack trace: $st');
      rethrow;
    }
  }

  /// Installs a GGUF model from the network via a proxy with resume support.
  Future<void> installModelWithProxy({
    required String url,
    required String proxyUrl,
    String? token,
    void Function(DownloadProgress progress)? onProgress,
  }) async {
    debugPrint(
      '[GemmaRepo] installModelWithProxy(url=$url, proxy=$proxyUrl, hasToken=${token != null})',
    );
    if (!_isGgufPath(url)) {
      throw ArgumentError.value(url, 'url', 'Only GGUF models are supported.');
    }

    try {
      final filePath = await _downloadFile(
        url: url,
        proxyUrl: proxyUrl,
        token: token,
        onProgress: onProgress,
      );
      debugPrint('[GemmaRepo] GGUF download ready at: $filePath');
      _setStatus(GemmaModelStatus.installed);
    } catch (e, st) {
      debugPrint('[GemmaRepo] installModelWithProxy FAILED: $e');
      debugPrint('[GemmaRepo] Error type: ${e.runtimeType}');
      debugPrint('[GemmaRepo] Stack trace: $st');
      rethrow;
    }
  }

  /// Imports a user-selected GGUF file into the app-managed model cache.
  Future<void> importModelFromFile({
    required GemmaModelInfo info,
    required String sourcePath,
  }) async {
    debugPrint(
      '[GemmaRepo] importModelFromFile(model=${info.id}, source=$sourcePath)',
    );
    if (!info.isGguf) {
      throw ArgumentError.value(
        info.id,
        'info',
        'Only GGUF models are supported.',
      );
    }
    if (!_isGgufPath(sourcePath)) {
      throw ArgumentError.value(
        sourcePath,
        'sourcePath',
        'Only .gguf files are supported.',
      );
    }

    try {
      final source = File(sourcePath);
      if (!source.existsSync() || source.lengthSync() <= 0) {
        throw FileSystemException('Selected model file is missing', sourcePath);
      }

      final destinationPath = await modelFilePath(info);
      final destination = File(destinationPath);
      destination.parent.createSync(recursive: true);

      if (!p.equals(source.absolute.path, destination.absolute.path)) {
        await source.copy(destinationPath);
      }

      final imported = File(destinationPath);
      if (!imported.existsSync() || imported.lengthSync() <= 0) {
        throw FileSystemException(
          'Imported model file is missing',
          destinationPath,
        );
      }

      debugPrint('[GemmaRepo] Imported GGUF model to: $destinationPath');
      _setStatus(GemmaModelStatus.installed);
    } catch (e, st) {
      debugPrint('[GemmaRepo] importModelFromFile FAILED: $e');
      debugPrint('[GemmaRepo] Stack trace: $st');
      _setError('Failed to import model: $e');
      rethrow;
    }
  }

  /// Pauses an active download while preserving its partial file for resume.
  Future<void> pauseModelDownload(String url) async {
    debugPrint('[GemmaRepo] pauseModelDownload(url=$url)');
    _activeDownloads[url]?.pause();
  }

  /// Cancels an active download and removes its partial file.
  Future<void> cancelModelDownload(String url) async {
    debugPrint('[GemmaRepo] cancelModelDownload(url=$url)');
    final control = _activeDownloads[url];
    if (control == null) {
      await deleteDownloadForUrl(url);
      return;
    }
    control.cancel();
  }

  /// Deletes the partial or completed download file for a preset URL.
  Future<void> deleteDownloadForUrl(String url) async {
    _cleanupDownloadFile(await _downloadFilePathForUrl(url));
  }

  /// Downloads a file with HTTP Range resume support.
  ///
  /// GGUF files are downloaded into the app cache under
  /// `lib_llama_cpp/models/<org>/<repo>/` because the app owns those files.
  Future<String> _downloadFile({
    required String url,
    String? proxyUrl,
    String? token,
    void Function(DownloadProgress progress)? onProgress,
  }) async {
    final filePath = await _downloadFilePathForUrl(url);
    final file = File(filePath);
    file.parent.createSync(recursive: true);

    var existingBytes = 0;
    if (file.existsSync()) {
      existingBytes = file.lengthSync();
      debugPrint(
        '[GemmaRepo] Found partial download: $existingBytes bytes at $filePath',
      );
    }

    final client = HttpClient();
    final control = _DownloadControl(client);
    _activeDownloads[url] = control;
    IOSink? sink;
    var deletePartial = false;

    void throwIfInterrupted() {
      if (control.isCanceled) {
        deletePartial = true;
        throw const ModelDownloadCanceledException();
      }
      if (control.isPaused) {
        throw const ModelDownloadPausedException();
      }
    }

    try {
      if (proxyUrl != null) {
        final proxyUri = Uri.parse(proxyUrl);
        final proxyHost = proxyUri.host;
        final proxyPort = proxyUri.hasPort
            ? proxyUri.port
            : (proxyUri.scheme == 'https' ? 443 : 8080);
        final proxyDirective = 'PROXY $proxyHost:$proxyPort';
        debugPrint('[GemmaRepo] Proxy config: $proxyDirective');
        client.findProxy = (uri) => proxyDirective;
      }

      debugPrint(
        '[GemmaRepo] Sending GET request to $url (resume from $existingBytes bytes)...',
      );
      final request = await client.getUrl(Uri.parse(url));
      if (token != null) {
        request.headers.set('Authorization', 'Bearer $token');
      }
      if (existingBytes > 0) {
        request.headers.set('Range', 'bytes=$existingBytes-');
        debugPrint('[GemmaRepo] Added Range header: bytes=$existingBytes-');
      }

      final response = await request.close();
      debugPrint('[GemmaRepo] Response status: ${response.statusCode}');
      throwIfInterrupted();

      int totalBytes;
      int received;

      if (response.statusCode == 206) {
        totalBytes = response.contentLength > 0
            ? existingBytes + response.contentLength
            : -1;
        received = existingBytes;
        sink = file.openWrite(mode: FileMode.append);
        debugPrint(
          '[GemmaRepo] Resuming download: $existingBytes / $totalBytes bytes',
        );
      } else if (response.statusCode == 200) {
        totalBytes = response.contentLength;
        received = 0;
        sink = file.openWrite();
        debugPrint(
          '[GemmaRepo] Starting fresh download (totalBytes=$totalBytes)',
        );
      } else if (response.statusCode == 416) {
        await response.drain<void>();
        debugPrint(
          '[GemmaRepo] 416 Range Not Satisfiable; keeping existing file ($existingBytes bytes)',
        );
        return filePath;
      } else {
        final errorBody = await response.transform(utf8.decoder).join();
        debugPrint('[GemmaRepo] Error response body: $errorBody');
        throw HttpException(
          'Download failed with status ${response.statusCode}: $errorBody',
        );
      }

      final stopwatch = Stopwatch()..start();

      void emitProgress() {
        final pct = totalBytes > 0
            ? (received / totalBytes * 100).clamp(0.0, 100.0)
            : 0.0;
        final elapsedSeconds = stopwatch.elapsedMicroseconds / 1000000;
        final bytesDownloadedThisRequest = (received - existingBytes).clamp(
          0,
          received,
        );
        final bytesPerSecond = elapsedSeconds > 0
            ? bytesDownloadedThisRequest / elapsedSeconds
            : null;
        final progress = DownloadProgress(
          percentage: pct,
          receivedBytes: received,
          totalBytes: totalBytes > 0 ? totalBytes : null,
          bytesPerSecond: bytesPerSecond,
        );
        onProgress?.call(progress);
        _progressController.add(progress);
      }

      if (received > 0) {
        emitProgress();
      }

      var lastLogPercent = -1;
      await for (final chunk in response) {
        throwIfInterrupted();
        sink.add(chunk);
        received += chunk.length;
        if (totalBytes > 0) {
          final percent = (received / totalBytes * 100).clamp(0.0, 100.0);
          final percentInt = percent.toInt();
          if (percentInt != lastLogPercent && percentInt % 10 == 0) {
            debugPrint(
              '[GemmaRepo] Download progress: $percentInt% ($received / $totalBytes bytes)',
            );
            lastLogPercent = percentInt;
          }
        }
        emitProgress();
        throwIfInterrupted();
      }
      await sink.close();
      sink = null;

      final fileSize = file.lengthSync();
      debugPrint('[GemmaRepo] Download complete: $filePath ($fileSize bytes)');
      return filePath;
    } on ModelDownloadCanceledException {
      deletePartial = true;
      rethrow;
    } on ModelDownloadPausedException {
      rethrow;
    } catch (e) {
      if (control.isCanceled) {
        deletePartial = true;
        throw const ModelDownloadCanceledException();
      }
      if (control.isPaused) {
        throw const ModelDownloadPausedException();
      }
      rethrow;
    } finally {
      if (sink != null) {
        try {
          await sink.close();
        } catch (_) {
          // Closing after a forced HttpClient shutdown can surface stream errors.
        }
      }
      if (deletePartial) {
        _cleanupDownloadFile(filePath);
      }
      _activeDownloads.remove(url);
      client.close();
      debugPrint('[GemmaRepo] HttpClient closed');
    }
  }

  void _cleanupDownloadFile(String filePath) {
    try {
      File(filePath).deleteSync();
      debugPrint('[GemmaRepo] Cleaned up download file: $filePath');
    } catch (e) {
      debugPrint(
        '[GemmaRepo] Failed to clean up download file: $filePath ($e)',
      );
    }
  }

  /// Returns the app-managed local path for a catalog model file.
  Future<String> modelFilePath(GemmaModelInfo info) async {
    return _downloadFilePathForUrl(info.downloadUrl);
  }

  Future<String> _downloadFilePathForUrl(String url) async {
    final cacheDir = await getApplicationCacheDirectory();
    final fileName = Uri.parse(url).pathSegments.last;
    final repoPath = _huggingFaceRepoPath(url);
    final pathSegments = repoPath == null
        ? <String>[cacheDir.path, 'lib_llama_cpp', 'models']
        : <String>[
            cacheDir.path,
            'lib_llama_cpp',
            'models',
            ...repoPath.split('/'),
          ];
    return p.joinAll([...pathSegments, fileName]);
  }

  String? _huggingFaceRepoPath(String url) {
    final uri = Uri.parse(url);
    if (uri.host != 'huggingface.co' || uri.pathSegments.length < 2) {
      return null;
    }
    return '${uri.pathSegments[0]}/${uri.pathSegments[1]}';
  }

  /// Lists all installed app-managed GGUF model IDs.
  Future<List<String>> listInstalledModels() async {
    debugPrint('[GemmaRepo] listInstalledModels()');
    final installed = <String>[];

    for (final model in GemmaModelInfo.availableModels.where((m) => m.isGguf)) {
      final filePath = await modelFilePath(model);
      final file = File(filePath);
      if (file.existsSync() && file.lengthSync() > 0) {
        installed.add(model.id);
      }
    }

    debugPrint(
      '[GemmaRepo] listInstalledModels => $installed (${installed.length} models)',
    );
    return installed;
  }

  /// Loads the selected GGUF model into memory with the given configuration.
  Future<void> loadModel(
    ModelConfig config, {
    bool supportImage = false,
    bool supportAudio = false,
    bool isThinking = false,
    bool supportsFunctionCalls = false,
  }) async {
    final llamaModelPath = _llamaModelPath;
    await unloadModel();
    _setStatus(GemmaModelStatus.loading);

    try {
      if (llamaModelPath == null) {
        _setStatus(GemmaModelStatus.notInstalled);
        return;
      }

      final file = File(llamaModelPath);
      if (!file.existsSync()) {
        _setStatus(GemmaModelStatus.notInstalled);
        return;
      }

      _llamaModelPath = llamaModelPath;
      _llamaConfig = config;
      _setStatus(GemmaModelStatus.ready);
    } catch (e) {
      debugPrint('[GemmaRepo] loadModel FAILED: $e');
      _setError('Failed to load model: $e');
    }
  }

  /// Unloads the active model selection.
  Future<void> unloadModel() async {
    _llamaModelPath = null;
    _llamaConfig = null;

    if (_status == GemmaModelStatus.ready) {
      _setStatus(GemmaModelStatus.installed);
    }
  }

  /// Deletes a model by its installed ID string.
  Future<void> deleteModelById(String modelId) async {
    debugPrint('[GemmaRepo] deleteModelById($modelId)');
    await unloadModel();

    try {
      final info = GemmaModelInfo.findById(modelId);
      if (info == null) {
        _setError('Unknown model: $modelId');
        return;
      }

      _cleanupDownloadFile(await modelFilePath(info));
      debugPrint('[GemmaRepo] deleteModelById removed GGUF for $modelId');
      _setStatus(GemmaModelStatus.notInstalled);
    } catch (e, st) {
      debugPrint('[GemmaRepo] deleteModelById FAILED: $e');
      debugPrint('[GemmaRepo] Stack trace: $st');
      _setError('Failed to delete model: $e');
    }
  }

  /// Generates a response for a list of messages.
  Stream<ChatGenerationChunk> generateResponse(
    List<Message> messages, {
    List<Map<String, dynamic>> tools = const [],
    ModelConfig? config,
  }) async* {
    if (_llamaModelPath == null) {
      throw StateError('Model is not loaded. Call loadModel() first.');
    }
    yield* _generateLlamaResponse(messages, tools: tools, config: config);
  }

  Stream<ChatGenerationChunk> _generateLlamaResponse(
    List<Message> messages, {
    required List<Map<String, dynamic>> tools,
    ModelConfig? config,
  }) async* {
    final modelPath = _llamaModelPath;
    if (modelPath == null) {
      throw StateError('Model is not loaded. Call loadModel() first.');
    }

    final effectiveConfig =
        (config ?? _llamaConfig ?? ModelConfig.platformDefaultConfig)
            .withSupportedBackendForCurrentPlatform();
    final commands = Stream<llama.LlamaCommand>.fromIterable([
      llama.LlamaLoadModelCommand(
        modelPath: modelPath,
        gpuLayerCount: effectiveConfig.backend.usesGpuLayers ? 99 : 0,
      ),
      buildLlamaGenerateCommand(
        messages: messages,
        tools: tools,
        maxTokens: effectiveConfig.maxTokens,
        temperature: effectiveConfig.temperature,
        stop: const ['<end_of_turn>', '<start_of_turn>'],
      ),
      const llama.LlamaDisposeCommand(),
    ]);

    await for (final response in _llamaEngine.transform(
      commands,
      libraryRequest: _libraryRequestForBackend(effectiveConfig.backend),
    )) {
      switch (response) {
        case llama.LlamaTokenResponse(:final text):
          yield ChatTextChunk(text);
        case llama.LlamaToolCallResponse(:final toolCall):
          yield ChatFunctionCallChunk(
            name: toolCall.name,
            args: _decodeToolArgs(toolCall.arguments),
          );
        case llama.LlamaErrorResponse(:final message):
          _setError(message);
          throw StateError(message);
        case llama.LlamaReadyResponse() ||
            llama.LlamaStateChangedResponse() ||
            llama.LlamaDoneResponse():
          break;
      }
    }
  }

  /// Generates a complete response without streaming.
  Future<String> generateResponseSync(
    List<Message> messages, {
    List<Map<String, dynamic>> tools = const [],
    ModelConfig? config,
  }) async {
    if (_llamaModelPath == null) {
      throw StateError('Model is not loaded. Call loadModel() first.');
    }

    final buffer = StringBuffer();
    await for (final response in generateResponse(
      messages,
      tools: tools,
      config: config,
    )) {
      if (response is ChatTextChunk) {
        buffer.write(response.text);
      }
    }
    return buffer.toString();
  }

  /// Stops the current generation.
  Future<void> stopGeneration() async {}

  /// Disposes all resources.
  Future<void> dispose() async {
    await unloadModel();
    await _statusController.close();
    await _progressController.close();
  }

  void _setStatus(GemmaModelStatus newStatus) {
    debugPrint('[GemmaRepo] Status: $_status => $newStatus');
    _status = newStatus;
    _lastError = null;
    _statusController.add(newStatus);
  }

  /// Sets an error state with the given message.
  ///
  /// Exposed for the BLoC layer to report platform-level incompatibilities
  /// without attempting a load that would crash the native process.
  void setError(String message) => _setError(message);

  void _setError(String message) {
    debugPrint('[GemmaRepo] ERROR: $message (status was $_status)');
    _status = GemmaModelStatus.error;
    _lastError = message;
    _statusController.add(GemmaModelStatus.error);
  }

  Map<String, dynamic> _decodeToolArgs(String arguments) {
    final trimmed = arguments.trim();
    if (trimmed.isEmpty) return const {};

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'value': decoded};
    } catch (_) {
      return {'raw': trimmed};
    }
  }

  llama_platform.LlamaCppLibraryRequest _libraryRequestForBackend(
    GemmaBackend backend,
  ) {
    return llama_platform.LlamaCppLibraryRequest(
      requiredCapabilities: {
        switch (backend) {
          GemmaBackend.cpu => llama_platform.LlamaCppLibraryCapability.cpu,
          GemmaBackend.metal => llama_platform.LlamaCppLibraryCapability.metal,
          GemmaBackend.cuda => llama_platform.LlamaCppLibraryCapability.cuda,
          GemmaBackend.vulkan =>
            llama_platform.LlamaCppLibraryCapability.vulkan,
        },
      },
    );
  }
}

class _DownloadControl {
  _DownloadControl(this._client);

  final HttpClient _client;
  var isPaused = false;
  var isCanceled = false;

  void pause() {
    isPaused = true;
    _client.close(force: true);
  }

  void cancel() {
    isCanceled = true;
    _client.close(force: true);
  }
}
