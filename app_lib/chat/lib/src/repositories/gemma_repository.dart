import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:lib_llama_cpp/lib_llama_cpp.dart' as llama;
import 'package:lib_llama_cpp_platform_interface/lib_llama_cpp_platform_interface.dart'
    as llama_platform;
import 'package:lib_llama_cpp_server/lib_llama_cpp_server.dart' as llama_server;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:app_local_llm/app_local_llm.dart' as app_local_llm;
import 'package:app_client_info/app_client_info.dart' as app_client_info;
import 'package:background_downloader/background_downloader.dart';

import '../models/inference.dart';
import '../models/message.dart';
import '../models/model_config.dart';
import 'llama_request_adapter.dart';

const _defaultLlamaContextSize = 4096;
const _llamaContextPromptReserve = 1024;
const _mobileLiteRtLmContextSize = 2048;
const _localPromptApproxCharsPerToken = 4;
const _localPromptSafetyTokens = 64;
const _localPromptOutputReserveTokens = 512;
const _localPromptMinimumTokens = 256;
const _localLlamaModelAlias = 'local';
const _localLlamaStopSequences = [
  '<turn|>',
  '<end_of_turn>',
  '<start_of_turn>',
];

/// Configuration used to start the local llama.cpp server.
@visibleForTesting
final class LocalLlamaServerConfig {
  const LocalLlamaServerConfig({
    required this.model,
    required this.modelPath,
    required this.contextSize,
    required this.gpuLayerCount,
    required this.libraryRequest,
  });

  final String model;
  final String modelPath;
  final int contextSize;
  final int gpuLayerCount;
  final llama_platform.LlamaCppLibraryRequest libraryRequest;
}

/// Active local llama.cpp server session.
@visibleForTesting
abstract interface class LocalLlamaServerSession {
  Stream<Map<String, Object?>> streamChatCompletion({
    required String model,
    required List<Map<String, Object?>> messages,
    int? maxTokens,
    double? temperature,
    double? topP,
    List<String> stop,
  });

  Future<void> close();
}

