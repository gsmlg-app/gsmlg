import 'dart:convert';

import 'package:app_chat/app_chat.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    this.showTypingIndicator = false,
    this.showThinking = false,
  });

  final Message message;
  final bool showTypingIndicator;
  final bool showThinking;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _copyToClipboard(context),
      child: DmChatBubble(message: _toDmMessage(), avatar: _avatar(context)),
    );
  }

  DmChatMessage _toDmMessage() {
    return DmChatMessage(
      id: message.id,
      role: _role(),
      blocks: _blocks(),
      status: _status(),
      createdAt: message.timestamp,
    );
  }

  DmChatRole _role() {
    return switch (message) {
      UserMessage() => DmChatRole.user,
      AssistantMessage() => DmChatRole.assistant,
      ToolResponseMessage() => DmChatRole.assistant,
      SystemMessage() => DmChatRole.system,
    };
  }

  DmChatMessageStatus _status() {
    return switch (message) {
      AssistantMessage(:final isStreaming) when isStreaming =>
        DmChatMessageStatus.streaming,
      _ => DmChatMessageStatus.complete,
    };
  }

  List<DmChatBlock> _blocks() {
    final blocks = <DmChatBlock>[];

    switch (message) {
      case UserMessage(:final imageBytes, :final audioBytes):
        final attachments = <DmChatAttachment>[];
        if (imageBytes != null) {
          attachments.add(
            DmChatAttachment(
              id: '${message.id}:image',
              name: 'image.png',
              sizeBytes: imageBytes.length,
              mimeType: 'image/png',
              bytes: imageBytes,
              status: DmChatAttachmentStatus.done,
            ),
          );
        }
        if (audioBytes != null) {
          attachments.add(
            DmChatAttachment(
              id: '${message.id}:audio',
              name: 'audio.wav',
              sizeBytes: audioBytes.length,
              mimeType: 'audio/wav',
              bytes: audioBytes,
              status: DmChatAttachmentStatus.done,
            ),
          );
        }
        if (attachments.isNotEmpty) {
          blocks.add(DmChatAttachmentBlock(attachments: attachments));
        }
        if (message.content.isNotEmpty) {
          blocks.add(DmChatTextBlock(text: message.content));
        }
      case AssistantMessage(:final thinkingContent):
        if (showThinking &&
            thinkingContent != null &&
            thinkingContent.isNotEmpty) {
          blocks.add(DmChatThinkingBlock(text: thinkingContent));
        }
        if (message.content.isNotEmpty) {
          blocks.add(DmChatTextBlock(text: message.content));
        } else if (showTypingIndicator) {
          blocks.add(const DmChatTextBlock(text: '...'));
        }
      case ToolResponseMessage(:final toolName):
        blocks.add(
          DmChatToolCallBlock(
            id: message.id,
            name: toolName,
            output: _tryParseJson(message.content),
            status: DmChatToolCallStatus.done,
          ),
        );
      case SystemMessage():
        blocks.add(DmChatTextBlock(text: message.content));
    }

    if (blocks.isEmpty) {
      blocks.add(const DmChatTextBlock(text: ''));
    }
    return blocks;
  }

  Object _tryParseJson(String content) {
    try {
      return jsonDecode(content) as Object;
    } catch (_) {
      return content;
    }
  }

  Widget? _avatar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (message) {
      UserMessage() => CircleAvatar(
        radius: 16,
        backgroundColor: colorScheme.secondaryContainer,
        child: Icon(
          Icons.person,
          size: 18,
          color: colorScheme.onSecondaryContainer,
        ),
      ),
      AssistantMessage() || ToolResponseMessage() => CircleAvatar(
        radius: 16,
        backgroundColor: colorScheme.primaryContainer,
        child: Icon(
          Icons.smart_toy,
          size: 18,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
      SystemMessage() => null,
    };
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
