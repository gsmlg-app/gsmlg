import 'audio_clip.dart';
import 'speaker_profile.dart';
import 'training_text_item.dart';
import 'validation_issue.dart';

class TtsDatasetTargetProfiles {
  const TtsDatasetTargetProfiles._();

  static const qwen3Tts12HzRaw = 'qwen3_tts_12hz_raw';
}

class ProjectStatus {
  const ProjectStatus._();

  static const draft = 'draft';
  static const recording = 'recording';
  static const validating = 'validating';
  static const ready = 'ready';
  static const exported = 'exported';
}

class TtsDatasetProject {
  const TtsDatasetProject({
    required this.id,
    required this.name,
    required this.targetProfile,
    required this.language,
    required this.speakerId,
    required this.rootPath,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String targetProfile;
  final String language;
  final String speakerId;
  final String rootPath;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class TtsDatasetProjectDetail {
  const TtsDatasetProjectDetail({
    required this.project,
    required this.speaker,
    required this.prompts,
    required this.clips,
    required this.issues,
  });

  final TtsDatasetProject project;
  final SpeakerProfile speaker;
  final List<TrainingTextItem> prompts;
  final List<AudioClip> clips;
  final List<ValidationIssue> issues;
}
