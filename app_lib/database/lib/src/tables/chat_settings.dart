import 'package:drift/drift.dart';

/// Drift table definition for chat model settings.
///
/// Stores a single row of model configuration settings.
class ChatSettingsTable extends Table {
  /// Singleton key (always 'default').
  TextColumn get key => text().withDefault(const Constant('default'))();

  /// Model type: gemma2bIt, gemma7bIt, or custom.
  TextColumn get modelType => text().withDefault(const Constant('gemma2bIt'))();

  /// Path to custom model file (nullable).
  TextColumn get customModelPath => text().nullable()();

  /// Maximum number of tokens to generate.
  IntColumn get maxTokens => integer().withDefault(const Constant(2048))();

  /// Temperature for sampling (stored as integer * 100).
  IntColumn get temperatureX100 => integer().withDefault(const Constant(80))();

  /// Top-K sampling parameter.
  IntColumn get topK => integer().withDefault(const Constant(40))();

  /// Backend to use: gpu or cpu.
  TextColumn get backend => text().withDefault(const Constant('gpu'))();

  /// Default system prompt for new conversations.
  TextColumn get defaultSystemPrompt => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}
