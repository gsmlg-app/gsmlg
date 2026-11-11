import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:app_locale/app_locale.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tab_switcher_sections.dart';
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

/// Actions the tab switcher reports while staying open.
class TabSwitcherCallbacks {
  const TabSwitcherCallbacks({
    this.onRename,
    this.onMoveBefore,
    this.onCreateGroup,
    this.onMoveToGroup,
    this.onUngroup,
    this.onRenameGroup,
    this.onToggleCollapsed,
    this.onCloseGroup,
    this.onMoveSessionsToGroup,
    this.onCreateGroupWithSessions,
    this.onUngroupSessions,
  });

  final void Function(String sessionId, String title)? onRename;
  final void Function(String sessionId, String targetSessionId)? onMoveBefore;
  final void Function(String sessionId, String name)? onCreateGroup;
  final void Function(String sessionId, String groupId)? onMoveToGroup;
  final ValueChanged<String>? onUngroup;
  final void Function(String groupId, String name)? onRenameGroup;
  final ValueChanged<String?>? onToggleCollapsed;
  final ValueChanged<String>? onCloseGroup;
  final void Function(List<String> sessionIds, String groupId)?
  onMoveSessionsToGroup;
  final void Function(List<String> sessionIds, String name)?
  onCreateGroupWithSessions;
  final ValueChanged<List<String>>? onUngroupSessions;
}

