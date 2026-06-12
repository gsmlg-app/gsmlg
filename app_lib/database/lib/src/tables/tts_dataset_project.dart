import 'package:drift/drift.dart';

/// Drift table definition for TTS dataset projects.
class TtsDatasetProjectTable extends Table {
  /// Primary key.
  TextColumn get id => text()();

  /// Display name of the dataset project.
  TextColumn get name => text()();

  /// Export target profile, such as qwen3_tts_12hz_raw.
  TextColumn get targetProfile => text()();

  /// Dataset language label.
  TextColumn get language => text()();

  /// Primary speaker id for the single-speaker MVP.
  TextColumn get speakerId => text()();

  /// Local project root path.
  TextColumn get rootPath => text()();

  /// Project lifecycle status.
  TextColumn get status => text()();

  /// Timestamp when the project was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Timestamp when the project was last updated.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
