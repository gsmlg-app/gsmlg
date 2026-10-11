part of 'bloc.dart';

enum TtsStatus { idle, synthesizing, ready, error }

enum AsrStatus { idle, recording, transcribing, success, error }

@immutable
class AudioServiceState extends Equatable {
  const AudioServiceState({
    this.ttsStatus = TtsStatus.idle,
    this.audioBytes,
    this.ttsError,
    this.asrStatus = AsrStatus.idle,
    this.recordingPath,
    this.transcription,
    this.asrError,
  });

  final TtsStatus ttsStatus;
  final Uint8List? audioBytes;
  final String? ttsError;

  final AsrStatus asrStatus;
  final String? recordingPath;
  final String? transcription;
  final String? asrError;

  AudioServiceState copyWith({
    TtsStatus? ttsStatus,
    Uint8List? audioBytes,
    bool clearAudio = false,
    String? ttsError,
    bool clearTtsError = false,
    AsrStatus? asrStatus,
    String? recordingPath,
    bool clearRecordingPath = false,
    String? transcription,
    bool clearTranscription = false,
    String? asrError,
    bool clearAsrError = false,
  }) {
    return AudioServiceState(
      ttsStatus: ttsStatus ?? this.ttsStatus,
      audioBytes: clearAudio ? null : audioBytes ?? this.audioBytes,
      ttsError: clearTtsError ? null : ttsError ?? this.ttsError,
      asrStatus: asrStatus ?? this.asrStatus,
      recordingPath: clearRecordingPath
          ? null
          : recordingPath ?? this.recordingPath,
      transcription: clearTranscription
          ? null
          : transcription ?? this.transcription,
      asrError: clearAsrError ? null : asrError ?? this.asrError,
    );
  }

  @override
  List<Object?> get props => [
    ttsStatus,
    audioBytes,
    ttsError,
    asrStatus,
    recordingPath,
    transcription,
    asrError,
  ];
}
