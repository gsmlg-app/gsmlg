import 'package:app_agent/app_agent.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'chat_message_bubble.dart';

const chatMessageGap = 12.0;

class ChatMessageList extends StatefulWidget {
  const ChatMessageList({
    super.key,
    required this.messages,
    this.isStreaming = false,
    this.showThinking = false,
    this.onEditUserMessage,
    this.onRegenerateResponse,
    this.onForkConversation,
  });

  final List<Message> messages;
  final bool isStreaming;
  final bool showThinking;
  final ValueChanged<UserMessage>? onEditUserMessage;
  final void Function(AssistantMessage message)? onRegenerateResponse;
  final void Function(AssistantMessage message)? onForkConversation;

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  @override
  Widget build(BuildContext context) {
    final visibleMessages = _orderedVisibleMessages(widget.messages);
    final messagesById = {for (final m in visibleMessages) m.id: m};
    final theme =
        (Theme.of(context).extension<DmChatTheme>() ??
                DmChatTheme.withContext(context))
            .copyWith(
              rowSpacing: chatMessageGap,
              customBuilders: {chatTypingBlockKind: buildChatTypingBlock},
            );
    return DmChatView(
      messages: [
        for (var index = 0; index < visibleMessages.length; index++)
          toDmChatMessage(
            visibleMessages[index],
            showThinking: widget.showThinking,
            showTypingIndicator:
                index == visibleMessages.length - 1 &&
                widget.isStreaming &&
                visibleMessages[index] is AssistantMessage &&
                (visibleMessages[index] as AssistantMessage).isStreaming,
          ),
      ],
      footerBuilder: (context, dmMessage) {
        final message = messagesById[dmMessage.id];
        if (message == null) return null;
        return _ChatMessageActions(
          message: message,
          enabled: !widget.isStreaming,
          onCopy: () => _copyMessage(context, message),
          onEdit: message is UserMessage && widget.onEditUserMessage != null
              ? () => widget.onEditUserMessage?.call(message)
              : null,
          onRegenerate: message is AssistantMessage
              ? () => widget.onRegenerateResponse?.call(message)
              : null,
          onFork: message is AssistantMessage
              ? () => widget.onForkConversation?.call(message)
              : null,
        );
      },
      showInput: false,
      isStreaming: widget.isStreaming,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      emptyBuilder: (_) => const Text('No messages yet'),
      theme: theme,
    );
  }

  List<Message> _orderedVisibleMessages(List<Message> messages) {
    final visible = messages.where((m) => m is! SystemMessage).toList();
    final ordered = <Message>[];
    var index = 0;

    while (index < visible.length) {
      final message = visible[index];
      if (message is AssistantMessage) {
        final meta = AgentMessageMetadata.decode(message.agentMetadata);
        final hasToolCalls = meta?.toolCalls.isNotEmpty ?? false;
        final hasVisibleText = message.content.trim().isNotEmpty;
        final hasVisibleThinking =
            widget.showThinking &&
            (message.thinkingContent?.trim().isNotEmpty ?? false);

        // Pure tool-call carrier turns have no visible body; skip rendering an
        // empty assistant bubble while keeping their ToolResponseMessages.
        if (hasToolCalls &&
            !message.isStreaming &&
            !hasVisibleText &&
            !hasVisibleThinking) {
          index++;
          continue;
        }

        // Preserve tool-call turns in chronological order before their results.
        if (hasToolCalls) {
          ordered.add(message);
          index++;
          continue;
        }

        // Legacy conversations persisted tool responses after the final
        // assistant reply; keep displaying those tool cards above the answer.
        final toolResponses = <ToolResponseMessage>[];
        var nextIndex = index + 1;
        while (nextIndex < visible.length &&
            visible[nextIndex] is ToolResponseMessage) {
          toolResponses.add(visible[nextIndex] as ToolResponseMessage);
          nextIndex++;
        }
        ordered
          ..addAll(toolResponses)
          ..add(message);
        index = nextIndex;
      } else {
        ordered.add(message);
        index++;
      }
    }

    return ordered;
  }

  Future<void> _copyMessage(BuildContext context, Message message) async {
    await Clipboard.setData(ClipboardData(text: message.content));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied message')));
  }
}

