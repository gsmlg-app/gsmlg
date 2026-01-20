part of 'bloc.dart';

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
    this.errorMessage,
    this.configChanged = false,
  });

  /// Current status of settings.
  final ChatSettingsStatus status;

  /// The current model configuration.
  final ModelConfig config;

  /// The default system prompt for new conversations.
  final String? defaultSystemPrompt;

  /// Error message if status is error.
  final String? errorMessage;

  /// Whether the config has been changed since last model load.
  /// Used to trigger model reload when navigating away from settings.
  final bool configChanged;

  @override
  List<Object?> get props => [
        status,
        config,
        defaultSystemPrompt,
        errorMessage,
        configChanged,
      ];

  /// Whether settings are loaded.
  bool get isLoaded => status == ChatSettingsStatus.loaded;

  /// Whether there is an error.
  bool get hasError => status == ChatSettingsStatus.error;

  ChatSettingsState copyWith({
    ChatSettingsStatus? status,
    ModelConfig? config,
    String? defaultSystemPrompt,
    String? errorMessage,
    bool? configChanged,
    bool clearSystemPrompt = false,
  }) {
    return ChatSettingsState(
      status: status ?? this.status,
      config: config ?? this.config,
      defaultSystemPrompt:
          clearSystemPrompt ? null : (defaultSystemPrompt ?? this.defaultSystemPrompt),
      errorMessage: errorMessage,
      configChanged: configChanged ?? false,
    );
  }
}
