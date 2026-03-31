part of 'bloc.dart';

/// Progress info for a single model download.
class ModelDownloadProgress extends Equatable {
  const ModelDownloadProgress({
    required this.modelId,
    this.progress = 0,
  });

  final String modelId;

  /// Download progress percentage (0-100).
  final double progress;

  @override
  List<Object?> get props => [modelId, progress];
}

/// State for the GemmaModelBloc.
class GemmaModelState extends Equatable {
  const GemmaModelState({
    this.status = GemmaModelStatus.initial,
    this.modelType = GemmaModelType.gemma2bIt,
    this.errorMessage,
    this.installedModels = const [],
    this.proxyUrl,
    this.selectedModelId,
    this.activeDownloads = const [],
  });

  /// Current status of the model.
  final GemmaModelStatus status;

  /// The currently selected model type.
  final GemmaModelType modelType;

  /// Error message if status is error.
  final String? errorMessage;

  /// List of installed model IDs.
  final List<String> installedModels;

  /// Proxy URL for model downloads (null = no proxy).
  final String? proxyUrl;

  /// The user-selected model ID, persisted in SharedPreferences.
  final String? selectedModelId;

  /// Currently active downloads (max 3 concurrent).
  final List<ModelDownloadProgress> activeDownloads;

  @override
  List<Object?> get props => [
        status,
        modelType,
        errorMessage,
        installedModels,
        proxyUrl,
        selectedModelId,
        activeDownloads,
      ];

  /// Whether the model is ready for inference.
  bool get isReady => status == GemmaModelStatus.ready;

  /// Whether the model is installed.
  bool get isInstalled =>
      status == GemmaModelStatus.installed || status == GemmaModelStatus.ready;

  /// Whether the model is currently loading.
  bool get isLoading =>
      status == GemmaModelStatus.loading ||
      status == GemmaModelStatus.downloading ||
      status == GemmaModelStatus.checking;

  /// Whether there is an error.
  bool get hasError => status == GemmaModelStatus.error;

  /// Whether any download is currently active.
  bool get isDownloading => activeDownloads.isNotEmpty;

  /// The first downloading model ID (for backward-compat banner display).
  String? get downloadingModelId =>
      activeDownloads.isNotEmpty ? activeDownloads.first.modelId : null;

  /// The first download's progress (for backward-compat banner display).
  double get downloadProgress =>
      activeDownloads.isNotEmpty ? activeDownloads.first.progress : 0;

  /// Check if a specific model is currently downloading.
  bool isModelDownloading(String modelId) =>
      activeDownloads.any((d) => d.modelId == modelId);

  /// Get download progress for a specific model.
  double? downloadProgressFor(String modelId) {
    final match = activeDownloads.where((d) => d.modelId == modelId);
    return match.isNotEmpty ? match.first.progress : null;
  }

  GemmaModelState copyWith({
    GemmaModelStatus? status,
    GemmaModelType? modelType,
    String? errorMessage,
    List<String>? installedModels,
    String? proxyUrl,
    bool clearProxy = false,
    String? selectedModelId,
    bool clearSelectedModel = false,
    List<ModelDownloadProgress>? activeDownloads,
  }) {
    return GemmaModelState(
      status: status ?? this.status,
      modelType: modelType ?? this.modelType,
      errorMessage: errorMessage,
      installedModels: installedModels ?? this.installedModels,
      proxyUrl: clearProxy ? null : (proxyUrl ?? this.proxyUrl),
      selectedModelId:
          clearSelectedModel ? null : (selectedModelId ?? this.selectedModelId),
      activeDownloads: activeDownloads ?? this.activeDownloads,
    );
  }
}
