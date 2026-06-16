part of 'bloc.dart';

enum TtsDatasetStatus { initial, loading, loaded, exported, error }

const _unset = Object();

class TtsDatasetState extends Equatable {
  const TtsDatasetState({
    this.status = TtsDatasetStatus.initial,
    this.projects = const [],
    this.selectedProject,
    this.selectedPromptId,
    this.validationResult,
    this.exportResult,
    this.errorMessage,
  });

  final TtsDatasetStatus status;
  final List<TtsDatasetProject> projects;
  final TtsDatasetProjectDetail? selectedProject;
  final String? selectedPromptId;
  final ValidationResult? validationResult;
  final DatasetExportResult? exportResult;
  final String? errorMessage;

  factory TtsDatasetState.initial() {
    return const TtsDatasetState();
  }

  TtsDatasetState copyWith({
    TtsDatasetStatus? status,
    List<TtsDatasetProject>? projects,
    Object? selectedProject = _unset,
    Object? selectedPromptId = _unset,
    ValidationResult? validationResult,
    DatasetExportResult? exportResult,
    String? errorMessage,
  }) {
    return TtsDatasetState(
      status: status ?? this.status,
      projects: projects ?? this.projects,
      selectedProject: identical(selectedProject, _unset)
          ? this.selectedProject
          : selectedProject as TtsDatasetProjectDetail?,
      selectedPromptId: identical(selectedPromptId, _unset)
          ? this.selectedPromptId
          : selectedPromptId as String?,
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
    selectedPromptId,
    validationResult,
    exportResult,
    errorMessage,
  ];
}
