import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'terminal_app_bar.dart';

/// Result of the tab switcher dialog.
sealed class TabSwitcherResult {}

/// User selected a tab to switch to.
class TabSwitcherSelect extends TabSwitcherResult {
  final String sessionId;
  TabSwitcherSelect(this.sessionId);
}

/// User requested to close a tab.
class TabSwitcherClose extends TabSwitcherResult {
  final String sessionId;
  TabSwitcherClose(this.sessionId);
}

/// User requested to close multiple selected tabs.
class TabSwitcherCloseSelected extends TabSwitcherResult {
  final List<String> sessionIds;
  TabSwitcherCloseSelected(List<String> sessionIds)
    : sessionIds = List.unmodifiable(sessionIds);
}

/// Shows a modal tab switcher grid overlay.
/// Returns a [TabSwitcherResult] or null if dismissed.
Future<TabSwitcherResult?> showTabSwitcher(
  BuildContext context, {
  required List<SessionInfo> sessions,
  required String? currentSessionId,
  ValueChanged<List<String>>? onReorder,
  void Function(String sessionId, String title)? onRename,
}) {
  final navigator = Navigator.of(context, rootNavigator: true);
  return navigator.push(
    _TabSwitcherRoute(
      context: context,
      themes: InheritedTheme.capture(from: context, to: navigator.context),
      builder: (context) => _TabSwitcherDialog(
        sessions: sessions,
        currentSessionId: currentSessionId,
        onReorder: onReorder,
        onRename: onRename,
      ),
    ),
  );
}

class _TabSwitcherRoute extends DialogRoute<TabSwitcherResult> {
  _TabSwitcherRoute({
    required super.context,
    required super.builder,
    required super.themes,
  }) : super(
         barrierColor: Colors.black54,
         traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
       );

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final displayFeatures = mediaQuery.displayFeatures
        .where(
          (feature) =>
              feature.type != DisplayFeatureType.fold ||
              !feature.bounds.isEmpty,
        )
        .toList();
    final page = super.buildPage(context, animation, secondaryAnimation);
    if (displayFeatures.length == mediaQuery.displayFeatures.length) {
      return page;
    }
    // Filter before DialogRoute chooses a sub-screen for the switcher.
    return MediaQuery(
      data: mediaQuery.copyWith(displayFeatures: displayFeatures),
      child: page,
    );
  }
}

enum _TabSwitcherMode { switcher, select, reorder }

class _TabSwitcherDialog extends StatefulWidget {
  const _TabSwitcherDialog({
    required this.sessions,
    required this.currentSessionId,
    required this.onReorder,
    required this.onRename,
  });

  final List<SessionInfo> sessions;
  final String? currentSessionId;
  final ValueChanged<List<String>>? onReorder;
  final void Function(String sessionId, String title)? onRename;

  @override
  State<_TabSwitcherDialog> createState() => _TabSwitcherDialogState();
}

class _TabSwitcherDialogState extends State<_TabSwitcherDialog> {
  late int _selectedIndex;
  late List<SessionInfo> _sessions;
  final _selectedSessionIds = <String>{};
  final _focusNode = FocusNode();
  _TabSwitcherMode _mode = _TabSwitcherMode.switcher;

  int get _cols => max(1, sqrt(_sessions.length).ceil());

  @override
  void initState() {
    super.initState();
    _sessions = List.of(widget.sessions);
    _selectedIndex = _sessions.indexWhere(
      (s) => s.id == widget.currentSessionId,
    );
    if (_selectedIndex < 0) _selectedIndex = 0;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _closeSelectedTab() async {
    if (_sessions.isEmpty) return;

    final session = _sessions[_selectedIndex];

    if (session.isRunning) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Close Tab?'),
          content: Text(
            'The session "${session.name}" has a running process. '
            'Are you sure you want to close it?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      if (!mounted || confirmed != true) return;
    }

    Navigator.of(context).pop(TabSwitcherClose(session.id));
  }

  Future<void> _closeSelectedTabs() async {
    if (_selectedSessionIds.isEmpty) return;

    final selectedSessions = _sessions
        .where((session) => _selectedSessionIds.contains(session.id))
        .toList();
    final count = selectedSessions.length;
    final runningCount = selectedSessions
        .where((session) => session.isRunning)
        .length;
    final title = count == 1 ? 'Close 1 Tab?' : 'Close $count Tabs?';
    final content = runningCount == 0
        ? 'Close the selected ${count == 1 ? 'tab' : 'tabs'}?'
        : '$runningCount selected ${runningCount == 1 ? 'tab has' : 'tabs have'} '
              'a running process. Close the selected '
              '${count == 1 ? 'tab' : 'tabs'}?';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Close'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    Navigator.of(context).pop(
      TabSwitcherCloseSelected(
        selectedSessions.map((session) => session.id).toList(),
      ),
    );
  }

  void _moveTo(int newIndex) {
    if (newIndex >= 0 && newIndex < _sessions.length) {
      setState(() => _selectedIndex = newIndex);
    }
  }

