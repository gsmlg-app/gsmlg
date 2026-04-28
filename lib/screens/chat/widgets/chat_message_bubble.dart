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
      case UserMessage(
        :final imageBytes,
        :final audioBytes,
        :final attachments,
      ):
        final dmAttachments = <DmChatAttachment>[
          for (final attachment in attachments) _toDmAttachment(attachment),
        ];
        if (imageBytes != null) {
          final alreadyShown = attachments.any(
            (attachment) =>
                attachment.isImage || identical(attachment.bytes, imageBytes),
          );
          if (!alreadyShown) {
            dmAttachments.add(
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
        }
        if (audioBytes != null) {
          final alreadyShown = attachments.any(
            (attachment) =>
                attachment.isAudio || identical(attachment.bytes, audioBytes),
          );
          if (!alreadyShown) {
            dmAttachments.add(
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
        }
        if (dmAttachments.isNotEmpty) {
          blocks.add(DmChatAttachmentBlock(attachments: dmAttachments));
        }
        if (message.content.isNotEmpty) {
          blocks.add(DmChatTextBlock(text: message.content));
        }
      case AssistantMessage(:final thinkingContent):
        final taggedContent = _splitTaggedThinking(message.content);
        final thinkingText = _joinThinking(
          thinkingContent,
          taggedContent.thinkingContent,
        );
        if (showThinking && thinkingText != null && thinkingText.isNotEmpty) {
          blocks.add(DmChatThinkingBlock(text: thinkingText));
        }
        if (taggedContent.visibleContent.isNotEmpty) {
          blocks.add(DmChatTextBlock(text: taggedContent.visibleContent));
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

  DmChatAttachment _toDmAttachment(ChatAttachment attachment) {
    return DmChatAttachment(
      id: attachment.id,
      name: attachment.name,
      sizeBytes: attachment.sizeBytes ?? attachment.bytes?.length,
      mimeType: attachment.mimeType,
      bytes: attachment.bytes,
      status: DmChatAttachmentStatus.done,
    );
  }

  Object _tryParseJson(String content) {
    try {
      return jsonDecode(content) as Object;
    } catch (_) {
      return content;
    }
  }

  _TaggedThinkingContent _splitTaggedThinking(String content) {
    const startTag = '<think>';
    const endTag = '</think>';
    if (!content.contains(startTag)) {
      return _TaggedThinkingContent(visibleContent: content);
    }

    final visible = StringBuffer();
    final thinking = StringBuffer();
    var index = 0;

    while (index < content.length) {
      final startIndex = content.indexOf(startTag, index);
      if (startIndex == -1) {
        visible.write(content.substring(index));
        break;
      }

      visible.write(content.substring(index, startIndex));
      final thinkingStart = startIndex + startTag.length;
      final endIndex = content.indexOf(endTag, thinkingStart);
      if (endIndex == -1) {
        _writeThinkingPart(thinking, content.substring(thinkingStart));
        break;
      }

      _writeThinkingPart(thinking, content.substring(thinkingStart, endIndex));
      index = endIndex + endTag.length;
    }

    return _TaggedThinkingContent(
      visibleContent: visible.toString(),
      thinkingContent: thinking.toString(),
    );
  }

  void _writeThinkingPart(StringBuffer buffer, String text) {
    if (text.isEmpty) return;
    if (buffer.isNotEmpty) buffer.write('\n');
    buffer.write(text);
  }

  String? _joinThinking(String? structured, String? tagged) {
    final parts = [
      if (structured != null && structured.isNotEmpty) structured,
      if (tagged != null && tagged.isNotEmpty) tagged,
    ];
    if (parts.isEmpty) return null;
    return parts.join('\n');
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

class _TaggedThinkingContent {
  const _TaggedThinkingContent({
    required this.visibleContent,
    this.thinkingContent,
  });

  final String visibleContent;
  final String? thinkingContent;
}
