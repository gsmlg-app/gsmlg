import 'dart:convert';

import 'package:app_chat/app_chat.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart' show DmMarkdown, DmMarkdownConfig;
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
    // WORKAROUND(upstream): duskmoon-dev/flutter-duskmoon-ui#10
    // DmChatBubble notifies BubbleStreamScope from didUpdateWidget while
    // Flutter is already building. Keep this widget on plain Flutter widgets
    // until the upstream bubble can defer those stream-scope notifications.
    return GestureDetector(
      onLongPress: () => _copyToClipboard(context),
      child: _ChatBubbleFrame(
        role: _bubbleRole(),
        avatar: _avatar(context),
        child: _body(context),
      ),
    );
  }

  _BubbleRole _bubbleRole() {
    return switch (message) {
      UserMessage() => _BubbleRole.user,
      AssistantMessage() => _BubbleRole.assistant,
      ToolResponseMessage() => _BubbleRole.assistant,
      SystemMessage() => _BubbleRole.system,
    };
  }

  Widget _body(BuildContext context) {
    return switch (message) {
      final UserMessage user => _userBody(context, user),
      final AssistantMessage assistant => _assistantBody(context, assistant),
      final ToolResponseMessage tool => _toolBody(tool),
      final SystemMessage system => _MarkdownText(data: system.content),
    };
  }

  Widget _userBody(BuildContext context, UserMessage user) {
    final attachments = _displayAttachments(user);
    final children = <Widget>[
      if (attachments.isNotEmpty) _AttachmentList(attachments: attachments),
      if (user.content.isNotEmpty) _MarkdownText(data: user.content),
    ];

    if (children.isEmpty) return const SizedBox.shrink();
    return _SpacedColumn(children: children);
  }

  Widget _assistantBody(BuildContext context, AssistantMessage assistant) {
    final taggedContent = _splitTaggedThinking(assistant.content);
    final thinkingText = _joinThinking(
      assistant.thinkingContent,
      taggedContent.thinkingContent,
    );
    final visibleContent = _stripToolExecutionMarkers(
      taggedContent.visibleContent,
    ).trim();
    final children = <Widget>[
      if (showThinking &&
          thinkingText != null &&
          thinkingText.trim().isNotEmpty)
        _ThinkingBlock(text: thinkingText.trim()),
      if (visibleContent.isNotEmpty)
        _MarkdownText(data: visibleContent)
      else if (showTypingIndicator)
        const _TypingDots(key: ValueKey('chat.typing_dots')),
    ];

    if (children.isEmpty) return const SizedBox.shrink();
    return _SpacedColumn(children: children);
  }

  Widget _toolBody(ToolResponseMessage tool) {
    return _ToolCallBlock(
      toolName: tool.toolName,
      output: _formatToolOutput(tool.content),
    );
  }

  List<_DisplayAttachment> _displayAttachments(UserMessage user) {
    final attachments = <_DisplayAttachment>[
      for (final attachment in user.attachments)
        _DisplayAttachment.fromChatAttachment(attachment),
    ];

    final imageBytes = user.imageBytes;
    if (imageBytes != null) {
      final alreadyShown = user.attachments.any(
        (attachment) =>
            attachment.isImage || identical(attachment.bytes, imageBytes),
      );
      if (!alreadyShown) {
        attachments.add(
          _DisplayAttachment(
            name: 'image.png',
            mimeType: 'image/png',
            sizeBytes: imageBytes.length,
            isImage: true,
          ),
        );
      }
    }

    final audioBytes = user.audioBytes;
    if (audioBytes != null) {
      final alreadyShown = user.attachments.any(
        (attachment) =>
            attachment.isAudio || identical(attachment.bytes, audioBytes),
      );
      if (!alreadyShown) {
        attachments.add(
          _DisplayAttachment(
            name: 'audio.wav',
            mimeType: 'audio/wav',
            sizeBytes: audioBytes.length,
            isAudio: true,
          ),
        );
      }
    }

    return attachments;
  }

  String _formatToolOutput(String content) {
    final parsed = _tryParseJson(content);
    if (parsed is String) return parsed;
    return const JsonEncoder.withIndent('  ').convert(parsed);
  }

  Object? _tryParseJson(String content) {
    try {
      return jsonDecode(content);
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

  String _stripToolExecutionMarkers(String content) {
    final marker = RegExp(r'^\s*>\s*\*\*[^*]+\*\*\s+executed\s*$');
    return content
        .split('\n')
        .where((line) => !marker.hasMatch(line))
        .join('\n');
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

enum _BubbleRole { user, assistant, system }

class _MarkdownText extends StatelessWidget {
  const _MarkdownText({required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    final defaultColor = DefaultTextStyle.of(context).style.color;
    final theme = Theme.of(context);
    final markdownTheme = defaultColor == null
        ? theme
        : theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              onSurface: defaultColor,
              onSurfaceVariant: defaultColor.withValues(alpha: 0.78),
            ),
            textTheme: theme.textTheme.apply(
              bodyColor: defaultColor,
              displayColor: defaultColor,
            ),
          );

    return DmMarkdown(
      data: data,
      config: const DmMarkdownConfig(),
      selectable: true,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      themeData: markdownTheme,
    );
  }
}

class _ToolCallBlock extends StatefulWidget {
  const _ToolCallBlock({required this.toolName, required this.output});

  final String toolName;
  final String output;

  @override
  State<_ToolCallBlock> createState() => _ToolCallBlockState();
}

class _ToolCallBlockState extends State<_ToolCallBlock> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      key: ValueKey('chat.tool_call.${widget.toolName}'),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: colorScheme.onSurfaceVariant),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              key: ValueKey('chat.tool_call.toggle.${widget.toolName}'),
              borderRadius: BorderRadius.circular(10),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.build_circle_outlined,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.toolName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded) ...[
              Divider(height: 1, color: colorScheme.outlineVariant),
              Padding(
                padding: const EdgeInsets.all(12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(10),
                    child: SelectableText(
                      widget.output,
                      key: ValueKey('chat.tool_call.output.${widget.toolName}'),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChatBubbleFrame extends StatelessWidget {
  const _ChatBubbleFrame({
    required this.role,
    required this.child,
    this.avatar,
  });

  final _BubbleRole role;
  final Widget child;
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return switch (role) {
      _BubbleRole.user => LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth * 0.82
              : 560.0;
          return Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                      child: DefaultTextStyle.merge(
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                        ),
                        child: child,
                      ),
                    ),
                  ),
                  if (avatar != null) ...[const SizedBox(width: 8), avatar!],
                ],
              ),
            ),
          );
        },
      ),
      _BubbleRole.assistant => LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth * 0.88
              : 640.0;
          return Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (avatar != null) ...[avatar!, const SizedBox(width: 10)],
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: DefaultTextStyle.merge(
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      _BubbleRole.system => Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DefaultTextStyle.merge(
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              child: child,
            ),
          ),
        ),
      ),
    };
  }
}

