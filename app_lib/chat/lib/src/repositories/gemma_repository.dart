import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart' as gemma;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../models/message.dart';
import '../models/model_config.dart';

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
  });

  /// Download progress as a percentage (0-100).
  final double percentage;

  @override
  String toString() => 'DownloadProgress(${percentage.toStringAsFixed(1)}%)';
}

/// Repository for interacting with the Gemma model.
///
/// Wraps the flutter_gemma package to provide a simplified API
/// for model management and text generation.
class GemmaRepository {
  GemmaRepository();

  gemma.InferenceModel? _model;
  gemma.InferenceChat? _chat;
  bool _isThinking = false;

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

  /// Gets the model ID for a given model type.
  String _getModelId(GemmaModelType modelType) {
    final id = switch (modelType) {
      GemmaModelType.gemma2bIt => 'gemma-2b-it',
      GemmaModelType.gemma7bIt => 'gemma-7b-it',
      GemmaModelType.custom => 'custom-model',
    };
    debugPrint('[GemmaRepo] _getModelId($modelType) => $id');
    return id;
  }

  /// Checks if a model is installed.
  Future<bool> checkModelInstalled(GemmaModelType modelType) async {
    debugPrint('[GemmaRepo] checkModelInstalled($modelType)');
    _setStatus(GemmaModelStatus.checking);

    try {
      final modelId = _getModelId(modelType);
      debugPrint('[GemmaRepo] Checking isModelInstalled for id=$modelId');
      final isInstalled = await gemma.FlutterGemma.isModelInstalled(modelId);
      debugPrint('[GemmaRepo] isModelInstalled($modelId) => $isInstalled');

      _setStatus(isInstalled
          ? GemmaModelStatus.installed
          : GemmaModelStatus.notInstalled);
      return isInstalled;
    } catch (e, st) {
      debugPrint('[GemmaRepo] checkModelInstalled FAILED: $e');
      debugPrint('[GemmaRepo] Stack trace: $st');
      _setError('Failed to check model installation: $e');
      return false;
    }
  }

  /// Determines the [gemma.ModelFileType] from a URL or file path.
  ///
  /// `.litertlm` files use [gemma.ModelFileType.litertlm] (LiteRT-LM SDK
  /// handles chat templates on desktop). `.task` files use
  /// [gemma.ModelFileType.task] (MediaPipe handles templates). All other
  /// extensions default to [gemma.ModelFileType.binary].
  static gemma.ModelFileType _fileTypeFromPath(String path) {
    if (path.endsWith('.litertlm')) return gemma.ModelFileType.litertlm;
    if (path.endsWith('.task')) return gemma.ModelFileType.task;
    return gemma.ModelFileType.binary;
  }

  /// Activates an already-installed model so [getActiveModel] can find it.
  ///
  /// flutter_gemma keeps the "active model" in memory only, so after an app
  /// restart we must re-run the install flow. The install is idempotent: if
  /// the model file already exists the download is skipped, but the model is
  /// still set as active.
  Future<void> activateModel(GemmaModelInfo info) async {
    debugPrint(
        '[GemmaRepo] activateModel(${info.id}, modelType=${info.modelType})');
    try {
      final downloadUrl = info.downloadUrl;
      final builder = gemma.FlutterGemma.installModel(
        modelType: info.modelType,
        fileType: _fileTypeFromPath(downloadUrl),
      );
      // fromNetwork detects the model is already installed and skips download,
      // but still calls setActiveModel internally.
      await builder.fromNetwork(downloadUrl).install();
      debugPrint('[GemmaRepo] activateModel completed for ${info.id}');
      _setStatus(GemmaModelStatus.installed);
    } catch (e, st) {
      debugPrint('[GemmaRepo] activateModel FAILED: $e');
      debugPrint('[GemmaRepo] Stack trace: $st');
      _setError('Failed to activate model: $e');
    }
  }

