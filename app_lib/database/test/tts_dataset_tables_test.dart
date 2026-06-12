import 'package:app_database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('persists a TTS dataset project with speaker, prompt, clip, and issue',
      () async {
    final database = AppDatabase.forTesting();
    addTearDown(database.close);

    final now = DateTime.utc(2026, 6, 12);
    await database.into(database.ttsDatasetProjectTable).insert(
          TtsDatasetProjectTableCompanion.insert(
            id: 'project-1',
            name: 'My voice',
            targetProfile: 'qwen3_tts_12hz_raw',
            language: 'English',
            speakerId: 'speaker-1',
            rootPath: '/tmp/project-1',
            status: 'draft',
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    await database.into(database.ttsDatasetSpeakerTable).insert(
          TtsDatasetSpeakerTableCompanion.insert(
            id: 'speaker-1',
            projectId: 'project-1',
            displayName: 'Example Speaker',
            consentStatus: 'granted',
            allowedUse: 'fine_tune_tts',
            datasetLicense: 'private',
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    await database.into(database.ttsDatasetPromptTable).insert(
          TtsDatasetPromptTableCompanion.insert(
            id: 'prompt-1',
            projectId: 'project-1',
            rawText: 'Hello world.',
            normalizedText: 'Hello world.',
            language: 'English',
            tags: const ['starter'],
            sortOrder: 0,
            status: 'new',
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    await database.into(database.ttsDatasetClipTable).insert(
          TtsDatasetClipTableCompanion.insert(
            id: 'clip-1',
            projectId: 'project-1',
            speakerId: 'speaker-1',
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
            noiseReductionMode: 'medium',
            status: 'accepted',
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    await database.into(database.ttsDatasetValidationIssueTable).insert(
          TtsDatasetValidationIssueTableCompanion.insert(
            id: 'issue-1',
            projectId: 'project-1',
            category: 'export',
            severity: 'info',
            code: 'ready',
            message: 'Ready to export.',
          ),
        );

    expect(await database.select(database.ttsDatasetProjectTable).get(),
        hasLength(1));
    expect(
      (await database.select(database.ttsDatasetPromptTable).get()).single.tags,
      ['starter'],
    );
    expect(await database.select(database.ttsDatasetClipTable).get(),
        hasLength(1));
    expect(
      await database.select(database.ttsDatasetValidationIssueTable).get(),
      hasLength(1),
    );
  });
}
