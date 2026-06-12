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
