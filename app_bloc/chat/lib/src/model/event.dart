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

/// Check if a model is installed.
final class GemmaModelCheckInstallation extends GemmaModelEvent {
  const GemmaModelCheckInstallation({required this.modelType});

  final GemmaModelType modelType;
}

/// Install a model from a network URL.
final class GemmaModelInstall extends GemmaModelEvent {
  const GemmaModelInstall({
    required this.nativeModelType,
    required this.url,
    this.modelId,
    this.token,
  });

  /// The flutter_gemma native model type.
  final NativeModelType nativeModelType;
  final String url;

  /// Catalog model ID for tracking which model is downloading.
  final String? modelId;
  final String? token;
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

/// Install a model from a bundled Flutter asset.
final class GemmaModelInstallFromAsset extends GemmaModelEvent {
  const GemmaModelInstallFromAsset({
    required this.modelId,
    required this.assetPath,
  });

  final String modelId;
  final String assetPath;
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

/// Delete the installed model.
final class GemmaModelDelete extends GemmaModelEvent {
  const GemmaModelDelete({required this.modelType});

  final GemmaModelType modelType;
}

/// Select a model, persist the selection, and activate + auto-load it.
final class GemmaModelSelect extends GemmaModelEvent {
  const GemmaModelSelect({required this.modelId});

  final String modelId;
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

/// Internal event for download progress updates.
final class _GemmaModelDownloadProgress extends GemmaModelEvent {
  const _GemmaModelDownloadProgress(this.progress);

  final DownloadProgress progress;
}

/// Internal event fired when a single model download completes.
final class _GemmaModelDownloadComplete extends GemmaModelEvent {
  const _GemmaModelDownloadComplete({
    required this.modelId,
    this.errorMessage,
  });

  final String modelId;

  /// Non-null when the download failed.
  final String? errorMessage;
}
