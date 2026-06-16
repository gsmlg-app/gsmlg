import 'package:app_database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tts_dataset/tts_dataset.dart';

void main() {
  test('creates a project with speaker metadata and starter prompts', () async {
    final database = AppDatabase.forTesting();
    addTearDown(database.close);
    final repository = TtsDatasetRepository(database);

    final detail = await repository.createProject(
      name: 'My voice',
      targetProfile: TtsDatasetTargetProfiles.qwen3Tts12HzRaw,
      language: 'English',
      speakerDisplayName: 'Example Speaker',
      datasetLicense: 'private',
      consentStatus: ConsentStatus.granted,
      rootPath: '/tmp/my_voice',
      defaultNoiseReductionMode: NoiseReductionMode.medium,
      starterPrompts: englishStarterPrompts.take(2).toList(),
    );

    expect(detail.project.name, 'My voice');
    expect(detail.speaker.displayName, 'Example Speaker');
    expect(detail.speaker.consentStatus, ConsentStatus.granted);
    expect(detail.prompts, hasLength(2));
    expect(
      detail.prompts.first.normalizedText,
      'She said she would be here by noon.',
    );

    final projects = await repository.listProjects();
    expect(projects.single.id, detail.project.id);
  });

  test('stores manual clip metadata and reference clip selection', () async {
    final database = AppDatabase.forTesting();
    addTearDown(database.close);
    final repository = TtsDatasetRepository(database);
    final detail = await repository.createProject(
      name: 'My voice',
      targetProfile: TtsDatasetTargetProfiles.qwen3Tts12HzRaw,
      language: 'English',
      speakerDisplayName: 'Example Speaker',
      datasetLicense: 'private',
      consentStatus: ConsentStatus.granted,
      rootPath: '/tmp/my_voice',
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
      durationMs: 3000,
      sampleRate: 24000,
      channels: 1,
      bitDepth: 16,
      noiseReductionMode: NoiseReductionMode.medium,
      status: ClipStatus.accepted,
    );
    await repository.selectReferenceClip(detail.project.id, clip.id);

    final loaded = await repository.loadProject(detail.project.id);
    expect(loaded, isNotNull);
    expect(loaded!.clips.single.id, clip.id);
    expect(loaded.speaker.referenceClipId, clip.id);
  });

  test('deletes a project with prompts, clips, and speaker metadata', () async {
    final database = AppDatabase.forTesting();
    addTearDown(database.close);
    final repository = TtsDatasetRepository(database);
    final detail = await repository.createProject(
      name: 'My voice',
      targetProfile: TtsDatasetTargetProfiles.qwen3Tts12HzRaw,
      language: 'English',
      speakerDisplayName: 'Example Speaker',
      datasetLicense: 'private',
      consentStatus: ConsentStatus.granted,
      rootPath: '/tmp/my_voice',
      defaultNoiseReductionMode: NoiseReductionMode.medium,
      starterPrompts: englishStarterPrompts.take(1).toList(),
    );
    await repository.addManualClip(
      projectId: detail.project.id,
      speakerId: detail.speaker.id,
      promptId: detail.prompts.single.id,
      rawPath: 'raw/utt000001_original.wav',
      processedPath: 'wavs/utt000001.wav',
      exportWavPath: 'wavs/utt000001.wav',
      rawText: detail.prompts.single.rawText,
      normalizedText: detail.prompts.single.normalizedText,
      language: detail.prompts.single.language,
      durationMs: 3000,
      sampleRate: 24000,
      channels: 1,
      bitDepth: 16,
      noiseReductionMode: NoiseReductionMode.medium,
      status: ClipStatus.accepted,
    );

    final deleted = await repository.deleteProject(detail.project.id);

    expect(deleted?.project.id, detail.project.id);
    expect(await repository.loadProject(detail.project.id), isNull);
    expect(await repository.listProjects(), isEmpty);
  });
}
