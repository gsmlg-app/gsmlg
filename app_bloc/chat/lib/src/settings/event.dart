part of 'bloc.dart';

/// Events for the ChatSettingsBloc.
sealed class ChatSettingsEvent {
  const ChatSettingsEvent();
}

/// Load settings from storage.
final class ChatSettingsLoad extends ChatSettingsEvent {
  const ChatSettingsLoad();
}

/// Update the model configuration.
final class ChatSettingsUpdateConfig extends ChatSettingsEvent {
  const ChatSettingsUpdateConfig({required this.config, this.agentId});

  final ModelConfig config;
  final String? agentId;
}

/// Update the default system prompt.
final class ChatSettingsUpdateSystemPrompt extends ChatSettingsEvent {
  const ChatSettingsUpdateSystemPrompt({this.prompt, this.agentId});

  final String? prompt;
  final String? agentId;
}

/// Add or update an agent definition.
///
/// Null optional fields keep the existing agent's values; empty
/// [instructions] clear them and [clearAllowedTools] resets the tool list to
/// "all tools".
final class ChatSettingsSaveAgent extends ChatSettingsEvent {
  const ChatSettingsSaveAgent({
    this.id,
    required this.name,
    this.instructions,
    this.avatar,
    this.description,
    this.config,
    this.thinkingEnabled,
    this.allowedTools,
    this.clearAllowedTools = false,
  });

  final String? id;
  final String name;
  final String? instructions;
  final String? avatar;
  final String? description;
  final ModelConfig? config;
  final bool? thinkingEnabled;
  final List<String>? allowedTools;
  final bool clearAllowedTools;
}

/// Delete a chat agent profile.
final class ChatSettingsDeleteAgent extends ChatSettingsEvent {
  const ChatSettingsDeleteAgent({required this.id});

  final String id;
}

/// Select the active chat agent profile.
final class ChatSettingsSelectAgent extends ChatSettingsEvent {
  const ChatSettingsSelectAgent({required this.id});

  final String id;
}

/// Toggle thinking/chain-of-thought display.
final class ChatSettingsToggleThinking extends ChatSettingsEvent {
  const ChatSettingsToggleThinking({required this.enabled, this.agentId});

  final bool enabled;
  final String? agentId;
}

/// Reset settings to defaults.
final class ChatSettingsReset extends ChatSettingsEvent {
  const ChatSettingsReset();
}
