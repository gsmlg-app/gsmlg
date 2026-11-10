import 'package:app_agent/app_agent.dart';
import 'package:app_logging/app_logging.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/chat/chat_screen.dart';
import 'package:gsmlg/screens/chat/widgets/local_model_action_button.dart';

import 'duo_controller.dart';

/// Handles companion chat intents while the conversation screen (which owns
/// the regular Duo chat handlers) is not mounted, e.g. on the agents home.
///
/// A send continues the selected conversation, or starts one with the active
/// agent when nothing is selected, then shows the conversation screen.
///
/// Blocs are resolved when an intent arrives, so installing the fallback does
/// not require them; without them intents are ignored (and logged).
class DuoChatFallback {
  DuoChatFallback({
    required this.chatBloc,
    required this.settingsBloc,
    required this.router,
    this.modelBloc,
  });

  final ChatBloc? Function() chatBloc;
  final ChatSettingsBloc? Function() settingsBloc;

  /// Installed local models, used to pick a model for a local agent that has
  /// none configured (as the chat screen does).
  final GemmaModelBloc? Function()? modelBloc;
  final GoRouter router;

  (ChatBloc, ChatSettingsBloc)? _blocs() {
    final chat = chatBloc();
    final settings = settingsBloc();
    if (chat == null || settings == null) {
      AppLogger().w('Duo chat intent ignored: chat blocs unavailable');
      return null;
    }
    return (chat, settings);
  }

  void install(DuoDisplayManager manager) {
    manager
      ..onFallbackTextSubmit = send
      ..onFallbackChatSend = send
      ..onFallbackChatStop = stop
      ..onFallbackChatSelectAgent = selectAgent;
  }

  void send(String text, {List<ChatAttachment>? attachments}) {
    if (text.trim().isEmpty && (attachments == null || attachments.isEmpty)) {
      return;
    }
    final blocs = _blocs();
    if (blocs == null) return;
    final (chatBloc, settingsBloc) = blocs;
    final chat = chatBloc.state;
    if (chat.isBusy) return;
    final settings = settingsBloc.state;
    final conversation = chat.conversation;
    ModelConfig config;
    final String? agentId;
    final String? systemPrompt;
    if (conversation == null) {
      final agent = settings.activeAgent;
      config = agent?.config ?? settings.config;
      agentId = agent?.id;
      systemPrompt = agent?.instructions ?? settings.defaultSystemPrompt;
      chatBloc.add(
        ChatNewConversation(
          systemPrompt: systemPrompt,
          config: config,
          agentId: agentId,
          thinkingEnabled: agent?.thinkingEnabled ?? settings.thinkingEnabled,
        ),
      );
    } else {
      final owner = settings.agents
          .where((agent) => agent.id == conversation.agentId)
          .firstOrNull;
      final session = chat.sessionFor(conversation.id);
      config = owner?.config ?? session?.config ?? settings.config;
      agentId = owner?.id ?? session?.agentId ?? settings.activeAgentId;
      systemPrompt =
          owner?.instructions ??
          session?.systemPrompt ??
          settings.defaultSystemPrompt;
    }
    final models = modelBloc?.call();
    if (models != null &&
        config.inferenceMode == ChatInferenceMode.local &&
        config.localModelId == null) {
      config = config.copyWith(
        localModelId: resolveLocalModelId(settings, models.state),
      );
    }
    // Without an id the bloc targets the selected conversation, which is the
    // one started above when nothing was selected.
    chatBloc.add(
      ChatSendMessage(
        content: text,
        conversationId: conversation?.id,
        config: config,
        agentId: agentId,
        systemPrompt: systemPrompt,
        attachments: attachments ?? const [],
      ),
    );
    router.goNamed(ChatScreen.name);
  }

  void stop() {
    final chatBloc = _blocs()?.$1;
    if (chatBloc == null) return;
    chatBloc.add(
      ChatStopGeneration(conversationId: chatBloc.state.conversation?.id),
    );
  }

  /// Makes [agentId] the active agent, so the next send starts with it.
  void selectAgent(String agentId) {
    _blocs()?.$2.add(ChatSettingsSelectAgent(id: agentId));
  }
}