  /// Installs a model from the network with resume support.
  ///
  /// Downloads using dart:io HttpClient with HTTP Range requests so that
  /// interrupted downloads can be resumed from where they left off.
  /// [nativeModelType] - The flutter_gemma ModelType for the model.
  /// [url] - The URL to download the model from (e.g., Hugging Face).
  /// [token] - Optional authentication token for the download.
  /// [onProgress] - Per-download progress callback for parallel downloads.
  Future<void> installModel({
    required gemma.ModelType nativeModelType,
    required String url,
    String? token,
    void Function(double percentage)? onProgress,
  }) async {
    debugPrint(
        '[GemmaRepo] installModel(nativeModelType=$nativeModelType, url=$url, hasToken=${token != null})');

    try {
      final filePath = await _downloadFile(
        url: url,
        token: token,
        onProgress: onProgress,
      );

      debugPrint(
          '[GemmaRepo] Installing model from downloaded file: $filePath');
      await gemma.FlutterGemma.installModel(
        modelType: nativeModelType,
        fileType: _fileTypeFromPath(url),
      ).fromFile(filePath).install();
      debugPrint('[GemmaRepo] fromFile().install() completed successfully');

      // Do NOT delete the downloaded file — flutter_gemma's fromFile()
      // registers the file path rather than copying it, so the file must
      // remain on disk for loadModel/getActiveModel to find it.
    } catch (e, st) {
      debugPrint('[GemmaRepo] installModel FAILED: $e');
      debugPrint('[GemmaRepo] Error type: ${e.runtimeType}');
      debugPrint('[GemmaRepo] Stack trace: $st');
      rethrow;
    }
  }

  /// Installs a model from the network via a proxy with resume support.
  ///
  /// Downloads using dart:io HttpClient with proxy and HTTP Range requests
  /// so that interrupted downloads can be resumed.
  /// [onProgress] - Per-download progress callback for parallel downloads.
  Future<void> installModelWithProxy({
    required gemma.ModelType nativeModelType,
    required String url,
    required String proxyUrl,
    String? token,
    void Function(double percentage)? onProgress,
  }) async {
    debugPrint(
        '[GemmaRepo] installModelWithProxy(nativeModelType=$nativeModelType, url=$url, proxy=$proxyUrl, hasToken=${token != null})');

    try {
      final filePath = await _downloadFile(
        url: url,
        proxyUrl: proxyUrl,
        token: token,
        onProgress: onProgress,
      );

      debugPrint(
          '[GemmaRepo] Installing model from downloaded file: $filePath');
      await gemma.FlutterGemma.installModel(
        modelType: nativeModelType,
        fileType: _fileTypeFromPath(url),
      ).fromFile(filePath).install();
      debugPrint('[GemmaRepo] fromFile().install() completed successfully');
    } catch (e, st) {
      debugPrint('[GemmaRepo] installModelWithProxy FAILED: $e');
      debugPrint('[GemmaRepo] Error type: ${e.runtimeType}');
      debugPrint('[GemmaRepo] Stack trace: $st');
      rethrow;
    }
  }

