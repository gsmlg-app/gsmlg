import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_manager_plugin/file_manager_plugin.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/material.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/terminal_hosts.dart';
import 'package:terminal_plugin/terminal_plugin.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:terminal_tabs/terminal_tabs.dart';

import 'session_store.dart';

/// A tab whose descriptor survived restoration but cannot currently connect.
class UnavailableSessionTab extends TabItem implements TerminalTabTitleRenamer {
  UnavailableSessionTab({
    required this.descriptor,
    required this.label,
    required Widget child,
  }) {
    title.value = Text(label);
    content.value = child;
  }

  final Map<String, dynamic> descriptor;
  String label;

  @override
  void renameTitle(String value) {
    label = value;
    descriptor['customTitle'] = value;
    title.value = Text(value);
  }
}

/// Persists the workspace independently of whichever route is currently shown.
class SessionController extends ChangeNotifier with WidgetsBindingObserver {
  SessionController({
    required this.store,
    required this.tabs,
    this._startPeriodicTimer = Timer.periodic,
  }) {
    _subscription = tabs.stream.listen(_onState);
    WidgetsBinding.instance.addObserver(this);
    _foreground =
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  }

  final SessionStore store;
  final TerminalTabBloc tabs;
  final Timer Function(Duration, void Function(Timer)) _startPeriodicTimer;
  late final StreamSubscription<TerminalTabState> _subscription;
  final _titleListeners = <PluginTab, VoidCallback>{};
  final _directories = <PluginTab, String>{};
  final _cwdListeners = <PluginTab, VoidCallback>{};
  final _sessionListeners = <PluginTab, VoidCallback>{};
  final _polls = Map<ExecutionSession, Future<void>>.identity();
  Timer? _directoryTimer;
  bool _terminalRouteVisible = false;
  bool _foreground = false;
  PluginTab? _pollTarget;
  ExecutionSession? _pollSession;
  bool _ready = false;
  bool _closing = false;
  String? _lastLayout;
  Object? persistenceError;
  bool startupPromptDismissed = false;
  SessionSnapshot? requestedRestore;
  final _baselineTabs = <PluginTab>{};
  bool _hasChanges = false;

  void requestRestore(SessionSnapshot snapshot) {
    requestedRestore = snapshot;
    notifyListeners();
  }

  SessionSnapshot? takeRestoreRequest() {
    final snapshot = requestedRestore;
    requestedRestore = null;
    return snapshot;
  }

  void dismissStartupPrompt() {
    startupPromptDismissed = true;
    notifyListeners();
  }

  String? cachedDirectory(PluginTab tab) {
    final directory = _directories[tab];
    return directory == '~' && tab.manager.hostSpec is SSHHostSpec
        ? null
        : directory;
  }

  void rememberDirectory(PluginTab tab, String directory) {
    _directories[tab] = directory;
  }

  void resumeAfterCanceledExit() {
    _closing = false;
    _syncDirectorySchedule();
  }

  void markReady() {
    if (_ready) return;
    _ready = true;
    _syncListeners();
    _baselineTabs.addAll(_titleListeners.keys);
    for (final tab in _baselineTabs) {
      final directory = tab.currentWorkingDirectory;
      _directories.putIfAbsent(
        tab,
        () => directory == '~' && tab.manager.hostSpec is! SSHHostSpec
            ? Platform.environment['HOME'] ?? directory
            : directory,
      );
    }
    _lastLayout = jsonEncode(layout());
    _syncDirectorySchedule();
  }

  void _onState(TerminalTabState state) {
    _syncListeners();
    _syncDirectorySchedule();
    if (_ready && !_closing && state is TerminalTabLoaded) {
      unawaited(capture());
    }
  }

