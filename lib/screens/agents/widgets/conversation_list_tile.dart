import 'package:app_agent/app_agent.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gsmlg/screens/chat/widgets/chat_session_status.dart';
import 'package:intl/intl.dart';

/// A conversation row: title, live session status and last update time.
class ConversationListTile extends StatelessWidget {
  const ConversationListTile({
    required this.conversation,
    required this.onTap,
    super.key,
  });

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final live = context.select<ChatBloc, ChatSessionState?>(
      (bloc) => bloc.state.sessionFor(conversation.id),
    );
    final title = live?.conversation.title ?? conversation.title;
    return ListTile(
      leading: const Icon(Icons.chat_bubble_outline),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (live != null) ChatSessionStatus(session: live),
          Text(
            DateFormat.MMMd().add_jm().format(conversation.updatedAt),
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