class _ChatMessageActions extends StatelessWidget {
  const _ChatMessageActions({
    required this.message,
    required this.enabled,
    required this.onCopy,
    this.onEdit,
    this.onRegenerate,
    this.onFork,
  });

  final Message message;
  final bool enabled;
  final VoidCallback onCopy;
  final VoidCallback? onEdit;
  final VoidCallback? onRegenerate;
  final VoidCallback? onFork;

  @override
  Widget build(BuildContext context) {
    final isUser = message is UserMessage;
    final assistant = message is AssistantMessage
        ? message as AssistantMessage
        : null;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2,
        children: [
          IconButton(
            icon: const Icon(Icons.copy),
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            tooltip: 'Copy message',
            onPressed: onCopy,
          ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit),
              iconSize: 18,
              visualDensity: VisualDensity.compact,
              tooltip: 'Edit message',
              onPressed: enabled ? onEdit : null,
            ),
          if (onRegenerate != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              iconSize: 18,
              visualDensity: VisualDensity.compact,
              tooltip: 'Regenerate response',
              onPressed: enabled ? onRegenerate : null,
            ),
          if (onFork != null)
            IconButton(
              icon: const Icon(Icons.call_split),
              iconSize: 18,
              visualDensity: VisualDensity.compact,
              tooltip: 'Fork conversation',
              onPressed: enabled ? onFork : null,
            ),
          if (assistant != null && assistant.isStreaming)
            _LiveResponseSpeedChip(message: assistant),
          if (assistant != null) _ResponseInfoButton(message: assistant),
        ],
      ),
    );
  }
}

class _LiveResponseSpeedChip extends StatelessWidget {
  const _LiveResponseSpeedChip({required this.message});

  final AssistantMessage message;

  @override
  Widget build(BuildContext context) {
    final speed = message.responseInfo?.tokensPerSecond ?? 0;
    final label = '${speed.toStringAsFixed(1)} t/s';
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Tooltip(
      message: 'Live response speed',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.speed, size: 14, color: colorScheme.onTertiaryContainer),
            const SizedBox(width: 4),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onTertiaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResponseInfoButton extends StatelessWidget {
  const _ResponseInfoButton({required this.message});

  final AssistantMessage message;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      tooltip: 'Response info',
      icon: const Icon(Icons.info_outline),
      iconSize: 18,
      itemBuilder: (context) => [
        PopupMenuItem<void>(
          enabled: false,
          child: _ResponseInfoPanel(message: message),
        ),
      ],
    );
  }
}

class _ResponseInfoPanel extends StatelessWidget {
  const _ResponseInfoPanel({required this.message});

  final AssistantMessage message;

  @override
  Widget build(BuildContext context) {
    final info = message.responseInfo;
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: 240,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Response info', style: textTheme.titleSmall),
          const SizedBox(height: 8),
          if (info == null)
            const Text('Response info unavailable')
          else ...[
            _ResponseInfoRow(
              label: 'Speed',
              value: '${info.tokensPerSecond.toStringAsFixed(1)} t/s',
            ),
            _ResponseInfoRow(
              label: 'TTFT',
              value: info.timeToFirstToken == null
                  ? '—'
                  : _formatDuration(info.timeToFirstToken!),
            ),
            _ResponseInfoRow(
              label: 'Context size',
              value: _formatTokenCount(info.contextTokens),
            ),
            _ResponseInfoRow(
              label: 'Output tokens',
              value: _formatTokenCount(info.outputTokens),
            ),
            if (info.maxOutputTokens != null)
              _ResponseInfoRow(
                label: 'Max output',
                value: _formatTokenCount(info.maxOutputTokens),
              ),
            _ResponseInfoRow(
              label: 'Duration',
              value: _formatDuration(info.duration),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResponseInfoRow extends StatelessWidget {
  const _ResponseInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodySmall),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatTokenCount(int? tokens) {
  if (tokens == null) return 'Unknown';
  return '$tokens tokens';
}

String _formatDuration(Duration duration) {
  final milliseconds = duration.inMilliseconds;
  if (milliseconds < 1000) return '${milliseconds}ms';
  return '${(milliseconds / 1000).toStringAsFixed(1)}s';
}
