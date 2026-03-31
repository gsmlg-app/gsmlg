import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    this.enabled = true,
    this.isStreaming = false,
    this.supportsImage = false,
    required this.onSend,
    required this.onStop,
  });

  final bool enabled;
  final bool isStreaming;
  final bool supportsImage;
  final void Function(String text, {Uint8List? imageBytes}) onSend;
  final VoidCallback onStop;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Uint8List? _pendingImage;

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty && _pendingImage == null) return;

    widget.onSend(text, imageBytes: _pendingImage);
    _controller.clear();
    setState(() => _pendingImage = null);
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

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
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
                      icon: Icon(Icons.close,
                          size: 18, color: colorScheme.onSurface),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            colorScheme.surface.withValues(alpha: 0.8),
                        minimumSize: const Size(28, 28),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () =>
                          setState(() => _pendingImage = null),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                if (widget.supportsImage)
                  IconButton(
                    onPressed: widget.enabled && !widget.isStreaming
                        ? _pickImage
                        : null,
                    icon: const Icon(Icons.image),
                    tooltip: 'Attach image',
                  ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled && !widget.isStreaming,
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: widget.enabled
                          ? 'Type a message...'
                          : 'Model not ready',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: widget.enabled && !widget.isStreaming
                        ? (_) => _handleSend()
                        : null,
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
