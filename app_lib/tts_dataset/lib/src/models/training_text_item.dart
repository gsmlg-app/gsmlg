class PromptStatus {
  const PromptStatus._();

  static const newPrompt = 'new';
  static const recorded = 'recorded';
  static const skipped = 'skipped';
  static const retired = 'retired';
}

class TrainingTextItem {
  const TrainingTextItem({
    required this.id,
    required this.projectId,
    required this.rawText,
    required this.normalizedText,
    required this.language,
    required this.tags,
    required this.sortOrder,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String projectId;
  final String rawText;
  final String normalizedText;
  final String language;
  final List<String> tags;
  final int sortOrder;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
}