  /// Downloads a file with HTTP Range resume support.
  ///
  /// Downloads directly to [getApplicationDocumentsDirectory] because
  /// flutter_gemma's `UnifiedModelManager` validates model files at that
  /// location (via `ModelFileSystemManager.getModelFilePath`). Placing the
  /// file elsewhere causes "Model file validation failed" even though
  /// `fromFile().install()` succeeds.
  ///
  /// Returns the absolute path to the completed download.
  Future<String> _downloadFile({
    required String url,
    String? proxyUrl,
    String? token,
    void Function(double percentage)? onProgress,
  }) async {
    final docsDir = await getApplicationDocumentsDirectory();

    final fileName = Uri.parse(url).pathSegments.last;
    final filePath = p.join(docsDir.path, fileName);
    final file = File(filePath);

    var existingBytes = 0;
    if (file.existsSync()) {
      existingBytes = file.lengthSync();
      debugPrint(
          '[GemmaRepo] Found partial download: $existingBytes bytes at $filePath');
    }

    final client = HttpClient();
    try {
      // Configure proxy if provided
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
          '[GemmaRepo] Sending GET request to $url (resume from $existingBytes bytes)...');
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

      int totalBytes;
      int received;
      IOSink sink;

      if (response.statusCode == 206) {
        // Partial Content — server supports resume.
        // Content-Length in a 206 is the *remaining* bytes.
        totalBytes = existingBytes + response.contentLength;
        received = existingBytes;
        sink = file.openWrite(mode: FileMode.append);
        debugPrint(
            '[GemmaRepo] Resuming download: $existingBytes / $totalBytes bytes');
      } else if (response.statusCode == 200) {
        // Full content — server ignored Range or doesn't support it.
        totalBytes = response.contentLength;
        received = 0;
        sink = file.openWrite(); // overwrite
        debugPrint(
            '[GemmaRepo] Starting fresh download (totalBytes=$totalBytes)');
      } else if (response.statusCode == 416) {
        // Range Not Satisfiable — the file may already be complete.
        // Drain response and return the existing file.
        await response.drain<void>();
        debugPrint(
            '[GemmaRepo] 416 Range Not Satisfiable — file may be complete ($existingBytes bytes)');
        return filePath;
      } else {
        final errorBody = await response.transform(utf8.decoder).join();
        debugPrint('[GemmaRepo] Error response body: $errorBody');
        throw HttpException(
            'Download failed with status ${response.statusCode}: $errorBody');
      }

      // Report initial progress for resumed downloads
      if (received > 0 && totalBytes > 0) {
        final pct = (received / totalBytes * 100).clamp(0.0, 100.0);
        onProgress?.call(pct);
        _progressController.add(DownloadProgress(percentage: pct));
      }

      var lastLogPercent = -1;
      await for (final chunk in response) {
        sink.add(chunk);
        received += chunk.length;
        if (totalBytes > 0) {
          final percent = (received / totalBytes * 100).clamp(0.0, 100.0);
          final percentInt = percent.toInt();
          if (percentInt != lastLogPercent && percentInt % 10 == 0) {
            debugPrint(
                '[GemmaRepo] Download progress: $percentInt% ($received / $totalBytes bytes)');
            lastLogPercent = percentInt;
          }
          onProgress?.call(percent);
          _progressController.add(DownloadProgress(percentage: percent));
        }
      }
      await sink.close();

      final fileSize = file.lengthSync();
      debugPrint('[GemmaRepo] Download complete: $filePath ($fileSize bytes)');
      return filePath;
    } finally {
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
          '[GemmaRepo] Failed to clean up download file: $filePath ($e)');
    }
  }

  /// Installs a model from a Flutter asset.
  ///
  /// On macOS the native `large_file_handler` channel is not available, so we
  /// resolve the asset inside the app bundle and install via [fromFile] instead.
  Future<void> installModelFromAsset({
    required gemma.ModelType modelType,
    required String assetPath,
  }) async {
    debugPrint(
        '[GemmaRepo] installModelFromAsset(modelType=$modelType, assetPath=$assetPath)');
    _setStatus(GemmaModelStatus.downloading);

    try {
      if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
        // Desktop platforms: large_file_handler has no implementation, so
        // resolve the asset from the app bundle and use fromFile().
        final resolvedPath = _resolveBundledAssetPath(assetPath);
        debugPrint(
            '[GemmaRepo] Desktop platform, resolved asset path: $resolvedPath');
        if (resolvedPath != null && File(resolvedPath).existsSync()) {
          debugPrint(
              '[GemmaRepo] Asset file found (${File(resolvedPath).lengthSync()} bytes), installing via fromFile...');
          await gemma.FlutterGemma.installModel(
            modelType: modelType,
            fileType: _fileTypeFromPath(resolvedPath),
          ).fromFile(resolvedPath).install();
          debugPrint(
              '[GemmaRepo] fromFile().install() completed successfully (desktop asset fallback)');
        } else {
          debugPrint('[GemmaRepo] Asset file NOT found at: $resolvedPath');
          throw Exception(
              'Bundled asset not found at resolved path: $resolvedPath');
        }
      } else {
        // Mobile platforms: use native fromAsset() via large_file_handler.
        debugPrint(
            '[GemmaRepo] Mobile platform, using fromAsset($assetPath)...');
        await gemma.FlutterGemma.installModel(
          modelType: modelType,
          fileType: _fileTypeFromPath(assetPath),
        ).fromAsset(assetPath).install();
        debugPrint('[GemmaRepo] fromAsset().install() completed successfully');
      }

      _setStatus(GemmaModelStatus.installed);
    } catch (e, st) {
      debugPrint('[GemmaRepo] installModelFromAsset FAILED: $e');
      debugPrint('[GemmaRepo] Error type: ${e.runtimeType}');
      debugPrint('[GemmaRepo] Stack trace: $st');
      _setError('Failed to install model from asset: $e');
    }
  }

  /// Resolves a Flutter asset path to an absolute file system path.
  ///
  /// On macOS assets live inside the app bundle at:
  ///   `<Bundle>/Contents/Frameworks/App.framework/Resources/flutter_assets/<assetPath>`
  /// On Linux they are at:
  ///   `<exe_dir>/data/flutter_assets/<assetPath>`
  /// On Windows:
  ///   `<exe_dir>/data/flutter_assets/<assetPath>`
  String? _resolveBundledAssetPath(String assetPath) {
    if (Platform.isMacOS) {
      final executable = Platform.resolvedExecutable;
      final bundlePath = p.dirname(p.dirname(executable));
      return p.join(bundlePath, 'Frameworks', 'App.framework', 'Resources',
          'flutter_assets', assetPath);
    }
    if (Platform.isLinux || Platform.isWindows) {
      final exeDir = p.dirname(Platform.resolvedExecutable);
      return p.join(exeDir, 'data', 'flutter_assets', assetPath);
    }
    return null;
  }

  /// Installs a model from a local file path.
  Future<void> installModelFromFile({
    required gemma.ModelType nativeModelType,
    required String filePath,
  }) async {
    debugPrint(
        '[GemmaRepo] installModelFromFile(nativeModelType=$nativeModelType, filePath=$filePath)');
    _setStatus(GemmaModelStatus.downloading);

    try {
      debugPrint('[GemmaRepo] Creating install builder fromFile($filePath)...');
      await gemma.FlutterGemma.installModel(
        modelType: nativeModelType,
        fileType: _fileTypeFromPath(filePath),
      ).fromFile(filePath).install();
      debugPrint('[GemmaRepo] fromFile().install() completed successfully');

      _setStatus(GemmaModelStatus.installed);
    } catch (e, st) {
      debugPrint('[GemmaRepo] installModelFromFile FAILED: $e');
      debugPrint('[GemmaRepo] Error type: ${e.runtimeType}');
      debugPrint('[GemmaRepo] Stack trace: $st');
      _setError('Failed to install model from file: $e');
    }
  }

  /// Lists all installed model IDs.
  Future<List<String>> listInstalledModels() async {
    debugPrint('[GemmaRepo] listInstalledModels()');
    try {
      final models = await gemma.FlutterGemma.listInstalledModels();
      debugPrint(
          '[GemmaRepo] listInstalledModels => $models (${models.length} models)');
      return models;
    } catch (e, st) {
      debugPrint('[GemmaRepo] listInstalledModels FAILED: $e');
      debugPrint('[GemmaRepo] Stack trace: $st');
      _setError('Failed to list installed models: $e');
      return [];
    }
  }

  /// Loads the model into memory with the given configuration.
  ///
  /// When [supportImage] is true, the model is configured for multimodal input.
  /// When [supportsFunctionCalls] is true and [tools] are provided, the model
  /// is configured for function/tool calling.
  Future<void> loadModel(
    ModelConfig config, {
    bool supportImage = false,
    bool supportAudio = false,
    bool isThinking = false,
    bool supportsFunctionCalls = false,
    List<gemma.Tool> tools = const [],
    gemma.ModelType? nativeModelType,
  }) async {
    // Unload existing model if any
    await unloadModel();

    _isThinking = isThinking;
    _setStatus(GemmaModelStatus.loading);

    try {
      _model = await gemma.FlutterGemma.getActiveModel(
        maxTokens: config.maxTokens,
        preferredBackend: _toGemmaBackend(config.backend),
        supportImage: supportImage,
        supportAudio: supportAudio,
      );

      _chat = await _model!.createChat(
        temperature: config.temperature,
        topK: config.topK,
        supportImage: supportImage,
        supportAudio: supportAudio,
        isThinking: isThinking,
        supportsFunctionCalls: supportsFunctionCalls,
        tools: tools,
        modelType: nativeModelType,
      );
      _setStatus(GemmaModelStatus.ready);
    } catch (e) {
      debugPrint('[GemmaRepo] loadModel FAILED: $e');
      final msg = e.toString();
      // If the model file is missing/corrupted despite being in the registry,
      // clean up the stale entry and report as not installed.
      if (msg.contains('no longer installed') ||
          msg.contains('validation failed')) {
        debugPrint(
            '[GemmaRepo] Model file missing on disk, cleaning stale registry entry');
        _setStatus(GemmaModelStatus.notInstalled);
      } else {
        _setError('Failed to load model: $e');
      }
    }
  }

  /// Unloads the model from memory.
  Future<void> unloadModel() async {
    if (_chat != null) {
      // Chat doesn't have a close method, but we can clear it
      _chat = null;
    }

    if (_model != null) {
      await _model!.close();
      _model = null;
    }

    if (_status == GemmaModelStatus.ready) {
      _setStatus(GemmaModelStatus.installed);
    }
  }

  /// Deletes the installed model.
  Future<void> deleteModel(GemmaModelType modelType) async {
    await unloadModel();

    try {
      final modelId = _getModelId(modelType);
      await gemma.FlutterGemma.uninstallModel(modelId);
      _setStatus(GemmaModelStatus.notInstalled);
    } catch (e) {
      _setError('Failed to delete model: $e');
    }
  }

  /// Deletes a model by its installed ID string.
  ///
  /// Also removes the downloaded model file from disk if it exists
  /// in the managed download directory.
  Future<void> deleteModelById(String modelId) async {
    debugPrint('[GemmaRepo] deleteModelById($modelId)');
    await unloadModel();

    try {
      await gemma.FlutterGemma.uninstallModel(modelId);
      debugPrint('[GemmaRepo] deleteModelById completed for $modelId');

      // Clean up the downloaded file if it exists in our download directory.
      _cleanupDownloadFile(await _downloadFilePath(modelId));

      _setStatus(GemmaModelStatus.notInstalled);
    } catch (e, st) {
      debugPrint('[GemmaRepo] deleteModelById FAILED: $e');
      debugPrint('[GemmaRepo] Stack trace: $st');
      _setError('Failed to delete model: $e');
    }
  }

  /// Returns the expected download file path for a given model filename.
  Future<String> _downloadFilePath(String fileName) async {
    final docsDir = await getApplicationDocumentsDirectory();
    return p.join(docsDir.path, fileName);
  }

  /// Generates a response for a list of messages.
  ///
  /// Returns a stream of [gemma.ModelResponse] which can be:
  /// - [gemma.TextResponse] for text tokens
  /// - [gemma.FunctionCallResponse] for tool/function calls
  Stream<gemma.ModelResponse> generateResponse(List<Message> messages) async* {
    if (_chat == null || _model == null) {
      throw StateError('Model is not loaded. Call loadModel() first.');
    }

    // Clear existing chat history
    await _chat!.clearHistory();

    // Filter out the empty streaming assistant placeholder and system messages.
    // System messages are prepended to the first user message as context since
    // the InferenceChat API only supports user/model roles.
    String? systemPrompt;
    final chatMessages = <Message>[];
    for (final message in messages) {
      if (message is SystemMessage) {
        systemPrompt = message.content;
      } else if (message is AssistantMessage && message.isStreaming) {
        // Skip the empty placeholder we're about to generate into
        continue;
      } else {
        chatMessages.add(message);
      }
    }

    // Add messages to the chat context
    for (var i = 0; i < chatMessages.length; i++) {
      final message = chatMessages[i];
      var content = message.content;

      // Prepend system prompt to the first user message
      if (i == 0 && message is UserMessage && systemPrompt != null) {
        content = '$systemPrompt\n\n$content';
      }

      final gemmaMessage = switch (message) {
        UserMessage(:final audioBytes) when audioBytes != null =>
          gemma.Message.withAudio(
            text: content,
            audioBytes: audioBytes,
            isUser: true,
          ),
        UserMessage(:final imageBytes) when imageBytes != null =>
          gemma.Message.withImage(
            text: content,
            imageBytes: imageBytes,
            isUser: true,
          ),
        ToolResponseMessage(:final toolName) => gemma.Message.toolResponse(
            toolName: toolName,
            response: _tryParseJson(content),
          ),
        _ => gemma.Message.text(
            text: content,
            isUser: message is UserMessage,
          ),
      };

      await _chat!.addQueryChunk(gemmaMessage);
    }

    // When _isThinking is true, flutter_gemma's ModelThinkingFilter handles
    // <think> separation and emits ThinkingResponse objects — pass through.
    // When false, manually strip <think> blocks (DeepSeek always emits them).
    if (_isThinking) {
      await for (final response in _chat!.generateChatResponseAsync()) {
        yield response;
      }
    } else {
      // Track whether we're inside a <think> block (reasoning tokens)
      var inThinkBlock = false;
      var buffer = '';

      await for (final response in _chat!.generateChatResponseAsync()) {
        if (response is gemma.FunctionCallResponse) {
          if (buffer.isNotEmpty && !inThinkBlock) {
            yield gemma.TextResponse(buffer);
            buffer = '';
          }
          yield response;
          continue;
        }

        if (response is gemma.TextResponse && response.token.isNotEmpty) {
          buffer += response.token;

          while (buffer.isNotEmpty) {
            if (inThinkBlock) {
              final endIdx = buffer.indexOf('</think>');
              if (endIdx != -1) {
                buffer = buffer.substring(endIdx + 8);
                inThinkBlock = false;
              } else {
                buffer = '';
                break;
              }
            } else {
              final startIdx = buffer.indexOf('<think>');
              if (startIdx != -1) {
                if (startIdx > 0) {
                  yield gemma.TextResponse(buffer.substring(0, startIdx));
                }
                buffer = buffer.substring(startIdx + 7);
                inThinkBlock = true;
              } else {
                if (buffer.length > 7 && buffer.contains('<')) {
                  final lastLt = buffer.lastIndexOf('<');
                  if (lastLt > buffer.length - 8) {
                    yield gemma.TextResponse(buffer.substring(0, lastLt));
                    buffer = buffer.substring(lastLt);
                    break;
                  }
                }
                yield gemma.TextResponse(buffer);
                buffer = '';
                break;
              }
            }
          }
        }
      }

      if (buffer.isNotEmpty && !inThinkBlock) {
        yield gemma.TextResponse(buffer);
      }
    }
  }

  Map<String, dynamic> _tryParseJson(String content) {
    try {
      final decoded = jsonDecode(content);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return {'result': content};
  }

  /// Generates a complete response without streaming.
  Future<String> generateResponseSync(List<Message> messages) async {
    if (_chat == null || _model == null) {
      throw StateError('Model is not loaded. Call loadModel() first.');
    }

    // Collect streaming text response into a single string
    final buffer = StringBuffer();
    await for (final response in generateResponse(messages)) {
      if (response is gemma.TextResponse) {
        buffer.write(response.token);
      }
    }
    return buffer.toString();
  }

  /// Stops the current generation.
  Future<void> stopGeneration() async {
    if (_chat != null) {
      await _chat!.stopGeneration();
    }
  }

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
  /// (e.g. desktop server not supporting vision models) without attempting
  /// a load that would crash the native process.
  void setError(String message) => _setError(message);

  void _setError(String message) {
    debugPrint('[GemmaRepo] ERROR: $message (status was $_status)');
    _status = GemmaModelStatus.error;
    _lastError = message;
    _statusController.add(GemmaModelStatus.error);
  }

  gemma.PreferredBackend _toGemmaBackend(GemmaBackend backend) {
    return switch (backend) {
      GemmaBackend.gpu => gemma.PreferredBackend.gpu,
      GemmaBackend.cpu => gemma.PreferredBackend.cpu,
    };
  }
}