class _SpacedColumn extends StatelessWidget {
  const _SpacedColumn({required this.children, this.spacing = 10});

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) SizedBox(height: spacing),
          children[index],
        ],
      ],
    );
  }
}

class _ThinkingBlock extends StatelessWidget {
  const _ThinkingBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: colorScheme.onSurfaceVariant),
        child: _SpacedColumn(
          spacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.psychology_outlined,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'Thinking',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Text(text),
          ],
        ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots({super.key});

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    final color =
        DefaultTextStyle.of(context).style.color ??
        Theme.of(context).colorScheme.onSurface;

    if (mediaQuery?.disableAnimations ?? false) {
      return Semantics(
        label: 'Generating response',
        child: _TypingDotsRow(color: color),
      );
    }

    return Semantics(
      label: 'Generating response',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return _TypingDotsRow(color: color, progress: _controller.value);
        },
      ),
    );
  }
}

class _TypingDotsRow extends StatelessWidget {
  const _TypingDotsRow({required this.color, this.progress = 0});

  final Color color;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < 3; index++) ...[
            if (index > 0) const SizedBox(width: 5),
            _TypingDot(color: color, pulse: _pulseFor(index)),
          ],
        ],
      ),
    );
  }

  double _pulseFor(int index) {
    final phase = (progress + index * 0.18) % 1.0;
    final triangle = 1 - ((phase - 0.5).abs() * 2);
    return Curves.easeInOut.transform(triangle.clamp(0, 1).toDouble());
  }
}

class _TypingDot extends StatelessWidget {
  const _TypingDot({required this.color, required this.pulse});

  final Color color;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -3 * pulse),
      child: Transform.scale(
        scale: 0.82 + pulse * 0.22,
        child: Opacity(
          opacity: 0.35 + pulse * 0.65,
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

class _AttachmentList extends StatelessWidget {
  const _AttachmentList({required this.attachments});

  final List<_DisplayAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    return _SpacedColumn(
      spacing: 6,
      children: [
        for (final attachment in attachments)
          _AttachmentRow(attachment: attachment),
      ],
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  const _AttachmentRow({required this.attachment});

  final _DisplayAttachment attachment;

  @override
  Widget build(BuildContext context) {
    final color = DefaultTextStyle.of(context).style.color;
    final detail = [
      if (attachment.mimeType != null) attachment.mimeType!,
      if (attachment.sizeBytes != null) _formatBytes(attachment.sizeBytes!),
    ].join(' · ');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(attachment.icon, size: 16, color: color?.withValues(alpha: 0.78)),
        const SizedBox(width: 6),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                attachment.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (detail.isNotEmpty)
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color?.withValues(alpha: 0.72),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(bytes < 10 * 1024 ? 1 : 0)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _DisplayAttachment {
  const _DisplayAttachment({
    required this.name,
    this.mimeType,
    this.sizeBytes,
    this.isImage = false,
    this.isAudio = false,
  });

  factory _DisplayAttachment.fromChatAttachment(ChatAttachment attachment) {
    return _DisplayAttachment(
      name: attachment.name,
      mimeType: attachment.mimeType,
      sizeBytes: attachment.sizeBytes ?? attachment.bytes?.length,
      isImage: attachment.isImage,
      isAudio: attachment.isAudio,
    );
  }

  final String name;
  final String? mimeType;
  final int? sizeBytes;
  final bool isImage;
  final bool isAudio;

  IconData get icon {
    if (isImage || mimeType?.startsWith('image/') == true) {
      return Icons.image_outlined;
    }
    if (isAudio || mimeType?.startsWith('audio/') == true) {
      return Icons.graphic_eq;
    }
    return Icons.attach_file;
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
