import 'dart:convert';

import 'package:app_chat/app_chat.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';

const chatTypingBlockKind = 'gsmlg.typing';

/// Preserves app message semantics while letting Duskmoon render native blocks.
DmChatMessage toDmChatMessage(
  Message message, {
  bool showThinking = false,
  bool showTypingIndicator = false,
  DmChatCustomBlock? actions,
}) {
  final blocks = <DmChatBlock>[];
  switch (message) {
    case final UserMessage user:
      final attachments = _attachments(user);
      if (attachments.isNotEmpty) {
        blocks.add(DmChatAttachmentBlock(attachments: attachments));
      }
      if (user.content.isNotEmpty) {
        blocks.add(DmChatTextBlock(text: user.content));
      }
    case final AssistantMessage assistant:
      final content = _splitTaggedThinking(assistant.content);
      final thinking = [
        if (assistant.thinkingContent?.trim().isNotEmpty ?? false)
          assistant.thinkingContent!.trim(),
        if (content.thinkingContent?.trim().isNotEmpty ?? false)
          content.thinkingContent!.trim(),
      ].join('\n');
      if (showThinking && thinking.isNotEmpty) {
        blocks.add(DmChatThinkingBlock(text: thinking));
      }
      final marker = RegExp(r'^\s*>\s*\*\*[^*]+\*\*\s+executed\s*$');
      final visible = content.visibleContent
          .split('\n')
          .where((line) => !marker.hasMatch(line))
          .join('\n')
          .trim();
      if (visible.isNotEmpty) {
        blocks.add(DmChatTextBlock(text: visible));
      } else if (showTypingIndicator) {
        blocks.add(const DmChatCustomBlock(kind: chatTypingBlockKind));
      }
    case final ToolResponseMessage tool:
      Object? output;
      try {
        output = jsonDecode(tool.content);
      } on FormatException {
        output = tool.content;
      }
      final text = output is String
          ? output
          : const JsonEncoder.withIndent('  ').convert(output);
      final longestBackticks = RegExp(r'`+')
          .allMatches(text)
          .fold<int>(
            2,
            (longest, match) => match.group(0)!.length > longest
                ? match.group(0)!.length
                : longest,
          );
      final fence = List.filled(longestBackticks + 1, '`').join();
      blocks.add(
        DmChatToolCallBlock(
          id: tool.id,
          name: tool.toolName,
          output: '$fence${output is String ? 'text' : 'json'}\n$text\n$fence',
          status: DmChatToolCallStatus.done,
        ),
      );
    case final SystemMessage system:
      blocks.add(DmChatTextBlock(text: system.content));
  }
  if (actions != null) blocks.add(actions);
  return DmChatMessage(
    id: message.id,
    role: switch (message) {
      UserMessage() => DmChatRole.user,
      SystemMessage() => DmChatRole.system,
      _ => DmChatRole.assistant,
    },
    blocks: blocks,
    createdAt: message.timestamp,
    status: message is AssistantMessage && message.isStreaming
        ? DmChatMessageStatus.streaming
        : DmChatMessageStatus.complete,
  );
}

Widget buildChatTypingBlock(BuildContext context, DmChatCustomBlock block) =>
    const _TypingDots(key: ValueKey('chat.typing_dots'));

List<DmChatAttachment> _attachments(UserMessage user) {
  final attachments = [
    for (final attachment in user.attachments)
      DmChatAttachment(
        id: attachment.id,
        name: attachment.name,
        mimeType: attachment.mimeType,
        sizeBytes: attachment.sizeBytes ?? attachment.bytes?.length,
        bytes: attachment.bytes,
        status: DmChatAttachmentStatus.done,
      ),
  ];
  final image = user.imageBytes;
  if (image != null &&
      !user.attachments.any(
        (attachment) =>
            attachment.isImage || identical(attachment.bytes, image),
      )) {
    attachments.add(
      DmChatAttachment(
        id: '${user.id}-image',
        name: 'image.png',
        mimeType: 'image/png',
        sizeBytes: image.length,
        bytes: image,
        status: DmChatAttachmentStatus.done,
      ),
    );
  }
  final audio = user.audioBytes;
  if (audio != null &&
      !user.attachments.any(
        (attachment) =>
            attachment.isAudio || identical(attachment.bytes, audio),
      )) {
    attachments.add(
      DmChatAttachment(
        id: '${user.id}-audio',
        name: 'audio.wav',
        mimeType: 'audio/wav',
        sizeBytes: audio.length,
        bytes: audio,
        status: DmChatAttachmentStatus.done,
      ),
    );
  }
  return attachments;
}

({String visibleContent, String? thinkingContent}) _splitTaggedThinking(
  String content,
) {
  const startTag = '<think>';
  const endTag = '</think>';
  final visible = StringBuffer();
  final thinking = <String>[];
  var index = 0;
  while (index < content.length) {
    final start = content.indexOf(startTag, index);
    if (start == -1) {
      visible.write(content.substring(index));
      break;
    }
    visible.write(content.substring(index, start));
    final thinkingStart = start + startTag.length;
    final end = content.indexOf(endTag, thinkingStart);
    thinking.add(content.substring(thinkingStart, end == -1 ? null : end));
    if (end == -1) break;
    index = end + endTag.length;
  }
  return (
    visibleContent: visible.toString(),
    thinkingContent: thinking.join('\n'),
  );
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
