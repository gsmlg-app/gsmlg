import 'package:drift/drift.dart';

/// Drift table definition for chat model settings.
///
/// Stores a single row of model configuration settings.
class ChatSettingsTable extends Table {
  /// Singleton key (always 'default').
  TextColumn get key => text().withDefault(const Constant('default'))();

  /// Inference mode: local or remote.
  TextColumn get inferenceMode => text().withDefault(const Constant('local'))();

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

  /// Remote provider type.
  TextColumn get remoteProvider =>
      text().withDefault(const Constant('openAiCompatible'))();

  /// Remote API protocol type.
  TextColumn get remoteApiType =>
      text().withDefault(const Constant('openAiChatCompletions'))();

  /// Service account ID containing the remote provider API key.
  IntColumn get remoteAccountId => integer().nullable()();

  /// Remote API base URL.
  TextColumn get remoteBaseUrl =>
      text().withDefault(const Constant('https://api.openai.com/v1'))();

  /// Remote model identifier.
  TextColumn get remoteModel =>
      text().withDefault(const Constant('gpt-4.1-mini'))();

  /// Whether remote responses should be streamed.
  BoolColumn get remoteStreamingEnabled =>
      boolean().withDefault(const Constant(true))();

  /// Remote provider thinking effort: off, high, or max.
  TextColumn get remoteThinkingEffort =>
      text().withDefault(const Constant('off'))();

  /// Default system prompt for new conversations.
  TextColumn get defaultSystemPrompt => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}
