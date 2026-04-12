import 'package:app_chat/app_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatMessageBubble extends StatefulWidget {
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
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble> {
  bool _thinkingExpanded = false;

  Message get message => widget.message;
  bool get isUser => message is UserMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                Icons.smart_toy,
                size: 18,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () => _copyToClipboard(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isUser
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 16),
                  ),
                ),
                child: widget.showTypingIndicator
                    ? _buildTypingIndicator(context)
                    : _buildMessageContent(context),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.secondaryContainer,
              child: Icon(
                Icons.person,
                size: 18,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor =
        isUser ? colorScheme.onPrimary : colorScheme.onSurface;

    // Tool response messages
    if (message is ToolResponseMessage) {
      final toolMsg = message as ToolResponseMessage;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.build, size: 14, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                toolMsg.toolName,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            toolMsg.content,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
            maxLines: 8,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    if (isUser) {
      final userMsg = message as UserMessage;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (userMsg.hasImage)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  userMsg.imageBytes!,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (userMsg.hasAudio)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic, size: 16, color: textColor.withAlpha(180)),
                  const SizedBox(width: 4),
                  Text(
                    'Audio attached',
                    style: TextStyle(
                      color: textColor.withAlpha(180),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          if (message.content.isNotEmpty)
            Text(
              message.content,
              style: TextStyle(color: textColor, fontSize: 16, height: 1.4),
            ),
        ],
      );
    }

    // Assistant messages — optionally show thinking section
    final assistantMsg = message as AssistantMessage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showThinking && assistantMsg.hasThinking)
          _buildThinkingSection(context, assistantMsg),
        if (message.content.isNotEmpty) _buildAssistantMarkdown(context),
      ],
    );
  }

  Widget _buildThinkingSection(
      BuildContext context, AssistantMessage assistantMsg) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => setState(() => _thinkingExpanded = !_thinkingExpanded),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology,
                      size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    assistantMsg.isStreaming &&
                            assistantMsg.content.isEmpty
                        ? 'Thinking...'
                        : 'Thinking',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _thinkingExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              if (_thinkingExpanded) ...[
                const SizedBox(height: 6),
                Text(
                  assistantMsg.thinkingContent!,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssistantMarkdown(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;
    return MarkdownBody(
      data: message.content,
      selectable: true,
      onTapLink: (text, href, title) {
        if (href != null) {
          launchUrl(Uri.parse(href));
        }
      },
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(color: textColor, fontSize: 16, height: 1.4),
        h1: TextStyle(
          color: textColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
        h2: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
        h3: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
        code: TextStyle(
          color: textColor,
          backgroundColor: colorScheme.surfaceContainerHigh,
          fontFamily: 'monospace',
          fontSize: 14,
        ),
        codeblockDecoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        codeblockPadding: const EdgeInsets.all(12),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: colorScheme.primary,
              width: 3,
            ),
          ),
        ),
        blockquotePadding: const EdgeInsets.only(left: 12),
        listBullet: TextStyle(color: textColor, fontSize: 16),
        a: TextStyle(
          color: colorScheme.primary,
          decoration: TextDecoration.underline,
        ),
        strong: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        em: TextStyle(
          color: textColor,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TypingDot(delay: 0),
        SizedBox(width: 4),
        _TypingDot(delay: 200),
        SizedBox(width: 4),
        _TypingDot(delay: 400),
      ],
    );
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

class _TypingDot extends StatefulWidget {
  const _TypingDot({required this.delay});

  final int delay;

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: 0.3 + (_animation.value * 0.7),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
