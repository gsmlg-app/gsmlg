import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_agent/app_agent.dart';
import 'package:app_locale/app_locale.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/chat/chat_history_screen.dart';
import 'package:gsmlg/screens/chat/chat_screen.dart';
import 'package:gsmlg/screens/home/home_screen.dart';

import 'agent_editor_screen.dart';
import 'agent_sessions_screen.dart';
import 'widgets/agent_avatar.dart';
import 'widgets/conversation_list_tile.dart';

/// Landing page of the chat tab: the user's agents as cards, plus chats that
/// do not belong to any existing agent.
class AgentsScreen extends StatefulWidget {
  static const name = 'Agents';
  static const path = '/chat';

  const AgentsScreen({super.key});

  @override
  State<AgentsScreen> createState() => _AgentsScreenState();
}

class _AgentsScreenState extends State<AgentsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChatSettingsBloc>().add(const ChatSettingsLoad());
    context.read<ChatBloc>().add(const ChatLoadHistory());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppAdaptiveScaffold(
      navigationRestoreInHeader: true,
      selectedIndex: Destinations.indexOf(const Key(HomeScreen.name), context),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => Scaffold(
        appBar: DmAppBar(
          restoreNavigation: true,
          title: Text(l10n.agentsTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: l10n.agentsHistory,
              onPressed: () => context.goNamed(ChatHistoryScreen.name),
            ),
          ],
        ),
        body: BlocBuilder<ChatSettingsBloc, ChatSettingsState>(
          buildWhen: (previous, current) => previous.agents != current.agents,
          builder: (context, settings) {
            final agentIds = {for (final agent in settings.agents) agent.id};
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 260,
                          mainAxisExtent: 180,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    delegate: SliverChildListDelegate([
                      for (final agent in settings.agents)
                        _AgentCard(
                          key: ValueKey('agent-card-${agent.id}'),
                          agent: agent,
                        ),
                      const _NewAgentCard(),
                    ]),
                  ),
                ),
                BlocBuilder<ChatBloc, ChatState>(
                  buildWhen: (previous, current) =>
                      previous.conversationHistory !=
                      current.conversationHistory,
                  builder: (context, chat) {
                    final others = chat.conversationHistory
                        .where(
                          (conversation) =>
                              !agentIds.contains(conversation.agentId),
                        )
                        .toList();
                    return SliverList.list(
                      children: [
                        if (others.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                            child: Text(
                              l10n.agentsOtherChats,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        for (final conversation in others)
                          ConversationListTile(
                            key: ValueKey(conversation.id),
                            conversation: conversation,
                            onTap: () => _openConversation(conversation),
                          ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openConversation(Conversation conversation) {
    context.read<ChatBloc>().add(ChatLoadConversation(id: conversation.id));
    context.goNamed(ChatScreen.name);
  }
}

class _AgentCard extends StatelessWidget {
  const _AgentCard({required this.agent, super.key});

  final AgentDefinition agent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final description = agent.description;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.goNamed(
          AgentSessionsScreen.name,
          pathParameters: {'agentId': agent.id},
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 4, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: AgentAvatar(agent: agent, size: 48),
                  ),
                  const Spacer(),
                  PopupMenuButton<_AgentAction>(
                    icon: const Icon(Icons.more_vert),
                    tooltip: l10n.agentsMore,
                    onSelected: (action) => switch (action) {
                      _AgentAction.edit => context.goNamed(
                        AgentEditorScreen.name,
                        pathParameters: {'agentId': agent.id},
                      ),
                      _AgentAction.delete => _confirmDelete(context),
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: _AgentAction.edit,
                        child: Text(l10n.edit),
                      ),
                      PopupMenuItem(
                        value: _AgentAction.delete,
                        child: Text(l10n.delete),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                agent.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              if (description != null && description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.agentsDeleteTitle),
        content: Text(l10n.agentsDeleteMessage(agent.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              context.read<ChatSettingsBloc>().add(
                ChatSettingsDeleteAgent(id: agent.id),
              );
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

enum _AgentAction { edit, delete }

class _NewAgentCard extends StatelessWidget {
  const _NewAgentCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surfaceContainerLow,
      child: InkWell(
        onTap: () => context.goNamed(AgentEditorScreen.createName),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 40,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.agentsNewAgent,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
