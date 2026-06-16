import 'dart:io';

import 'package:app_database/app_database.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:tts_dataset/tts_dataset.dart';
import 'package:tts_dataset_bloc/tts_dataset_bloc.dart';

void main() {
  group('TtsDatasetBloc', () {
    late AppDatabase database;
    late TtsDatasetRepository repository;

    setUp(() {
      database = AppDatabase.forTesting();
      repository = TtsDatasetRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('initial state is correct', () {
      final bloc = TtsDatasetBloc(repository: repository);
      addTearDown(bloc.close);

      expect(bloc.state.status, TtsDatasetStatus.initial);
      expect(bloc.state.projects, isEmpty);
    });

    blocTest<TtsDatasetBloc, TtsDatasetState>(
      'loads existing projects',
      build: () => TtsDatasetBloc(repository: repository),
      act: (bloc) async {
        await repository.createProject(
          name: 'My voice',
          targetProfile: TtsDatasetTargetProfiles.qwen3Tts12HzRaw,
          language: 'English',
          speakerDisplayName: 'Example Speaker',
          datasetLicense: 'private',
          consentStatus: ConsentStatus.granted,
          rootPath: '/tmp/my_voice',
          defaultNoiseReductionMode: NoiseReductionMode.medium,
        );
        bloc.add(const TtsDatasetLoadProjects());
      },
      expect: () => [
        isA<TtsDatasetState>().having(
          (state) => state.status,
          'status',
          TtsDatasetStatus.loading,
        ),
        isA<TtsDatasetState>()
            .having((state) => state.status, 'status', TtsDatasetStatus.loaded)
            .having((state) => state.projects, 'projects', hasLength(1)),
      ],
    );

    blocTest<TtsDatasetBloc, TtsDatasetState>(
      'creates a project and reloads project list',
      build: () => TtsDatasetBloc(repository: repository),
      act: (bloc) => bloc.add(
        const TtsDatasetCreateProject(
          name: 'My voice',
          language: 'English',
          speakerDisplayName: 'Example Speaker',
          datasetLicense: 'private',
          consentStatus: ConsentStatus.granted,
          rootPath: '/tmp/my_voice',
        ),
      ),
      expect: () => [
        isA<TtsDatasetState>().having(
          (state) => state.status,
          'status',
          TtsDatasetStatus.loading,
        ),
        isA<TtsDatasetState>()
            .having((state) => state.status, 'status', TtsDatasetStatus.loaded)
            .having((state) => state.projects, 'projects', hasLength(1))
            .having(
              (state) => state.selectedProject?.prompts.length,
              'starter prompts',
              englishStarterPrompts.length,
            ),
      ],
    );

    blocTest<TtsDatasetBloc, TtsDatasetState>(
      'creates a Chinese project with Chinese preset training text',
      build: () => TtsDatasetBloc(repository: repository),
      act: (bloc) => bloc.add(
        const TtsDatasetCreateProject(
          name: 'Chinese voice',
          language: 'Chinese',
          speakerDisplayName: 'Example Speaker',
          datasetLicense: 'private',
          consentStatus: ConsentStatus.granted,
          rootPath: '/tmp/chinese_voice',
        ),
      ),
      expect: () => [
        isA<TtsDatasetState>().having(
          (state) => state.status,
          'status',
          TtsDatasetStatus.loading,
        ),
        isA<TtsDatasetState>()
            .having((state) => state.status, 'status', TtsDatasetStatus.loaded)
            .having(
              (state) => state.selectedProject?.prompts.length,
              'starter prompts',
              chineseStarterPrompts.length,
            )
            .having(
              (state) => state.selectedProject?.prompts.first.rawText,
              'first Chinese prompt',
              chineseStarterPrompts.first,
            ),
      ],
    );

    blocTest<TtsDatasetBloc, TtsDatasetState>(
      'opens a project and selects the first training text',
      build: () => TtsDatasetBloc(repository: repository),
      act: (bloc) async {
        final detail = await repository.createProject(
          name: 'My voice',
          targetProfile: TtsDatasetTargetProfiles.qwen3Tts12HzRaw,
          language: 'English',
          speakerDisplayName: 'Example Speaker',
          datasetLicense: 'private',
          consentStatus: ConsentStatus.granted,
          rootPath: '/tmp/my_voice',
          defaultNoiseReductionMode: NoiseReductionMode.medium,
          starterPrompts: englishStarterPrompts,
        );

        bloc.add(TtsDatasetOpenProject(projectId: detail.project.id));
      },
      expect: () => [
        isA<TtsDatasetState>().having(
          (state) => state.status,
          'status',
          TtsDatasetStatus.loading,
        ),
        isA<TtsDatasetState>()
            .having((state) => state.status, 'status', TtsDatasetStatus.loaded)
            .having(
              (state) => state.selectedProject?.project.name,
              'project name',
              'My voice',
            )
            .having(
              (state) => state.selectedPromptId,
              'selected prompt',
              isNotNull,
            ),
      ],
    );

    blocTest<TtsDatasetBloc, TtsDatasetState>(
      'saves a prompt recording as an accepted training clip',
      build: () => TtsDatasetBloc(repository: repository),
      act: (bloc) async {
        final tempDir = await Directory.systemTemp.createTemp(
          'tts_recording_bloc_test_',
        );
        addTearDown(() => tempDir.delete(recursive: true));
        final recording = File(p.join(tempDir.path, 'recording.wav'));
        await recording.writeAsBytes(_tinyWavBytes);

        final detail = await repository.createProject(
          name: 'My voice',
          targetProfile: TtsDatasetTargetProfiles.qwen3Tts12HzRaw,
          language: 'English',
          speakerDisplayName: 'Example Speaker',
          datasetLicense: 'private',
          consentStatus: ConsentStatus.granted,
          rootPath: p.join(tempDir.path, 'project'),
          defaultNoiseReductionMode: NoiseReductionMode.medium,
          starterPrompts: englishStarterPrompts,
        );
        final promptId = detail.prompts.first.id;

        bloc.add(
          TtsDatasetSavePromptRecording(
            projectId: detail.project.id,
            promptId: promptId,
            recordingPath: recording.path,
            durationMs: 1200,
          ),
        );
      },
      expect: () => [
        isA<TtsDatasetState>().having(
          (state) => state.status,
          'status',
          TtsDatasetStatus.loading,
        ),
        isA<TtsDatasetState>()
            .having((state) => state.status, 'status', TtsDatasetStatus.loaded)
            .having(
              (state) => state.selectedProject?.clips,
              'clips',
              hasLength(1),
            )
            .having(
              (state) => state.selectedProject?.clips.single.status,
              'clip status',
              ClipStatus.accepted,
            )
            .having(
              (state) => state.selectedProject?.prompts.first.status,
              'prompt status',
              PromptStatus.recorded,
            ),
      ],
      wait: const Duration(milliseconds: 100),
    );

    late File clearedRawFile;
    late File clearedWavFile;
    blocTest<TtsDatasetBloc, TtsDatasetState>(
      'clears a prompt recording and resets the prompt status',
      build: () => TtsDatasetBloc(repository: repository),
      act: (bloc) async {
        final tempDir = await Directory.systemTemp.createTemp(
          'tts_clear_recording_bloc_test_',
        );
        addTearDown(() => tempDir.delete(recursive: true));
        final projectRoot = Directory(p.join(tempDir.path, 'project'));
        await Directory(
          p.join(projectRoot.path, 'raw'),
        ).create(recursive: true);
        await Directory(
          p.join(projectRoot.path, 'wavs'),
        ).create(recursive: true);

        final detail = await repository.createProject(
          name: 'My voice',
          targetProfile: TtsDatasetTargetProfiles.qwen3Tts12HzRaw,
          language: 'English',
          speakerDisplayName: 'Example Speaker',
          datasetLicense: 'private',
          consentStatus: ConsentStatus.granted,
          rootPath: projectRoot.path,
          defaultNoiseReductionMode: NoiseReductionMode.medium,
          starterPrompts: englishStarterPrompts,
        );
        final prompt = detail.prompts.first;
        clearedRawFile = File(
          p.join(projectRoot.path, 'raw', 'utt000001_original.wav'),
        );
        clearedWavFile = File(
          p.join(projectRoot.path, 'wavs', 'utt000001.wav'),
        );
        await clearedRawFile.writeAsBytes(_tinyWavBytes);
        await clearedWavFile.writeAsBytes(_tinyWavBytes);
        final clip = await repository.addManualClip(
          projectId: detail.project.id,
          speakerId: detail.speaker.id,
          promptId: prompt.id,
          rawPath: 'raw/utt000001_original.wav',
          processedPath: 'wavs/utt000001.wav',
          exportWavPath: 'wavs/utt000001.wav',
          rawText: prompt.rawText,
          normalizedText: prompt.normalizedText,
          language: prompt.language,
          durationMs: 1200,
          sampleRate: 24000,
          channels: 1,
          bitDepth: 16,
          noiseReductionMode: NoiseReductionMode.medium,
          status: ClipStatus.accepted,
        );
        await repository.updatePromptStatus(prompt.id, PromptStatus.recorded);
        await repository.selectReferenceClip(detail.project.id, clip.id);

        bloc.add(
          TtsDatasetClearPromptRecording(
            projectId: detail.project.id,
            promptId: prompt.id,
          ),
        );
      },
      expect: () => [
        isA<TtsDatasetState>().having(
          (state) => state.status,
          'status',
          TtsDatasetStatus.loading,
        ),
        isA<TtsDatasetState>()
            .having((state) => state.status, 'status', TtsDatasetStatus.loaded)
            .having((state) => state.selectedProject?.clips, 'clips', isEmpty)
            .having(
              (state) => state.selectedProject?.prompts.first.status,
              'prompt status',
              PromptStatus.newPrompt,
            )
            .having(
              (state) => state.selectedProject?.speaker.referenceClipId,
              'reference clip',
              isNull,
            ),
      ],
      verify: (_) async {
        final detail = await repository.listProjects();
        expect(detail, hasLength(1));
        expect(clearedRawFile.existsSync(), isFalse);
        expect(clearedWavFile.existsSync(), isFalse);
      },
      wait: const Duration(milliseconds: 100),
    );

    late File deletedWavFile;
    blocTest<TtsDatasetBloc, TtsDatasetState>(
      'deletes a project, clears selection, and removes project files',
      build: () => TtsDatasetBloc(repository: repository),
      act: (bloc) async {
        final tempDir = await Directory.systemTemp.createTemp(
          'tts_delete_project_bloc_test_',
        );
        addTearDown(() async {
          if (tempDir.existsSync()) {
            await tempDir.delete(recursive: true);
          }
        });
        final projectRoot = Directory(p.join(tempDir.path, 'project'));
        await Directory(
          p.join(projectRoot.path, 'wavs'),
        ).create(recursive: true);
        deletedWavFile = File(
          p.join(projectRoot.path, 'wavs', 'utt000001.wav'),
        );
        await deletedWavFile.writeAsBytes(_tinyWavBytes);
        final detail = await repository.createProject(
          name: 'My voice',
          targetProfile: TtsDatasetTargetProfiles.qwen3Tts12HzRaw,
          language: 'English',
          speakerDisplayName: 'Example Speaker',
          datasetLicense: 'private',
          consentStatus: ConsentStatus.granted,
          rootPath: projectRoot.path,
          defaultNoiseReductionMode: NoiseReductionMode.medium,
          starterPrompts: englishStarterPrompts,
        );
        await repository.addManualClip(
          projectId: detail.project.id,
          speakerId: detail.speaker.id,
          promptId: detail.prompts.first.id,
          rawPath: 'wavs/utt000001.wav',
          processedPath: 'wavs/utt000001.wav',
          exportWavPath: 'wavs/utt000001.wav',
          rawText: detail.prompts.first.rawText,
          normalizedText: detail.prompts.first.normalizedText,
          language: detail.prompts.first.language,
          durationMs: 1200,
          sampleRate: 24000,
          channels: 1,
          bitDepth: 16,
          noiseReductionMode: NoiseReductionMode.medium,
          status: ClipStatus.accepted,
        );
        bloc.add(TtsDatasetOpenProject(projectId: detail.project.id));
        await Future<void>.delayed(const Duration(milliseconds: 100));

        bloc.add(TtsDatasetDeleteProject(projectId: detail.project.id));
      },
      expect: () => [
        isA<TtsDatasetState>().having(
          (state) => state.status,
          'status',
          TtsDatasetStatus.loading,
        ),
        isA<TtsDatasetState>().having(
          (state) => state.status,
          'status',
          TtsDatasetStatus.loaded,
        ),
        isA<TtsDatasetState>().having(
          (state) => state.status,
          'status',
          TtsDatasetStatus.loading,
        ),
        isA<TtsDatasetState>()
            .having((state) => state.status, 'status', TtsDatasetStatus.loaded)
            .having((state) => state.projects, 'projects', isEmpty)
            .having(
              (state) => state.selectedProject,
              'selected project',
              isNull,
            )
            .having(
              (state) => state.selectedPromptId,
              'selected prompt',
              isNull,
            ),
      ],
      verify: (_) async {
        expect(await repository.listProjects(), isEmpty);
        expect(deletedWavFile.existsSync(), isFalse);
      },
      wait: const Duration(milliseconds: 200),
    );

    blocTest<TtsDatasetBloc, TtsDatasetState>(
      'validates a project and exposes blocking issues',
      build: () => TtsDatasetBloc(repository: repository),
      act: (bloc) async {
        final detail = await repository.createProject(
          name: 'My voice',
          targetProfile: TtsDatasetTargetProfiles.qwen3Tts12HzRaw,
          language: 'English',
          speakerDisplayName: 'Example Speaker',
          datasetLicense: 'private',
          consentStatus: ConsentStatus.pending,
          rootPath: '/tmp/my_voice',
          defaultNoiseReductionMode: NoiseReductionMode.medium,
        );
        bloc.add(TtsDatasetValidateProject(projectId: detail.project.id));
      },
      expect: () => [
        isA<TtsDatasetState>().having(
          (state) => state.status,
          'status',
          TtsDatasetStatus.loading,
        ),
        isA<TtsDatasetState>()
            .having((state) => state.status, 'status', TtsDatasetStatus.loaded)
            .having(
              (state) => state.validationResult?.hasErrors,
              'errors',
              true,
            )
            .having(
              (state) => state.validationResult!.errors
                  .map((issue) => issue.code)
                  .toList(),
              'codes',
              contains(ValidationCodes.consentNotGranted),
            ),
      ],
    );

    blocTest<TtsDatasetBloc, TtsDatasetState>(
      'exports a valid project and exposes result',
      build: () => TtsDatasetBloc(repository: repository),
      act: (bloc) async {
        final tempDir = await Directory.systemTemp.createTemp('tts_bloc_test_');
        addTearDown(() => tempDir.delete(recursive: true));
        final projectRoot = Directory(p.join(tempDir.path, 'project'));
        await projectRoot.create();
        await Directory(p.join(projectRoot.path, 'raw')).create();
        await Directory(p.join(projectRoot.path, 'wavs')).create();
        await File(
          p.join(projectRoot.path, 'raw', 'utt000001_original.wav'),
        ).writeAsBytes(_tinyWavBytes);
        await File(
          p.join(projectRoot.path, 'wavs', 'utt000001.wav'),
        ).writeAsBytes(_tinyWavBytes);

        final detail = await repository.createProject(
          name: 'My voice',
          targetProfile: TtsDatasetTargetProfiles.qwen3Tts12HzRaw,
          language: 'English',
          speakerDisplayName: 'Example Speaker',
          datasetLicense: 'private',
          consentStatus: ConsentStatus.granted,
          rootPath: projectRoot.path,
          defaultNoiseReductionMode: NoiseReductionMode.medium,
        );
        final clip = await repository.addManualClip(
          projectId: detail.project.id,
          speakerId: detail.speaker.id,
          rawPath: 'raw/utt000001_original.wav',
          processedPath: 'wavs/utt000001.wav',
          exportWavPath: 'wavs/utt000001.wav',
          rawText: 'Hello world.',
          normalizedText: 'Hello world.',
          language: 'English',
          durationMs: 1000,
          sampleRate: 24000,
          channels: 1,
          bitDepth: 16,
          noiseReductionMode: NoiseReductionMode.medium,
          status: ClipStatus.accepted,
        );
        await repository.selectReferenceClip(detail.project.id, clip.id);

        bloc.add(
          TtsDatasetExportProject(
            projectId: detail.project.id,
            outputPath: p.join(tempDir.path, 'my_voice_dataset.zip'),
          ),
        );
      },
      expect: () => [
        isA<TtsDatasetState>().having(
          (state) => state.status,
          'status',
          TtsDatasetStatus.loading,
        ),
        isA<TtsDatasetState>()
            .having(
              (state) => state.status,
              'status',
              TtsDatasetStatus.exported,
            )
            .having((state) => state.exportResult?.sha256Hex.length, 'sha', 64),
      ],
      wait: const Duration(milliseconds: 100),
    );
  });
}

const _tinyWavBytes = <int>[
  0x52,
  0x49,
  0x46,
  0x46,
  0x24,
  0x00,
  0x00,
  0x00,
  0x57,
  0x41,
  0x56,
  0x45,
  0x66,
  0x6d,
  0x74,
  0x20,
  0x10,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x01,
  0x00,
  0xc0,
  0x5d,
  0x00,
  0x00,
  0x80,
  0xbb,
  0x00,
  0x00,
  0x02,
  0x00,
  0x10,
  0x00,
  0x64,
  0x61,
  0x74,
  0x61,
  0x00,
  0x00,
  0x00,
  0x00,
];
