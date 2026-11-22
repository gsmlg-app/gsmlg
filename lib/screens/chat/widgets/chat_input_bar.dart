import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_agent/app_agent.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/duo/duo_controller.dart';
import 'package:gsmlg/screens/agents/agent_model_config.dart';
import 'package:record/record.dart';

import 'chat_composer_popovers.dart';
import 'clipboard_attachments.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    this.enabled = true,
    this.conversationId,
    this.draft,
    this.onDraftChanged,
    this.onAttachmentsAdded,
    this.isQueued = false,
    this.isStreaming = false,
    this.supportsImage = false,
    this.supportsAudio = false,
    this.supportsThinking = false,
    this.thinkingEnabled = false,
    this.thinkingEffort,
    this.permissionMode = ChatPermissionMode.fullAccess,
    this.onPermissionModeChanged,
    this.selectedModelName,
    this.modelChoices = const [],
    this.onModelChoiceSelect,
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
    this.editingMessageId,
    this.onCancelEdit,
  });

  final String? conversationId;
  final ChatDraft? draft;
  final void Function(String? conversationId, ChatDraft draft)? onDraftChanged;
  final void Function(String? conversationId, List<ChatAttachment> attachments)?
  onAttachmentsAdded;
  final bool isQueued;
  final bool enabled;
  final bool isStreaming;
  final bool supportsImage;
  final bool supportsAudio;
  final bool supportsThinking;
  final bool thinkingEnabled;
  final RemoteThinkingEffort? thinkingEffort;
  final ChatPermissionMode permissionMode;
  final ValueChanged<ChatPermissionMode>? onPermissionModeChanged;
  final String? selectedModelName;
  final List<AgentModelChoice> modelChoices;
  final ValueChanged<AgentModelChoice>? onModelChoiceSelect;
  final List<String> installedModels;
  final List<String> remoteModels;
  final String? selectedModelId;
  final String? selectedAgentName;
  final String? selectedAgentId;
  final List<AgentDefinition> agents;
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
  final String? editingMessageId;
  final VoidCallback? onCancelEdit;

  bool get isEditingMessage => editingMessageId != null;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = DmMarkdownInputController();
  final _inputFocusNode = FocusNode();
  final _recorder = AudioRecorder();
  final List<DmChatAttachment> _pendingAttachments = [];
  bool _isRecording = false;
  String? _recordingConversationId;
  bool _restoringDraft = false;
  bool _submittingDraft = false;
  int _inputTokenCount = 0;
  bool _relayToSecondary = true;
  late ChatPermissionMode _permissionMode;

  bool get _isDuoConnected {
    final duo = DuoDisplayManager.instance;
    return duo != null && !duo.secondary && duo.connected;
  }

  @override
  void initState() {
    super.initState();
    _permissionMode = widget.permissionMode;
    _restoreDraft();
    _controller.addListener(_onTextChanged);
    _setupDuoRelay();
  }

  @override
  void didUpdateWidget(covariant ChatInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.permissionMode != widget.permissionMode) {
      _permissionMode = widget.permissionMode;
    }
    if (oldWidget.conversationId != widget.conversationId) {
      if (_isRecording) unawaited(_finishRecording());
      _restoreDraft(force: true);
      final duo = DuoDisplayManager.instance;
      duo?.syncPrimaryText(_controller.text);
    } else if (oldWidget.draft != widget.draft) {
      _restoreDraft();
    }
    if (widget.editingMessageId != null &&
        widget.editingMessageId != oldWidget.editingMessageId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _inputFocusNode.requestFocus();
      });
    }
  }

  void _restoreDraft({bool force = false}) {
    final draft = widget.draft;
    if (draft == null) return;
    _restoringDraft = true;
    final length = draft.text.length;
    final selection = TextSelection(
      baseOffset: draft.selectionBase.clamp(0, length),
      extentOffset: draft.selectionExtent.clamp(0, length),
    );
    // Echoing our own draft must preserve the platform IME composing range.
    // Compare offsets only: the platform's selection may carry an affinity the
    // draft does not store, and rewriting the value mid-composition makes the
    // iOS IME re-insert its marked text (typing "a" produced "aa").
    final current = _controller.selection;
    if (force ||
        _controller.text != draft.text ||
        current.baseOffset != selection.baseOffset ||
        current.extentOffset != selection.extentOffset) {
      _controller.value = TextEditingValue(
        text: draft.text,
        selection: selection,
      );
    }
    _pendingAttachments
      ..clear()
      ..addAll(
        draft.attachments.map(
          (a) => DmChatAttachment(
            id: a.id,
            name: a.name,
            bytes: a.bytes,
            mimeType: a.mimeType,
            sizeBytes: a.sizeBytes,
            status: a.bytes == null
                ? DmChatAttachmentStatus.error
                : DmChatAttachmentStatus.done,
            errorMessage: a.bytes == null ? 'Unable to read file' : null,
          ),
        ),
      );
    _inputTokenCount = (length / 4).round();
    _restoringDraft = false;
  }

  ChatDraft _draftSnapshot() => ChatDraft(
    text: _controller.text,
    selectionBase: _controller.selection.baseOffset,
    selectionExtent: _controller.selection.extentOffset,
    attachments: _pendingAttachments.map(_toChatAttachment).toList(),
  );

  void _saveDraft() {
    if (!_restoringDraft && !_submittingDraft) {
      widget.onDraftChanged?.call(widget.conversationId, _draftSnapshot());
    }
  }

  void _addPickedAttachments(
    String? conversationId,
    List<DmChatAttachment> attachments,
  ) {
    final callback = widget.onAttachmentsAdded;
    if (callback != null) {
      callback(conversationId, attachments.map(_toChatAttachment).toList());
    } else if (mounted && conversationId == widget.conversationId) {
      setState(() => _pendingAttachments.addAll(attachments));
      _saveDraft();
    }
  }

  void _setupDuoRelay() {
    final duo = DuoDisplayManager.instance;
    if (duo == null || duo.secondary) return;

    duo.addListener(_onDuoStateChanged);

    duo.onTextInput = (text) {
      if (mounted && _controller.text != text) {
        _controller.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    };

    duo.onTextSubmit = (text) {
      if (mounted && widget.enabled && !widget.isStreaming) {
        _handleSend(text, _pendingAttachments);
        if (widget.onDraftChanged == null) _controller.clear();
      }
    };

    duo.onEscKey = () {
      if (mounted && widget.isStreaming) {
        widget.onStop();
      }
    };
  }

  void _onDuoStateChanged() {
    if (mounted) setState(() {});
  }

  void _onTextChanged() {
    if (_restoringDraft || _submittingDraft) return;
    _saveDraft();
    final text = _controller.text;
    final tokens = (text.length / 4).round();
    if (tokens != _inputTokenCount) {
      setState(() {
        _inputTokenCount = tokens;
      });
    }
    final duo = DuoDisplayManager.instance;
    if (duo != null && !duo.secondary && duo.connected) {
      duo.syncPrimaryText(text);
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

    if (widget.onDraftChanged == null) {
      setState(_pendingAttachments.clear);
    } else {
      // DmChatInput clears its controller synchronously after onSend. Keep the
      // authoritative draft until the coordinator accepts this submission.
      _submittingDraft = true;
      scheduleMicrotask(() {
        if (!mounted) return;
        _restoreDraft();
        _submittingDraft = false;
      });
    }
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
    _saveDraft();
  }

  Future<void> _pickAttachments() async {
    if (!widget.enabled || widget.isStreaming) return;

    final targetId = widget.conversationId;
    final files = await FilePicker.pickFiles();
    if (files.isEmpty) return;

    final picked = <DmChatAttachment>[];
    for (final file in files) {
      Uint8List? bytes;
      String? errorMessage;
      try {
        bytes = await file.readAsBytes();
      } catch (_) {
        errorMessage = 'Unable to read file';
      }

      var name = file.name;
      var mimeType = _mimeTypeFor(file.name, file.extension);
      if (bytes != null && _isImageExtension(_extensionFor(name, mimeType))) {
        final normalized = await ClipboardAttachments.normalizeImage(bytes);
        if (normalized != null) {
          bytes = normalized.bytes;
          mimeType = normalized.mimeType;
          name = ClipboardAttachments.replaceExtension(
            name,
            normalized.extension,
          );
        }
      }

      picked.add(
        DmChatAttachment(
          id: '$name:${DateTime.now().microsecondsSinceEpoch}',
          name: name,
          sizeBytes: bytes?.length ?? file.lengthSync(),
          mimeType: mimeType,
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

    if (!mounted) return;
    _addPickedAttachments(targetId, picked);
  }

  Future<bool> _pasteFromClipboard() async {
    if (!widget.enabled || widget.isStreaming) return false;
    final targetId = widget.conversationId;
    final items = await ClipboardAttachments.read();
    if (items.isEmpty || !mounted) return false;

    final now = DateTime.now().microsecondsSinceEpoch;
    final pasted = <DmChatAttachment>[];
    for (var i = 0; i < items.length; i++) {
      var name = items[i].name;
      var bytes = items[i].bytes;
      var mimeType = items[i].mimeType ?? _mimeTypeFor(name, null);
      if (_isImageExtension(_extensionFor(name, mimeType))) {
        final normalized = await ClipboardAttachments.normalizeImage(bytes);
        if (normalized != null) {
          bytes = normalized.bytes;
          mimeType = normalized.mimeType;
          name = ClipboardAttachments.replaceExtension(
            name,
            normalized.extension,
          );
        }
      }
      pasted.add(
        DmChatAttachment(
          id: 'clip:$name:$now:$i',
          name: name,
          sizeBytes: bytes.length,
          mimeType: mimeType,
          bytes: bytes,
          status: DmChatAttachmentStatus.done,
        ),
      );
    }

    if (!mounted) return false;
    _addPickedAttachments(targetId, pasted);
    return true;
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

  Future<void> _finishRecording() async {
    final targetId = _recordingConversationId;
    _isRecording = false;
    final path = await _recorder.stop();
    if (path != null) {
      try {
        final bytes = await File(path).readAsBytes();
        if (mounted) {
          _addPickedAttachments(targetId, [
            DmChatAttachment(
              id: 'audio:${DateTime.now().microsecondsSinceEpoch}',
              name: 'recording.wav',
              sizeBytes: bytes.length,
              mimeType: 'audio/wav',
              bytes: bytes,
              status: DmChatAttachmentStatus.done,
            ),
          ]);
        }
      } finally {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _finishRecording();
      return;
    }
    final targetId = widget.conversationId;
    if (await _recorder.hasPermission()) {
      if (!mounted || targetId != widget.conversationId) return;
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.wav),
        path:
            '${Directory.systemTemp.path}/chat_audio_${DateTime.now().microsecondsSinceEpoch}.wav',
      );
      _recordingConversationId = targetId;
      if (!mounted) return;
      if (targetId != widget.conversationId) {
        await _finishRecording();
      } else {
        setState(() => _isRecording = true);
      }
    }
  }

  @override
  void dispose() {
    final duo = DuoDisplayManager.instance;
    if (duo != null) {
      duo.removeListener(_onDuoStateChanged);
      if (duo.onTextInput != null) duo.onTextInput = null;
      if (duo.onTextSubmit != null) duo.onTextSubmit = null;
      if (duo.onEscKey != null) duo.onEscKey = null;
    }
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _inputFocusNode.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Widget? _buildAgentControl() {
    if (widget.selectedAgentName == null) return null;
    return ComposerAgentPill(
      selectedAgentName: widget.selectedAgentName!,
      selectedAgentId: widget.selectedAgentId,
      agents: widget.agents,
      onAgentSelect: widget.onAgentSelect,
      onManageAgents: widget.onModelTap,
    );
  }

  void _handlePermissionChanged(ChatPermissionMode mode) {
    setState(() => _permissionMode = mode);
    widget.onPermissionModeChanged?.call(mode);
  }

  Widget _buildLeadingControls() {
    final totalTokens = widget.historyTokenCount + _inputTokenCount;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ComposerAddMenuButton(
          enabled: widget.enabled && !widget.isStreaming,
          onAttachFiles: _pickAttachments,
          onPasteClipboard: () => unawaited(_pasteFromClipboard()),
          supportsAudio: widget.supportsAudio,
          isRecording: _isRecording,
          onToggleRecording: _toggleRecording,
          onOpenAgentSettings: widget.onModelTap,
          tokenCount: totalTokens,
        ),
        const SizedBox(width: 2),
        ComposerPermissionPill(
          value: _permissionMode,
          enabled: !widget.isStreaming,
          onChanged: _handlePermissionChanged,
          onManage: widget.onModelTap,
        ),
      ],
    );
  }

  Widget _buildTrailingControls() {
    final colorScheme = Theme.of(context).colorScheme;
    final hasModelOrEffort =
        widget.selectedModelName != null ||
        widget.modelChoices.isNotEmpty ||
        (widget.thinkingEffort != null &&
            widget.onThinkingEffortChanged != null) ||
        widget.onThinkingToggle != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_isDuoConnected)
          IconButton(
            onPressed: () {
              setState(() {
                _relayToSecondary = !_relayToSecondary;
              });
            },
            icon: Icon(
              _relayToSecondary
                  ? Icons.keyboard_alt_outlined
                  : Icons.keyboard_outlined,
              size: 18,
              color: _relayToSecondary ? colorScheme.primary : null,
            ),
            tooltip: _relayToSecondary
                ? 'Keyboard relayed to Display 6. Tap to type here.'
                : 'Keyboard on Display 0. Tap to relay to Display 6.',
            visualDensity: VisualDensity.compact,
          ),
        if (hasModelOrEffort)
          Flexible(
            child: ComposerModelEffortControl(
              modelName: widget.selectedModelName,
              thinkingEffort: widget.thinkingEffort,
              thinkingEnabled: widget.thinkingEnabled,
              enabled: widget.enabled && !widget.isStreaming,
              onThinkingEffortChanged: widget.onThinkingEffortChanged,
              onThinkingToggle: widget.onThinkingToggle,
              onModelTap: widget.onModelTap,
              modelChoices: widget.modelChoices,
              onModelChoiceSelect: widget.onModelChoiceSelect,
              installedModels: widget.installedModels,
              remoteModels: widget.remoteModels,
              selectedModelId: widget.selectedModelId,
              onModelSelect: widget.onModelSelect,
            ),
          ),
        if (widget.supportsAudio) ...[
          const SizedBox(width: 2),
          IconButton(
            onPressed: widget.enabled && !widget.isStreaming
                ? _toggleRecording
                : null,
            icon: Icon(
              _isRecording ? Icons.stop_circle : Icons.mic_none,
              size: 20,
              color: _isRecording
                  ? colorScheme.error
                  : colorScheme.onSurfaceVariant,
            ),
            tooltip: _isRecording ? 'Stop recording' : 'Record audio',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ],
    );
  }

  String _placeholderText() {
    if (widget.isQueued) return 'Queued — you can edit your next draft';
    if (_isRecording) return 'Recording...';
    if (!widget.enabled) return 'Model not ready';
    if (_isDuoConnected && _relayToSecondary) {
      return 'Tap here to type on Display 6...';
    }
    final agent = widget.selectedAgentName?.trim();
    if (agent != null && agent.isNotEmpty) {
      return 'Message $agent...';
    }
    return 'Type a message...';
  }

  Widget? _buildEditingHeader(BuildContext context) {
    if (!widget.isEditingMessage) return null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      key: const ValueKey('chat-editing-banner'),
      padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.edit_outlined, size: 15, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Editing message — send to restart from here',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            key: const ValueKey('chat-editing-cancel'),
            onPressed: widget.onCancelEdit,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final input = DmChatInput(
      controller: _controller,
      focusNode: _inputFocusNode,
      header: _buildEditingHeader(context),
      onCancel: widget.isEditingMessage ? widget.onCancelEdit : null,
      onSend: _handleSend,
      onStop: widget.onStop,
      isStreaming: widget.isStreaming,
      pendingAttachments: _pendingAttachments,
      onRemoveAttachment: _removeAttachment,
      onPaste: _pasteFromClipboard,
      placeholder: _placeholderText(),
      minLines: 1,
      maxLines: 6,
      submitShortcut: DmChatSubmitShortcut.cmdEnter,
      leading: _buildLeadingControls(),
      trailing: _buildTrailingControls(),
      idleActionIcon: widget.supportsAudio
          ? (_isRecording ? Icons.stop : Icons.graphic_eq)
          : null,
      idleActionTooltip: widget.supportsAudio
          ? (_isRecording ? 'Stop recording' : 'Voice')
          : null,
      onIdleAction:
          widget.supportsAudio && widget.enabled && !widget.isStreaming
          ? _toggleRecording
          : null,
    );

    final showOverlay = !widget.enabled && !widget.isStreaming;
    final agentOverlayControl = showOverlay ? _buildAgentControl() : null;

    final inputWidget = Stack(
      clipBehavior: Clip.none,
      children: [
        Focus(
          onFocusChange: (hasFocus) {
            if (hasFocus && _isDuoConnected && _relayToSecondary) {
              FocusManager.instance.primaryFocus?.unfocus();
              DuoDisplayManager.instance?.requestSecondaryFocus();
            }
          },
          child: IgnorePointer(
            ignoring: showOverlay,
            child: Opacity(
              opacity: widget.enabled || widget.isStreaming ? 1 : 0.62,
              child: input,
            ),
          ),
        ),
        if (agentOverlayControl != null)
          Positioned(bottom: 22, left: 58, child: agentOverlayControl),
      ],
    );

    return SafeArea(top: false, child: inputWidget);
  }
}
