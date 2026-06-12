class ConsentStatus {
  const ConsentStatus._();

  static const pending = 'pending';
  static const granted = 'granted';
  static const revoked = 'revoked';
}

class SpeakerProfile {
  const SpeakerProfile({
    required this.id,
    required this.projectId,
    required this.displayName,
    required this.consentStatus,
    required this.allowedUse,
    required this.datasetLicense,
    required this.createdAt,
    required this.updatedAt,
    this.consentDocumentPath,
    this.referenceClipId,
  });

  final String id;
  final String projectId;
  final String displayName;
  final String consentStatus;
  final String allowedUse;
  final String datasetLicense;
  final String? consentDocumentPath;
  final String? referenceClipId;
  final DateTime createdAt;
  final DateTime updatedAt;
}
