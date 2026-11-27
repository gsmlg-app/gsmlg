import 'message.dart';

/// Ordered canonical LLM message history owned by [AgentState].
class AgentMessageHistory {
  AgentMessageHistory({List<LLMMessage>? messages})
    : messages = List<LLMMessage>.from(messages ?? const []);

  final List<LLMMessage> messages;

  Map<String, dynamic> toJson() => {
    'messages': [for (final m in messages) m.toJson()],
  };

  factory AgentMessageHistory.fromJson(Map<String, dynamic> json) =>
      AgentMessageHistory(
        messages: [
          for (final item in (json['messages'] as List? ?? const []))
            LLMMessage.fromJson(Map<String, dynamic>.from(item as Map)),
        ],
      );
}

/// Canonical per-session state owned and persisted by `AgentRuntime`.
class AgentState {
  AgentState({
    required this.sessionId,
    AgentMessageHistory? history,
    List<ModelUsage>? usages,
    Map<String, dynamic>? metadata,
    this.isRunning = false,
    this.totalLoopCount = 0,
    this.currentLoopCount = 0,
    this.lastError,
  }) : history = history ?? AgentMessageHistory(),
       usages = List<ModelUsage>.from(usages ?? const []),
       metadata = Map<String, dynamic>.from(metadata ?? const {});

  final String sessionId;
  final AgentMessageHistory history;
  final List<ModelUsage> usages;
  final Map<String, dynamic> metadata;
  bool isRunning;
  int totalLoopCount;
  int currentLoopCount;
  String? lastError;

  Map<String, dynamic> toJson() => {
    'version': 1,
    'sessionId': sessionId,
    'history': history.toJson(),
    'usages': [for (final u in usages) u.toJson()],
    'metadata': metadata,
    'isRunning': isRunning,
    'totalLoopCount': totalLoopCount,
    'currentLoopCount': currentLoopCount,
    if (lastError != null) 'lastError': lastError,
  };

  factory AgentState.fromJson(Map<String, dynamic> json) => AgentState(
    sessionId: json['sessionId'] as String? ?? '',
    history: json['history'] is Map
        ? AgentMessageHistory.fromJson(
            Map<String, dynamic>.from(json['history'] as Map),
          )
        : AgentMessageHistory(),
    usages: [
      for (final u in (json['usages'] as List? ?? const []))
        ModelUsage.fromJson(Map<String, dynamic>.from(u as Map)),
    ],
    metadata: json['metadata'] is Map
        ? Map<String, dynamic>.from(json['metadata'] as Map)
        : const {},
    isRunning: json['isRunning'] as bool? ?? false,
    totalLoopCount: (json['totalLoopCount'] as num?)?.toInt() ?? 0,
    currentLoopCount: (json['currentLoopCount'] as num?)?.toInt() ?? 0,
    lastError: json['lastError'] as String?,
  );
}

/// Optional persistence contract for [AgentState].
abstract interface class AgentStateStore {
  Future<AgentState?> load(String sessionId);
  Future<void> save(AgentState state);
  Future<void> delete(String sessionId);
}
