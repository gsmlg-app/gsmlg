import 'package:drift/drift.dart';

import '../type_converter.dart';
import 'tts_dataset_project.dart';

/// Drift table definition for TTS dataset training prompts.
class TtsDatasetPromptTable extends Table {
  /// Primary key.
  TextColumn get id => text()();

  /// Owning dataset project.
  TextColumn get projectId => text().references(TtsDatasetProjectTable, #id)();

  /// Original prompt text.
  TextColumn get rawText => text()();

  /// Normalized prompt text for export.
  TextColumn get normalizedText => text()();

  /// Prompt language label.
  TextColumn get language => text()();

  /// Prompt tags encoded as JSON.
  TextColumn get tags => text().map(const StringListConverter())();

  /// Manual sort order.
  IntColumn get sortOrder => integer()();

  /// Prompt status: new, recorded, skipped, or retired.
  TextColumn get status => text()();

  /// Timestamp when the prompt was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Timestamp when the prompt was last updated.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
