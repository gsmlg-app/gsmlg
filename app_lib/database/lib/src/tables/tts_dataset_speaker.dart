import 'package:drift/drift.dart';

import 'tts_dataset_project.dart';

/// Drift table definition for TTS dataset speaker metadata.
class TtsDatasetSpeakerTable extends Table {
  /// Primary key.
  TextColumn get id => text()();

  /// Owning dataset project.
  TextColumn get projectId => text().references(TtsDatasetProjectTable, #id)();

  /// Human-readable speaker name.
  TextColumn get displayName => text()();

  /// Consent status: pending, granted, or revoked.
  TextColumn get consentStatus => text()();

  /// Allowed use category, such as fine_tune_tts.
  TextColumn get allowedUse => text()();

  /// Dataset license label.
  TextColumn get datasetLicense => text()();

  /// Optional local consent document path.
  TextColumn get consentDocumentPath => text().nullable()();

  /// Selected reference clip id.
  TextColumn get referenceClipId => text().nullable()();

  /// Timestamp when the speaker profile was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Timestamp when the speaker profile was last updated.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
