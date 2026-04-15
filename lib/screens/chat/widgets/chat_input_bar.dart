import 'dart:io';
import 'dart:typed_data';

import 'package:app_chat/app_chat.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
    this.selectedModelName,
    this.installedModels = const [],
    this.selectedModelId,
    required this.onSend,
    required this.onStop,
    this.onThinkingToggle,
    this.onModelTap,
    this.onModelSelect,
  });

  final bool enabled;
  final bool isStreaming;
  final bool supportsImage;
  final bool supportsAudio;
  final bool supportsThinking;
  final bool thinkingEnabled;
  final String? selectedModelName;
  final List<String> installedModels;
  final String? selectedModelId;
  final void Function(
    String text, {
    Uint8List? imageBytes,
    Uint8List? audioBytes,
  }) onSend;
  final VoidCallback onStop;
  final ValueChanged<bool>? onThinkingToggle;
  final VoidCallback? onModelTap;
  final ValueChanged<String>? onModelSelect;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = DmMarkdownInputController();
  final _recorder = AudioRecorder();
  Uint8List? _pendingImage;
  Uint8List? _pendingAudio;
  bool _isRecording = false;

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty && _pendingImage == null && _pendingAudio == null) return;

    widget.onSend(text, imageBytes: _pendingImage, audioBytes: _pendingAudio);
    _controller.clear();
    setState(() {
      _pendingImage = null;
      _pendingAudio = null;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _pendingImage = bytes);
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.pickFiles(type: FileType.audio);
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;
    final bytes = await File(path).readAsBytes();
    setState(() => _pendingAudio = bytes);
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      if (path != null) {
        final bytes = await File(path).readAsBytes();
        setState(() {
          _pendingAudio = bytes;
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

  void _showAttachmentOptions() {
    final hasImage = widget.supportsImage;
    final hasAudio = widget.supportsAudio;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasImage)
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Image'),
                subtitle: const Text('Pick from gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage();
                },
              ),
            if (hasAudio) ...[
              ListTile(
                leading: const Icon(Icons.audio_file),
                title: const Text('Audio File'),
                subtitle: const Text('Pick an audio file'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAudioFile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.mic),
                title: const Text('Record Audio'),
                subtitle: const Text('Record with microphone'),
                onTap: () {
                  Navigator.pop(ctx);
                  _toggleRecording();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasAttachments = widget.supportsImage || widget.supportsAudio;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image preview
            if (_pendingImage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        _pendingImage!,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: colorScheme.onSurface,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            colorScheme.surface.withValues(alpha: 0.8),
                        minimumSize: const Size(28, 28),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () => setState(() => _pendingImage = null),
                    ),
                  ],
                ),
              ),
            // Audio preview
            if (_pendingAudio != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Chip(
                  avatar: const Icon(Icons.audio_file, size: 18),
                  label: Text(
                    'Audio attached (${(_pendingAudio!.length / 1024).toStringAsFixed(0)} KB)',
                  ),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => setState(() => _pendingAudio = null),
                ),
              ),
            // Unified card: input + bottom bar
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text input (no bottom slots — avoids Expanded issue)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: DmMarkdownInput(
                      controller: _controller,
                      enabled: widget.enabled && !widget.isStreaming,
                      showPreview: false,
                      showLineNumbers: false,
                      minLines: 1,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: _isRecording
                            ? 'Recording...'
                            : widget.enabled
                                ? 'Type a message...'
                                : 'Model not ready',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  // Bottom action bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        // Left actions
                        if (hasAttachments)
                          IconButton(
                            onPressed: widget.enabled && !widget.isStreaming
                                ? _showAttachmentOptions
                                : null,
                            icon: const Icon(Icons.add, size: 20),
                            tooltip: 'Attach file',
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
                              color: _isRecording ? colorScheme.error : null,
                            ),
                            tooltip: _isRecording
                                ? 'Stop recording'
                                : 'Record audio',
                            visualDensity: VisualDensity.compact,
                          ),
                        if (widget.supportsThinking)
                          IconButton(
                            onPressed: () => widget.onThinkingToggle
                                ?.call(!widget.thinkingEnabled),
                            icon: Icon(
                              Icons.psychology,
                              size: 20,
                              color: widget.thinkingEnabled
                                  ? colorScheme.primary
                                  : null,
                            ),
                            tooltip: widget.thinkingEnabled
                                ? 'Thinking: ON'
                                : 'Thinking: OFF',
                            visualDensity: VisualDensity.compact,
                          ),
                        const Spacer(),
                        // Right: model selector + send
                        if (widget.selectedModelName != null)
                          _ModelSelector(
                            selectedModelName: widget.selectedModelName!,
                            selectedModelId: widget.selectedModelId,
                            installedModels: widget.installedModels,
                            onModelSelect: widget.onModelSelect,
                            onModelTap: widget.onModelTap,
                          ),
                        const SizedBox(width: 4),
                        widget.isStreaming
                            ? IconButton.filled(
                                onPressed: widget.onStop,
                                icon: const Icon(Icons.stop, size: 20),
                                tooltip: 'Stop generation',
                                visualDensity: VisualDensity.compact,
                              )
                            : IconButton.filled(
                                onPressed:
                                    widget.enabled ? _handleSend : null,
                                icon:
                                    const Icon(Icons.arrow_upward, size: 20),
                                tooltip: 'Send message',
                                visualDensity: VisualDensity.compact,
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    this.onModelSelect,
    this.onModelTap,
  });

  final String selectedModelName;
  final String? selectedModelId;
  final List<String> installedModels;
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

    return InkWell(
      onTap: compatibleModels.length > 1 && onModelSelect != null
          ? () => _showModelMenu(context, compatibleModels, colorScheme)
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
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
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
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
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
