import 'package:drift/drift.dart';

import 'tts_dataset_project.dart';
import 'tts_dataset_prompt.dart';
import 'tts_dataset_speaker.dart';

/// Drift table definition for TTS dataset clip metadata.
class TtsDatasetClipTable extends Table {
  /// Primary key.
  TextColumn get id => text()();

  /// Owning dataset project.
  TextColumn get projectId => text().references(TtsDatasetProjectTable, #id)();

  /// Speaker for this clip.
  TextColumn get speakerId => text().references(TtsDatasetSpeakerTable, #id)();

  /// Optional linked prompt.
  TextColumn get promptId =>
      text().nullable().references(TtsDatasetPromptTable, #id)();

  /// Project-relative raw recording path.
  TextColumn get rawPath => text()();

  /// Project-relative processed recording path.
  TextColumn get processedPath => text()();

  /// Project-relative training WAV path used for export.
  TextColumn get exportWavPath => text()();

  /// Original transcript text.
  TextColumn get rawText => text()();

  /// Normalized transcript text for export.
  TextColumn get normalizedText => text()();

  /// Clip language label.
  TextColumn get language => text()();

  /// Duration in milliseconds.
  IntColumn get durationMs => integer()();

  /// Sample rate in hertz.
  IntColumn get sampleRate => integer()();

  /// Channel count.
  IntColumn get channels => integer()();

  /// Bit depth.
  IntColumn get bitDepth => integer()();

  /// Peak level in dB.
  RealColumn get peakDb => real().nullable()();

  /// RMS level in dB.
  RealColumn get rmsDb => real().nullable()();

  /// Estimated noise floor in dB.
  RealColumn get noiseFloorDb => real().nullable()();

  /// Estimated SNR in dB.
  RealColumn get snrEstimateDb => real().nullable()();

  /// Count of clipped samples or frames.
  IntColumn get clippingCount => integer().nullable()();

  /// Leading silence estimate in milliseconds.
  IntColumn get leadingSilenceMs => integer().nullable()();

  /// Trailing silence estimate in milliseconds.
  IntColumn get trailingSilenceMs => integer().nullable()();

  /// Noise reduction mode: off, low, medium, or high.
  TextColumn get noiseReductionMode => text()();

  /// Optional processing engine label.
  TextColumn get noiseReductionEngine => text().nullable()();

  /// Optional processing profile id.
  TextColumn get processingProfileId => text().nullable()();

  /// Clip review status.
  TextColumn get status => text()();

  /// Optional rejection reason.
  TextColumn get rejectionReason => text().nullable()();

  /// Timestamp when the clip was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Timestamp when the clip was last updated.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
