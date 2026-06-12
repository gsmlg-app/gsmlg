import 'package:drift/drift.dart';

import 'tts_dataset_clip.dart';
import 'tts_dataset_project.dart';

/// Drift table definition for TTS dataset validation issues.
class TtsDatasetValidationIssueTable extends Table {
  /// Primary key.
  TextColumn get id => text()();

  /// Owning dataset project.
  TextColumn get projectId => text().references(TtsDatasetProjectTable, #id)();

  /// Optional affected clip.
  TextColumn get clipId =>
      text().nullable().references(TtsDatasetClipTable, #id)();

  /// Issue category: schema, audio, text, consent, qwen, or export.
  TextColumn get category => text()();

  /// Issue severity: error, warning, or info.
  TextColumn get severity => text()();

  /// Stable issue code.
  TextColumn get code => text()();

  /// User-facing issue message.
  TextColumn get message => text()();

  /// Optional suggested fix.
  TextColumn get suggestedFix => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
