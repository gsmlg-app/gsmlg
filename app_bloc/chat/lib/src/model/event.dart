part of 'bloc.dart';

/// Events for the GemmaModelBloc.
sealed class GemmaModelEvent {
  const GemmaModelEvent();
}

/// Initialize the model manager and check installation status.
final class GemmaModelInitialize extends GemmaModelEvent {
  const GemmaModelInitialize({this.modelType = GemmaModelType.gemma2bIt});

  final GemmaModelType modelType;
}

/// Install a model from a network URL.
final class GemmaModelInstall extends GemmaModelEvent {
  const GemmaModelInstall({
    required this.url,
    this.modelId,
    this.token,
  });

  final String url;

  /// Catalog model ID for tracking which model is downloading.
  final String? modelId;
  final String? token;
}

/// Import a model file that the user already downloaded.
final class GemmaModelImportFromFile extends GemmaModelEvent {
  const GemmaModelImportFromFile({
    required this.modelId,
    required this.filePath,
  });

  final String modelId;
  final String filePath;
}

/// Pause an active model download and keep the partial file for resume.
final class GemmaModelPauseDownload extends GemmaModelEvent {
  const GemmaModelPauseDownload({
    required this.url,
    required this.modelId,
  });

  final String url;
  final String modelId;
}

/// Cancel an active or paused model download and delete the partial file.
final class GemmaModelCancelDownload extends GemmaModelEvent {
  const GemmaModelCancelDownload({
    required this.url,
    required this.modelId,
  });

  final String url;
  final String modelId;
}

/// Load the model into memory with configuration.
final class GemmaModelLoad extends GemmaModelEvent {
  const GemmaModelLoad({required this.config});

  final ModelConfig config;
}

/// Unload the model from memory.
final class GemmaModelUnload extends GemmaModelEvent {
  const GemmaModelUnload();
}

/// Refresh the list of installed models.
final class GemmaModelListInstalled extends GemmaModelEvent {
  const GemmaModelListInstalled();
}

/// Set or clear the proxy URL for model downloads.
final class GemmaModelSetProxy extends GemmaModelEvent {
  const GemmaModelSetProxy({this.proxyUrl});

  /// Proxy URL (null to clear).
  final String? proxyUrl;
}

/// Select a model, persist the selection, and activate + auto-load it.
final class GemmaModelSelect extends GemmaModelEvent {
  const GemmaModelSelect({required this.modelId, this.config});

  final String modelId;
  final ModelConfig? config;
}

/// Deselect the current model without deleting it.
final class GemmaModelDeselect extends GemmaModelEvent {
  const GemmaModelDeselect();
}

/// Delete a model by its installed ID string.
final class GemmaModelDeleteById extends GemmaModelEvent {
  const GemmaModelDeleteById({required this.modelId});

  final String modelId;
}

/// Dismiss a failed download from the failed list.
final class GemmaModelDismissFailure extends GemmaModelEvent {
  const GemmaModelDismissFailure({required this.modelId});

  final String modelId;
}

/// Internal event for status changes from the repository.
final class _GemmaModelStatusChanged extends GemmaModelEvent {
  const _GemmaModelStatusChanged(this.status);

  final GemmaModelStatus status;
}

/// Internal event for download progress updates (legacy shared stream).
final class _GemmaModelDownloadProgress extends GemmaModelEvent {
  const _GemmaModelDownloadProgress(this.progress);

  final DownloadProgress progress;
}

/// Internal event for per-model download progress.
final class _GemmaModelPerModelProgress extends GemmaModelEvent {
  const _GemmaModelPerModelProgress({
    required this.modelId,
    required this.progress,
  });

  final String modelId;
  final DownloadProgress progress;
}

/// Internal event fired when a single model download completes.
final class _GemmaModelDownloadComplete extends GemmaModelEvent {
  const _GemmaModelDownloadComplete({
    required this.modelId,
    this.result = _ModelDownloadResult.completed,
    this.errorMessage,
  });

  final String modelId;
  final _ModelDownloadResult result;

  /// Non-null when the download failed.
  final String? errorMessage;
}

enum _ModelDownloadResult { completed, failed, paused, canceled }
