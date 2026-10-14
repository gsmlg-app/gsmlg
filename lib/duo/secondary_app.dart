import 'dart:io';

import 'package:app_chat/app_chat.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';

import 'duo_controller.dart';
import '../screens/toolbox/bluetooth/bluetooth_scanner_screen.dart';

class DuoCompanionApp extends StatefulWidget {
  const DuoCompanionApp({super.key});

  @override
  State<DuoCompanionApp> createState() => _DuoCompanionAppState();
}

class _DuoCompanionAppState extends State<DuoCompanionApp> {
  late final DuoDisplayManager _manager;

  @override
  void initState() {
    super.initState();
    _manager = DuoDisplayManager(
      secondary: true,
      platform: defaultDisplayPlatform(),
      bridge: defaultBridge(secondary: true),
    );
    _manager.addListener(_onStateChanged);
    _manager.start();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _manager.removeListener(_onStateChanged);
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _manager.isDark ? DmThemeData.moonlight() : DmThemeData.sunshine();

    return DuskmoonApp(
      platformStyle: DmPlatformStyle.material,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GSMLG Companion',
        theme: theme,
        darkTheme: DmThemeData.moonlight(),
        themeMode: _manager.isDark ? ThemeMode.dark : ThemeMode.light,
        home: DuoCompanionScaffold(manager: _manager),
        routes: {
          secondaryRouteName: (_) => DuoCompanionScaffold(manager: _manager),
        },
      ),
    );
  }
}

class DuoCompanionScaffold extends StatefulWidget {
  const DuoCompanionScaffold({super.key, required this.manager});

  final DuoDisplayManager manager;

  static const _quickTools = [
    (icon: Icons.chat_bubble_outline, label: 'AI Chat', route: 'Chat'),
    (icon: Icons.dns_outlined, label: 'DNS Zones', route: 'Domain'),
    (icon: Icons.cloud_outlined, label: 'Vultr Servers', route: 'Vultr'),
    (icon: Icons.code, label: 'GitHub', route: 'GitHub'),
    (icon: Icons.bluetooth, label: 'Bluetooth', route: BluetoothScannerScreen.name),
    (icon: Icons.search, label: 'WHOIS', route: 'Whois'),
    (icon: Icons.monitor_heart_outlined, label: 'System Monitor', route: 'Monitor'),
    (icon: Icons.explore_outlined, label: 'Compass', route: 'Compass'),
  ];

  static const _navItems = [
    (icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
    (icon: Icons.miscellaneous_services_outlined, selectedIcon: Icons.miscellaneous_services, label: 'Service'),
    (icon: Icons.build_outlined, selectedIcon: Icons.build, label: 'Toolbox'),
    (icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: 'Settings'),
  ];

  @override
  State<DuoCompanionScaffold> createState() => _DuoCompanionScaffoldState();
}

class _DuoCompanionScaffoldState extends State<DuoCompanionScaffold> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<ChatAttachment> _pendingAttachments = [];
  final AudioRecorder _recorder = AudioRecorder();

  bool _ctrlActive = false;
  bool _altActive = false;
  bool _isRecording = false;

