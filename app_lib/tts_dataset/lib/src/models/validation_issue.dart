class ValidationSeverity {
  const ValidationSeverity._();

  static const error = 'error';
  static const warning = 'warning';
  static const info = 'info';
}

class ValidationCodes {
  const ValidationCodes._();

  static const noAcceptedClips = 'no_accepted_clips';
  static const missingTranscript = 'missing_transcript';
  static const missingAudioFile = 'missing_audio_file';
  static const missingReferenceAudio = 'missing_reference_audio';
  static const consentNotGranted = 'consent_not_granted';
  static const multipleSpeakers = 'multiple_speakers';
  static const absoluteExportPath = 'absolute_export_path';
  static const duplicateText = 'duplicate_text';
  static const nonQwenAudioMetadata = 'non_qwen_audio_metadata';
  static const ready = 'ready';
}

class ValidationIssue {
  const ValidationIssue({
    required this.id,
    required this.projectId,
    required this.category,
    required this.severity,
    required this.code,
    required this.message,
    this.clipId,
    this.suggestedFix,
  });

  final String id;
  final String projectId;
  final String? clipId;
  final String category;
  final String severity;
  final String code;
  final String message;
  final String? suggestedFix;

  bool get isError => severity == ValidationSeverity.error;
  bool get isWarning => severity == ValidationSeverity.warning;
}

class ValidationResult {
  const ValidationResult(this.issues);

  final List<ValidationIssue> issues;

  List<ValidationIssue> get errors =>
      issues.where((issue) => issue.isError).toList(growable: false);

  List<ValidationIssue> get warnings =>
      issues.where((issue) => issue.isWarning).toList(growable: false);

  bool get hasErrors => errors.isNotEmpty;
}