/// Shows a modal tab switcher grid overlay, sectioned by tab group.
///
/// [data] is listened to while the switcher is open, so group changes made
/// through [callbacks] show up immediately.
/// Returns a [TabSwitcherResult] or null if dismissed.
Future<TabSwitcherResult?> showTabSwitcher(
  BuildContext context, {
  required ValueListenable<TabSwitcherData> data,
  bool currentGroupOnly = false,
  TabSwitcherCallbacks callbacks = const TabSwitcherCallbacks(),
}) {
  final navigator = Navigator.of(context, rootNavigator: true);
  return navigator.push(
    _TabSwitcherRoute(
      context: context,
      themes: InheritedTheme.capture(from: context, to: navigator.context),
      builder: (context) => _TabSwitcherDialog(
        data: data,
        currentGroupOnly: currentGroupOnly,
        callbacks: callbacks,
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

enum _CardAction { rename, moveTo, newGroup, ungroup }

enum _GroupAction { rename, close }

class _TabSwitcherDialog extends StatefulWidget {
  const _TabSwitcherDialog({
    required this.data,
    required this.currentGroupOnly,
    required this.callbacks,
  });

  final ValueListenable<TabSwitcherData> data;
  final bool currentGroupOnly;
  final TabSwitcherCallbacks callbacks;

  @override
  State<_TabSwitcherDialog> createState() => _TabSwitcherDialogState();
}

class _TabSwitcherDialogState extends State<_TabSwitcherDialog> {
  late TabSwitcherData _data;
  String? _focusedId;
  final _selectedSessionIds = <String>{};
  final _focusNode = FocusNode();
  _TabSwitcherMode _mode = _TabSwitcherMode.switcher;

  /// The section containing the current tab when the switcher opened is shown
  /// expanded until the user toggles it.
  bool _currentSectionReleased = false;

  TabSwitcherCallbacks get _callbacks => widget.callbacks;

  @override
  void initState() {
    super.initState();
    _data = widget.data.value;
    widget.data.addListener(_onDataChanged);
    _focusedId = _data.currentSessionId;
  }

  @override
  void dispose() {
    widget.data.removeListener(_onDataChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    final previous = _visibleSessions();
    final previousIndex = previous.indexWhere((s) => s.id == _focusedId);
    setState(() {
      _data = widget.data.value;
      final ids = {for (final s in _data.sessions) s.id};
      _selectedSessionIds.retainAll(ids);
      final visible = _visibleSessions();
      if (visible.any((s) => s.id == _focusedId)) return;
      _focusedId = visible.isEmpty
          ? null
          : visible[previousIndex.clamp(0, visible.length - 1)].id;
    });
    if (_data.sessions.isEmpty) {
      Navigator.of(context).maybePop();
    }
  }

  String get _ungroupedLabel => context.l10n.tabGroupUngrouped;

  List<TabSwitcherSection> _sections() {
    final sections = buildSwitcherSections(
      _data,
      ungroupedLabel: _ungroupedLabel,
      currentGroupOnly: widget.currentGroupOnly,
    );
    if (!_currentSectionReleased || sections.isEmpty) return sections;
    final current = sections.first;
    if (!current.sessions.any((s) => s.id == _data.currentSessionId)) {
      return sections;
    }
    return [
      TabSwitcherSection(
        groupId: current.groupId,
        name: current.name,
        sessions: current.sessions,
        collapsed: _storedCollapsed(current.groupId),
      ),
      ...sections.skip(1),
    ];
  }

  bool _storedCollapsed(String? groupId) {
    if (groupId == null) return _data.ungroupedCollapsed;
    for (final group in _data.groups) {
      if (group.id == groupId) return group.collapsed;
    }
    return false;
  }

  List<TabSwitcherSection> _openSections() =>
      _sections().where((s) => !s.collapsed).toList();

  List<SessionInfo> _visibleSessions() => [
    for (final section in _openSections()) ...section.sessions,
  ];

  static const double _maxCardWidth = 160;
  static const double _cardSpacing = 6;
  static const double _gridPadding = 8;

  /// Column count of the rendered grid, kept for keyboard navigation.
  int _gridCols = 1;

  /// Enough columns that no card is wider than [_maxCardWidth].
  static int _colsForWidth(double width) {
    final available = width - _gridPadding * 2;
    return max(
      1,
      ((available + _cardSpacing) / (_maxCardWidth + _cardSpacing)).ceil(),
    );
  }

  SessionInfo? get _focusedSession {
    for (final session in _data.sessions) {
      if (session.id == _focusedId) return session;
    }
    return null;
  }

  int _globalIndexOf(SessionInfo session) =>
      _data.sessions.indexWhere((s) => s.id == session.id);

  String? _groupIdOf(SessionInfo session) {
    final id = session.groupId;
    if (id == null) return null;
    return _data.groups.any((g) => g.id == id) ? id : null;
  }

  Future<void> _closeSelectedTab() async {
    final session = _focusedSession;
    if (session == null) return;

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

    final selectedSessions = _data.sessions
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

  void _enterSelectMode() {
    setState(() {
      _mode = _TabSwitcherMode.select;
      _selectedSessionIds.clear();
    });
  }

  void _enterReorderMode() {
    setState(() {
      _mode = _TabSwitcherMode.reorder;
      _selectedSessionIds.clear();
    });
  }

  void _exitMode() {
    setState(() {
      _mode = _TabSwitcherMode.switcher;
      _selectedSessionIds.clear();
    });
    _focusNode.requestFocus();
  }

  Future<String?> _askName({
    required String title,
    required String label,
    String initial = '',
  }) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) =>
          _NameDialog(title: title, label: label, initialValue: initial),
    );
    if (!mounted) return null;
    _focusNode.requestFocus();
    final trimmed = name?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _renameSession(SessionInfo session) async {
    final title = await _askName(
      title: 'Rename Tab',
      label: 'Title',
      initial: session.name,
    );
    if (title != null) _callbacks.onRename?.call(session.id, title);
  }

  void _toggleSelected(String sessionId) {
    setState(() {
      if (!_selectedSessionIds.add(sessionId)) {
        _selectedSessionIds.remove(sessionId);
      }
    });
  }

  void _toggleSection(TabSwitcherSection section) {
    final isForcedOpen =
        !_currentSectionReleased &&
        section.sessions.any((s) => s.id == _data.currentSessionId);
    if (isForcedOpen) {
      setState(() => _currentSectionReleased = true);
      if (_storedCollapsed(section.groupId)) return;
    }
    _callbacks.onToggleCollapsed?.call(section.groupId);
  }

  void _handleSessionTap(SessionInfo session) {
    setState(() => _focusedId = session.id);

    switch (_mode) {
      case _TabSwitcherMode.switcher:
        Navigator.of(context).pop(TabSwitcherSelect(session.id));
      case _TabSwitcherMode.select:
        _toggleSelected(session.id);
      case _TabSwitcherMode.reorder:
        break;
    }
  }

  RelativeRect _menuPosition(Offset globalPosition) {
    final overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    return RelativeRect.fromRect(
      globalPosition & Size.zero,
      Offset.zero & overlay.size,
    );
  }

  Future<void> _showCardMenu(SessionInfo session, Offset position) async {
    if (_mode == _TabSwitcherMode.reorder) return;
    final l10n = context.l10n;
    final groupId = _groupIdOf(session);
    final targets = _data.groups.where((g) => g.id != groupId).toList();
    final menuPosition = _menuPosition(position);
    final action = await showMenu<_CardAction>(
      context: context,
      position: menuPosition,
      items: [
        PopupMenuItem(value: _CardAction.rename, child: Text(l10n.tabRename)),
        if (targets.isNotEmpty)
          PopupMenuItem(
            value: _CardAction.moveTo,
            child: Text(l10n.tabGroupMoveTo),
          ),
        PopupMenuItem(
          value: _CardAction.newGroup,
          child: Text(l10n.tabGroupNew),
        ),
        if (groupId != null)
          PopupMenuItem(
            value: _CardAction.ungroup,
            child: Text(l10n.tabGroupRemove),
          ),
      ],
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _CardAction.rename:
        await _renameSession(session);
      case _CardAction.moveTo:
        final target = await showMenu<String>(
          context: context,
          position: menuPosition,
          items: [
            for (final group in targets)
              PopupMenuItem(value: group.id, child: Text(group.name)),
          ],
        );
        if (!mounted || target == null) return;
        _callbacks.onMoveToGroup?.call(session.id, target);
      case _CardAction.newGroup:
        final name = await _askName(
          title: l10n.tabGroupNew,
          label: l10n.tabGroupNameHint,
        );
        if (name != null) _callbacks.onCreateGroup?.call(session.id, name);
      case _CardAction.ungroup:
        _callbacks.onUngroup?.call(session.id);
    }
    _focusNode.requestFocus();
  }

  /// Groups every selected tab at once (select mode).
  Future<void> _showSelectionGroupMenu(Offset position) async {
    final l10n = context.l10n;
    final selected = [
      for (final session in _data.sessions)
        if (_selectedSessionIds.contains(session.id)) session,
    ];
    if (selected.isEmpty) return;
    final ids = [for (final session in selected) session.id];
    final anyGrouped = selected.any((s) => _groupIdOf(s) != null);
    final menuPosition = _menuPosition(position);
    final action = await showMenu<_CardAction>(
      context: context,
      position: menuPosition,
      items: [
        if (_data.groups.isNotEmpty)
          PopupMenuItem(
            value: _CardAction.moveTo,
            child: Text(l10n.tabGroupMoveTo),
          ),
        PopupMenuItem(
          value: _CardAction.newGroup,
          child: Text(l10n.tabGroupNew),
        ),
        if (anyGrouped)
          PopupMenuItem(
            value: _CardAction.ungroup,
            child: Text(l10n.tabGroupRemove),
          ),
      ],
    );
    if (!mounted || action == null) return;
    var done = false;
    switch (action) {
      case _CardAction.moveTo:
        final target = await showMenu<String>(
          context: context,
          position: menuPosition,
          items: [
            for (final group in _data.groups)
              PopupMenuItem(value: group.id, child: Text(group.name)),
          ],
        );
        if (!mounted || target == null) break;
        _callbacks.onMoveSessionsToGroup?.call(ids, target);
        done = true;
      case _CardAction.newGroup:
        final name = await _askName(
          title: l10n.tabGroupNew,
          label: l10n.tabGroupNameHint,
        );
        if (name == null) break;
        _callbacks.onCreateGroupWithSessions?.call(ids, name);
        done = true;
      case _CardAction.ungroup:
        _callbacks.onUngroupSessions?.call(ids);
        done = true;
      case _CardAction.rename:
        break;
    }
    if (done && mounted) setState(_selectedSessionIds.clear);
    _focusNode.requestFocus();
  }

  Future<void> _showGroupMenu(
    TabSwitcherSection section,
    Offset position,
  ) async {
    final groupId = section.groupId;
    if (groupId == null) return;
    final l10n = context.l10n;
    final action = await showMenu<_GroupAction>(
      context: context,
      position: _menuPosition(position),
      items: [
        PopupMenuItem(
          value: _GroupAction.rename,
          child: Text(l10n.tabGroupRename),
        ),
        PopupMenuItem(
          value: _GroupAction.close,
          child: Text(l10n.tabGroupClose),
        ),
      ],
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _GroupAction.rename:
        final name = await _askName(
          title: l10n.tabGroupRename,
          label: l10n.tabGroupNameHint,
          initial: section.name,
        );
        if (name != null) _callbacks.onRenameGroup?.call(groupId, name);
      case _GroupAction.close:
        _callbacks.onCloseGroup?.call(groupId);
    }
    _focusNode.requestFocus();
  }

  /// Moves focus by grid position across the open sections.
  void _moveFocus({int dx = 0, int dy = 0}) {
    final sections = _openSections();
    final visible = [for (final s in sections) ...s.sessions];
    if (visible.isEmpty) return;
    final flatIndex = visible.indexWhere((s) => s.id == _focusedId);
    if (flatIndex < 0) {
      setState(() => _focusedId = visible.first.id);
      return;
    }
    if (dx != 0) {
      final next = flatIndex + dx;
      if (next >= 0 && next < visible.length) {
        setState(() => _focusedId = visible[next].id);
      }
      return;
    }

    final cols = _gridCols;
    var sectionIndex = 0;
    var index = flatIndex;
    while (index >= sections[sectionIndex].sessions.length) {
      index -= sections[sectionIndex].sessions.length;
      sectionIndex++;
    }
    final section = sections[sectionIndex].sessions;
    final col = index % cols;
    SessionInfo? target;
    if (dy > 0) {
      if (index + cols < section.length) {
        target = section[index + cols];
      } else if (index ~/ cols < (section.length - 1) ~/ cols) {
        target = section.last;
      } else if (sectionIndex + 1 < sections.length) {
        final next = sections[sectionIndex + 1].sessions;
        target = next[min(col, next.length - 1)];
      }
    } else {
      if (index - cols >= 0) {
        target = section[index - cols];
      } else if (sectionIndex > 0) {
        final previous = sections[sectionIndex - 1].sessions;
        final lastRowStart = (previous.length - 1) ~/ cols * cols;
        target = previous[min(lastRowStart + col, previous.length - 1)];
      }
    }
    if (target != null) setState(() => _focusedId = target!.id);
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.keyJ) {
      _moveFocus(dy: 1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.keyK) {
      _moveFocus(dy: -1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.keyL) {
      _moveFocus(dx: 1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyH) {
      _moveFocus(dx: -1);
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      final session = _focusedSession;
      switch (_mode) {
        case _TabSwitcherMode.switcher:
          if (session != null) {
            Navigator.of(context).pop(TabSwitcherSelect(session.id));
          }
        case _TabSwitcherMode.select:
          if (session != null) _toggleSelected(session.id);
        case _TabSwitcherMode.reorder:
          _exitMode();
      }
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.escape) {
      if (_mode == _TabSwitcherMode.switcher) {
        Navigator.of(context).pop();
      } else {
        _exitMode();
      }
      return KeyEventResult.handled;
    }

    // Close tab: Cmd+Backspace (macOS) / Ctrl+Backspace (Linux/Win)
    if (key == LogicalKeyboardKey.backspace) {
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
    final sections = _sections();
    final title = widget.currentGroupOnly && sections.isNotEmpty
        ? sections.first.name
        : null;

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
                _buildHeader(context, title: title),
                const Divider(height: 1),
                Flexible(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = _gridCols = _colsForWidth(
                        constraints.maxWidth,
                      );
                      return CustomScrollView(
                        shrinkWrap: true,
                        slivers: [
                          for (final section in sections) ...[
                            SliverToBoxAdapter(
                              child: _buildSectionHeader(context, section),
                            ),
                            if (!section.collapsed)
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                  _gridPadding,
                                  0,
                                  _gridPadding,
                                  _gridPadding,
                                ),
                                sliver: SliverGrid(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: cols,
                                        mainAxisSpacing: _cardSpacing,
                                        crossAxisSpacing: _cardSpacing,
                                        childAspectRatio: 1.6,
                                      ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) => _buildGridItem(
                                      context,
                                      section.sessions[index],
                                    ),
                                    childCount: section.sessions.length,
                                  ),
                                ),
                              ),
                          ],
                        ],
                      );
                    },
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

  Widget _buildSectionHeader(BuildContext context, TabSwitcherSection section) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return GestureDetector(
      key: ValueKey('tab-switcher-section-${section.groupId ?? 'ungrouped'}'),
      behavior: HitTestBehavior.opaque,
      onTap: () => _toggleSection(section),
      onSecondaryTapUp: (details) =>
          _showGroupMenu(section, details.globalPosition),
      onLongPressStart: (details) =>
          _showGroupMenu(section, details.globalPosition),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
        child: Row(
          children: [
            Icon(
              section.collapsed ? Icons.chevron_right : Icons.expand_more,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${section.name} · ${section.sessions.length}',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {String? title}) {
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
                _TabSwitcherMode.switcher => title ?? 'Switch Tab',
                _TabSwitcherMode.select => 'Select Tabs',
                _TabSwitcherMode.reorder => 'Reorder Tabs',
              },
              overflow: TextOverflow.ellipsis,
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
                  onPressed: _enterReorderMode,
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
                Builder(
                  builder: (buttonContext) => IconButton(
                    tooltip: context.l10n.tabGroupSelected,
                    icon: const Icon(Icons.create_new_folder_outlined),
                    onPressed: selectedCount == 0
                        ? null
                        : () {
                            final box =
                                buttonContext.findRenderObject()! as RenderBox;
                            _showSelectionGroupMenu(
                              box.localToGlobal(
                                box.size.bottomLeft(Offset.zero),
                              ),
                            );
                          },
                  ),
                ),
                IconButton(
                  tooltip: 'Close selected tabs',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: selectedCount == 0 ? null : _closeSelectedTabs,
                ),
              ],
            ),
            _TabSwitcherMode.reorder => IconButton(
              tooltip: 'Done reordering',
              icon: const Icon(Icons.check),
              onPressed: _exitMode,
            ),
          },
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, SessionInfo session) {
    final index = _globalIndexOf(session);
    final isFocused = session.id == _focusedId;
    final isCurrent = session.id == _data.currentSessionId;
    final isMarkedForClose = _selectedSessionIds.contains(session.id);

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) =>
          _mode == _TabSwitcherMode.reorder && details.data != session.id,
      onAcceptWithDetails: (details) =>
          _callbacks.onMoveBefore?.call(details.data, session.id),
      builder: (context, candidateData, rejectedData) {
        final isDropTarget = candidateData.isNotEmpty;
        final card = GestureDetector(
          key: ValueKey('tab-switcher-card-${session.id}'),
          onTap: () => _handleSessionTap(session),
          onSecondaryTapUp: (details) =>
              _showCardMenu(session, details.globalPosition),
          onLongPressStart: _mode == _TabSwitcherMode.reorder
              ? null
              : (details) => _showCardMenu(session, details.globalPosition),
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

        return Draggable<String>(
          data: session.id,
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
        final isCompact = constraints.maxHeight < 96;
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
        'hjkl/←↓↑→ Navigate  ↵ Select  Right-click Menu  $deleteHint  Esc Cancel',
      _TabSwitcherMode.select =>
        'hjkl/←↓↑→ Navigate  ↵ Select tab  $deleteHint selected  Esc Cancel',
      _TabSwitcherMode.reorder => 'Drag tabs to reorder  ↵/Esc Done',
    };
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.label,
    required this.initialValue,
  });

  final String title;
  final String label;
  final String initialValue;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(labelText: widget.label),
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
