import 'package:drift/drift.dart';

/// Drift table definition for persisted agent definitions.
class AgentDefinitionTable extends Table {
  /// Primary key (UUID string).
  TextColumn get id => text()();

  TextColumn get name => text()();

  /// Emoji avatar.
  TextColumn get avatar => text().nullable()();

  TextColumn get description => text().nullable()();

  /// System instructions for the agent.
  TextColumn get instructions => text().nullable()();

  /// JSON-encoded model configuration.
  TextColumn get config => text()();

  BoolColumn get thinkingEnabled =>
      boolean().withDefault(const Constant(false))();

  /// JSON array of allowed tool names; null means all tools.
  TextColumn get allowedTools => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
