import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
    on<TtsDatasetOpenProject>(_onOpenProject);
    on<TtsDatasetSelectPrompt>(_onSelectPrompt);
    on<TtsDatasetSavePromptRecording>(_onSavePromptRecording);
    on<TtsDatasetClearPromptRecording>(_onClearPromptRecording);
    on<TtsDatasetDeleteProject>(_onDeleteProject);
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
        starterPrompts: starterPromptsForLanguage(event.language),
      );
      final projects = await _repository.listProjects();
      emit(
        state.copyWith(
          status: TtsDatasetStatus.loaded,
          projects: projects,
          selectedProject: detail,
          selectedPromptId: _firstPromptId(detail),
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

  Future<void> _onOpenProject(
    TtsDatasetOpenProject event,
    Emitter<TtsDatasetState> emit,
  ) async {
    try {
      emit(state.copyWith(status: TtsDatasetStatus.loading));
      final detail = await _repository.loadProject(event.projectId);
      if (detail == null) {
        throw StateError('TTS dataset project not found: ${event.projectId}');
      }
      final projects = await _repository.listProjects();
      emit(
        state.copyWith(
          status: TtsDatasetStatus.loaded,
          projects: projects,
          selectedProject: detail,
          selectedPromptId: _firstPromptId(detail),
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

  void _onSelectPrompt(
    TtsDatasetSelectPrompt event,
    Emitter<TtsDatasetState> emit,
  ) {
    emit(state.copyWith(selectedPromptId: event.promptId));
  }

  Future<void> _onSavePromptRecording(
    TtsDatasetSavePromptRecording event,
    Emitter<TtsDatasetState> emit,
  ) async {
    try {
      emit(state.copyWith(status: TtsDatasetStatus.loading));
      final detail = await _repository.loadProject(event.projectId);
      if (detail == null) {
        throw StateError('TTS dataset project not found: ${event.projectId}');
      }
      final prompt = _promptById(detail, event.promptId);
      final recording = File(event.recordingPath);
      if (!recording.existsSync()) {
        throw StateError('Recording file not found: ${event.recordingPath}');
      }

      final rawDirectory = Directory(p.join(detail.project.rootPath, 'raw'));
      final wavDirectory = Directory(p.join(detail.project.rootPath, 'wavs'));
      await rawDirectory.create(recursive: true);
      await wavDirectory.create(recursive: true);

      final stem = _recordingStem(prompt);
      final rawPath = p.join('raw', '${stem}_original.wav');
      final processedPath = p.join('wavs', '$stem.wav');
      await recording.copy(p.join(detail.project.rootPath, rawPath));
      await recording.copy(p.join(detail.project.rootPath, processedPath));

      final clip = await _repository.addManualClip(
        projectId: detail.project.id,
        speakerId: detail.speaker.id,
        promptId: prompt.id,
        rawPath: rawPath,
        processedPath: processedPath,
        exportWavPath: processedPath,
        rawText: prompt.rawText,
        normalizedText: prompt.normalizedText,
        language: prompt.language,
        durationMs: event.durationMs,
        sampleRate: 24000,
        channels: 1,
        bitDepth: 16,
        noiseReductionMode: NoiseReductionMode.medium,
        status: ClipStatus.accepted,
      );
      await _repository.updatePromptStatus(prompt.id, PromptStatus.recorded);
      if (detail.speaker.referenceClipId == null) {
        await _repository.selectReferenceClip(detail.project.id, clip.id);
      }

      final projects = await _repository.listProjects();
      final updatedDetail = await _repository.loadProject(event.projectId);
      emit(
        state.copyWith(
          status: TtsDatasetStatus.loaded,
          projects: projects,
          selectedProject: updatedDetail,
          selectedPromptId: prompt.id,
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

  Future<void> _onClearPromptRecording(
    TtsDatasetClearPromptRecording event,
    Emitter<TtsDatasetState> emit,
  ) async {
    try {
      emit(state.copyWith(status: TtsDatasetStatus.loading));
      final detail = await _repository.loadProject(event.projectId);
      if (detail == null) {
        throw StateError('TTS dataset project not found: ${event.projectId}');
      }
      _promptById(detail, event.promptId);

      final deletedClips = await _repository.clearPromptClips(
        projectId: event.projectId,
        promptId: event.promptId,
      );
      for (final clip in deletedClips) {
        await _deleteClipFiles(detail.project.rootPath, clip);
      }

      if (_didDeleteReferenceClip(detail, deletedClips)) {
        final updatedDetail = await _repository.loadProject(event.projectId);
        await _repository.selectReferenceClip(
          event.projectId,
          _firstAcceptedClipId(updatedDetail),
        );
      }

      final projects = await _repository.listProjects();
      final updatedDetail = await _repository.loadProject(event.projectId);
      emit(
        state.copyWith(
          status: TtsDatasetStatus.loaded,
          projects: projects,
          selectedProject: updatedDetail,
          selectedPromptId: event.promptId,
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

  Future<void> _onDeleteProject(
    TtsDatasetDeleteProject event,
    Emitter<TtsDatasetState> emit,
  ) async {
    try {
      emit(state.copyWith(status: TtsDatasetStatus.loading));
      final deletedDetail = await _repository.deleteProject(event.projectId);
      if (deletedDetail != null) {
        await _deleteProjectFiles(deletedDetail);
      }

      final projects = await _repository.listProjects();
      final removedSelectedProject =
          state.selectedProject?.project.id == event.projectId;
      emit(
        state.copyWith(
          status: TtsDatasetStatus.loaded,
          projects: projects,
          selectedProject: removedSelectedProject
              ? null
              : state.selectedProject,
          selectedPromptId: removedSelectedProject
              ? null
              : state.selectedPromptId,
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
          selectedPromptId: state.selectedPromptId,
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

  String? _firstPromptId(TtsDatasetProjectDetail detail) {
    if (detail.prompts.isEmpty) return null;
    return detail.prompts.first.id;
  }

  TrainingTextItem _promptById(
    TtsDatasetProjectDetail detail,
    String promptId,
  ) {
    for (final prompt in detail.prompts) {
      if (prompt.id == promptId) return prompt;
    }
    throw StateError('TTS dataset prompt not found: $promptId');
  }

  String _recordingStem(TrainingTextItem prompt) {
    final order = (prompt.sortOrder + 1).toString().padLeft(6, '0');
    return 'utt$order-${DateTime.now().microsecondsSinceEpoch}';
  }

  Future<void> _deleteClipFiles(String rootPath, AudioClip clip) async {
    final relativePaths = <String>{
      clip.rawPath,
      clip.processedPath,
      clip.exportWavPath,
    };
    for (final relativePath in relativePaths) {
      final file = File(p.join(rootPath, relativePath));
      if (file.existsSync()) {
        await file.delete();
      }
    }
  }

  Future<void> _deleteProjectFiles(TtsDatasetProjectDetail detail) async {
    for (final clip in detail.clips) {
      await _deleteClipFiles(detail.project.rootPath, clip);
    }

    final projectRoot = Directory(detail.project.rootPath);
    if (_isManagedProjectRoot(projectRoot) && projectRoot.existsSync()) {
      await projectRoot.delete(recursive: true);
    }
  }

  bool _isManagedProjectRoot(Directory projectRoot) {
    final managedParent = p.normalize(
      p.join(Directory.systemTemp.path, 'gsmlg_tts_datasets'),
    );
    final normalizedRoot = p.normalize(projectRoot.absolute.path);
    return p.isWithin(managedParent, normalizedRoot);
  }

  bool _didDeleteReferenceClip(
    TtsDatasetProjectDetail detail,
    List<AudioClip> deletedClips,
  ) {
    final referenceClipId = detail.speaker.referenceClipId;
    if (referenceClipId == null) return false;
    return deletedClips.any((clip) => clip.id == referenceClipId);
  }

  String? _firstAcceptedClipId(TtsDatasetProjectDetail? detail) {
    if (detail == null) return null;
    for (final clip in detail.clips) {
      if (clip.status == ClipStatus.accepted) return clip.id;
    }
    return null;
  }
}