  void _syncListeners() {
    final state = tabs.state;
    final live = state is TerminalTabLoaded
        ? state.allTabs.whereType<PluginTab>().toSet()
        : <PluginTab>{};
    for (final tab in _titleListeners.keys.toList()) {
      if (live.contains(tab)) continue;
      final listener = _titleListeners.remove(tab)!;
      tab.plugin.title.removeListener(listener);
      if (tab.plugin is FileManagerPlugin) {
        (tab.plugin as FileManagerPlugin).currentPath.removeListener(listener);
      }
      _removeDirectoryListeners(tab);
      _directories.remove(tab);
    }
    for (final tab in live) {
      if (_titleListeners.containsKey(tab)) continue;
      void changed() {
        if (!_ready || _closing) return;
        unawaited(capture());
      }

      _titleListeners[tab] = changed;
      tab.plugin.title.addListener(changed);
      if (tab.plugin is FileManagerPlugin) {
        (tab.plugin as FileManagerPlugin).currentPath.addListener(changed);
      }
      if (tab.plugin case final TerminalPlugin plugin) {
        void directoryChanged() {
          final directory = plugin.reportedWorkingDirectory.value;
          if (directory != null) _observeDirectory(tab, directory);
        }

        _cwdListeners[tab] = directoryChanged;
        _sessionListeners[tab] = _syncDirectorySchedule;
        plugin.reportedWorkingDirectory.addListener(directoryChanged);
        plugin.cwdSession.addListener(_syncDirectorySchedule);
        directoryChanged();
      }
    }
  }

