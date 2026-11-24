import 'dart:collection';

import 'package:app_vnc/app_vnc.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

/// Compact scrollable toolbar for VNC modifier toggles, quick keys, and an
/// inline soft-keyboard text entry bar.
class VncShortcutBar extends StatefulWidget {
  const VncShortcutBar({
    super.key,
    required this.onKeyEvent,
    this.enabled = true,
  });

  final void Function(int keysym, bool down) onKeyEvent;
  final bool enabled;

  @override
  State<VncShortcutBar> createState() => _VncShortcutBarState();
}

class _VncShortcutBarState extends State<VncShortcutBar> {
  static const String _sentinel = '\u200B';

  final LinkedHashSet<int> _activeModifiers = LinkedHashSet<int>();
  late final TextEditingController _textController;
  late final FocusNode _textFocusNode;
  bool _showTextInput = false;
  bool _updatingText = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: _sentinel);
    _textController.selection = const TextSelection.collapsed(offset: 1);
    _textFocusNode = FocusNode(debugLabel: 'VncShortcutBarInput');
  }

  @override
  void didUpdateWidget(covariant VncShortcutBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && oldWidget.enabled) {
      _releaseAllModifiers();
      if (_showTextInput) {
        setState(() {
          _showTextInput = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _releaseAllModifiers();
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  void _releaseAllModifiers() {
    if (_activeModifiers.isEmpty) return;
    final mods = _activeModifiers.toList().reversed;
    _activeModifiers.clear();
    for (final mod in mods) {
      widget.onKeyEvent(mod, false);
    }
  }

  void _toggleModifier(int keysym) {
    if (!widget.enabled) return;
    setState(() {
      if (_activeModifiers.contains(keysym)) {
        _activeModifiers.remove(keysym);
        widget.onKeyEvent(keysym, false);
      } else {
        _activeModifiers.add(keysym);
        widget.onKeyEvent(keysym, true);
      }
    });
  }

  void _sendQuickKey(int keysym) {
    if (!widget.enabled) return;
    widget.onKeyEvent(keysym, true);
    widget.onKeyEvent(keysym, false);
    if (_activeModifiers.isNotEmpty) {
      setState(_releaseAllModifiers);
    }
  }

  void _sendCtrlAltDel() {
    if (!widget.enabled) return;
    if (_activeModifiers.isNotEmpty) {
      setState(_releaseAllModifiers);
    }
    widget.onKeyEvent(X11Keysym.controlL, true);
    widget.onKeyEvent(X11Keysym.altL, true);
    widget.onKeyEvent(X11Keysym.delete, true);
    widget.onKeyEvent(X11Keysym.delete, false);
    widget.onKeyEvent(X11Keysym.altL, false);
    widget.onKeyEvent(X11Keysym.controlL, false);
  }

  void _resetSentinel() {
    _updatingText = true;
    _textController.value = const TextEditingValue(
      text: _sentinel,
      selection: TextSelection.collapsed(offset: 1),
    );
    _updatingText = false;
  }

  void _handleTextChanged(String raw) {
    if (_updatingText || !widget.enabled) return;

    final value = _textController.value;
    if (value.composing.isValid && !value.composing.isCollapsed) {
      return;
    }

    if (raw.isEmpty) {
      _sendQuickKey(X11Keysym.backSpace);
      _resetSentinel();
      return;
    }

    final committed = raw.replaceAll(_sentinel, '');
    if (committed.isEmpty) {
      _resetSentinel();
      return;
    }

    for (final rune in committed.runes) {
      final ks = unicodeToKeysym(rune);
      if (ks != 0) {
        _sendQuickKey(ks);
      }
    }
    _resetSentinel();
  }

  void _handleTextSubmitted(String _) {
    if (!widget.enabled) return;
    _sendQuickKey(X11Keysym.returnKey);
    _resetSentinel();
    _textFocusNode.requestFocus();
  }

  void _toggleTextInput() {
    if (!widget.enabled) return;
    setState(() {
      _showTextInput = !_showTextInput;
    });
    if (_showTextInput) {
      _resetSentinel();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _showTextInput) {
          _textFocusNode.requestFocus();
        }
      });
    } else {
      _textFocusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHigh,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showTextInput)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _textFocusNode,
                      enabled: widget.enabled,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.send,
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Type text to send...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                      onChanged: _handleTextChanged,
                      onSubmitted: _handleTextSubmitted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Close keyboard input',
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: _toggleTextInput,
                  ),
                ],
              ),
            ),
          Container(
            height: 44,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ModifierChip(
                    label: '⌘',
                    active: _activeModifiers.contains(X11Keysym.superL),
                    enabled: widget.enabled,
                    onTap: () => _toggleModifier(X11Keysym.superL),
                  ),
                  _ModifierChip(
                    label: '⌥',
                    active: _activeModifiers.contains(X11Keysym.altL),
                    enabled: widget.enabled,
                    onTap: () => _toggleModifier(X11Keysym.altL),
                  ),
                  _ModifierChip(
                    label: '⌃',
                    active: _activeModifiers.contains(X11Keysym.controlL),
                    enabled: widget.enabled,
                    onTap: () => _toggleModifier(X11Keysym.controlL),
                  ),
                  _ModifierChip(
                    label: '⇧',
                    active: _activeModifiers.contains(X11Keysym.shiftL),
                    enabled: widget.enabled,
                    onTap: () => _toggleModifier(X11Keysym.shiftL),
                  ),
                  const VerticalDivider(width: 16, indent: 6, endIndent: 6),
                  _KeyChip(
                    label: 'Esc',
                    enabled: widget.enabled,
                    onTap: () => _sendQuickKey(X11Keysym.escape),
                  ),
                  _KeyChip(
                    label: 'Tab',
                    enabled: widget.enabled,
                    onTap: () => _sendQuickKey(X11Keysym.tab),
                  ),
                  _KeyChip(
                    label: '←',
                    enabled: widget.enabled,
                    onTap: () => _sendQuickKey(X11Keysym.left),
                  ),
                  _KeyChip(
                    label: '↑',
                    enabled: widget.enabled,
                    onTap: () => _sendQuickKey(X11Keysym.up),
                  ),
                  _KeyChip(
                    label: '↓',
                    enabled: widget.enabled,
                    onTap: () => _sendQuickKey(X11Keysym.down),
                  ),
                  _KeyChip(
                    label: '→',
                    enabled: widget.enabled,
                    onTap: () => _sendQuickKey(X11Keysym.right),
                  ),
                  _KeyChip(
                    label: 'Del',
                    enabled: widget.enabled,
                    onTap: () => _sendQuickKey(X11Keysym.delete),
                  ),
                  _KeyChip(
                    label: 'Ctrl+Alt+Del',
                    enabled: widget.enabled,
                    onTap: _sendCtrlAltDel,
                  ),
                  const VerticalDivider(width: 16, indent: 6, endIndent: 6),
                  _IconKeyChip(
                    icon: _showTextInput
                        ? Icons.keyboard_hide_outlined
                        : Icons.keyboard_outlined,
                    tooltip: 'Soft keyboard',
                    active: _showTextInput,
                    enabled: widget.enabled,
                    onTap: _toggleTextInput,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModifierChip extends StatelessWidget {
  const _ModifierChip({
    required this.label,
    required this.active,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = active
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final foreground = active
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(6),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 34, minHeight: 32),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: enabled
                        ? foreground
                        : foreground.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KeyChip extends StatelessWidget {
  const _KeyChip({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(6),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 34, minHeight: 32),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: enabled
                        ? foreground
                        : foreground.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconKeyChip extends StatelessWidget {
  const _IconKeyChip({
    required this.icon,
    required this.tooltip,
    required this.active,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = active
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final foreground = active
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 36,
              height: 32,
              child: Icon(
                icon,
                size: 18,
                color: enabled ? foreground : foreground.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
