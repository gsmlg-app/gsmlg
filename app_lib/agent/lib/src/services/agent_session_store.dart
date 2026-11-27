import '../models/message.dart';

/// Persistence boundary owned by the agent runtime and worker isolates.
///
/// The agent stores its canonical serialized `agent_runtime` `AgentState`
/// plus the turn-by-turn message records it produces (`AssistantMessage` and
/// `ToolResponseMessage`) through this interface. UI layers (such as
/// `ChatBloc`) only read and display persisted data rather than writing
/// agent outputs themselves.
abstract interface class AgentSessionStore {
  /// Returns the persisted JSON-encoded `AgentState` for [sessionId], or `null`
  /// if none has been saved yet (or if it was invalidated).
  Future<String?> loadAgentState(String sessionId);

  /// Persists the JSON-encoded `AgentState` for [sessionId].
  Future<void> saveAgentState(String sessionId, String stateJson);

  /// Removes the persisted `AgentState` for [sessionId].
  Future<void> deleteAgentState(String sessionId);

  /// Inserts or updates a persisted chat message produced during a session.
  Future<void> saveMessage(Message message);

  /// Deletes a persisted chat message by [id].
  Future<void> deleteMessage(String id);

  /// Loads persisted chat messages for [sessionId] in chronological order.
  Future<List<Message>> loadMessages(String sessionId);
}

/// Simple in-memory [AgentSessionStore] for tests and standalone runtimes.
class InMemoryAgentSessionStore implements AgentSessionStore {
  final Map<String, String> _states = {};
  final Map<String, Message> _messages = {};

  Map<String, String> get states => Map.unmodifiable(_states);
  Map<String, Message> get messages => Map.unmodifiable(_messages);

  @override
  Future<String?> loadAgentState(String sessionId) async => _states[sessionId];

  @override
  Future<void> saveAgentState(String sessionId, String stateJson) async {
    _states[sessionId] = stateJson;
  }

  @override
  Future<void> deleteAgentState(String sessionId) async {
    _states.remove(sessionId);
  }

  @override
  Future<void> saveMessage(Message message) async {
    _messages[message.id] = message;
  }

  @override
  Future<void> deleteMessage(String id) async {
    _messages.remove(id);
  }

  @override
  Future<List<Message>> loadMessages(String sessionId) async {
    final list = _messages.values
        .where((m) => m.conversationId == sessionId)
        .toList();
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return list;
  }
}
