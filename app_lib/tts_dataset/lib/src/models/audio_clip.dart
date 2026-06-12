class NoiseReductionMode {
  const NoiseReductionMode._();

  static const off = 'off';
  static const low = 'low';
  static const medium = 'medium';
  static const high = 'high';
}

class ClipStatus {
  const ClipStatus._();

  static const draft = 'draft';
  static const needsReview = 'needsReview';
  static const accepted = 'accepted';
  static const rejected = 'rejected';
  static const exported = 'exported';
}

class AudioClip {
  const AudioClip({
    required this.id,
    required this.projectId,
    required this.speakerId,
    required this.rawPath,
    required this.processedPath,
    required this.exportWavPath,
    required this.rawText,
    required this.normalizedText,
    required this.language,
    required this.durationMs,
    required this.sampleRate,
    required this.channels,
    required this.bitDepth,
    required this.noiseReductionMode,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.promptId,
    this.peakDb,
    this.rmsDb,
    this.noiseFloorDb,
    this.snrEstimateDb,
    this.clippingCount,
    this.leadingSilenceMs,
    this.trailingSilenceMs,
    this.noiseReductionEngine,
    this.processingProfileId,
    this.rejectionReason,
  });

  final String id;
  final String projectId;
  final String speakerId;
  final String? promptId;
  final String rawPath;
  final String processedPath;
  final String exportWavPath;
  final String rawText;
  final String normalizedText;
  final String language;
  final int durationMs;
  final int sampleRate;
  final int channels;
  final int bitDepth;
  final double? peakDb;
  final double? rmsDb;
  final double? noiseFloorDb;
  final double? snrEstimateDb;
  final int? clippingCount;
  final int? leadingSilenceMs;
  final int? trailingSilenceMs;
  final String noiseReductionMode;
  final String? noiseReductionEngine;
  final String? processingProfileId;
  final String status;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isAccepted => status == ClipStatus.accepted;
}
