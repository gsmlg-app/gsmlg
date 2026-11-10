import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_agent/app_agent.dart';
import 'package:app_locale/app_locale.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/chat/chat_screen.dart';
import 'package:gsmlg/screens/home/home_screen.dart';

import 'agent_editor_screen.dart';
import 'widgets/agent_avatar.dart';
import 'widgets/conversation_list_tile.dart';

/// One agent's conversations, with a shortcut to start a new one.
class AgentSessionsScreen extends StatefulWidget {
  static const name = 'AgentSessions';
  static const path = 'agents/:agentId';

  const AgentSessionsScreen({required this.agentId, super.key});

  final String agentId;

  @override
  State<AgentSessionsScreen> createState() => _AgentSessionsScreenState();
}

class _AgentSessionsScreenState extends State<AgentSessionsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(const ChatLoadHistory());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final agent = context.select<ChatSettingsBloc, AgentDefinition?>(
      (bloc) => bloc.state.agents
          .where((agent) => agent.id == widget.agentId)
          .firstOrNull,
    );
    return AppAdaptiveScaffold(
      navigationRestoreInHeader: true,
      selectedIndex: Destinations.indexOf(const Key(HomeScreen.name), context),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => Scaffold(
        appBar: DmAppBar(
          restoreNavigation: true,
          title: Text(agent?.name ?? l10n.agentsSessionsTitle),
        ),
        body: agent == null
            ? Center(child: Text(l10n.agentsNotFound))
            : _buildBody(context, agent),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AgentDefinition agent) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (previous, current) =>
          previous.conversationHistory != current.conversationHistory,
      builder: (context, chat) {
        final sessions = chat.conversationHistory
            .where((conversation) => conversation.agentId == agent.id)
            .toList();
        return _buildList(context, agent, sessions);
      },
    );
  }

  Widget _buildList(
    BuildContext context,
    AgentDefinition agent,
    List<Conversation> sessions,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final description = agent.description;
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AgentAvatar(agent: agent, size: 64),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(agent.name, style: theme.textTheme.titleLarge),
                    if (description != null && description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          icon: const Icon(Icons.add_comment_outlined),
                          label: Text(l10n.agentsNewChat),
                          onPressed: () => _newChat(agent),
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(l10n.edit),
                          onPressed: () => context.goNamed(
                            AgentEditorScreen.name,
                            pathParameters: {'agentId': agent.id},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        if (sessions.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                l10n.agentsNoSessions,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          for (final conversation in sessions)
            ConversationListTile(
              key: ValueKey(conversation.id),
              conversation: conversation,
              onTap: () => _openConversation(conversation),
            ),
      ],
    );
  }

  void _newChat(AgentDefinition agent) {
    context.read<ChatBloc>().add(
      ChatNewConversation(
        systemPrompt: agent.instructions,
        config: agent.config,
        agentId: agent.id,
        thinkingEnabled: agent.thinkingEnabled,
      ),
    );
    context.goNamed(ChatScreen.name);
  }

  void _openConversation(Conversation conversation) {
    // ChatScreen loads the conversation from the link; selecting it here
    // would race its "nothing selected" start.
    context.goNamed(ChatScreen.name, queryParameters: {'id': conversation.id});
  }
}
