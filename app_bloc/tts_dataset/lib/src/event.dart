part of 'bloc.dart';

/// {@template tts_dataset_event}
/// Base class for all TtsDataset events.
/// {@endtemplate}
sealed class TtsDatasetEvent extends Equatable {
  /// {@macro tts_dataset_event}
  const TtsDatasetEvent();

  @override
  List<Object?> get props => [];
}

final class TtsDatasetLoadProjects extends TtsDatasetEvent {
  const TtsDatasetLoadProjects();
}

final class TtsDatasetCreateProject extends TtsDatasetEvent {
  const TtsDatasetCreateProject({
    required this.name,
    required this.language,
    required this.speakerDisplayName,
    required this.datasetLicense,
    required this.consentStatus,
    required this.rootPath,
    this.targetProfile = TtsDatasetTargetProfiles.qwen3Tts12HzRaw,
    this.defaultNoiseReductionMode = NoiseReductionMode.medium,
  });

  final String name;
  final String language;
  final String speakerDisplayName;
  final String datasetLicense;
  final String consentStatus;
  final String rootPath;
  final String targetProfile;
  final String defaultNoiseReductionMode;

  @override
  List<Object?> get props => [
    name,
    language,
    speakerDisplayName,
    datasetLicense,
    consentStatus,
    rootPath,
    targetProfile,
    defaultNoiseReductionMode,
  ];
}

final class TtsDatasetValidateProject extends TtsDatasetEvent {
  const TtsDatasetValidateProject({required this.projectId});

  final String projectId;

  @override
  List<Object?> get props => [projectId];
}

final class TtsDatasetExportProject extends TtsDatasetEvent {
  const TtsDatasetExportProject({
    required this.projectId,
    required this.outputPath,
  });

  final String projectId;
  final String outputPath;

  @override
  List<Object?> get props => [projectId, outputPath];
}
