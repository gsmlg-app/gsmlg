import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:app_database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:tts_dataset/tts_dataset.dart';

void main() {
  test('exports a Qwen3-TTS raw ZIP with relative JSONL paths', () async {
    final tempDir = await Directory.systemTemp.createTemp('tts_export_test_');
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
      rootPath: projectRoot.path,
      defaultNoiseReductionMode: NoiseReductionMode.medium,
      starterPrompts: const ['Hello world.'],
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

    final outputPath = p.join(tempDir.path, 'my_voice_dataset.zip');
    final result = await Qwen3TtsRawZipExporter(repository).export(
      DatasetExportRequest(
        projectId: detail.project.id,
        outputPath: outputPath,
      ),
    );

    expect(result.outputPath, outputPath);
    expect(result.sha256Hex, hasLength(64));

    final archive = ZipDecoder().decodeBytes(
      await File(outputPath).readAsBytes(),
    );
    final names = archive.files.map((file) => file.name).toSet();
    expect(
      names,
      containsAll({
        'my_voice_dataset/train_raw.jsonl',
        'my_voice_dataset/manifest.json',
        'my_voice_dataset/README.md',
        'my_voice_dataset/consent/speaker_consent.json',
        'my_voice_dataset/ref/ref.wav',
        'my_voice_dataset/wavs/utt000001.wav',
        'my_voice_dataset/raw/utt000001_original.wav',
        'my_voice_dataset/text/prompts.csv',
        'my_voice_dataset/text/clips_transcripts.csv',
        'my_voice_dataset/reports/validation_report.json',
        'my_voice_dataset/reports/quality_report.csv',
      }),
    );

    final jsonl = utf8.decode(
      archive.files
              .singleWhere((file) => file.name.endsWith('train_raw.jsonl'))
              .content
          as List<int>,
    );
    expect(
      jsonl.trim(),
      jsonEncode({
        'audio': './wavs/utt000001.wav',
        'text': 'Hello world.',
        'ref_audio': './ref/ref.wav',
      }),
    );
    expect(jsonl, isNot(contains(projectRoot.path)));
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
