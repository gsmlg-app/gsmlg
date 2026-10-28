import 'package:drift/drift.dart';

/// Drift table definition for chat conversations.
class ChatConversationTable extends Table {
  /// Primary key (UUID string).
  TextColumn get id => text()();

  /// Display title of the conversation.
  TextColumn get title => text()();

  /// Legacy and ambiguous custom titles are protected.
  TextColumn get titleSource => text().withDefault(const Constant('manual'))();
  IntColumn get titleRevision => integer().withDefault(const Constant(0))();
  IntColumn get contentRevision => integer().withDefault(const Constant(0))();

  /// Optional system prompt for this conversation.
  TextColumn get systemPrompt => text().nullable()();

  /// Timestamp when the conversation was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Timestamp when the conversation was last updated.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