  void _enterSelectMode() {
    setState(() {
      _mode = _TabSwitcherMode.select;
      _selectedSessionIds.clear();
    });
  }

  void _enterReorderMode(int index) {
    setState(() {
      _mode = _TabSwitcherMode.reorder;
      _selectedIndex = index;
      _selectedSessionIds.clear();
    });
  }

  Future<void> _renameSession(SessionInfo session, int index) async {
    final title = await showDialog<String>(
      context: context,
      builder: (context) => _RenameTabDialog(initialTitle: session.name),
    );

    if (!mounted) return;
    final trimmed = title?.trim();
    if (trimmed == null || trimmed.isEmpty) return;

    widget.onRename?.call(session.id, trimmed);
    setState(() {
      _sessions[index] = SessionInfo(
        id: session.id,
        name: trimmed,
        onClose: session.onClose,
        isRunning: session.isRunning,
      );
    });
  }

  void _exitMode({bool resetOrder = false}) {
    setState(() {
      _mode = _TabSwitcherMode.switcher;
      _selectedSessionIds.clear();
      if (resetOrder) {
        _sessions = List.of(widget.sessions);
        _selectedIndex = _sessions.indexWhere(
          (session) => session.id == widget.currentSessionId,
        );
        if (_selectedIndex < 0) _selectedIndex = 0;
      }
    });
  }

  void _toggleSelected(String sessionId) {
    setState(() {
      if (!_selectedSessionIds.add(sessionId)) {
        _selectedSessionIds.remove(sessionId);
      }
    });
  }

  void _reorderSession(int fromIndex, int toIndex) {
    if (fromIndex == toIndex ||
        fromIndex < 0 ||
        fromIndex >= _sessions.length ||
        toIndex < 0 ||
        toIndex >= _sessions.length) {
      return;
    }

    setState(() {
      final session = _sessions.removeAt(fromIndex);
      _sessions.insert(toIndex, session);
      _selectedIndex = toIndex;
    });
  }

  void _finishReorder() {
    widget.onReorder?.call(
      _sessions.map((session) => session.id).toList(growable: false),
    );
    setState(() => _mode = _TabSwitcherMode.switcher);
  }

  void _handleSessionTap(SessionInfo session, int index) {
    setState(() => _selectedIndex = index);

    switch (_mode) {
      case _TabSwitcherMode.switcher:
        Navigator.of(context).pop(TabSwitcherSelect(session.id));
      case _TabSwitcherMode.select:
        _toggleSelected(session.id);
      case _TabSwitcherMode.reorder:
        break;
    }
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final cols = _cols;
    final row = _selectedIndex ~/ cols;
    final col = _selectedIndex % cols;

    // Navigate down: Arrow Down / j
    if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.keyJ) {
      _moveTo((row + 1) * cols + col);
      return KeyEventResult.handled;
    }