  void _removeDirectoryListeners(PluginTab tab) {
    if (tab.plugin case final TerminalPlugin plugin) {
      final cwdListener = _cwdListeners.remove(tab);
      final sessionListener = _sessionListeners.remove(tab);
      if (cwdListener != null) {
        plugin.reportedWorkingDirectory.removeListener(cwdListener);
      }
      if (sessionListener != null) {
        plugin.cwdSession.removeListener(sessionListener);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncDirectorySchedule();
  }

  void setTerminalRouteVisible(bool visible) {
    _terminalRouteVisible = visible;
    _syncDirectorySchedule();
  }

  void _syncDirectorySchedule() {
    final state = tabs.state;
    final active = state is TerminalTabLoaded ? state.activeTab : null;
    final plugin = active is PluginTab ? active.plugin : null;
    final shell = plugin is TerminalPlugin ? plugin.session : null;
    final nextTarget =
        _ready &&
            !_closing &&
            _foreground &&
            _terminalRouteVisible &&
            active is PluginTab &&
            shell is WorkingDirectoryAware
        ? active
        : null;
    final nextShell = nextTarget == null ? null : shell;
    if (identical(_pollTarget, nextTarget) &&
        identical(_pollSession, nextShell)) {
      return;
    }
    _directoryTimer?.cancel();
    _directoryTimer = null;
    _pollTarget = nextTarget;
    _pollSession = nextShell;
    if (nextTarget == null || nextShell == null || plugin is! TerminalPlugin) {
      return;
    }
    void poll() {
      final latest = tabs.state;
      if (latest is! TerminalTabLoaded ||
          !identical(latest.activeTab, nextTarget) ||
          !identical(plugin.session, nextShell)) {
        return;
      }
      _polls.putIfAbsent(
        nextShell,
        () => _pollDirectory(nextTarget, plugin, nextShell),
      );
    }

    _directoryTimer = _startPeriodicTimer(
      const Duration(seconds: 1),
      (_) => poll(),
    );
    poll();
  }

  Future<void> _pollDirectory(
    PluginTab tab,
    TerminalPlugin plugin,
    ExecutionSession source,
  ) async {
    try {
      final directory = await plugin.liveWorkingDirectory();
      if (!_closing &&
          directory != null &&
          identical(source, plugin.session) &&
          _titleListeners.containsKey(tab)) {
        plugin.reportWorkingDirectory(directory);
      }
    } finally {
      _polls.remove(source);
    }
  }

  void _observeDirectory(PluginTab tab, String directory) {
    _directories[tab] = directory;
    if (!_ready || _closing) return;
    if (_baselineTabs.remove(tab) && !_hasChanges) {
      _lastLayout = jsonEncode(layout());
    }
    unawaited(capture());
  }

  Map<String, dynamic>? _descriptor(TabItem tab) {
    if (tab is UnavailableSessionTab) return Map.of(tab.descriptor);
    if (tab is! PluginTab) return null;
    final spec = tab.manager.hostSpec;
    final descriptor = <String, dynamic>{};
    if (spec is SSHHostSpec) {
      descriptor.addAll({
        'type': tab.plugin is FileManagerPlugin ? 'sftp' : 'ssh',
        'hostId': spec.record.id,
      });
    } else if (spec is LocalHostSpec ||
        spec is AndroidHostSpec ||
        spec is IosHostSpec) {
      descriptor.addAll({'type': 'local', 'profileId': tab.shellProfileId});
    } else {
      return null;
    }
    final directory = tab.plugin is FileManagerPlugin
        ? (tab.plugin as FileManagerPlugin).currentPath.value ??
              _directories[tab]
        : _directories[tab] ?? tab.currentWorkingDirectory;
    if (directory != null) descriptor['workingDirectory'] = directory;
    if (tab.customTitle != null) descriptor['customTitle'] = tab.customTitle;
    return descriptor;
  }

  Map<String, dynamic> layout({bool groupOnly = false, String? groupId}) {
    final state = tabs.state;
    if (state is! TerminalTabLoaded) return {'tabs': [], 'activeIndex': 0};
    final grouping = state.grouping;
    final descriptors = <Map<String, dynamic>>[];
    var activeIndex = 0;
    for (final tab in state.allTabs) {
      if (groupOnly && grouping.groupIdOf(tab) != groupId) continue;
      final descriptor = _descriptor(tab);
      if (descriptor == null) continue;
      final memberGroupId = grouping.groupIdOf(tab);
      if (memberGroupId != null) descriptor['groupId'] = memberGroupId;
      if (identical(tab, state.activeTab)) activeIndex = descriptors.length;
      descriptors.add(descriptor);
    }
    final usedGroups = descriptors.map((tab) => tab['groupId']).toSet();
    final groups = [
      for (final group in grouping.groups)
        if (usedGroups.contains(group.id))
          {'id': group.id, 'name': group.name, 'collapsed': group.collapsed},
    ];
    return {
      'activeIndex': activeIndex,
      'tabs': descriptors,
      if (groups.isNotEmpty) 'groups': groups,
      if (grouping.ungroupedCollapsed) 'ungroupedCollapsed': true,
    };
  }

  Future<void> capture({bool force = false}) async {
    if (!_ready || _closing) return;
    final captured = layout();
    final encoded = jsonEncode(captured);
    if (!force && encoded == _lastLayout) return;
    _lastLayout = encoded;
    _hasChanges = true;
    try {
      await store.record(captured);
      if (persistenceError != null) {
        persistenceError = null;
        notifyListeners();
      }
    } catch (error) {
      persistenceError = error;
      notifyListeners();
    }
  }

  Future<SessionSnapshot> save(
    String name, {
    bool groupOnly = false,
    String? groupId,
  }) async {
    await capture(force: true);
    final snapshot = await store.save(
      name,
      layout(groupOnly: groupOnly, groupId: groupId),
      group: groupOnly,
    );
    notifyListeners();
    return snapshot;
  }

  Future<void> deleteSaved(String id) async {
    await store.deleteSaved(id);
    notifyListeners();
  }

  Future<void> prepareExit() async {
    _closing = true;
    _syncDirectorySchedule();
    if (persistenceError != null && _lastLayout != null) {
      await store.record(jsonDecode(_lastLayout!) as Map<String, dynamic>);
    }
    await store.flush();
  }

  Future<void> finishExit() => store.finishExit();

  @override
  void dispose() {
    _closing = true;
    _syncDirectorySchedule();
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription.cancel());
    for (final entry in _titleListeners.entries) {
      entry.key.plugin.title.removeListener(entry.value);
      _removeDirectoryListeners(entry.key);
      if (entry.key.plugin is FileManagerPlugin) {
        (entry.key.plugin as FileManagerPlugin).currentPath.removeListener(
          entry.value,
        );
      }
    }
    _titleListeners.clear();
    super.dispose();
  }
}
