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

/// Reset settings to defaults.
final class ChatSettingsReset extends ChatSettingsEvent {
  const ChatSettingsReset();
}
