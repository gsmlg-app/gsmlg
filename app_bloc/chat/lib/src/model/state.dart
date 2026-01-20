part of 'bloc.dart';

/// State for the GemmaModelBloc.
class GemmaModelState extends Equatable {
  const GemmaModelState({
    this.status = GemmaModelStatus.initial,
    this.modelType = GemmaModelType.gemma2bIt,
    this.downloadProgress = 0,
    this.errorMessage,
  });

  /// Current status of the model.
  final GemmaModelStatus status;

  /// The currently selected model type.
  final GemmaModelType modelType;

  /// Download progress percentage (0-100).
  final double downloadProgress;

  /// Error message if status is error.
  final String? errorMessage;

  @override
  List<Object?> get props => [status, modelType, downloadProgress, errorMessage];

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

  GemmaModelState copyWith({
    GemmaModelStatus? status,
    GemmaModelType? modelType,
    double? downloadProgress,
    String? errorMessage,
  }) {
    return GemmaModelState(
      status: status ?? this.status,
      modelType: modelType ?? this.modelType,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      errorMessage: errorMessage,
    );
  }
}
