import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/home/home_screen.dart';

import 'widgets/chat_session_status.dart';

class ChatHistoryScreen extends StatefulWidget {
  static const name = 'ChatHistory';
  static const path = 'history';

  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  bool _runningOnly = false;
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(const ChatLoadHistory());
  }

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      navigationRestoreInHeader: true,
      selectedIndex: Destinations.indexOf(const Key(HomeScreen.name), context),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => Scaffold(
        appBar: DmAppBar(
          restoreNavigation: true,
          title: const Text('Chat History'),
          actions: [
            BlocSelector<ChatBloc, ChatState, int>(
              selector: (state) => state.runningCount,
              builder: (context, count) {
                if (count == 0 && !_runningOnly) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FilterChip(
                    selected: _runningOnly,
                    label: Text('Running $count'),
                    avatar: const Icon(Icons.play_circle_outline, size: 18),
                    onSelected: (value) => setState(() => _runningOnly = value),
                  ),
                );
              },
            ),
            BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state.conversationHistory.isEmpty) {
                  return const SizedBox.shrink();
                }
                return IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  tooltip: 'Delete All',
                  onPressed: () => _confirmDeleteAll(context),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<ChatBloc, ChatState>(
          buildWhen: (previous, current) =>
              previous.conversationHistory != current.conversationHistory ||
              previous.conversation?.id != current.conversation?.id ||
              previous.runningCount != current.runningCount ||
              previous.sessions.entries
                      .where((e) => e.value.status == ChatStatus.streaming)
                      .map((e) => e.key)
                      .join(',') !=
                  current.sessions.entries
                      .where((e) => e.value.status == ChatStatus.streaming)
                      .map((e) => e.key)
                      .join(','),
          builder: (context, state) {
            final history = state.conversationHistory
                .where(
                  (conversation) =>
                      !_runningOnly ||
                      state.sessionFor(conversation.id)?.status ==
                          ChatStatus.streaming,
                )
                .toList();
            if (_runningOnly && history.isEmpty) {
              return const Center(child: Text('No running conversations'));
            }
            if (history.isEmpty) {
              return _buildEmptyView(context);
            }

            return ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final conversation = history[index];
                return _ConversationTile(
                  key: ValueKey(conversation.id),
                  conversation: conversation,
                  isSelected: state.conversation?.id == conversation.id,
                  onTap: () {
                    context.read<ChatBloc>().add(
                      ChatLoadConversation(id: conversation.id),
                    );
                    context.pop();
                  },
                  onDelete: () => _confirmDelete(context, conversation),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a new chat to begin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Conversation conversation) {
    final session = context.read<ChatBloc>().state.sessionFor(conversation.id);
    final busy = session?.isBusy ?? false;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          busy ? 'Stop and Delete Conversation?' : 'Delete Conversation?',
        ),
        content: Text(
          'Are you sure you want to delete "${conversation.title}"? '
          '${busy ? 'Its pending response will be stopped. ' : ''}'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              context.read<ChatBloc>().add(
                ChatDeleteConversation(id: conversation.id),
              );
              Navigator.pop(dialogContext);
            },
            child: Text(busy ? 'Stop and Delete' : 'Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete All Conversations?'),
        content: const Text(
          'Are you sure you want to delete all conversations? '
          'Pending responses will be stopped. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              final history = context
                  .read<ChatBloc>()
                  .state
                  .conversationHistory;
              for (final conv in history) {
                context.read<ChatBloc>().add(
                  ChatDeleteConversation(id: conv.id),
                );
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    super.key,
    required this.conversation,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  final Conversation conversation;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat.MMMd().add_jm();
    final live = context.select<ChatBloc, ChatSessionState?>(
      (bloc) => bloc.state.sessionFor(conversation.id),
    );
    final draft = context.select<ChatBloc, ChatDraft?>(
      (bloc) => bloc.state.drafts[conversation.id],
    );
    final preview = live?.conversation ?? conversation;

    return ListTile(
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.5),
      leading: CircleAvatar(
        backgroundColor: isSelected
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.chat_bubble_outline,
          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
        ),
      ),
      title: Text(
        conversation.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChatSessionStatus(
            session: live,
            hasDraft:
                draft != null &&
                (draft.text.isNotEmpty || draft.attachments.isNotEmpty),
          ),
          if (preview.lastMessage != null)
            Text(
              preview.lastMessage!.content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          Text(
            dateFormat.format(conversation.updatedAt),
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Rename conversation',
            onPressed: () async {
              final bloc = context.read<ChatBloc>();
              var editedTitle = preview.title;
              final title = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Rename conversation'),
                  content: TextFormField(
                    initialValue: preview.title,
                    onChanged: (value) => editedTitle = value,
                    autofocus: true,
                    maxLength: 80,
                    onFieldSubmitted: (value) => Navigator.pop(context, value),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, editedTitle),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
              if (title != null && !bloc.isClosed) {
                bloc.add(
                  ChatRenameConversation(id: conversation.id, title: title),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
