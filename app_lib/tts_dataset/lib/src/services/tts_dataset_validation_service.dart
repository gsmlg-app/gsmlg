import 'package:path/path.dart' as p;

import '../models/audio_clip.dart';
import '../models/speaker_profile.dart';
import '../models/tts_dataset_project.dart';
import '../models/validation_issue.dart';

typedef TtsDatasetFileExists = bool Function(String rootPath, String path);

class TtsDatasetValidationService {
  const TtsDatasetValidationService();

  ValidationResult validate(
    TtsDatasetProjectDetail detail, {
    required TtsDatasetFileExists fileExists,
  }) {
    final issues = <ValidationIssue>[];
    final acceptedClips = detail.clips.where(
      (clip) => clip.status == ClipStatus.accepted,
    );
    final accepted = acceptedClips.toList(growable: false);

    if (accepted.isEmpty) {
      issues.add(
        _issue(
          detail,
          category: 'export',
          severity: ValidationSeverity.error,
          code: ValidationCodes.noAcceptedClips,
          message: 'At least one accepted clip is required for export.',
        ),
      );
    }

    if (detail.speaker.consentStatus != ConsentStatus.granted) {
      issues.add(
        _issue(
          detail,
          category: 'consent',
          severity: ValidationSeverity.error,
          code: ValidationCodes.consentNotGranted,
          message: 'Speaker consent must be granted before export.',
        ),
      );
    }

    final referenceClipId = detail.speaker.referenceClipId;
    if (referenceClipId == null ||
        !accepted.any((clip) => clip.id == referenceClipId)) {
      issues.add(
        _issue(
          detail,
          category: 'qwen',
          severity: ValidationSeverity.error,
          code: ValidationCodes.missingReferenceAudio,
          message: 'Select one accepted clip as the reference audio.',
        ),
      );
    }

    final speakerIds = accepted.map((clip) => clip.speakerId).toSet();
    if (speakerIds.length > 1) {
      issues.add(
        _issue(
          detail,
          category: 'speaker',
          severity: ValidationSeverity.error,
          code: ValidationCodes.multipleSpeakers,
          message: 'Qwen3-TTS MVP export supports one speaker per dataset.',
        ),
      );
    }

    final textCounts = <String, int>{};
    for (final clip in accepted) {
      final normalizedText = clip.normalizedText.trim();
      textCounts[normalizedText] = (textCounts[normalizedText] ?? 0) + 1;

      if (normalizedText.isEmpty) {
        issues.add(
          _clipIssue(
            detail,
            clip,
            category: 'text',
            severity: ValidationSeverity.error,
            code: ValidationCodes.missingTranscript,
            message: 'Accepted clips must have transcript text.',
          ),
        );
      }

      if (p.isAbsolute(clip.exportWavPath) ||
          p.isAbsolute(clip.rawPath) ||
          p.isAbsolute(clip.processedPath)) {
        issues.add(
          _clipIssue(
            detail,
            clip,
            category: 'qwen',
            severity: ValidationSeverity.error,
            code: ValidationCodes.absoluteExportPath,
            message: 'Export paths must be relative to the project folder.',
          ),
        );
      }

      if (!fileExists(detail.project.rootPath, clip.exportWavPath) ||
          !fileExists(detail.project.rootPath, clip.rawPath)) {
        issues.add(
          _clipIssue(
            detail,
            clip,
            category: 'audio',
            severity: ValidationSeverity.error,
            code: ValidationCodes.missingAudioFile,
            message: 'Accepted clip audio files must exist before export.',
          ),
        );
      }

      if (clip.sampleRate != 24000 || clip.channels != 1) {
        issues.add(
          _clipIssue(
            detail,
            clip,
            category: 'qwen',
            severity: ValidationSeverity.warning,
            code: ValidationCodes.nonQwenAudioMetadata,
            message: 'Qwen3-TTS export expects 24 kHz mono WAV metadata.',
          ),
        );
      }
    }

    final hasDuplicateText = textCounts.entries.any(
      (entry) => entry.key.isNotEmpty && entry.value > 1,
    );
    if (hasDuplicateText) {
      issues.add(
        _issue(
          detail,
          category: 'text',
          severity: ValidationSeverity.warning,
          code: ValidationCodes.duplicateText,
          message: 'Multiple accepted clips use the same normalized text.',
        ),
      );
    }

    if (issues.isEmpty) {
      issues.add(
        _issue(
          detail,
          category: 'export',
          severity: ValidationSeverity.info,
          code: ValidationCodes.ready,
          message: 'Dataset is ready for Qwen3-TTS export.',
        ),
      );
    }

    return ValidationResult(issues);
  }

  ValidationIssue _issue(
    TtsDatasetProjectDetail detail, {
    required String category,
    required String severity,
    required String code,
    required String message,
  }) {
    return ValidationIssue(
      id: '${detail.project.id}-$code',
      projectId: detail.project.id,
      category: category,
      severity: severity,
      code: code,
      message: message,
    );
  }

  ValidationIssue _clipIssue(
    TtsDatasetProjectDetail detail,
    AudioClip clip, {
    required String category,
    required String severity,
    required String code,
    required String message,
  }) {
    return ValidationIssue(
      id: '${clip.id}-$code',
      projectId: detail.project.id,
      clipId: clip.id,
      category: category,
      severity: severity,
      code: code,
      message: message,
    );
  }
}
