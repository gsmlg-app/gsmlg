import 'package:drift/drift.dart';

/// Drift table definition for chat conversations.
class ChatConversationTable extends Table {
  /// Primary key (UUID string).
  TextColumn get id => text()();

  /// Display title of the conversation.
  TextColumn get title => text()();

  /// Optional system prompt for this conversation.
  TextColumn get systemPrompt => text().nullable()();

  /// Timestamp when the conversation was created.
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// Timestamp when the conversation was last updated.
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
