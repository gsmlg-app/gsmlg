import 'package:drift/drift.dart';

import 'chat_conversation.dart';

/// Drift table definition for chat messages.
class ChatMessageTable extends Table {
  /// Primary key (UUID string).
  TextColumn get id => text()();

  /// Foreign key to the conversation.
  TextColumn get conversationId =>
      text().references(ChatConversationTable, #id)();

  /// The role of the message sender (user, assistant, system).
  TextColumn get role => text()();

  /// The text content of the message.
  TextColumn get content => text()();

  /// Number of tokens in the message (null if not computed).
  IntColumn get tokenCount => integer().nullable()();

  /// Image data for multimodal user messages (null for text-only).
  BlobColumn get imageBytes => blob().nullable()();

  /// Tool name for tool_response messages (null for other roles).
  TextColumn get toolName => text().nullable()();

  /// Timestamp when the message was created.
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