    // Navigate up: Arrow Up / k
    if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.keyK) {
      _moveTo((row - 1) * cols + col);
      return KeyEventResult.handled;
    }

    // Navigate right: Arrow Right / l
    if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.keyL) {
      _moveTo(row * cols + col + 1);
      return KeyEventResult.handled;
    }

    // Navigate left: Arrow Left / h
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.keyH) {
      _moveTo(row * cols + col - 1);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      switch (_mode) {
        case _TabSwitcherMode.switcher:
          Navigator.of(
            context,
          ).pop(TabSwitcherSelect(_sessions[_selectedIndex].id));
        case _TabSwitcherMode.select:
          _toggleSelected(_sessions[_selectedIndex].id);
        case _TabSwitcherMode.reorder:
          _finishReorder();
      }
      return KeyEventResult.handled;
    }

    // Cancel: Escape
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (_mode == _TabSwitcherMode.switcher) {
        Navigator.of(context).pop();
      } else {
        _exitMode(resetOrder: _mode == _TabSwitcherMode.reorder);
      }
      return KeyEventResult.handled;
    }

    // Close tab: Cmd+Backspace (macOS) / Ctrl+Backspace (Linux/Win)
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      final isApple =
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.iOS;
      final mod = isApple
          ? HardwareKeyboard.instance.isMetaPressed
          : HardwareKeyboard.instance.isControlPressed;
      if (mod) {
        if (_mode == _TabSwitcherMode.select) {
          _closeSelectedTabs();
        } else {
          _closeSelectedTab();
        }
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isApple =
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final deleteHint = isApple ? '⌘⌫ Close' : 'Ctrl+⌫ Close';
    final cols = _cols;

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _onKeyEvent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 520),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surfaceContainer,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const Divider(height: 1),
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: _sessions.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 1.6,
                    ),
                    itemBuilder: _buildGridItem,
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _footerText(deleteHint),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedCount = _selectedSessionIds.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              switch (_mode) {
                _TabSwitcherMode.switcher => 'Switch Tab',
                _TabSwitcherMode.select => 'Select Tabs',
                _TabSwitcherMode.reorder => 'Reorder Tabs',
              },
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          switch (_mode) {
            _TabSwitcherMode.switcher => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Reorder tabs',
                  icon: const Icon(Icons.reorder),
                  onPressed: () => _enterReorderMode(_selectedIndex),
                ),
                IconButton(
                  tooltip: 'Select tabs',
                  icon: const Icon(Icons.checklist_rtl),
                  onPressed: _enterSelectMode,
                ),
              ],
            ),
            _TabSwitcherMode.select => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Cancel selection',
                  icon: const Icon(Icons.close),
                  onPressed: _exitMode,
                ),
                IconButton(
                  tooltip: 'Close selected tabs',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: selectedCount == 0 ? null : _closeSelectedTabs,
                ),
              ],
            ),
            _TabSwitcherMode.reorder => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Cancel reordering',
                  icon: const Icon(Icons.close),
                  onPressed: () => _exitMode(resetOrder: true),
                ),
                IconButton(
                  tooltip: 'Done reordering',
                  icon: const Icon(Icons.check),
                  onPressed: _finishReorder,
                ),
              ],
            ),
          },
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, int index) {
    final session = _sessions[index];
    final isFocused = index == _selectedIndex;
    final isCurrent = session.id == widget.currentSessionId;
    final isMarkedForClose = _selectedSessionIds.contains(session.id);

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) =>
          _mode == _TabSwitcherMode.reorder && details.data != index,
      onAcceptWithDetails: (details) => _reorderSession(details.data, index),
      builder: (context, candidateData, rejectedData) {
        final isDropTarget = candidateData.isNotEmpty;
        final card = GestureDetector(
          key: ValueKey('tab-switcher-card-${session.id}'),
          onTap: () => _handleSessionTap(session, index),
          onLongPress: _mode == _TabSwitcherMode.reorder
              ? null
              : () => _renameSession(session, index),
          child: _buildSessionCard(
            context,
            session: session,
            index: index,
            isFocused: isFocused,
            isCurrent: isCurrent,
            isMarkedForClose: isMarkedForClose,
            isDropTarget: isDropTarget,
          ),
        );

        if (_mode != _TabSwitcherMode.reorder) {
          return card;
        }

        return Draggable<int>(
          data: index,
          feedback: SizedBox(
            width: 160,
            height: 100,
            child: Material(
              color: Colors.transparent,
              child: _buildSessionCard(
                context,
                session: session,
                index: index,
                isFocused: true,
                isCurrent: isCurrent,
                isMarkedForClose: false,
                isDropTarget: false,
                isDragging: true,
              ),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.45, child: card),
          child: card,
        );
      },
    );
  }

  Widget _buildSessionCard(
    BuildContext context, {
    required SessionInfo session,
    required int index,
    required bool isFocused,
    required bool isCurrent,
    required bool isMarkedForClose,
    required bool isDropTarget,
    bool isDragging = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelecting = _mode == _TabSwitcherMode.select;
    final cardColor = isMarkedForClose
        ? colorScheme.secondaryContainer
        : isFocused
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final contentColor = isMarkedForClose
        ? colorScheme.onSecondaryContainer
        : isFocused
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;
    final borderColor = isDropTarget
        ? colorScheme.tertiary
        : isMarkedForClose
        ? colorScheme.secondary
        : isCurrent
        ? colorScheme.primary
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 80;
        final padding = isCompact ? 8.0 : 10.0;
        final iconSize = isCompact ? 20.0 : 24.0;
        final iconGap = isCompact ? 4.0 : 6.0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(8),
            border: borderColor == null
                ? null
                : Border.all(
                    color: borderColor,
                    width: isDropTarget || isCurrent ? 2 : 1.5,
                  ),
            boxShadow: isDragging
                ? [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          padding: EdgeInsets.all(padding),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _mode == _TabSwitcherMode.reorder
                          ? Icons.drag_indicator
                          : Icons.terminal,
                      size: iconSize,
                      color: isFocused || isMarkedForClose
                          ? contentColor
                          : colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(height: iconGap),
                    Text(
                      session.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: contentColor,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (!isCompact) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${index + 1}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: contentColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelecting)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(
                    isMarkedForClose
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: isMarkedForClose
                        ? colorScheme.secondary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _footerText(String deleteHint) {
    return switch (_mode) {
      _TabSwitcherMode.switcher =>
        'hjkl/←↓↑→ Navigate  ↵ Select  Long press Rename  $deleteHint  Esc Cancel',
      _TabSwitcherMode.select =>
        'hjkl/←↓↑→ Navigate  ↵ Select tab  $deleteHint selected  Esc Cancel',
      _TabSwitcherMode.reorder => 'Drag tabs to reorder  ↵ Done  Esc Cancel',
    };
  }
}

class _RenameTabDialog extends StatefulWidget {
  const _RenameTabDialog({required this.initialTitle});

  final String initialTitle;

  @override
  State<_RenameTabDialog> createState() => _RenameTabDialogState();
}

class _RenameTabDialogState extends State<_RenameTabDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename Tab'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Title'),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
