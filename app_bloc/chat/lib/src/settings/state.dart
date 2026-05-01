part of 'bloc.dart';

/// A reusable chat-agent profile.
class ChatAgent extends Equatable {
  const ChatAgent({
    required this.id,
    required this.name,
    required this.config,
    this.systemPrompt,
    this.thinkingEnabled = false,
  });

  final String id;
  final String name;
  final ModelConfig config;
  final String? systemPrompt;
  final bool thinkingEnabled;

  ChatAgent copyWith({
    String? name,
    ModelConfig? config,
    String? systemPrompt,
    bool? thinkingEnabled,
    bool clearSystemPrompt = false,
  }) {
    return ChatAgent(
      id: id,
      name: name ?? this.name,
      config: config ?? this.config,
      systemPrompt:
          clearSystemPrompt ? null : (systemPrompt ?? this.systemPrompt),
      thinkingEnabled: thinkingEnabled ?? this.thinkingEnabled,
    );
  }

  @override
  List<Object?> get props => [id, name, config, systemPrompt, thinkingEnabled];
}

/// Status of the chat settings.
enum ChatSettingsStatus {
  /// Initial state, settings not loaded.
  initial,

  /// Loading settings.
  loading,

  /// Settings loaded successfully.
  loaded,

  /// An error occurred.
  error,
}

/// State for the ChatSettingsBloc.
class ChatSettingsState extends Equatable {
  const ChatSettingsState({
    this.status = ChatSettingsStatus.initial,
    this.config = ModelConfig.defaultConfig,
    this.defaultSystemPrompt,
    this.agents = const [],
    this.activeAgentId,
    this.errorMessage,
    this.configChanged = false,
    this.thinkingEnabled = false,
  });

  /// Current status of settings.
  final ChatSettingsStatus status;

  /// The current model configuration.
  final ModelConfig config;

  /// The default system prompt for new conversations.
  final String? defaultSystemPrompt;

  /// Saved chat-agent profiles.
  final List<ChatAgent> agents;

  /// The selected chat-agent profile id.
  final String? activeAgentId;

  /// Error message if status is error.
  final String? errorMessage;

  /// Whether the config has been changed since last model load.
  /// Used to trigger model reload when navigating away from settings.
  final bool configChanged;

  /// Whether to display thinking/chain-of-thought content from the model.
  final bool thinkingEnabled;

  @override
  List<Object?> get props => [
        status,
        config,
        defaultSystemPrompt,
        agents,
        activeAgentId,
        errorMessage,
        configChanged,
        thinkingEnabled,
      ];

  /// Whether settings are loaded.
  bool get isLoaded => status == ChatSettingsStatus.loaded;

  /// Whether there is an error.
  bool get hasError => status == ChatSettingsStatus.error;

  /// Currently selected chat agent, if any.
  ChatAgent? get activeAgent {
    for (final agent in agents) {
      if (agent.id == activeAgentId) return agent;
    }
    return null;
  }

  ChatSettingsState copyWith({
    ChatSettingsStatus? status,
    ModelConfig? config,
    String? defaultSystemPrompt,
    List<ChatAgent>? agents,
    String? activeAgentId,
    String? errorMessage,
    bool? configChanged,
    bool? thinkingEnabled,
    bool clearSystemPrompt = false,
    bool clearActiveAgent = false,
  }) {
    return ChatSettingsState(
      status: status ?? this.status,
      config: config ?? this.config,
      defaultSystemPrompt: clearSystemPrompt
          ? null
          : (defaultSystemPrompt ?? this.defaultSystemPrompt),
      agents: agents ?? this.agents,
      activeAgentId:
          clearActiveAgent ? null : (activeAgentId ?? this.activeAgentId),
      errorMessage: errorMessage,
      configChanged: configChanged ?? false,
      thinkingEnabled: thinkingEnabled ?? this.thinkingEnabled,
    );
  }
}
