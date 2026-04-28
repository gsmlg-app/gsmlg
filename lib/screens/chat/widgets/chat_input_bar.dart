import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_chat/app_chat.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    this.enabled = true,
    this.isStreaming = false,
    this.supportsImage = false,
    this.supportsAudio = false,
    this.supportsThinking = false,
    this.thinkingEnabled = false,
    this.thinkingEffort,
    this.selectedModelName,
    this.installedModels = const [],
    this.remoteModels = const [],
    this.selectedModelId,
    required this.onSend,
    required this.onStop,
    this.onThinkingToggle,
    this.onThinkingEffortChanged,
    this.onModelTap,
    this.onModelSelect,
  });

  final bool enabled;
  final bool isStreaming;
  final bool supportsImage;
  final bool supportsAudio;
  final bool supportsThinking;
  final bool thinkingEnabled;
  final RemoteThinkingEffort? thinkingEffort;
  final String? selectedModelName;
  final List<String> installedModels;
  final List<String> remoteModels;
  final String? selectedModelId;
  final void Function(
    String text, {
    Uint8List? imageBytes,
    Uint8List? audioBytes,
  })
  onSend;
  final VoidCallback onStop;
  final ValueChanged<bool>? onThinkingToggle;
  final ValueChanged<RemoteThinkingEffort>? onThinkingEffortChanged;
  final VoidCallback? onModelTap;
  final ValueChanged<String>? onModelSelect;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  static const _maxInlineFileBytes = 64 * 1024;

  final _controller = DmMarkdownInputController();
  final _recorder = AudioRecorder();
  final List<DmChatAttachment> _pendingAttachments = [];
  bool _isRecording = false;

  void _handleSend(String text, List<DmChatAttachment> attachments) {
    if (!widget.enabled || widget.isStreaming) return;

    final parts = <String>[];
    final trimmed = text.trim();
    if (trimmed.isNotEmpty) parts.add(trimmed);

    Uint8List? imageBytes;
    Uint8List? audioBytes;
    for (final attachment in attachments) {
      final bytes = attachment.bytes;
      if (bytes == null) continue;

      final extension = _extensionFor(attachment.name, attachment.mimeType);
      if (imageBytes == null &&
          widget.supportsImage &&
          _isImageExtension(extension)) {
        imageBytes = bytes;
        continue;
      }

      if (audioBytes == null &&
          widget.supportsAudio &&
          _isAudioExtension(extension)) {
        audioBytes = bytes;
        continue;
      }

      parts.add(
        _fileReferenceText(
          name: attachment.name,
          extension: extension,
          size: attachment.sizeBytes ?? bytes.length,
          bytes: bytes,
        ),
      );
    }

    if (parts.isEmpty && imageBytes == null && audioBytes == null) return;

    widget.onSend(
      parts.join('\n\n'),
      imageBytes: imageBytes,
      audioBytes: audioBytes,
    );

    setState(_pendingAttachments.clear);
  }

  String _fileReferenceText({
    required String name,
    required String extension,
    required int size,
    required Uint8List bytes,
  }) {
    final buffer = StringBuffer()
      ..writeln()
      ..writeln('Attached file: $name')
      ..writeln('Size: ${_formatBytes(size)}');

    if (_isTextExtension(extension) && bytes.length <= _maxInlineFileBytes) {
      final content = utf8.decode(bytes, allowMalformed: true);
      buffer
        ..writeln()
        ..writeln('```')
        ..writeln(content.trim())
        ..writeln('```');
    }

    return buffer.toString().trim();
  }

  void _handleAttach(List<DmChatAttachment> attachments) {
    setState(() {
      _pendingAttachments.addAll(
        attachments.map(
          (attachment) =>
              attachment.copyWith(status: DmChatAttachmentStatus.done),
        ),
      );
    });
  }

  void _removeAttachment(DmChatAttachment attachment) {
    setState(() {
      _pendingAttachments.removeWhere((item) => item.id == attachment.id);
    });
  }

  String _extensionFor(String name, String? mimeType) {
    final dot = name.lastIndexOf('.');
    if (dot != -1 && dot < name.length - 1) {
      return name.substring(dot + 1).toLowerCase();
    }
    return switch (mimeType) {
      'image/png' => 'png',
      'image/jpeg' => 'jpg',
      'image/gif' => 'gif',
      'image/webp' => 'webp',
      'audio/wav' => 'wav',
      'audio/mpeg' => 'mp3',
      'audio/mp4' => 'm4a',
      'text/plain' => 'txt',
      'application/json' => 'json',
      _ => '',
    };
  }

  bool _isImageExtension(String extension) {
    return const {
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'bmp',
      'heic',
      'heif',
    }.contains(extension);
  }

  bool _isAudioExtension(String extension) {
    return const {
      'aac',
      'aiff',
      'flac',
      'm4a',
      'mp3',
      'ogg',
      'opus',
      'wav',
      'webm',
    }.contains(extension);
  }

  bool _isTextExtension(String extension) {
    return const {
      'csv',
      'dart',
      'diff',
      'go',
      'html',
      'json',
      'log',
      'md',
      'py',
      'rs',
      'sql',
      'swift',
      'toml',
      'ts',
      'tsx',
      'txt',
      'yaml',
      'yml',
    }.contains(extension);
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      if (path != null) {
        final bytes = await File(path).readAsBytes();
        setState(() {
          _pendingAttachments.add(
            DmChatAttachment(
              id: 'audio:${DateTime.now().microsecondsSinceEpoch}',
              name: 'recording.wav',
              sizeBytes: bytes.length,
              mimeType: 'audio/wav',
              bytes: bytes,
              status: DmChatAttachmentStatus.done,
            ),
          );
          _isRecording = false;
        });
        try {
          await File(path).delete();
        } catch (_) {}
      } else {
        setState(() => _isRecording = false);
      }
    } else {
      if (await _recorder.hasPermission()) {
        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: '${Directory.systemTemp.path}/chat_audio.wav',
        );
        setState(() => _isRecording = true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final input = DmChatInput(
      controller: _controller,
      onSend: _handleSend,
      onStop: widget.onStop,
      onAttach: _handleAttach,
      isStreaming: widget.isStreaming,
      pendingAttachments: _pendingAttachments,
      onRemoveAttachment: _removeAttachment,
      placeholder: _isRecording
          ? 'Recording...'
          : widget.enabled
          ? 'Type a message...'
          : 'Model not ready',
      minLines: 1,
      maxLines: 6,
      submitShortcut: DmChatSubmitShortcut.cmdEnter,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.thinkingEffort != null &&
              widget.onThinkingEffortChanged != null)
            _ThinkEffortSelector(
              value: widget.thinkingEffort!,
              enabled: widget.enabled && !widget.isStreaming,
              onChanged: widget.onThinkingEffortChanged!,
            )
          else if (widget.onThinkingToggle != null)
            _ThinkSwitch(
              value: widget.thinkingEnabled,
              enabled: widget.enabled && !widget.isStreaming,
              onChanged: widget.onThinkingToggle!,
            ),
          if (widget.supportsAudio)
            IconButton(
              onPressed: widget.enabled && !widget.isStreaming
                  ? _toggleRecording
                  : null,
              icon: Icon(
                _isRecording ? Icons.stop_circle : Icons.mic,
                size: 20,
              ),
              tooltip: _isRecording ? 'Stop recording' : 'Record audio',
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
      trailing: widget.selectedModelName != null
          ? _ModelSelector(
              selectedModelName: widget.selectedModelName!,
              selectedModelId: widget.selectedModelId,
              installedModels: widget.installedModels,
              remoteModels: widget.remoteModels,
              onModelSelect: widget.onModelSelect,
              onModelTap: widget.onModelTap,
            )
          : null,
    );

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: IgnorePointer(
          ignoring: !widget.enabled && !widget.isStreaming,
          child: Opacity(
            opacity: widget.enabled || widget.isStreaming ? 1 : 0.62,
            child: input,
          ),
        ),
      ),
    );
  }
}