  static const _quickSymbols = [
    '/',
    '@',
    '#',
    ':',
    '`',
    '~',
    '-',
    '_',
    '?',
    '!',
    '(',
    ')',
    '[',
    ']',
    '{',
    '}',
    '=',
    '+',
    '*',
    '|',
    '\\',
    '\$',
    '"',
    "'",
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    _inputController.addListener(_onTextChanged);
    widget.manager.onTextSync = (text) {
      if (mounted && _inputController.text != text) {
        _inputController.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    };
    widget.manager.onRequestFocus = () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    };
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _inputController.removeListener(_onTextChanged);
    widget.manager.onTextSync = null;
    widget.manager.onRequestFocus = null;
    _inputController.dispose();
    _focusNode.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _pickAttachments() async {
    final files = await FilePicker.pickFiles();
    if (files.isEmpty) return;

    final picked = <ChatAttachment>[];
    for (final file in files) {
      Uint8List? bytes;
      int? size;
      try {
        bytes = await file.readAsBytes();
        size = await file.length();
      } catch (_) {}
      if (bytes != null) {
        final dot = file.name.lastIndexOf('.');
        final ext = dot != -1 && dot < file.name.length - 1
            ? file.name.substring(dot + 1)
            : null;
        picked.add(
          ChatAttachment(
            id: '${file.name}:${DateTime.now().microsecondsSinceEpoch}',
            name: file.name,
            sizeBytes: size ?? bytes.length,
            mimeType: _mimeTypeFor(file.name, ext),
            bytes: bytes,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _pendingAttachments.addAll(picked);
      });
    }
  }

  String? _mimeTypeFor(String name, String? extension) {
    final ext =
        (extension ?? (name.contains('.') ? name.split('.').last : ''))
            .toLowerCase();
    return switch (ext) {
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'wav' => 'audio/wav',
      'mp3' => 'audio/mpeg',
      'm4a' => 'audio/mp4',
      'txt' => 'text/plain',
      'json' => 'application/json',
      'pdf' => 'application/pdf',
      _ => null,
    };
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          if (mounted) {
            setState(() {
              _pendingAttachments.add(
                ChatAttachment(
                  id: 'audio:${DateTime.now().microsecondsSinceEpoch}',
                  name: 'recording.wav',
                  sizeBytes: bytes.length,
                  mimeType: 'audio/wav',
                  bytes: bytes,
                ),
              );
              _isRecording = false;
            });
          }
          try {
            await file.delete();
          } catch (_) {}
        } else {
          if (mounted) setState(() => _isRecording = false);
        }
      } else {
        if (mounted) setState(() => _isRecording = false);
      }
    } else {
      if (await _recorder.hasPermission()) {
        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: '${Directory.systemTemp.path}/duo_chat_audio.wav',
        );
        if (mounted) setState(() => _isRecording = true);
      }
    }
  }

  void _submitChat() {
    final chatState = widget.manager.chatState;
    if (chatState?.isStreaming == true) {
      widget.manager.sendChatStop();
      return;
    }

    final text = _inputController.text.trim();
    if (text.isEmpty && _pendingAttachments.isEmpty) return;

    widget.manager.sendChatSend(
      text,
      attachments: List.of(_pendingAttachments),
    );

    _inputController.clear();
    setState(() {
      _pendingAttachments.clear();
    });
  }

  void _insertSymbol(String sym) {
    final text = _inputController.text;
    final selection = _inputController.selection;
    final newText = selection.isValid && selection.start >= 0
        ? text.replaceRange(selection.start, selection.end, sym)
        : text + sym;
    final newOffset = selection.isValid && selection.start >= 0
        ? selection.start + sym.length
        : newText.length;
    _inputController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
    widget.manager.sendTextInput(newText);
    _focusNode.requestFocus();
  }

  void _submitText() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      widget.manager.sendTextSubmit(text);
      _inputController.clear();
      widget.manager.sendTextInput('');
    }
  }

  void _handleEsc() {
    if (widget.manager.chatState?.isStreaming == true) {
      widget.manager.sendChatStop();
      return;
    }
    if (_ctrlActive || _altActive) {
      setState(() {
        _ctrlActive = false;
        _altActive = false;
      });
      return;
    }
    if (_inputController.selection.isValid &&
        !_inputController.selection.isCollapsed) {
      _inputController.selection = TextSelection.collapsed(
        offset: _inputController.selection.end,
      );
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
    }
    widget.manager.sendSecondaryIntent(action: 'esc');
  }

  void _handleTab() {
    _insertSymbol('  ');
  }

  void _toggleCtrl() {
    setState(() {
      _ctrlActive = !_ctrlActive;
    });
  }

  void _toggleAlt() {
    setState(() {
      _altActive = !_altActive;
    });
  }

  int _findPrevWordBoundary(String text, int from) {
    if (from <= 0) return 0;
    int pos = from - 1;
    while (pos > 0 && text[pos] == ' ') {
      pos--;
    }
    while (pos > 0 && text[pos - 1] != ' ' && text[pos - 1] != '\n') {
      pos--;
    }
    return pos;
  }

  int _findNextWordBoundary(String text, int from) {
    if (from >= text.length) return text.length;
    int pos = from;
    while (pos < text.length && text[pos] != ' ' && text[pos] != '\n') {
      pos++;
    }
    while (pos < text.length && text[pos] == ' ') {
      pos++;
    }
    return pos;
  }

  void _cursorLeft() {
    final text = _inputController.text;
    final sel = _inputController.selection;
    if (!sel.isValid || sel.start <= 0) return;
    int newPos;
    if (_altActive || _ctrlActive) {
      newPos = _findPrevWordBoundary(text, sel.start);
      setState(() {
        _altActive = false;
        _ctrlActive = false;
      });
    } else {
      newPos = sel.isCollapsed ? sel.start - 1 : sel.start;
    }
    _inputController.selection = TextSelection.collapsed(offset: newPos);
    _focusNode.requestFocus();
  }

  void _cursorRight() {
    final text = _inputController.text;
    final sel = _inputController.selection;
    if (!sel.isValid || sel.end >= text.length) return;
    int newPos;
    if (_altActive || _ctrlActive) {
      newPos = _findNextWordBoundary(text, sel.end);
      setState(() {
        _altActive = false;
        _ctrlActive = false;
      });
    } else {
      newPos = sel.isCollapsed ? sel.end + 1 : sel.end;
    }
    _inputController.selection = TextSelection.collapsed(offset: newPos);
    _focusNode.requestFocus();
  }

  void _cursorUp() {
    final text = _inputController.text;
    final sel = _inputController.selection;
    if (!sel.isValid) return;
    final currentPos = sel.start;
    final lastNewline =
        text.lastIndexOf('\n', currentPos > 0 ? currentPos - 1 : 0);
    if (lastNewline >= 0) {
      final prevNewline =
          text.lastIndexOf('\n', lastNewline > 0 ? lastNewline - 1 : 0);
      final col = currentPos - (lastNewline + 1);
      final lineLen = lastNewline - (prevNewline + 1);
      final targetCol = col.clamp(0, lineLen);
      _inputController.selection =
          TextSelection.collapsed(offset: prevNewline + 1 + targetCol);
    } else {
      _inputController.selection = const TextSelection.collapsed(offset: 0);
    }
    _focusNode.requestFocus();
  }

  void _cursorDown() {
    final text = _inputController.text;
    final sel = _inputController.selection;
    if (!sel.isValid) return;
    final currentPos = sel.start;
    final nextNewline = text.indexOf('\n', currentPos);
    if (nextNewline >= 0) {
      final linesBefore = text.substring(0, currentPos).split('\n');
      final currentLineCol = linesBefore.last.length;
      final nextLineStart = currentPos + nextNewline + 1;
      final afterNext = text.substring(nextLineStart);
      final endOfNextLine = afterNext.indexOf('\n');
      final nextLineLen =
          endOfNextLine == -1 ? afterNext.length : endOfNextLine;
      final targetCol = currentLineCol.clamp(0, nextLineLen);
      _inputController.selection =
          TextSelection.collapsed(offset: nextLineStart + targetCol);
    } else {
      _inputController.selection = TextSelection.collapsed(offset: text.length);
    }
    _focusNode.requestFocus();
  }

  void _handleHome() {
    final text = _inputController.text;
    final sel = _inputController.selection;
    if (!sel.isValid) return;
    final lineStart = text.lastIndexOf('\n', sel.start > 0 ? sel.start - 1 : 0);
    final target = lineStart >= 0 ? lineStart + 1 : 0;
    _inputController.selection = TextSelection.collapsed(offset: target);
    _focusNode.requestFocus();
  }

  void _handleEnd() {
    final text = _inputController.text;
    final sel = _inputController.selection;
    if (!sel.isValid) return;
    final nextNewline = text.indexOf('\n', sel.start);
    final target = nextNewline >= 0 ? nextNewline : text.length;
    _inputController.selection = TextSelection.collapsed(offset: target);
    _focusNode.requestFocus();
  }

  void _selectAll() {
    _inputController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _inputController.text.length,
    );
    _focusNode.requestFocus();
    setState(() {
      _ctrlActive = false;
    });
  }

  void _copy() {
    final sel = _inputController.selection;
    if (sel.isValid && !sel.isCollapsed) {
      final selectedText =
          _inputController.text.substring(sel.start, sel.end);
      Clipboard.setData(ClipboardData(text: selectedText));
    }
    setState(() {
      _ctrlActive = false;
    });
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _insertSymbol(data.text!);
    }
    if (mounted) {
      setState(() {
        _ctrlActive = false;
      });
    }
  }

  void _cut() {
    final sel = _inputController.selection;
    if (sel.isValid && !sel.isCollapsed) {
      final selectedText =
          _inputController.text.substring(sel.start, sel.end);
      Clipboard.setData(ClipboardData(text: selectedText));
      final text = _inputController.text;
      final newText = text.replaceRange(sel.start, sel.end, '');
      _inputController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: sel.start),
      );
      widget.manager.sendTextInput(newText);
    }
    _focusNode.requestFocus();
    setState(() {
      _ctrlActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DmAdaptiveScaffold(
      duoScreenRole: DuoScreenRole.secondary,
      duoScreenPolicy: DuoScreenPolicy.navigationOnSecondary,
      useDrawer: false,
      appBarBreakpoint: Breakpoints.standard,
      appBar: DmAppBar(
        title: Row(
          children: [
            const Icon(Icons.gamepad_outlined, size: 22),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'GSMLG Companion Controller',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: widget.manager.connected
                    ? colorScheme.primaryContainer
                    : colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.manager.connected ? '● Linked to Display 0' : '○ Standby',
                style: textTheme.labelSmall?.copyWith(
                  color: widget.manager.connected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      destinations: [
        for (final item in DuoCompanionScaffold._navItems)
          NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: item.label,
          ),
      ],
      selectedIndex: widget.manager.selectedIndex.clamp(
        0,
        DuoCompanionScaffold._navItems.length - 1,
      ),
      onSelectedIndexChange: (idx) {
        widget.manager.sendSecondaryIntent(action: 'select', index: idx);
      },
      body: (_) => _buildControlCenter(context),
      smallSecondaryBody: (_) => _buildControlCenter(context),
      secondaryBody: (_) => _buildControlCenter(context),
    );
  }

  Widget _buildControlCenter(BuildContext context) {
    final isChatRoute = widget.manager.chatState != null ||
        widget.manager.currentRoute.startsWith('/chat') ||
        widget.manager.currentRoute.startsWith('/home') ||
        (widget.manager.selectedIndex == 0 &&
            !widget.manager.currentRoute.startsWith('/service') &&
            !widget.manager.currentRoute.startsWith('/toolbox') &&
            !widget.manager.currentRoute.startsWith('/settings'));
    if (isChatRoute) {
      return _buildChatCompanionPad(context);
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currentNav = DuoCompanionScaffold._navItems[widget.manager.selectedIndex
        .clamp(0, DuoCompanionScaffold._navItems.length - 1)];
    final isKeyboardActive =
        _focusNode.hasFocus || MediaQuery.of(context).viewInsets.bottom > 0;

    if (isKeyboardActive) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  radius: 14,
                  child: Icon(currentNav.selectedIcon, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Typing to Primary Display (${currentNav.label})',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    _focusNode.unfocus();
                  },
                  icon: const Icon(Icons.keyboard_hide, size: 16),
                  label: const Text('Hide'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Text(
                    _inputController.text.isEmpty
                        ? 'Drafting live message... Text streams in real time to Display 0.'
                        : _inputController.text,
                    style: textTheme.bodyLarge?.copyWith(
                      color: _inputController.text.isEmpty
                          ? colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildInputRelaySection(context),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 10.0,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    radius: 18,
                    child: Icon(currentNav.selectedIcon, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Workspace: ${currentNav.label}',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Display 0 is rendering ${currentNav.label} content full-screen',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      widget.manager.sendSecondaryIntent(action: 'toggleTheme');
                    },
                    icon: Icon(
                      widget.manager.isDark
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      size: 16,
                    ),
                    label: Text(widget.manager.isDark ? 'Light' : 'Dark'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Quick Launch to Primary Display',
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.4,
              ),
              itemCount: DuoCompanionScaffold._quickTools.length,
              itemBuilder: (context, index) {
                final tool = DuoCompanionScaffold._quickTools[index];
                return InkWell(
                  onTap: () {
                    widget.manager.sendSecondaryIntent(
                      action: 'route',
                      route: tool.route,
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: colorScheme.surface,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Icon(tool.icon, size: 18, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tool.label,
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.arrow_outward,
                          size: 12,
                          color: colorScheme.outline,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildInputRelaySection(context),
        ],
      ),
    );
  }

  Widget _buildAgentSelector(BuildContext context, DuoChatState? chatState) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final activeAgentName = chatState?.activeAgentName ?? 'Select Agent';
    final agents = chatState?.agents ?? const [];

    return PopupMenuButton<String>(
      tooltip: 'Select AI Agent',
      enabled: agents.isNotEmpty,
      onSelected: (agentId) {
        widget.manager.sendChatSelectAgent(agentId);
      },
      itemBuilder: (context) => [
        for (final agent in agents)
          PopupMenuItem<String>(
            value: agent.id,
            child: Row(
              children: [
                Icon(
                  agent.id == chatState?.activeAgentId
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 16,
                  color: agent.id == chatState?.activeAgentId
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    agent.name,
                    style: TextStyle(
                      fontWeight: agent.id == chatState?.activeAgentId
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_toy_outlined, size: 16, color: colorScheme.primary),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 130),
              child: Text(
                activeAgentName,
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
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

  Widget _buildChatCompanionPad(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final chatState = widget.manager.chatState;
    final isStreaming = chatState?.isStreaming ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top bar: Agent Selector, Token count, Model badge, Clear draft
          Row(
            children: [
              _buildAgentSelector(context, chatState),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.toll_outlined,
                      size: 13,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '~${(chatState?.historyTokens ?? 0) + ((_inputController.text.length) / 4).round()} tokens',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (chatState?.modelName != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    chatState!.modelName!,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ] else
                const Spacer(),
              if (_inputController.text.isNotEmpty ||
                  _pendingAttachments.isNotEmpty)
                TextButton(
                  onPressed: () {
                    _inputController.clear();
                    setState(() {
                      _pendingAttachments.clear();
                    });
                    widget.manager.sendTextInput('');
                  },
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: colorScheme.error,
                  ),
                  child: const Text('Clear'),
                ),
            ],
          ),
          const SizedBox(height: 6),

          // 2. Pending Attachments list
          if (_pendingAttachments.isNotEmpty) ...[
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _pendingAttachments.length,
                separatorBuilder: (_, index) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final att = _pendingAttachments[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          att.isImage
                              ? Icons.image
                              : (att.isAudio
                                  ? Icons.audiotrack
                                  : Icons.insert_drive_file),
                          size: 16,
                          color: colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: Text(
                            att.name,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _pendingAttachments.removeAt(index);
                            });
                          },
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
          ],

          // 3. Multiline Input Text Area
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? colorScheme.primary
                      : colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: _focusNode.hasFocus ? 1.5 : 1.0,
                ),
              ),
              child: TextField(
                controller: _inputController,
                focusNode: _focusNode,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: textTheme.bodyMedium,
                onChanged: (text) {
                  widget.manager.sendTextInput(text);
                },
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: isStreaming
                      ? 'Display 0 is generating... Tap Stop or ESC to cancel.'
                      : 'Type a message to Display 0...',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // 4. Tools & Extra Keys Bar
          Row(
            children: [
              IconButton(
                onPressed: _pickAttachments,
                icon: const Icon(Icons.attach_file, size: 20),
                tooltip: 'Attach file',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: _toggleRecording,
                icon: Icon(
                  _isRecording ? Icons.stop_circle : Icons.mic,
                  color: _isRecording ? colorScheme.error : null,
                  size: 20,
                ),
                tooltip: _isRecording ? 'Stop recording' : 'Record audio',
                visualDensity: VisualDensity.compact,
              ),
              Container(
                height: 20,
                width: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
              Expanded(
                child: _buildExtraKeysBar(context),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 5. Send / Stop Action Button Bar
          Row(
            children: [
              if (_focusNode.hasFocus)
                TextButton.icon(
                  onPressed: () => _focusNode.unfocus(),
                  icon: const Icon(Icons.keyboard_hide, size: 16),
                  label: const Text('Hide Keyboard'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              const Spacer(),
              if (isStreaming)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                  ),
                  onPressed: () => widget.manager.sendChatStop(),
                  icon: const Icon(Icons.stop_rounded, size: 18),
                  label: const Text('Stop Generation (ESC)'),
                )
              else
                FilledButton.icon(
                  onPressed: (chatState?.canSend != false &&
                          (_inputController.text.trim().isNotEmpty ||
                              _pendingAttachments.isNotEmpty))
                      ? _submitChat
                      : null,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Send to Display 0'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyButton({
    required Widget child,
    required VoidCallback onTap,
    bool isActive = false,
    bool isAccent = false,
    EdgeInsetsGeometry? padding,
    double minWidth = 32,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Material(
        color: isActive
            ? colorScheme.primary
            : isAccent
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(
            color: isActive
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(minWidth: minWidth, minHeight: 28),
            padding:
                padding ?? const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            alignment: Alignment.center,
            child: DefaultTextStyle(
              style: textTheme.labelSmall!.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: isActive
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExtraKeysBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Modifiers & Control Keys
          _buildKeyButton(
            child: const Text('ESC'),
            onTap: _handleEsc,
            isAccent: true,
          ),
          _buildKeyButton(
            child: const Text('TAB'),
            onTap: _handleTab,
          ),
          _buildKeyButton(
            child: const Text('CTRL'),
            onTap: _toggleCtrl,
            isActive: _ctrlActive,
          ),
          _buildKeyButton(
            child: const Text('ALT'),
            onTap: _toggleAlt,
            isActive: _altActive,
          ),

          // Divider
          Container(
            height: 18,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),

          // 2. Cursor Navigation Keys
          _buildKeyButton(
            child: const Icon(Icons.arrow_back, size: 14),
            onTap: _cursorLeft,
          ),
          _buildKeyButton(
            child: const Icon(Icons.arrow_upward, size: 14),
            onTap: _cursorUp,
          ),
          _buildKeyButton(
            child: const Icon(Icons.arrow_downward, size: 14),
            onTap: _cursorDown,
          ),
          _buildKeyButton(
            child: const Icon(Icons.arrow_forward, size: 14),
            onTap: _cursorRight,
          ),

          // Divider
          Container(
            height: 18,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),

          // 3. Document/Line Navigation
          _buildKeyButton(
            child: const Text('HOME'),
            onTap: _handleHome,
          ),
          _buildKeyButton(
            child: const Text('END'),
            onTap: _handleEnd,
          ),

          // 4. Ctrl Chord Shortcuts when CTRL is toggled
          if (_ctrlActive) ...[
            Container(
              height: 18,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: colorScheme.primary,
            ),
            _buildKeyButton(
              child: const Text('^A All'),
              onTap: _selectAll,
              isActive: true,
            ),
            _buildKeyButton(
              child: const Text('^C Copy'),
              onTap: _copy,
              isActive: true,
            ),
            _buildKeyButton(
              child: const Text('^V Paste'),
              onTap: _paste,
              isActive: true,
            ),
            _buildKeyButton(
              child: const Text('^X Cut'),
              onTap: _cut,
              isActive: true,
            ),
            _buildKeyButton(
              child: const Text('^K Clear'),
              onTap: () {
                _inputController.clear();
                widget.manager.sendTextInput('');
                setState(() => _ctrlActive = false);
              },
              isActive: true,
            ),
          ],

          // Divider
          Container(
            height: 18,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),

          // 5. Developer Quick Symbols
          for (final sym in _quickSymbols)
            _buildKeyButton(
              child: Text(sym),
              onTap: () => _insertSymbol(sym),
            ),
        ],
      ),
    );
  }

  Widget _buildInputRelaySection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focusNode.hasFocus
              ? colorScheme.primary
              : colorScheme.outlineVariant.withValues(alpha: 0.6),
          width: _focusNode.hasFocus ? 1.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.keyboard,
                size: 16,
                color: _focusNode.hasFocus
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                'Duo Keyboard Relay',
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _focusNode.hasFocus
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              if (_ctrlActive) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'CTRL',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
              if (_altActive) ...[
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'ALT',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (_inputController.text.isNotEmpty)
                InkWell(
                  onTap: () {
                    _inputController.clear();
                    widget.manager.sendTextInput('');
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Clear',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          _buildExtraKeysBar(context),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  focusNode: _focusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onChanged: (text) {
                    widget.manager.sendTextInput(text);
                  },
                  onSubmitted: (_) => _submitText(),
                  style: textTheme.bodyMedium,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    hintText:
                        'Tap here to type on Display 6 (stream to Display 0)...',
                    hintStyle: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.send_rounded, size: 18),
                onPressed: _submitText,
                tooltip: 'Send to Primary Display',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
