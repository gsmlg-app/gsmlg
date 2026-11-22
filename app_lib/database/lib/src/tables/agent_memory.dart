import 'package:drift/drift.dart';

/// Drift table definition for persisted scoped agent memories with provenance.
class AgentMemoryTable extends Table {
  /// Primary key (e.g. `mem_<timestamp>` or UUID).
  TextColumn get id => text()();

  /// Visibility scope (e.g. `global`, `agent:<id>`, `conversation:<id>`).
  TextColumn get scope => text()();

  /// Memory text content.
  TextColumn get content => text()();

  /// Source type: `user_fact`, `agent_inference`, or `tool_observation`.
  TextColumn get provenance =>
      text().withDefault(const Constant('agent_inference'))();

  /// Originating session or agent identifier, when known.
  TextColumn get sourceId => text().nullable()();

  /// SHA-256 hash of [content] for integrity and deduplication.
  TextColumn get contentHash => text()();

  /// JSON-encoded key-value metadata.
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
