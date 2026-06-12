import 'package:flutter_test/flutter_test.dart';
import 'package:tts_dataset/tts_dataset.dart';

void main() {
  test('blocks export when consent is not granted', () {
    final detail = _detail(consentStatus: ConsentStatus.pending);
    final issues = const TtsDatasetValidationService().validate(
      detail,
      fileExists: (_, _) => true,
    );

    expect(
      issues.errors.map((issue) => issue.code),
      contains(ValidationCodes.consentNotGranted),
    );
  });

  test('blocks export for missing transcript, reference, and files', () {
    final detail = _detail(
      referenceClipId: null,
      clip: _clip(normalizedText: ' '),
    );

    final issues = const TtsDatasetValidationService().validate(
      detail,
      fileExists: (_, _) => false,
    );

    expect(
      issues.errors.map((issue) => issue.code),
      containsAll([
        ValidationCodes.missingTranscript,
        ValidationCodes.missingReferenceAudio,
        ValidationCodes.missingAudioFile,
      ]),
    );
  });

  test('warns for duplicate text and non-Qwen audio metadata', () {
    final first = _clip(
      id: 'clip-1',
      normalizedText: 'Repeated text.',
      sampleRate: 44100,
      channels: 2,
    );
    final second = _clip(id: 'clip-2', normalizedText: 'Repeated text.');
    final detail = _detail(referenceClipId: first.id, clips: [first, second]);

    final issues = const TtsDatasetValidationService().validate(
      detail,
      fileExists: (_, _) => true,
    );

    expect(issues.hasErrors, isFalse);
    expect(
      issues.warnings.map((issue) => issue.code),
      containsAll([
        ValidationCodes.duplicateText,
        ValidationCodes.nonQwenAudioMetadata,
      ]),
    );
  });

  test('passes export-ready single-speaker project', () {
    final detail = _detail();
    final issues = const TtsDatasetValidationService().validate(
      detail,
      fileExists: (_, _) => true,
    );

    expect(issues.hasErrors, isFalse);
  });
}

TtsDatasetProjectDetail _detail({
  String consentStatus = ConsentStatus.granted,
  String? referenceClipId = 'clip-1',
  AudioClip? clip,
  List<AudioClip>? clips,
}) {
  final now = DateTime.utc(2026, 6, 12);
  final resolvedClip = clip ?? _clip();
  return TtsDatasetProjectDetail(
    project: TtsDatasetProject(
      id: 'project-1',
      name: 'My voice',
      targetProfile: TtsDatasetTargetProfiles.qwen3Tts12HzRaw,
      language: 'English',
      speakerId: 'speaker-1',
      rootPath: '/tmp/my_voice',
      status: ProjectStatus.draft,
      createdAt: now,
      updatedAt: now,
    ),
    speaker: SpeakerProfile(
      id: 'speaker-1',
      projectId: 'project-1',
      displayName: 'Example Speaker',
      consentStatus: consentStatus,
      allowedUse: 'fine_tune_tts',
      datasetLicense: 'private',
      referenceClipId: referenceClipId,
      createdAt: now,
      updatedAt: now,
    ),
    prompts: const [],
    clips: clips ?? [resolvedClip],
    issues: const [],
  );
}

AudioClip _clip({
  String id = 'clip-1',
  String speakerId = 'speaker-1',
  String normalizedText = 'Hello world.',
  int sampleRate = 24000,
  int channels = 1,
}) {
  final now = DateTime.utc(2026, 6, 12);
  return AudioClip(
    id: id,
    projectId: 'project-1',
    speakerId: speakerId,
    rawPath: 'raw/utt000001_original.wav',
    processedPath: 'wavs/utt000001.wav',
    exportWavPath: 'wavs/utt000001.wav',
    rawText: normalizedText,
    normalizedText: normalizedText,
    language: 'English',
    durationMs: 3000,
    sampleRate: sampleRate,
    channels: channels,
    bitDepth: 16,
    noiseReductionMode: NoiseReductionMode.medium,
    status: ClipStatus.accepted,
    createdAt: now,
    updatedAt: now,
  );
}
