import 'dart:io';
import 'dart:typed_data';

import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:file_picker/file_picker.dart';
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
    this.selectedAgentName,
    this.selectedAgentId,
    this.agents = const [],
    this.historyTokenCount = 0,
    required this.onSend,
    required this.onStop,
    this.onThinkingToggle,
    this.onThinkingEffortChanged,
    this.onModelTap,
    this.onModelSelect,
    this.onAgentSelect,
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
  final String? selectedAgentName;
  final String? selectedAgentId;
  final List<ChatAgent> agents;
  final int historyTokenCount;
  final void Function(
    String text, {
    Uint8List? imageBytes,
    Uint8List? audioBytes,
    List<ChatAttachment>? attachments,
  })
  onSend;
  final VoidCallback onStop;
  final ValueChanged<bool>? onThinkingToggle;
  final ValueChanged<RemoteThinkingEffort>? onThinkingEffortChanged;
  final VoidCallback? onModelTap;
  final ValueChanged<String>? onModelSelect;
  final ValueChanged<String>? onAgentSelect;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = DmMarkdownInputController();
  final _recorder = AudioRecorder();
  final List<DmChatAttachment> _pendingAttachments = [];
  bool _isRecording = false;
  int _inputTokenCount = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _controller.text;
    final tokens = (text.length / 4).round();
    if (tokens != _inputTokenCount) {
      setState(() {
        _inputTokenCount = tokens;
      });
    }
  }

  void _handleSend(String text, List<DmChatAttachment> attachments) {
    if (!widget.enabled || widget.isStreaming) return;

    final trimmed = text.trim();
    final chatAttachments = <ChatAttachment>[];
    Uint8List? imageBytes;
    Uint8List? audioBytes;
    for (final attachment in attachments) {
      final bytes = attachment.bytes;
      if (bytes == null) continue;

      chatAttachments.add(_toChatAttachment(attachment));

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
    }

    if (trimmed.isEmpty && chatAttachments.isEmpty) return;

    widget.onSend(
      trimmed,
      imageBytes: imageBytes,
      audioBytes: audioBytes,
      attachments: chatAttachments,
    );

    setState(_pendingAttachments.clear);
  }

  ChatAttachment _toChatAttachment(DmChatAttachment attachment) {
    return ChatAttachment(
      id: attachment.id,
      name: attachment.name,
      sizeBytes: attachment.sizeBytes ?? attachment.bytes?.length,
      mimeType: attachment.mimeType,
      bytes: attachment.bytes,
    );
  }

  void _removeAttachment(DmChatAttachment attachment) {
    setState(() {
      _pendingAttachments.removeWhere((item) => item.id == attachment.id);
    });
  }

  Future<void> _pickAttachments() async {
    if (!widget.enabled || widget.isStreaming) return;

    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      withData: !Platform.isMacOS,
    );
    if (result == null) return;

    final picked = <DmChatAttachment>[];
    for (final file in result.files) {
      Uint8List? bytes = file.bytes;
      String? errorMessage;
      try {
        if (bytes == null) {
          final path = file.path;
          if (path != null) {
            bytes = await File(path).readAsBytes();
          }
        }
      } catch (_) {
        errorMessage = 'Unable to read file';
      }

      picked.add(
        DmChatAttachment(
          id:
              file.identifier ??
              '${file.name}:${DateTime.now().microsecondsSinceEpoch}',
          name: file.name,
          sizeBytes: file.size == 0 ? bytes?.length : file.size,
          mimeType: _mimeTypeFor(file.name, file.extension),
          bytes: bytes,
          status: bytes == null
              ? DmChatAttachmentStatus.error
              : DmChatAttachmentStatus.done,
          errorMessage: bytes == null
              ? errorMessage ?? 'Unable to read file'
              : null,
        ),
      );
    }

    setState(() {
      _pendingAttachments.addAll(picked);
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

  String? _mimeTypeFor(String name, String? extension) {
    final normalized = (extension ?? _extensionFor(name, null)).toLowerCase();
    return switch (normalized) {
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'bmp' => 'image/bmp',
      'heic' => 'image/heic',
      'heif' => 'image/heif',
      'aac' => 'audio/aac',
      'aiff' => 'audio/aiff',
      'flac' => 'audio/flac',
      'm4a' => 'audio/mp4',
      'mp3' => 'audio/mpeg',
      'ogg' => 'audio/ogg',
      'opus' => 'audio/opus',
      'wav' => 'audio/wav',
      'webm' => 'audio/webm',
      'csv' => 'text/csv',
      'html' => 'text/html',
      'json' => 'application/json',
      'log' || 'md' || 'txt' => 'text/plain',
      'pdf' => 'application/pdf',
      _ => null,
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
    _controller.removeListener(_onTextChanged);
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
            _ThinkToggleSelector(
              value: widget.thinkingEnabled,
              enabled: widget.enabled && !widget.isStreaming,
              onChanged: widget.onThinkingToggle!,
            ),
          IconButton(
            onPressed: widget.enabled && !widget.isStreaming
                ? _pickAttachments
                : null,
            icon: const Icon(Icons.attach_file, size: 20),
            tooltip: 'Attach',
            visualDensity: VisualDensity.compact,
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
      trailing: widget.selectedAgentName != null
          ? _AgentSelector(
              selectedAgentName: widget.selectedAgentName!,
              selectedAgentId: widget.selectedAgentId,
              agents: widget.agents,
              onAgentSelect: widget.onAgentSelect,
              onAgentTap: widget.onModelTap,
            )
          : widget.selectedModelName != null
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

    final showOverlay = !widget.enabled && !widget.isStreaming;

    final inputWidget = Stack(
      clipBehavior: Clip.none,
      children: [
        IgnorePointer(
          ignoring: showOverlay,
          child: Opacity(
            opacity: widget.enabled || widget.isStreaming ? 1 : 0.62,
            child: input,
          ),
        ),
        if (showOverlay)
          Positioned(
            bottom: 12,
            right: 56, // SendButton is ~40 wide, container padding is 12, so 52-56 is standard placement
            child: widget.selectedAgentName != null
                ? _AgentSelector(
                    selectedAgentName: widget.selectedAgentName!,
                    selectedAgentId: widget.selectedAgentId,
                    agents: widget.agents,
                    onAgentSelect: widget.onAgentSelect,
                    onAgentTap: widget.onModelTap,
                  )
                : widget.selectedModelName != null
                ? _ModelSelector(
                    selectedModelName: widget.selectedModelName!,
                    selectedModelId: widget.selectedModelId,
                    installedModels: widget.installedModels,
                    remoteModels: widget.remoteModels,
                    onModelSelect: widget.onModelSelect,
                    onModelTap: widget.onModelTap,
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.toll_outlined,
                  size: 13,
                  color: Theme.of(context).colorScheme.primary.withAlpha(160),
                ),
                const SizedBox(width: 4),
                Text(
                  '~${widget.historyTokenCount + _inputTokenCount} tokens',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withAlpha(178),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 4),
            inputWidget,
          ],
        ),
      ),
    );
  }
}

class _ThinkToggleSelector extends StatelessWidget {
  const _ThinkToggleSelector({
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
    final activeColor = value
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return PopupMenuButton<bool>(
      enabled: enabled,
      tooltip: value ? 'Thinking: On' : 'Thinking: Off',
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final option in const [false, true])
          PopupMenuItem(
            value: option,
            child: Row(
              children: [
                Icon(
                  option == value
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(option ? 'On' : 'Off'),
              ],
            ),
          ),
      ],
      child: Semantics(
        label: 'Thinking',
        button: true,
        child: SizedBox(
          height: 36,
          width: 36,
          child: Center(
            child: Icon(Icons.psychology, size: 20, color: activeColor),
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
    final activeColor = active
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return PopupMenuButton<RemoteThinkingEffort>(
      enabled: enabled,
      tooltip: 'Thinking: ${value.displayName}',
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
          width: 36,
          child: Center(
            child: Icon(Icons.psychology, size: 20, color: activeColor),
          ),
        ),
      ),
    );
  }
}

class _AgentSelector extends StatelessWidget {
  const _AgentSelector({
    required this.selectedAgentName,
    this.selectedAgentId,
    this.agents = const [],
    this.onAgentSelect,
    this.onAgentTap,
  });

  final String selectedAgentName;
  final String? selectedAgentId;
  final List<ChatAgent> agents;
  final ValueChanged<String>? onAgentSelect;
  final VoidCallback? onAgentTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final canSelect = agents.isNotEmpty && onAgentSelect != null;

    return InkWell(
      onTap: canSelect
          ? () => _showAgentMenu(context, colorScheme)
          : onAgentTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                selectedAgentName,
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

  void _showAgentMenu(BuildContext context, ColorScheme colorScheme) {
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
      items: agents.map((agent) {
        final isSelected = agent.id == selectedAgentId;
        return PopupMenuItem<String>(
          value: agent.id,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  agent.name,
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
      if (selectedId != null && selectedId != selectedAgentId) {
        onAgentSelect?.call(selectedId);
      }
    });
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