@visibleForTesting
typedef LocalLlamaServerFactory =
    Future<LocalLlamaServerSession> Function(LocalLlamaServerConfig config);

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
    llama.LlamaEngine? llamaEngine,
    String? initialModelPath,
    LocalLlamaServerFactory? llamaServerFactory,
  }) : _llamaModelPath = initialModelPath,
       _llamaServerFactory =
           llamaServerFactory ?? _LibLlamaCppServerSession.start;

  final LocalLlamaServerFactory _llamaServerFactory;
  String? _llamaModelPath;
  GemmaModelInfo? _llamaModelInfo;
  ModelConfig? _llamaConfig;
  LocalLlamaServerConfig? _llamaServerConfig;
  LocalLlamaServerSession? _llamaServer;
  final _activeDownloads = <String, Object>{};

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

  static bool _isGgufPath(String path) {
    final lower = path.toLowerCase();
    if (Platform.isAndroid) {
      return lower.endsWith('.litertlm');
    }
    if (Platform.isIOS) {
      return lower.endsWith('.zip') || lower.contains('mlx');
    }
    return lower.endsWith('.gguf');
  }

  /// Activates an already-installed model so [loadModel] can use it.
  Future<void> activateModel(GemmaModelInfo info) async {
    debugPrint('[GemmaRepo] activateModel(${info.id})');
    try {
      if (!info.isGguf) {
        String expectedFormat = 'GGUF';
        if (Platform.isAndroid) expectedFormat = 'LiteRT-LM';
        if (Platform.isIOS) expectedFormat = 'MLX';
        _setError(
          'Only $expectedFormat models are supported for local inference.',
        );
        return;
      }

      final filePath = await modelFilePath(info);
      final file = File(filePath);
      if (!file.existsSync()) {
        _llamaModelPath = null;
        _llamaModelInfo = null;
        _setStatus(GemmaModelStatus.notInstalled);
        return;
      }

      // Check if file is truncated/corrupt (LiteRT-LM files should be > 1.5 GB on Android)
      if (Platform.isAndroid) {
        final fileSize = file.lengthSync();
        final expectedSize = info.id == 'gemma-4-E2B-it'
            ? 2588147712
            : 3659530240;
        if (fileSize < expectedSize - 10 * 1024 * 1024) {
          debugPrint(
            '[GemmaRepo] Model file is truncated ($fileSize bytes vs expected $expectedSize). Deleting.',
          );
          try {
            file.deleteSync();
          } catch (_) {}
          _llamaModelPath = null;
          _llamaModelInfo = null;
          _setStatus(GemmaModelStatus.notInstalled);
          return;
        }
      }

      _llamaModelPath = filePath;
      _llamaModelInfo = info;
      debugPrint('[GemmaRepo] activateModel using file: $filePath');
      _setStatus(GemmaModelStatus.installed);
    } catch (e, st) {
      debugPrint('[GemmaRepo] activateModel FAILED: $e');
      debugPrint('[GemmaRepo] Stack trace: $st');
      _setError('Failed to activate model: $e');
    }
  }

  /// Installs a model from the network with resume support.
  Future<void> installModel({
    required String url,
    String? token,
    void Function(DownloadProgress progress)? onProgress,
  }) async {
    debugPrint('[GemmaRepo] installModel(url=$url, hasToken=${token != null})');
    if (!_isGgufPath(url)) {
      String expectedFormat = 'GGUF';
      if (Platform.isAndroid) expectedFormat = 'LiteRT-LM';
      if (Platform.isIOS) expectedFormat = 'MLX';
      throw ArgumentError.value(
        url,
        'url',
        'Only $expectedFormat models are supported.',
      );
    }

    try {
      final filePath = await _downloadFile(
        url: url,
        token: token,
        onProgress: onProgress,
      );
      debugPrint('[GemmaRepo] download ready at: $filePath');
      _setStatus(GemmaModelStatus.installed);
    } catch (e, st) {
      debugPrint('[GemmaRepo] installModel FAILED: $e');
      debugPrint('[GemmaRepo] Error type: ${e.runtimeType}');
      debugPrint('[GemmaRepo] Stack trace: $st');
      rethrow;
    }
  }

  /// Installs a model from the network via a proxy with resume support.
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
      String expectedFormat = 'GGUF';
      if (Platform.isAndroid) expectedFormat = 'LiteRT-LM';
      if (Platform.isIOS) expectedFormat = 'MLX';
      throw ArgumentError.value(
        url,
        'url',
        'Only $expectedFormat models are supported.',
      );
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

  /// Imports a user-selected model file into the app-managed model cache.
  Future<void> importModelFromFile({
    required GemmaModelInfo info,
    required String sourcePath,
  }) async {
    debugPrint(
      '[GemmaRepo] importModelFromFile(model=${info.id}, source=$sourcePath)',
    );
    if (!info.isGguf) {
      String expectedFormat = 'GGUF';
      if (Platform.isAndroid) expectedFormat = 'LiteRT-LM';
      if (Platform.isIOS) expectedFormat = 'MLX';
      throw ArgumentError.value(
        info.id,
        'info',
        'Only $expectedFormat models are supported.',
      );
    }
    if (!_isGgufPath(sourcePath)) {
      String expectedExtension = '.gguf';
      if (Platform.isAndroid) expectedExtension = '.litertlm';
      if (Platform.isIOS) expectedExtension = '.zip or MLX';
      throw ArgumentError.value(
        sourcePath,
        'sourcePath',
        'Only $expectedExtension files are supported.',
      );
    }

    File? stagedImport;
    File? backupDestination;
    try {
      final source = File(sourcePath);
      if (!source.existsSync() || source.lengthSync() <= 0) {
        throw FileSystemException('Selected model file is missing', sourcePath);
      }
      final sourceLength = source.lengthSync();

      final destinationPath = await modelFilePath(info);
      final destination = File(destinationPath);
      destination.parent.createSync(recursive: true);

      if (!p.equals(source.absolute.path, destination.absolute.path)) {
        stagedImport = await _stageImportedModelFile(
          source: source,
          destinationPath: destinationPath,
          expectedBytes: sourceLength,
        );
        backupDestination = await _replaceModelFile(
          stagedImport: stagedImport,
          destination: destination,
        );
      }

      final imported = File(destinationPath);
      if (!imported.existsSync() || imported.lengthSync() != sourceLength) {
        throw FileSystemException(
          'Imported model file is incomplete',
          destinationPath,
        );
      }

      _deleteFileIfExists(backupDestination);
      debugPrint('[GemmaRepo] Imported GGUF model to: $destinationPath');
      _setStatus(GemmaModelStatus.installed);
    } catch (e, st) {
      _deleteFileIfExists(stagedImport);
      if (backupDestination != null && backupDestination.existsSync()) {
        try {
          final destination = File(await modelFilePath(info));
          _deleteFileIfExists(destination);
          await backupDestination.rename(destination.path);
        } catch (_) {
          // Best effort restore; the original error below is more useful.
        }
      }
      debugPrint('[GemmaRepo] importModelFromFile FAILED: $e');
      debugPrint('[GemmaRepo] Stack trace: $st');
      _setError('Failed to import model: $e');
      rethrow;
    }
  }

  Future<File> _stageImportedModelFile({
    required File source,
    required String destinationPath,
    required int expectedBytes,
  }) async {
    final staged = File('$destinationPath.importing');
    _deleteFileIfExists(staged);

    File result;
    if (await _isFilePickerCacheFile(source.absolute.path)) {
      try {
        result = await source.rename(staged.path);
      } catch (_) {
        result = await source.copy(staged.path);
      }
    } else {
      result = await source.copy(staged.path);
    }

    if (!result.existsSync() || result.lengthSync() != expectedBytes) {
      throw FileSystemException(
        'Imported model copy is incomplete',
        result.path,
      );
    }
    return result;
  }

  Future<File?> _replaceModelFile({
    required File stagedImport,
    required File destination,
  }) async {
    File? backup;
    if (destination.existsSync()) {
      backup = File('${destination.path}.backup');
      _deleteFileIfExists(backup);
      backup = await destination.rename(backup.path);
    }

    try {
      await stagedImport.rename(destination.path);
      return backup;
    } catch (_) {
      if (backup != null && backup.existsSync()) {
        await backup.rename(destination.path);
      }
      rethrow;
    }
  }

  Future<bool> _isFilePickerCacheFile(String sourcePath) async {
    final cacheDir = await getApplicationCacheDirectory();
    final filePickerCache = p.normalize(p.join(cacheDir.path, 'file_picker'));
    final normalizedSource = p.normalize(sourcePath);
    return p.equals(filePickerCache, normalizedSource) ||
        p.isWithin(filePickerCache, normalizedSource);
  }

  void _deleteFileIfExists(File? file) {
    if (file == null) return;
    try {
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (_) {}
  }

  /// Pauses an active download while preserving its partial file for resume.
  Future<void> pauseModelDownload(String url) async {
    debugPrint('[GemmaRepo] pauseModelDownload(url=$url)');
    final active = _activeDownloads[url];
    if (active is _DownloadControl) {
      active.pause();
    } else if (active is DownloadTask) {
      await FileDownloader().pause(active);
    }
  }

  /// Cancels an active download and removes its partial file.
  Future<void> cancelModelDownload(String url) async {
    debugPrint('[GemmaRepo] cancelModelDownload(url=$url)');
    final active = _activeDownloads[url];
    if (active is _DownloadControl) {
      active.cancel();
    } else if (active is DownloadTask) {
      await FileDownloader().cancelTasksWithIds([active.taskId]);
    } else {
      await deleteDownloadForUrl(url);
    }
  }

  /// Deletes the partial or completed download file for a preset URL.
  Future<void> deleteDownloadForUrl(String url) async {
    _cleanupDownloadFile(await _downloadFilePathForUrl(url));
  }

  /// Downloads a file with HTTP Range resume support.
  ///
  /// Model artifacts are downloaded into the app cache under
  /// `lib_llama_cpp/models/<org>/<repo>/` because the app owns those files.
  Future<String> _downloadFile({
    required String url,
    String? proxyUrl,
    String? token,
    void Function(DownloadProgress progress)? onProgress,
  }) async {
    final filePath = await _downloadFilePathForUrl(url);

    var useBackgroundDownloader = true;
    try {
      // Detect if platform channels are supported (throws MissingPluginException / UnsupportedError in test runner)
      await FileDownloader().trackTasks();
    } catch (_) {
      useBackgroundDownloader = false;
    }

    if (useBackgroundDownloader) {
      try {
        debugPrint('[GemmaRepo] Starting background_downloader for $url...');
        final task = DownloadTask(
          url: url,
          filename: p.basename(filePath),
          baseDirectory: BaseDirectory.temporary,
          updates: Updates.statusAndProgress,
          headers: token != null ? {'Authorization': 'Bearer $token'} : {},
        );
        _activeDownloads[url] = task;

        final result = await FileDownloader().download(
          task,
          onProgress: (progress) {
            final pct = (progress * 100).clamp(0.0, 100.0);
            final downloadProgress = DownloadProgress(
              percentage: pct,
              receivedBytes: null,
              totalBytes: null,
              bytesPerSecond: null,
            );
            onProgress?.call(downloadProgress);
            _progressController.add(downloadProgress);
          },
        );

        _activeDownloads.remove(url);

        if (result.status == TaskStatus.complete) {
          final tempDir = await getTemporaryDirectory();
          final tempPath = p.join(tempDir.path, task.filename);
          final downloadedFile = File(tempPath);
          if (downloadedFile.existsSync()) {
            final destination = File(filePath);
            destination.parent.createSync(recursive: true);
            if (destination.existsSync()) {
              destination.deleteSync();
            }
            await downloadedFile.rename(filePath);
          }
          debugPrint('[GemmaRepo] background_downloader complete: $filePath');
          return filePath;
        } else if (result.status == TaskStatus.canceled) {
          throw const ModelDownloadCanceledException();
        } else if (result.status == TaskStatus.paused) {
          throw const ModelDownloadPausedException();
        } else {
          throw HttpException('Download failed with status: ${result.status}');
        }
      } catch (e) {
        _activeDownloads.remove(url);
        if (e is ModelDownloadCanceledException ||
            e is ModelDownloadPausedException) {
          rethrow;
        }
        debugPrint(
          '[GemmaRepo] background_downloader failed, trying fallback: $e',
        );
      }
    }

    // Fallback: HttpClient Range download
    final file = File(filePath);
    file.parent.createSync(recursive: true);

    var existingBytes = 0;
    if (file.existsSync()) {
      existingBytes = file.lengthSync();
      debugPrint(
        '[GemmaRepo] Found partial download (fallback): $existingBytes bytes at $filePath',
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
        '[GemmaRepo] Sending GET request (fallback) to $url (resume from $existingBytes bytes)...',
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
          '[GemmaRepo] Resuming download (fallback): $existingBytes / $totalBytes bytes',
        );
      } else if (response.statusCode == 200) {
        totalBytes = response.contentLength;
        received = 0;
        sink = file.openWrite();
        debugPrint(
          '[GemmaRepo] Starting fresh download (fallback, totalBytes=$totalBytes)',
        );
      } else if (response.statusCode == 416) {
        await response.drain<void>();
        debugPrint(
          '[GemmaRepo] 416 Range Not Satisfiable (fallback); keeping existing file ($existingBytes bytes)',
        );
        return filePath;
      } else {
        final errorBody = await response.transform(utf8.decoder).join();
        debugPrint('[GemmaRepo] Error response body (fallback): $errorBody');
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
              '[GemmaRepo] Download progress (fallback): $percentInt% ($received / $totalBytes bytes)',
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
      debugPrint(
        '[GemmaRepo] Download complete (fallback): $filePath ($fileSize bytes)',
      );
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
        } catch (_) {}
      }
      if (deletePartial) {
        _cleanupDownloadFile(filePath);
      }
      _activeDownloads.remove(url);
      client.close();
      debugPrint('[GemmaRepo] HttpClient closed (fallback)');
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

  /// Lists all installed app-managed model IDs.
  Future<List<String>> listInstalledModels() async {
    debugPrint('[GemmaRepo] listInstalledModels()');
    final installed = <String>[];

    for (final model in GemmaModelInfo.availableModels.where((m) => m.isGguf)) {
      final filePath = await modelFilePath(model);
      final file = File(filePath);
      if (file.existsSync()) {
        if (Platform.isAndroid) {
          final expectedSize = model.id == 'gemma-4-E2B-it'
              ? 2588147712
              : 3659530240;
          if (file.lengthSync() >= expectedSize - 10 * 1024 * 1024) {
            installed.add(model.id);
          }
        } else {
          if (file.lengthSync() > 0) {
            installed.add(model.id);
          }
        }
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
    final llamaModelInfo = _llamaModelInfo;
    await unloadModel();
    _setStatus(GemmaModelStatus.loading);

    try {
      if (llamaModelPath == null) {
        _setStatus(GemmaModelStatus.notInstalled);
        return;
      }

      final file = File(llamaModelPath);
      debugPrint('[GemmaRepo] Checking model file path: $llamaModelPath');
      if (!file.existsSync()) {
        debugPrint(
          '[GemmaRepo] Model file does not exist at path: $llamaModelPath',
        );
        _setStatus(GemmaModelStatus.notInstalled);
        return;
      }
      debugPrint('[GemmaRepo] Model file size: ${file.lengthSync()} bytes');

      _llamaModelPath = llamaModelPath;
      _llamaModelInfo = llamaModelInfo;
      _llamaConfig = config;
      if (Platform.isAndroid || Platform.isIOS) {
        String? backendStr;
        String? dispatchLibDir;
        if (Platform.isAndroid) {
          switch (config.backend) {
            case GemmaBackend.vulkan:
              backendStr = 'gpu';
              break;
            case GemmaBackend.npu:
              backendStr = 'npu';
              try {
                final clientInfo = await app_client_info.ClientInfo.instance
                    .getData();
                dispatchLibDir =
                    clientInfo.additionalData['nativeLibraryDir'] as String?;
              } catch (e) {
                debugPrint(
                  '[GemmaRepo] Failed to retrieve nativeLibraryDir for NPU: $e',
                );
              }
              break;
            default:
              backendStr = 'cpu';
              break;
          }
        }
        await app_local_llm.LocalLlm.instance.loadModel(
          llamaModelPath,
          backend: backendStr,
          litertDispatchLibDir: dispatchLibDir,
          supportImage: supportImage,
          supportAudio: supportAudio,
        );
      } else {
        await _ensureLlamaServer(config);
      }
      _setStatus(GemmaModelStatus.ready);
    } catch (e) {
      debugPrint('[GemmaRepo] loadModel FAILED: $e');
      _setError('Failed to load model: $e');
    }
  }

  /// Unloads the active model selection.
  Future<void> unloadModel() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await app_local_llm.LocalLlm.instance.unloadModel();
    } else {
      await _closeLlamaServer();
    }
    _llamaModelPath = null;
    _llamaModelInfo = null;
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
    final blockReason = _llamaModelInfo?.localInferenceBlockReason;
    if (blockReason != null) {
      _setError(blockReason);
      throw StateError(blockReason);
    }
    if (Platform.isAndroid || Platform.isIOS) {
      yield* _generateMobileResponse(messages, tools: tools, config: config);
    } else {
      yield* _generateLlamaResponse(messages, tools: tools, config: config);
    }
  }

  Stream<ChatGenerationChunk> _generateMobileResponse(
    List<Message> messages, {
    List<Map<String, dynamic>> tools = const [],
    ModelConfig? config,
  }) async* {
    final effectiveConfig =
        (config ?? _llamaConfig ?? ModelConfig.platformDefaultConfig)
            .withSupportedBackendForCurrentPlatform();

    final llamaTools = llamaToolsFromOpenAiTools(tools);
    final serverMessages = _buildServerMessages(
      messages,
      llamaTools,
      promptBudgetChars: _localPromptBudgetChars(effectiveConfig),
    );

    if (_hasBinaryMedia(messages)) {
      const message =
          'Local OpenAI server multimodal input is not supported yet.';
      _setError(message);
      throw UnsupportedError(message);
    }

    try {
      yield* _parseOpenAiServerStream(
        app_local_llm.LocalLlm.instance.streamChatCompletion(
          model: _localLlamaModelAlias,
          messages: serverMessages,
          maxTokens: effectiveConfig.maxTokens,
          temperature: effectiveConfig.temperature,
          topK: effectiveConfig.topK,
          stop: _localLlamaStopSequences,
        ),
      );
    } catch (error) {
      _setError(error.toString());
      rethrow;
    }
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
    final llamaTools = llamaToolsFromOpenAiTools(tools);

    final server = await _ensureLlamaServer(effectiveConfig);
    final serverMessages = _buildServerMessages(
      messages,
      llamaTools,
      promptBudgetChars: _localPromptBudgetChars(effectiveConfig),
    );

    try {
      yield* _parseOpenAiServerStream(
        server.streamChatCompletion(
          model: _localLlamaModelAlias,
          messages: serverMessages,
          maxTokens: effectiveConfig.maxTokens,
          temperature: effectiveConfig.temperature,
          stop: _localLlamaStopSequences,
        ),
      );
    } on TimeoutException catch (error) {
      _setError(error.message ?? error.toString());
      rethrow;
    }
  }

  Stream<ChatGenerationChunk> _parseOpenAiServerStream(
    Stream<Map<String, Object?>> events,
  ) async* {
    final streamParser = _Gemma4StreamParser();
    final toolCallBuffers = <int, _LocalOpenAiToolCallBuffer>{};

    await for (final event in events) {
      final error = _serverErrorMessage(event);
      if (error != null) {
        _setError(error);
        throw StateError(error);
      }

      final toolCall = _serverToolCallChunk(event, toolCallBuffers);
      if (toolCall != null) {
        for (final chunk in streamParser.close()) {
          yield chunk;
        }
        yield toolCall;
        continue;
      }

      final content = _serverDeltaContent(event);
      if (content == null || content.isEmpty) {
        continue;
      }
      for (final chunk in streamParser.add(content)) {
        yield chunk;
      }
    }

    for (final chunk in streamParser.close()) {
      yield chunk;
    }
    final trailingToolCall = _toolCallChunkFromBuffers(toolCallBuffers);
    if (trailingToolCall != null) {
      yield trailingToolCall;
    }
  }

  Future<LocalLlamaServerSession> _ensureLlamaServer(ModelConfig config) async {
    final modelPath = _llamaModelPath;
    if (modelPath == null) {
      throw StateError('Model is not loaded. Call loadModel() first.');
    }

    final serverConfig = _serverConfigFor(modelPath: modelPath, config: config);
    final currentServer = _llamaServer;
    final currentConfig = _llamaServerConfig;
    if (currentServer != null &&
        currentConfig != null &&
        _sameServerConfig(currentConfig, serverConfig)) {
      return currentServer;
    }

    await _closeLlamaServer();
    final server = await _llamaServerFactory(serverConfig);
    _llamaServer = server;
    _llamaServerConfig = serverConfig;
    return server;
  }

  LocalLlamaServerConfig _serverConfigFor({
    required String modelPath,
    required ModelConfig config,
  }) {
    final effectiveConfig = config.withSupportedBackendForCurrentPlatform();
    final contextSize = math.max(
      _defaultLlamaContextSize,
      effectiveConfig.maxTokens + _llamaContextPromptReserve,
    );
    return LocalLlamaServerConfig(
      model: _localLlamaModelAlias,
      modelPath: modelPath,
      contextSize: contextSize,
      gpuLayerCount: effectiveConfig.backend.usesGpuLayers ? 99 : 0,
      libraryRequest: _libraryRequestForBackend(effectiveConfig.backend),
    );
  }

  bool _sameServerConfig(
    LocalLlamaServerConfig left,
    LocalLlamaServerConfig right,
  ) {
    return left.model == right.model &&
        left.modelPath == right.modelPath &&
        left.contextSize == right.contextSize &&
        left.gpuLayerCount == right.gpuLayerCount &&
        left.libraryRequest.preferredPath ==
            right.libraryRequest.preferredPath &&
        setEquals(
          left.libraryRequest.requiredCapabilities,
          right.libraryRequest.requiredCapabilities,
        );
  }

  Future<void> _closeLlamaServer() async {
    final server = _llamaServer;
    _llamaServer = null;
    _llamaServerConfig = null;
    if (server != null) {
      await server.close();
    }
  }

  /// Builds OpenAI-compatible messages from app [Message] list, injecting tool
  /// definitions into the system instruction.
  List<Map<String, Object?>> _buildServerMessages(
    List<Message> messages,
    List<llama.LlamaTool> tools, {
    int? promptBudgetChars,
  }) {
    String? systemInstruction;
    final result = <Map<String, Object?>>[];

    for (final message in messages) {
      if (message is SystemMessage) {
        systemInstruction ??= message.content;
        continue;
      }
      if (message is AssistantMessage && message.isStreaming) continue;

      final (role, content) = switch (message) {
        final UserMessage user => ('user', user.contentWithAttachments()),
        AssistantMessage(:final content) => ('assistant', content),
        ToolResponseMessage(:final toolName, :final content) => (
          'user',
          'Tool result for $toolName:\n$content',
        ),
        _ => ('user', message.content),
      };

      if (content.trim().isEmpty) continue;
      result.add({'role': role, 'content': content.trim()});
    }

    final effectiveSystem = _buildBudgetedSystemInstruction(
      systemInstruction,
      tools,
      promptBudgetChars: promptBudgetChars == null
          ? null
          : math.max(
              0,
              promptBudgetChars - _latestMessageContentLength(result),
            ),
    );

    if (effectiveSystem.isNotEmpty) {
      result.insert(0, {'role': 'system', 'content': effectiveSystem});
    }

    return _trimServerMessagesToBudget(result, promptBudgetChars);
  }

  int _localPromptBudgetChars(ModelConfig config) {
    final contextTokens = Platform.isAndroid || Platform.isIOS
        ? _mobileLiteRtLmContextSize
        : math.max(
            _defaultLlamaContextSize,
            config.maxTokens + _llamaContextPromptReserve,
          );
    final outputReserve = math.min(
      config.maxTokens,
      _localPromptOutputReserveTokens,
    );
    final promptTokens = math.max(
      _localPromptMinimumTokens,
      contextTokens - outputReserve - _localPromptSafetyTokens,
    );
    return promptTokens * _localPromptApproxCharsPerToken;
  }

  String _buildBudgetedSystemInstruction(
    String? systemInstruction,
    List<llama.LlamaTool> tools, {
    int? promptBudgetChars,
  }) {
    final trimmedSystem = systemInstruction?.trim() ?? '';
    if (promptBudgetChars != null && promptBudgetChars <= 0) {
      return '';
    }

    final parts = <String>[];
    var remaining = promptBudgetChars;
    if (trimmedSystem.isNotEmpty) {
      final systemPart = remaining == null
          ? trimmedSystem
          : _leadingChars(trimmedSystem, remaining);
      if (systemPart.isNotEmpty) {
        parts.add(systemPart);
        remaining = remaining == null ? null : remaining - systemPart.length;
      }
    }

    if (parts.isNotEmpty && remaining != null) {
      remaining -= 2;
    }
    final toolInstructions = remaining == null
        ? buildGemmaToolInstructions(tools)
        : _buildGemmaToolInstructionsWithinBudget(tools, remaining);
    if (toolInstructions.isNotEmpty) {
      parts.add(toolInstructions);
    }

    return parts.join('\n\n');
  }

  String _buildGemmaToolInstructionsWithinBudget(
    List<llama.LlamaTool> tools,
    int maxChars,
  ) {
    if (tools.isEmpty || maxChars <= 0) return '';

    final included = <llama.LlamaTool>[];
    for (final tool in tools) {
      final candidate = buildGemmaToolInstructions([...included, tool]);
      if (candidate.length <= maxChars) {
        included.add(tool);
      }
    }

    return buildGemmaToolInstructions(included);
  }

  List<Map<String, Object?>> _trimServerMessagesToBudget(
    List<Map<String, Object?>> messages,
    int? promptBudgetChars,
  ) {
    if (promptBudgetChars == null ||
        _serverMessagesContentLength(messages) <= promptBudgetChars) {
      return messages;
    }

    final result = [...messages];
    while (_serverMessagesContentLength(result) > promptBudgetChars &&
        result.length > 1) {
      final removableIndex = result.indexWhere(
        (message) => message['role'] != 'system' && message != result.last,
      );
      if (removableIndex == -1) break;
      result.removeAt(removableIndex);
    }

    if (_serverMessagesContentLength(result) > promptBudgetChars &&
        result.length > 1 &&
        result.first['role'] == 'system') {
      result.removeAt(0);
    }

    if (_serverMessagesContentLength(result) <= promptBudgetChars) {
      return result;
    }

    if (result.isEmpty) return result;
    final last = result.last;
    final content = last['content'];
    if (content is! String || content.length <= promptBudgetChars) {
      return result;
    }

    return [
      {
        'role': last['role'],
        'content': content.substring(content.length - promptBudgetChars),
      },
    ];
  }

  int _serverMessagesContentLength(List<Map<String, Object?>> messages) {
    return messages.fold<int>(0, (total, message) {
      final content = message['content'];
      return total + (content is String ? content.length : 0);
    });
  }

  int _latestMessageContentLength(List<Map<String, Object?>> messages) {
    if (messages.isEmpty) return 0;
    final content = messages.last['content'];
    return content is String ? content.length : 0;
  }

  String _leadingChars(String value, int maxChars) {
    if (maxChars <= 0) return '';
    if (value.length <= maxChars) return value;
    return value.substring(0, maxChars);
  }

  /// Maps a [GemmaBackend] to the [LlamaCppLibraryRequest] that tells the
  /// platform plugin which native library to load (CPU, Vulkan, Metal, etc.).
  static llama_platform.LlamaCppLibraryRequest _libraryRequestForBackend(
    GemmaBackend backend,
  ) {
    final capability = switch (backend) {
      GemmaBackend.metal => llama_platform.LlamaCppLibraryCapability.metal,
      GemmaBackend.cuda => llama_platform.LlamaCppLibraryCapability.cuda,
      GemmaBackend.vulkan => llama_platform.LlamaCppLibraryCapability.vulkan,
      GemmaBackend.cpu || GemmaBackend.npu => null,
    };
    if (capability == null) {
      return const llama_platform.LlamaCppLibraryRequest();
    }
    return llama_platform.LlamaCppLibraryRequest(
      requiredCapabilities: {capability},
    );
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

  String? _serverDeltaContent(Map<String, Object?> event) {
    final choices = event['choices'];
    if (choices is! List || choices.isEmpty) {
      final rootDelta = event['delta'];
      return rootDelta is String ? rootDelta : null;
    }

    final firstChoice = choices.first;
    if (firstChoice is! Map) {
      return null;
    }

    final delta = firstChoice['delta'];
    if (delta is Map) {
      final content = delta['content'];
      if (content is String) return content;
      final reasoningContent = delta['reasoning_content'];
      if (reasoningContent is String) return reasoningContent;
      final reasoning = delta['reasoning'];
      if (reasoning is String) return reasoning;
    }

    final message = firstChoice['message'];
    if (message is Map) {
      final content = message['content'];
      if (content is String) return content;
    }

    return null;
  }

  String? _serverErrorMessage(Map<String, Object?> event) {
    final error = event['error'];
    if (error is Map) {
      final message = error['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
      return error.toString();
    }
    return null;
  }

  bool _hasBinaryMedia(List<Message> messages) {
    for (final message in messages) {
      if (message is! UserMessage) continue;
      if (message.imageBytes != null || message.audioBytes != null) {
        return true;
      }
      for (final attachment in message.attachments) {
        if ((attachment.isImage || attachment.isAudio) &&
            attachment.bytes != null) {
          return true;
        }
      }
    }
    return false;
  }

  ChatFunctionCallChunk? _serverToolCallChunk(
    Map<String, Object?> event,
    Map<int, _LocalOpenAiToolCallBuffer> buffers,
  ) {
    final firstChoice = _firstServerChoice(event);
    if (firstChoice == null) return null;

    var hasCompleteMessageToolCall = false;
    final delta = firstChoice['delta'];
    if (delta is Map) {
      _collectToolCallDeltas(buffers, delta['tool_calls']);
      _collectLegacyFunctionCallDelta(buffers, delta['function_call']);
    }

    final message = firstChoice['message'];
    if (message is Map) {
      _collectToolCallDeltas(buffers, message['tool_calls']);
      _collectLegacyFunctionCallDelta(buffers, message['function_call']);
      hasCompleteMessageToolCall =
          message.containsKey('tool_calls') ||
          message.containsKey('function_call');
    }

    final finishReason = _stringValue(firstChoice['finish_reason']);
    if (finishReason == 'tool_calls' ||
        finishReason == 'function_call' ||
        hasCompleteMessageToolCall) {
      final chunk = _toolCallChunkFromBuffers(buffers);
      buffers.clear();
      return chunk;
    }

    return null;
  }

  Map? _firstServerChoice(Map<String, Object?> event) {
    final choices = event['choices'];
    if (choices is! List || choices.isEmpty) return null;
    final firstChoice = choices.first;
    return firstChoice is Map ? firstChoice : null;
  }

  void _collectToolCallDeltas(
    Map<int, _LocalOpenAiToolCallBuffer> buffers,
    Object? rawToolCalls,
  ) {
    if (rawToolCalls is! List) return;

    for (
      var fallbackIndex = 0;
      fallbackIndex < rawToolCalls.length;
      fallbackIndex++
    ) {
      final rawToolCall = rawToolCalls[fallbackIndex];
      if (rawToolCall is! Map) continue;

      final index = _intValue(rawToolCall['index']) ?? fallbackIndex;
      final buffer = buffers.putIfAbsent(index, _LocalOpenAiToolCallBuffer.new);

      final function = rawToolCall['function'];
      if (function is! Map) continue;

      final name = _stringValue(function['name']);
      if (name != null && name.isNotEmpty) buffer.name = name;

      final arguments = _stringValue(function['arguments']);
      if (arguments != null) buffer.arguments.write(arguments);
    }
  }

  void _collectLegacyFunctionCallDelta(
    Map<int, _LocalOpenAiToolCallBuffer> buffers,
    Object? rawFunctionCall,
  ) {
    if (rawFunctionCall is! Map) return;

    final buffer = buffers.putIfAbsent(0, _LocalOpenAiToolCallBuffer.new);
    final name = _stringValue(rawFunctionCall['name']);
    if (name != null && name.isNotEmpty) buffer.name = name;

    final arguments = _stringValue(rawFunctionCall['arguments']);
    if (arguments != null) buffer.arguments.write(arguments);
  }

  ChatFunctionCallChunk? _toolCallChunkFromBuffers(
    Map<int, _LocalOpenAiToolCallBuffer> buffers,
  ) {
    final indexes = buffers.keys.toList()..sort();
    for (final index in indexes) {
      final buffer = buffers[index]!;
      final name = buffer.name?.trim();
      if (name == null || name.isEmpty) continue;
      return ChatFunctionCallChunk(
        name: name,
        args: _decodeOpenAiToolArgs(buffer.arguments.toString()),
      );
    }
    return null;
  }

  Map<String, dynamic> _decodeOpenAiToolArgs(String arguments) {
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

  String? _stringValue(Object? value) => value is String ? value : null;

  int? _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }
}

final class _LocalOpenAiToolCallBuffer {
  String? name;
  final arguments = StringBuffer();
}

final class _LibLlamaCppServerSession implements LocalLlamaServerSession {
  _LibLlamaCppServerSession._({
    required llama_server.LlamaHttpServer server,
    required llama_server.LlamaServerClient client,
  }) : _server = server,
       _client = client;

  static Future<LocalLlamaServerSession> start(
    LocalLlamaServerConfig config,
  ) async {
    final descriptor = await llama_platform.LibLlamaCppPlatform.instance
        .resolveLibrary(request: config.libraryRequest);
    final libraryPath = _libraryPathForDescriptor(descriptor);
    final server = llama_server.LlamaHttpServer.open(
      config: llama_server.LlamaServerConfig(
        model: config.model,
        modelPath: config.modelPath,
        ctxSize: config.contextSize,
        gpuLayers: config.gpuLayerCount,
        port: 0,
      ),
      libraryPath: libraryPath,
    );
    final address = await server.start(host: '127.0.0.1', port: 0);
    final client = llama_server.LlamaServerClient(
      baseUri: Uri.parse('http://${address.host}:${address.port}/v1'),
    );
    return _LibLlamaCppServerSession._(server: server, client: client);
  }

  final llama_server.LlamaHttpServer _server;
  final llama_server.LlamaServerClient _client;

  @override
  Stream<Map<String, Object?>> streamChatCompletion({
    required String model,
    required List<Map<String, Object?>> messages,
    int? maxTokens,
    double? temperature,
    double? topP,
    List<String> stop = const [],
  }) {
    return _client.streamChatCompletion(
      model: model,
      messages: messages,
      maxTokens: maxTokens,
      temperature: temperature,
      topP: topP,
      stop: stop,
    );
  }

  @override
  Future<void> close() => _server.close();
}

String? _libraryPathForDescriptor(
  llama_platform.LlamaCppLibraryDescriptor descriptor,
) {
  return switch (descriptor.resolution) {
    llama_platform.LlamaCppLibraryResolution.path => descriptor.path,
    llama_platform.LlamaCppLibraryResolution.lookupName =>
      descriptor.lookupName,
    llama_platform.LlamaCppLibraryResolution.process ||
    llama_platform.LlamaCppLibraryResolution.executable => null,
  };
}

class _Gemma4StreamParser {
  static const _thinkStartTags = ['<think>', '<|think|>'];
  static const _thinkEndTags = ['</think>', '<|/think|>', '<think|>'];
  static const _toolStartTags = ['<|tool_call>', '<|tool_call|>'];
  static const _toolEndTags = ['<tool_call>', '</tool_call>', '<|/tool_call|>'];

  String _buffer = '';
  var _inThinking = false;

  List<ChatGenerationChunk> add(String text) {
    if (text.isEmpty) return const [];
    _buffer += text;
    return _drain(complete: false);
  }

  List<ChatGenerationChunk> close() {
    return _drain(complete: true);
  }

  List<ChatGenerationChunk> _drain({required bool complete}) {
    final chunks = <ChatGenerationChunk>[];

    while (_buffer.isNotEmpty) {
      if (_inThinking) {
        if (!_drainThinking(chunks, complete: complete)) break;
        continue;
      }

      final thinkStart = _findFirst(_buffer, _thinkStartTags);
      final toolStart = _findFirst(_buffer, _toolStartTags);
      final next = _earlier(thinkStart, toolStart);

      if (next == null) {
        final keep = complete
            ? 0
            : _trailingMarkerPrefixLength(_buffer, [
                ..._thinkStartTags,
                ..._toolStartTags,
              ]);
        _emitText(chunks, _buffer.substring(0, _buffer.length - keep));
        _buffer = _buffer.substring(_buffer.length - keep);
        break;
      }

      _emitText(chunks, _buffer.substring(0, next.index));
      _buffer = _buffer.substring(next.index + next.marker.length);

      if (_thinkStartTags.contains(next.marker)) {
        _inThinking = true;
        continue;
      }

      if (!_drainToolCall(chunks, next.marker, complete: complete)) break;
    }

    return chunks;
  }

  bool _drainThinking(
    List<ChatGenerationChunk> chunks, {
    required bool complete,
  }) {
    final end = _findFirst(_buffer, _thinkEndTags);
    if (end == null) {
      final keep = complete
          ? 0
          : _trailingMarkerPrefixLength(_buffer, _thinkEndTags);
      _emitThinking(chunks, _buffer.substring(0, _buffer.length - keep));
      _buffer = _buffer.substring(_buffer.length - keep);
      return false;
    }

    _emitThinking(chunks, _buffer.substring(0, end.index));
    _buffer = _buffer.substring(end.index + end.marker.length);
    _inThinking = false;
    return true;
  }

  bool _drainToolCall(
    List<ChatGenerationChunk> chunks,
    String startMarker, {
    required bool complete,
  }) {
    final end = _findFirst(_buffer, _toolEndTags);
    if (end == null) {
      if (!complete) {
        _buffer = '$startMarker$_buffer';
        return false;
      }
      final parsed = _parseToolCall(_buffer);
      if (parsed == null) {
        _emitText(chunks, '$startMarker$_buffer');
      } else {
        chunks.add(parsed);
      }
      _buffer = '';
      return false;
    }

    final body = _buffer.substring(0, end.index);
    final parsed = _parseToolCall(body);
    if (parsed == null) {
      _emitText(chunks, '$startMarker$body${end.marker}');
    } else {
      chunks.add(parsed);
    }
    _buffer = _buffer.substring(end.index + end.marker.length);
    return true;
  }

  ChatFunctionCallChunk? _parseToolCall(String body) {
    var text = body.trim();
    if (text.startsWith('call:')) {
      text = text.substring('call:'.length).trim();
    }

    if (text.startsWith('{')) {
      return _parseJsonToolCall(text);
    }

    final match = RegExp(
      r'^([A-Za-z_][A-Za-z0-9_.-]*)\s*(.*)$',
      dotAll: true,
    ).firstMatch(text);
    if (match == null) return null;

    final name = match.group(1)!.trim();
    var arguments = match.group(2)!.trim();
    if (arguments.startsWith('(') && arguments.endsWith(')')) {
      arguments = arguments.substring(1, arguments.length - 1).trim();
    }

    return ChatFunctionCallChunk(
      name: name,
      args: _decodeGemmaToolArgs(arguments),
    );
  }

  ChatFunctionCallChunk? _parseJsonToolCall(String text) {
    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map) return null;
      final function = decoded['function'];
      final source = function is Map ? function : decoded;
      final rawName = source['name'] ?? source['tool_name'];
      final name = rawName is String ? rawName.trim() : '';
      if (name.isEmpty) return null;
      return ChatFunctionCallChunk(
        name: name,
        args: _decodeGemmaToolArgs(source['arguments'] ?? source['args']),
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _decodeGemmaToolArgs(Object? arguments) {
    if (arguments == null) return const {};
    if (arguments is Map) {
      return {
        for (final entry in arguments.entries)
          if (entry.key != null) entry.key.toString(): entry.value,
      };
    }

    final text = arguments.toString().trim();
    if (text.isEmpty) return const {};
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map) {
        return {
          for (final entry in decoded.entries)
            if (entry.key != null) entry.key.toString(): entry.value,
        };
      }
      return {'value': decoded};
    } catch (_) {
      return {'raw': text};
    }
  }

  _Marker? _findFirst(String text, List<String> markers) {
    _Marker? result;
    for (final marker in markers) {
      final index = text.indexOf(marker);
      if (index == -1) continue;
      if (result == null ||
          index < result.index ||
          (index == result.index && marker.length > result.marker.length)) {
        result = _Marker(index: index, marker: marker);
      }
    }
    return result;
  }

  _Marker? _earlier(_Marker? first, _Marker? second) {
    if (first == null) return second;
    if (second == null) return first;
    if (first.index != second.index) {
      return first.index < second.index ? first : second;
    }
    return first.marker.length >= second.marker.length ? first : second;
  }

  int _trailingMarkerPrefixLength(String text, List<String> markers) {
    var keep = 0;
    for (final marker in markers) {
      final max = text.length < marker.length - 1
          ? text.length
          : marker.length - 1;
      for (var length = max; length > keep; length -= 1) {
        if (marker.startsWith(text.substring(text.length - length))) {
          keep = length;
          break;
        }
      }
    }
    return keep;
  }

  void _emitText(List<ChatGenerationChunk> chunks, String text) {
    if (text.isEmpty) return;
    chunks.add(ChatTextChunk(text));
  }

  void _emitThinking(List<ChatGenerationChunk> chunks, String text) {
    if (text.isEmpty) return;
    chunks.add(ChatThinkingChunk(text));
  }
}

class _Marker {
  const _Marker({required this.index, required this.marker});

  final int index;
  final String marker;
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
