import 'package:app_agent/app_agent.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/chat/chat_screen.dart';

import 'duo_controller.dart';

/// Handles companion chat intents while the conversation screen (which owns
/// the regular Duo chat handlers) is not mounted, e.g. on the agents home.
///
/// A send continues the selected conversation, or starts one with the active
/// agent when nothing is selected, then shows the conversation screen.
class DuoChatFallback {
  DuoChatFallback({
    required this.chatBloc,
    required this.settingsBloc,
    required this.router,
  });

  final ChatBloc chatBloc;
  final ChatSettingsBloc settingsBloc;
  final GoRouter router;

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
    final chat = chatBloc.state;
    if (chat.isBusy) return;
    final settings = settingsBloc.state;
    final conversation = chat.conversation;
    final ModelConfig config;
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
    chatBloc.add(
      ChatStopGeneration(conversationId: chatBloc.state.conversation?.id),
    );
  }

  /// Makes [agentId] the active agent, so the next send starts with it.
  void selectAgent(String agentId) {
    settingsBloc.add(ChatSettingsSelectAgent(id: agentId));
  }
}
