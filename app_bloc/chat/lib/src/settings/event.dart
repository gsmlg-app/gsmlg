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
  const ChatSettingsUpdateConfig({required this.config});

  final ModelConfig config;
}

/// Update the default system prompt.
final class ChatSettingsUpdateSystemPrompt extends ChatSettingsEvent {
  const ChatSettingsUpdateSystemPrompt({this.prompt});

  final String? prompt;
}

/// Add or update a chat agent profile.
final class ChatSettingsSaveAgent extends ChatSettingsEvent {
  const ChatSettingsSaveAgent({
    this.id,
    required this.name,
    required this.systemPrompt,
    this.config,
    this.thinkingEnabled,
  });

  final String? id;
  final String name;
  final String systemPrompt;
  final ModelConfig? config;
  final bool? thinkingEnabled;
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
  const ChatSettingsToggleThinking({required this.enabled});

  final bool enabled;
}

/// Reset settings to defaults.
final class ChatSettingsReset extends ChatSettingsEvent {
  const ChatSettingsReset();
}
