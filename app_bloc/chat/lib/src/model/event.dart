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
    required this.modelType,
    required this.url,
    this.token,
  });

  final GemmaModelType modelType;
  final String url;
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

/// Delete the installed model.
final class GemmaModelDelete extends GemmaModelEvent {
  const GemmaModelDelete({required this.modelType});

  final GemmaModelType modelType;
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
