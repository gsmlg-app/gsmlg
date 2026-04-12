import 'dart:io';
import 'dart:typed_data';

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
    required this.onSend,
    required this.onStop,
    this.onThinkingToggle,
  });

  final bool enabled;
  final bool isStreaming;
  final bool supportsImage;
  final bool supportsAudio;
  final bool supportsThinking;
  final bool thinkingEnabled;
  final void Function(
    String text, {
    Uint8List? imageBytes,
    Uint8List? audioBytes,
  })
  onSend;
  final VoidCallback onStop;
  final ValueChanged<bool>? onThinkingToggle;

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
        // Clean up temp file
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

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
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
                        backgroundColor: colorScheme.surface.withValues(
                          alpha: 0.8,
                        ),
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
            Row(
              children: [
                // Attachment button (opens bottom sheet)
                if (hasAttachments)
                  IconButton(
                    onPressed: widget.enabled && !widget.isStreaming
                        ? _showAttachmentOptions
                        : null,
                    icon: const Icon(Icons.attach_file),
                    tooltip: 'Attach file',
                  ),
                // Mic button for quick recording (only when audio supported)
                if (widget.supportsAudio)
                  IconButton(
                    onPressed: widget.enabled && !widget.isStreaming
                        ? _toggleRecording
                        : null,
                    icon: Icon(
                      _isRecording ? Icons.stop_circle : Icons.mic,
                      color: _isRecording ? colorScheme.error : null,
                    ),
                    tooltip: _isRecording ? 'Stop recording' : 'Record audio',
                  ),
                // Thinking toggle (only when model supports it)
                if (widget.supportsThinking)
                  IconButton(
                    onPressed: () =>
                        widget.onThinkingToggle?.call(!widget.thinkingEnabled),
                    icon: Icon(
                      Icons.psychology,
                      color: widget.thinkingEnabled
                          ? colorScheme.primary
                          : null,
                    ),
                    tooltip: widget.thinkingEnabled
                        ? 'Thinking: ON'
                        : 'Thinking: OFF',
                  ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 120,
                    ),
                    child: DmMarkdownInput(
                      controller: _controller,
                      enabled: widget.enabled && !widget.isStreaming,
                      showPreview: false,
                      showLineNumbers: false,
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
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                widget.isStreaming
                    ? IconButton.filled(
                        onPressed: widget.onStop,
                        icon: const Icon(Icons.stop),
                        tooltip: 'Stop generation',
                      )
                    : IconButton.filled(
                        onPressed: widget.enabled ? _handleSend : null,
                        icon: const Icon(Icons.send),
                        tooltip: 'Send message',
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
