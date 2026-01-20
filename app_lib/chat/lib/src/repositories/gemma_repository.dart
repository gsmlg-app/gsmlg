import 'dart:async';

import 'package:flutter_gemma/flutter_gemma.dart' as gemma;

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
    return switch (modelType) {
      GemmaModelType.gemma2bIt => 'gemma-2b-it',
      GemmaModelType.gemma7bIt => 'gemma-7b-it',
      GemmaModelType.custom => 'custom-model',
    };
  }

  /// Checks if a model is installed.
  Future<bool> checkModelInstalled(GemmaModelType modelType) async {
    _setStatus(GemmaModelStatus.checking);

    try {
      final modelId = _getModelId(modelType);
      final isInstalled = await gemma.FlutterGemma.isModelInstalled(modelId);

      _setStatus(
          isInstalled ? GemmaModelStatus.installed : GemmaModelStatus.notInstalled);
      return isInstalled;
    } catch (e) {
      _setError('Failed to check model installation: $e');
      return false;
    }
  }

  /// Installs a model from the network.
  ///
  /// [url] - The URL to download the model from (e.g., Hugging Face).
  /// [token] - Optional authentication token for the download.
  Future<void> installModel({
    required GemmaModelType modelType,
    required String url,
    String? token,
  }) async {
    _setStatus(GemmaModelStatus.downloading);
    _progressController.add(const DownloadProgress(percentage: 0));

    try {
      var builder = gemma.FlutterGemma.installModel(
        modelType: _toGemmaModelType(modelType),
      ).fromNetwork(url, token: token);

      builder = builder.withProgress((progress) {
        _progressController.add(DownloadProgress(
          percentage: progress.toDouble(),
        ));
      });

      await builder.install();

      _setStatus(GemmaModelStatus.installed);
    } catch (e) {
      _setError('Failed to install model: $e');
    }
  }

  /// Installs a model from a local file path.
  Future<void> installModelFromFile({
    required GemmaModelType modelType,
    required String filePath,
  }) async {
    _setStatus(GemmaModelStatus.downloading);

    try {
      await gemma.FlutterGemma.installModel(
        modelType: _toGemmaModelType(modelType),
      ).fromFile(filePath).install();

      _setStatus(GemmaModelStatus.installed);
    } catch (e) {
      _setError('Failed to install model from file: $e');
    }
  }

  /// Loads the model into memory with the given configuration.
  Future<void> loadModel(ModelConfig config) async {
    // Unload existing model if any
    await unloadModel();

    _setStatus(GemmaModelStatus.loading);

    try {
      _model = await gemma.FlutterGemma.getActiveModel(
        maxTokens: config.maxTokens,
        preferredBackend: _toGemmaBackend(config.backend),
      );

      _chat = await _model!.createChat(
        temperature: config.temperature,
        topK: config.topK,
      );
      _setStatus(GemmaModelStatus.ready);
    } catch (e) {
      _setError('Failed to load model: $e');
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

  /// Generates a response for a list of messages.
  ///
  /// Returns a stream of tokens as they are generated.
  Stream<String> generateResponse(List<Message> messages) async* {
    if (_chat == null || _model == null) {
      throw StateError('Model is not loaded. Call loadModel() first.');
    }

    // Clear existing chat history
    await _chat!.clearHistory();

    // Add all messages to the chat
    for (final message in messages) {
      await _chat!.addQueryChunk(
        gemma.Message.text(
          text: message.content,
          isUser: message is UserMessage,
        ),
      );
    }

    // Generate response with streaming
    await for (final response in _chat!.generateChatResponseAsync()) {
      if (response is gemma.TextResponse && response.token.isNotEmpty) {
        yield response.token;
      }
    }
  }

  /// Generates a complete response without streaming.
  Future<String> generateResponseSync(List<Message> messages) async {
    if (_chat == null || _model == null) {
      throw StateError('Model is not loaded. Call loadModel() first.');
    }

    // Clear existing chat history
    await _chat!.clearHistory();

    // Add all messages to the chat
    for (final message in messages) {
      await _chat!.addQueryChunk(
        gemma.Message.text(
          text: message.content,
          isUser: message is UserMessage,
        ),
      );
    }

    // Generate response - collect all tokens
    final buffer = StringBuffer();
    await for (final response in _chat!.generateChatResponseAsync()) {
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
    _status = newStatus;
    _lastError = null;
    _statusController.add(newStatus);
  }

  void _setError(String message) {
    _status = GemmaModelStatus.error;
    _lastError = message;
    _statusController.add(GemmaModelStatus.error);
  }

  gemma.ModelType _toGemmaModelType(GemmaModelType type) {
    return switch (type) {
      GemmaModelType.gemma2bIt => gemma.ModelType.gemmaIt,
      GemmaModelType.gemma7bIt => gemma.ModelType.gemmaIt,
      GemmaModelType.custom => gemma.ModelType.general,
    };
  }

  gemma.PreferredBackend _toGemmaBackend(GemmaBackend backend) {
    return switch (backend) {
      GemmaBackend.gpu => gemma.PreferredBackend.gpu,
      GemmaBackend.cpu => gemma.PreferredBackend.cpu,
    };
  }
}
