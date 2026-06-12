part of 'bloc.dart';

enum TtsDatasetStatus { initial, loading, loaded, exported, error }

class TtsDatasetState extends Equatable {
  const TtsDatasetState({
    this.status = TtsDatasetStatus.initial,
    this.projects = const [],
    this.selectedProject,
    this.validationResult,
    this.exportResult,
    this.errorMessage,
  });

  final TtsDatasetStatus status;
  final List<TtsDatasetProject> projects;
  final TtsDatasetProjectDetail? selectedProject;
  final ValidationResult? validationResult;
  final DatasetExportResult? exportResult;
  final String? errorMessage;

  factory TtsDatasetState.initial() {
    return const TtsDatasetState();
  }

  TtsDatasetState copyWith({
    TtsDatasetStatus? status,
    List<TtsDatasetProject>? projects,
    TtsDatasetProjectDetail? selectedProject,
    ValidationResult? validationResult,
    DatasetExportResult? exportResult,
    String? errorMessage,
  }) {
    return TtsDatasetState(
      status: status ?? this.status,
      projects: projects ?? this.projects,
      selectedProject: selectedProject ?? this.selectedProject,
      validationResult: validationResult ?? this.validationResult,
      exportResult: exportResult ?? this.exportResult,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    projects,
    selectedProject,
    validationResult,
    exportResult,
    errorMessage,
  ];
}
