import 'package:drift/drift.dart';

/// Drift table storing serialized `agent_runtime` [AgentState] per session.
///
/// Kept separate from [ChatConversationTable] so listing conversations does not
/// load serialized agent histories, while the agent runtime owns and persists
/// its canonical state per conversation/session.
class AgentSessionStateTable extends Table {
  /// Session ID matching `ChatConversationTable.id`.
  TextColumn get sessionId => text()();

  /// JSON-encoded `AgentState`.
  TextColumn get stateJson => text()();

  /// Last update timestamp.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {sessionId};
}
