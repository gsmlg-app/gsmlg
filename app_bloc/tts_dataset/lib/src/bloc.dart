import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:tts_dataset/tts_dataset.dart';

part 'event.dart';
part 'state.dart';

/// {@template tts_dataset_bloc}
/// TtsDatasetBLoC handles Tts dataset related business logic.
/// {@endtemplate}
class TtsDatasetBloc extends Bloc<TtsDatasetEvent, TtsDatasetState> {
  /// {@macro tts_dataset_bloc}
  TtsDatasetBloc({
    required TtsDatasetRepository repository,
    TtsDatasetValidationService validationService =
        const TtsDatasetValidationService(),
    Qwen3TtsRawZipExporter? exporter,
  }) : _repository = repository,
       _validationService = validationService,
       _exporter = exporter ?? Qwen3TtsRawZipExporter(repository),
       super(TtsDatasetState.initial()) {
    on<TtsDatasetLoadProjects>(_onLoadProjects);
    on<TtsDatasetCreateProject>(_onCreateProject);
    on<TtsDatasetValidateProject>(_onValidateProject);
    on<TtsDatasetExportProject>(_onExportProject);
  }

  final TtsDatasetRepository _repository;
  final TtsDatasetValidationService _validationService;
  final Qwen3TtsRawZipExporter _exporter;

  Future<void> _onLoadProjects(
    TtsDatasetLoadProjects event,
    Emitter<TtsDatasetState> emit,
  ) async {
    try {
      emit(state.copyWith(status: TtsDatasetStatus.loading));
      final projects = await _repository.listProjects();
      emit(state.copyWith(status: TtsDatasetStatus.loaded, projects: projects));
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: TtsDatasetStatus.error,
          errorMessage: error.toString(),
        ),
      );
      addError(error, stackTrace);
    }
  }

  Future<void> _onCreateProject(
    TtsDatasetCreateProject event,
    Emitter<TtsDatasetState> emit,
  ) async {
    try {
      emit(state.copyWith(status: TtsDatasetStatus.loading));
      final detail = await _repository.createProject(
        name: event.name,
        targetProfile: event.targetProfile,
        language: event.language,
        speakerDisplayName: event.speakerDisplayName,
        datasetLicense: event.datasetLicense,
        consentStatus: event.consentStatus,
        rootPath: event.rootPath,
        defaultNoiseReductionMode: event.defaultNoiseReductionMode,
        starterPrompts: englishStarterPrompts,
      );
      final projects = await _repository.listProjects();
      emit(
        state.copyWith(
          status: TtsDatasetStatus.loaded,
          projects: projects,
          selectedProject: detail,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: TtsDatasetStatus.error,
          errorMessage: error.toString(),
        ),
      );
      addError(error, stackTrace);
    }
  }

  Future<void> _onValidateProject(
    TtsDatasetValidateProject event,
    Emitter<TtsDatasetState> emit,
  ) async {
    try {
      emit(state.copyWith(status: TtsDatasetStatus.loading));
      final detail = await _repository.loadProject(event.projectId);
      if (detail == null) {
        throw StateError('TTS dataset project not found: ${event.projectId}');
      }
      final result = _validationService.validate(
        detail,
        fileExists: (rootPath, relativePath) =>
            File(p.join(rootPath, relativePath)).existsSync(),
      );
      await _repository.saveValidationIssues(event.projectId, result.issues);
      emit(
        state.copyWith(
          status: TtsDatasetStatus.loaded,
          selectedProject: await _repository.loadProject(event.projectId),
          validationResult: result,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: TtsDatasetStatus.error,
          errorMessage: error.toString(),
        ),
      );
      addError(error, stackTrace);
    }
  }

  Future<void> _onExportProject(
    TtsDatasetExportProject event,
    Emitter<TtsDatasetState> emit,
  ) async {
    try {
      emit(state.copyWith(status: TtsDatasetStatus.loading));
      final result = await _exporter.export(
        DatasetExportRequest(
          projectId: event.projectId,
          outputPath: event.outputPath,
        ),
      );
      emit(
        state.copyWith(status: TtsDatasetStatus.exported, exportResult: result),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: TtsDatasetStatus.error,
          errorMessage: error.toString(),
        ),
      );
      addError(error, stackTrace);
    }
  }
}
