import 'package:app_chat/app_chat.dart';
import 'package:flutter/material.dart';

import 'chat_message_bubble.dart';

class ChatMessageList extends StatefulWidget {
  const ChatMessageList({
    super.key,
    required this.messages,
    this.isStreaming = false,
    this.showThinking = false,
  });

  final List<Message> messages;
  final bool isStreaming;
  final bool showThinking;

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(ChatMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-scroll to bottom when new messages arrive
    if (widget.messages.length != oldWidget.messages.length ||
        widget.isStreaming) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter out system messages from display
    final visibleMessages = widget.messages
        .where((m) => m is! SystemMessage)
        .toList();

    if (visibleMessages.isEmpty) {
      return const Center(
        child: Text('No messages yet'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: visibleMessages.length,
      itemBuilder: (context, index) {
        final message = visibleMessages[index];
        final isLast = index == visibleMessages.length - 1;
        final showTypingIndicator = isLast &&
            widget.isStreaming &&
            message is AssistantMessage &&
            message.isStreaming;

        return ChatMessageBubble(
          message: message,
          showTypingIndicator: showTypingIndicator && message.content.isEmpty,
          showThinking: widget.showThinking,
        );
      },
    );
  }
}