class _ThinkSwitch extends StatelessWidget {
  const _ThinkSwitch({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: value ? 'Thinking: ON' : 'Thinking: OFF',
      child: Semantics(
        label: 'Thinking',
        toggled: value,
        child: SizedBox(
          height: 36,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.psychology,
                size: 18,
                color: value
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              Transform.scale(
                scale: 0.72,
                child: Switch.adaptive(
                  value: value,
                  onChanged: enabled ? onChanged : null,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThinkEffortSelector extends StatelessWidget {
  const _ThinkEffortSelector({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final RemoteThinkingEffort value;
  final bool enabled;
  final ValueChanged<RemoteThinkingEffort> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final active = value != RemoteThinkingEffort.off;

    return PopupMenuButton<RemoteThinkingEffort>(
      enabled: enabled,
      tooltip: 'Thinking effort: ${value.displayName}',
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final effort in RemoteThinkingEffort.values)
          PopupMenuItem(
            value: effort,
            child: Row(
              children: [
                Icon(
                  effort == value
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(effort.displayName),
              ],
            ),
          ),
      ],
      child: Semantics(
        button: true,
        label: 'Thinking effort ${value.displayName}',
        child: SizedBox(
          height: 36,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.psychology,
                size: 18,
                color: active
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                value.displayName,
                style: TextStyle(
                  fontSize: 12,
                  color: active
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModelSelector extends StatelessWidget {
  const _ModelSelector({
    required this.selectedModelName,
    this.selectedModelId,
    this.installedModels = const [],
    this.remoteModels = const [],
    this.onModelSelect,
    this.onModelTap,
  });

  final String selectedModelName;
  final String? selectedModelId;
  final List<String> installedModels;
  final List<String> remoteModels;
  final ValueChanged<String>? onModelSelect;
  final VoidCallback? onModelTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Build the list of installed platform-compatible models.
    final compatibleModels = <(String id, GemmaModelInfo info)>[];
    for (final id in installedModels) {
      final info = GemmaModelInfo.findById(id);
      if (info != null && info.isCurrentPlatformCompatible) {
        compatibleModels.add((id, info));
      }
    }

    final canSelectLocal = compatibleModels.length > 1 && onModelSelect != null;
    final remoteOptions = remoteModels.toSet().toList()..sort();
    final canSelectRemote = remoteOptions.length > 1 && onModelSelect != null;

    return InkWell(
      onTap: canSelectLocal
          ? () => _showModelMenu(context, compatibleModels, colorScheme)
          : canSelectRemote
          ? () => _showRemoteModelMenu(context, remoteOptions, colorScheme)
          : onModelTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                selectedModelName,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showModelMenu(
    BuildContext context,
    List<(String id, GemmaModelInfo info)> models,
    ColorScheme colorScheme,
  ) {
    final button = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      items: models.map((entry) {
        final (id, info) = entry;
        final isSelected = id == selectedModelId;
        return PopupMenuItem<String>(
          value: id,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  info.displayName,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check, size: 18, color: colorScheme.primary),
            ],
          ),
        );
      }).toList(),
    ).then((selectedId) {
      if (selectedId != null && selectedId != selectedModelId) {
        onModelSelect?.call(selectedId);
      }
    });
  }

  void _showRemoteModelMenu(
    BuildContext context,
    List<String> models,
    ColorScheme colorScheme,
  ) {
    final button = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      items: models.map((id) {
        final isSelected = id == selectedModelId;
        return PopupMenuItem<String>(
          value: id,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  id,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check, size: 18, color: colorScheme.primary),
            ],
          ),
        );
      }).toList(),
    ).then((selectedId) {
      if (selectedId != null && selectedId != selectedModelId) {
        onModelSelect?.call(selectedId);
      }
    });
  }
}
