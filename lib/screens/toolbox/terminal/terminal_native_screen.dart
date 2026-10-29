import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';
import 'package:flutter/services.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:app_logging/app_logging.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:gsmlg/destination.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/terminal_hosts.dart';
import 'package:terminal_plugin/terminal_plugin.dart';
import 'package:terminal_tabs/terminal_tabs.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xterm/xterm.dart' show TerminalCursorType;

import 'widgets/widgets.dart';

class TerminalScreen extends StatefulWidget {
  static const name = 'TerminalScreen';
  static const path = 'terminal';

  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  static const _persistedTabsKey = 'terminal.open_tabs.v1';

  late final TerminalTabBloc _terminalTabBloc;
  late final TerminalSettingsBloc _terminalSettingsBloc;
  late final SharedPreferences _sharedPreferences;
  final _analytics = TerminalAnalytics();
  final _terminalFocusNotifier = ValueNotifier<int>(0);
  late final _TerminalLifecycleObserver _lifecycleObserver;
  StreamSubscription<TerminalTabState>? _stateSubscription;
  StreamSubscription<TerminalSettingsState>? _settingsSubscription;
  StreamSubscription<ShellProfileState>? _profileSubscription;
  final _tabTitlePersistenceListeners = <PluginTab, VoidCallback>{};
  Timer? _saveOpenTabsTimer;
  bool _initialTabsHandled = false;
  bool _handlingInitialTabs = false;
  bool? _previousFullscreenState;

  @override
  void initState() {
    super.initState();
    _terminalTabBloc = context.read<TerminalTabBloc>();
    _terminalSettingsBloc = context.read<TerminalSettingsBloc>();
    _sharedPreferences = context.read<SharedPreferences>();
    _terminalTabBloc.add(TerminalTabStart());
    final existingState = _terminalTabBloc.state;
    if (existingState is TerminalTabLoaded) {
      _syncTabTitlePersistenceListeners(existingState);
    }
    // Listen for state changes to open initial tab when loaded
    _stateSubscription = _terminalTabBloc.stream.listen(_onStateChanged);
    _settingsSubscription = _terminalSettingsBloc.stream.listen(
      _onSettingsChanged,
    );
    _profileSubscription = context.read<ShellProfileBloc>().stream.listen(
      _onProfileChanged,
    );
    _lifecycleObserver = _TerminalLifecycleObserver(
      onAppExit: _saveOpenTabsToDisk,
    );
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    // Also check immediately in case state is already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryRestoreOrOpenInitialTabs();
    });
  }

  void _onStateChanged(TerminalTabState state) {
    if (state is TerminalTabLoaded) {
      _syncTabTitlePersistenceListeners(state);
    }
    _tryRestoreOrOpenInitialTabs();
    _trackFullscreenChange(state);
    if (_initialTabsHandled) {
      _saveOpenTabsToDisk();
    }
  }

  void _onSettingsChanged(TerminalSettingsState state) {
    _tryRestoreOrOpenInitialTabs();
    if (state is TerminalSettingsLoaded && !state.restoreTerminalTabs) {
      context.read<SharedPreferences>().remove(_persistedTabsKey);
    }
  }

  void _onProfileChanged(ShellProfileState state) {
    _tryRestoreOrOpenInitialTabs();
  }

  void _trackFullscreenChange(TerminalTabState state) {
    if (state is! TerminalTabLoaded) return;
    final isFullscreen = state.isFullscreen;
    if (_previousFullscreenState != null &&
        _previousFullscreenState != isFullscreen) {
      _analytics.trackFullscreenToggled(isFullscreen);
    }
    _previousFullscreenState = isFullscreen;
  }

  Future<void> _tryRestoreOrOpenInitialTabs() async {
    if (_initialTabsHandled || _handlingInitialTabs) return;

    final tabState = _terminalTabBloc.state;
    final settingsState = context.read<TerminalSettingsBloc>().state;
    if (tabState is! TerminalTabLoaded ||
        settingsState is! TerminalSettingsLoaded) {
      return;
    }
    if (tabState.tabs.children.isNotEmpty) {
      _initialTabsHandled = true;
      return;
    }
    // TODO(upstream): gsmlg-app/web-terminal#6 - wait for profile readiness.
    final profileState = context.read<ShellProfileBloc>().state;
    if (settingsState.restoreTerminalTabs &&
        (profileState is ShellProfileInitial ||
            profileState is ShellProfileLoading)) {
      return;
    }

    _handlingInitialTabs = true;
    _initialTabsHandled = true;
    try {
      var restored = false;
      if (settingsState.restoreTerminalTabs) {
        restored = await _restoreOpenTabsFromDisk();
      }
      if (!mounted) return;
      if (!restored && tabState.tabs.children.isEmpty) {
        _openLocalShell();
      }
    } finally {
      _handlingInitialTabs = false;
    }
  }

  @override
  void dispose() {
    _saveOpenTabsTimer?.cancel();
    unawaited(_saveOpenTabsToDisk());
    _removeTabTitlePersistenceListeners();
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    _stateSubscription?.cancel();
    _settingsSubscription?.cancel();
    _profileSubscription?.cancel();
    _terminalFocusNotifier.dispose();
    // The application owns the tabs and their connections across route changes.
    super.dispose();
  }

  void _syncTabTitlePersistenceListeners(TerminalTabLoaded state) {
    final currentTabs = state.allTabs.whereType<PluginTab>().toSet();

    for (final tab in _tabTitlePersistenceListeners.keys.toList()) {
      if (!currentTabs.contains(tab)) {
        tab.plugin.title.removeListener(_tabTitlePersistenceListeners[tab]!);
        _tabTitlePersistenceListeners.remove(tab);
      }
    }

    for (final tab in currentTabs) {
      if (_tabTitlePersistenceListeners.containsKey(tab)) continue;
      void listener() => _scheduleSaveOpenTabsToDisk();
      _tabTitlePersistenceListeners[tab] = listener;
      tab.plugin.title.addListener(listener);
    }
  }

  void _removeTabTitlePersistenceListeners() {
    for (final entry in _tabTitlePersistenceListeners.entries) {
      entry.key.plugin.title.removeListener(entry.value);
    }
    _tabTitlePersistenceListeners.clear();
  }

  void _scheduleSaveOpenTabsToDisk() {
    if (!mounted || !_initialTabsHandled) return;
    _saveOpenTabsTimer?.cancel();
    _saveOpenTabsTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      unawaited(_saveOpenTabsToDisk());
    });
  }

  void _openLocalShell() {
    if (!_checkMaxShellsLimit()) return;

    selectProfileAndOpenShell(
      context: context,
      onProfileSelected: (profile) {
        _openLocalShellWithProfile(profile);
      },
    );
  }

  ShellProfile? _getDefaultShellProfile() {
    final profileState = context.read<ShellProfileBloc>().state;
    if (profileState is ShellProfileLoaded) {
      return profileState.defaultProfile;
    }
    return null;
  }

  TerminalPlugin _createTerminalPlugin([ShellProfile? profile]) {
    final effectiveProfile = profile ?? _getDefaultShellProfile();
    return TerminalPlugin(
      profileFontSize: effectiveProfile?.fontSize ?? 14.0,
      profileFontFamily: effectiveProfile?.fontFamily ?? 'Source Code Pro',
      profileCursorType:
          TerminalCursorType.values[(effectiveProfile?.cursorStyle ?? 0).clamp(
            0,
            TerminalCursorType.values.length - 1,
          )],
      scrollbackLines: effectiveProfile?.scrollbackLines ?? 10000,
    );
  }

  void _openLocalShellWithProfile(
    ShellProfile? profile, {
    String? workingDirectoryOverride,
    bool activate = true,
  }) {
    final inheritedWorkingDirectory =
        workingDirectoryOverride ?? _getInheritedWorkingDirectory(profile);
    final plugin = _createTerminalPlugin(profile);
    final settingsState = _terminalSettingsBloc.state;
    final globalEnv = settingsState is TerminalSettingsLoaded
        ? settingsState.environmentVariables
        : const <String, String>{};
    final mergedEnv = <String, String>{
      ...globalEnv,
      ...?profile?.parsedEnvironmentVariables,
    };
    final initCommands = profile?.generateInitCommands(
      includeEnvExports: false,
    );
    final hostSpec = createDefaultHostSpec(
      name: profile?.name,
      environment: mergedEnv,
      initCommands: (initCommands != null && initCommands.trim().isNotEmpty)
          ? initCommands
          : null,
      workingDirectory:
          inheritedWorkingDirectory ??
          ((profile?.workingDirectory.isNotEmpty ?? false)
              ? profile!.workingDirectory
              : null),
      shellCommand: profile?.parsedShellType.name,
    );

    final manager = PluginManager(hostSpec);
    final tabItem = PluginTab(plugin, manager, shellProfileId: profile?.id);
    _terminalTabBloc.add(TerminalTabOpenTab(tabItem, activate: activate));
    _requestTerminalFocus();

    _analytics.trackSessionCreated(
      SessionType.local,
      metadata: profile != null ? {'profile': profile.name} : null,
    );
  }

  String? _getInheritedWorkingDirectory(ShellProfile? profile) {
    if (profile?.inheritCurrentState != true) return null;
    final state = _terminalTabBloc.state;
    if (state is! TerminalTabLoaded || state.activeTab is! PluginTab) {
      return null;
    }
    final directory = (state.activeTab as PluginTab).currentWorkingDirectory;
    return directory.isNotEmpty ? directory : null;
  }

  /// Checks if opening a new shell would exceed the max open shells limit.
  /// Returns true if a new shell can be opened, false otherwise.
  bool _checkMaxShellsLimit() {
    final tabState = _terminalTabBloc.state;
    if (tabState is! TerminalTabLoaded) return true;

    final settingsState = context.read<TerminalSettingsBloc>().state;
    final maxShells = settingsState is TerminalSettingsLoaded
        ? settingsState.maxOpenShells
        : kTerminalDefaultMaxOpenShells;

    if (tabState.tabCount >= maxShells) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Maximum of $maxShells open sessions reached. '
            'Close a session or increase the limit in Settings.',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _openSshSession() async {
    if (!_checkMaxShellsLimit()) return;

    final host = await SshHostSelector.show(context);
    if (host != null && mounted) {
      // Load SSH key if using key authentication
      SshKeyData? keyData;
      final identityType = SshIdentityType.fromValue(host.identityType);
      if (identityType == SshIdentityType.key) {
        if (host.identityKeyId == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'No SSH key selected for this host. Please edit the host and select a key.',
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          return;
        }
        try {
          keyData = await _loadSshKeyData(host.identityKeyId!);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load SSH key: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          return;
        }
      }

      final plugin = _createTerminalPlugin();
      if (!mounted) return;
      final manager = PluginManager(_sshHostSpec(host, keyData: keyData));
      final tabItem = PluginTab(plugin, manager);
      _terminalTabBloc.add(TerminalTabOpenTab(tabItem));

      // Track SSH session creation
      _analytics.trackSessionCreated(
        SessionType.ssh,
        metadata: {
          'host': host.hostname ?? 'unknown',
          'auth_type': keyData != null ? 'key' : 'password',
        },
      );
    }
  }

  /// Loads SSH key data from the database by key ID.
  Future<SshKeyData> _loadSshKeyData(int keyId) async {
    final database = context.read<AppDatabase>();
    final credentials = context.read<SshCredentialRepository>();
    final key = await (database.select(
      database.sshKeys,
    )..where((t) => t.id.equals(keyId))).getSingleOrNull();

    if (key == null) {
      throw Exception('SSH key not found');
    }

    return SshKeyData(
      content: await credentials.readPrivateKey(key),
      passphrase: await credentials.readKeyPassphrase(key),
    );
  }

  Future<bool> _restoreOpenTabsFromDisk() async {
    final prefs = context.read<SharedPreferences>();
    final raw = prefs.getString(_persistedTabsKey);
    if (raw == null || raw.isEmpty) return false;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final tabData = decoded['tabs'];
      if (tabData is! List || tabData.isEmpty) return false;

      final activeIndex = decoded['activeIndex'] is int
          ? decoded['activeIndex'] as int
          : tabData.length - 1;
      var restoredCount = 0;
      for (var i = 0; i < tabData.length; i++) {
        if (!mounted) return restoredCount > 0;
        final item = tabData[i];
        if (item is! Map<String, dynamic>) continue;
        final activate = i == activeIndex;
        final restored = await _restoreTab(item, activate: activate);
        if (restored) restoredCount++;
      }

      if (restoredCount > 0) {
        _requestTerminalFocus();
        return true;
      }
    } catch (_) {
      await prefs.remove(_persistedTabsKey);
    }
    return false;
  }

  Future<bool> _restoreTab(
    Map<String, dynamic> item, {
    required bool activate,
  }) async {
    final type = item['type'];
    switch (type) {
      case 'local':
        final profile = _findShellProfile(item['profileId']);
        _openLocalShellWithProfile(
          profile,
          workingDirectoryOverride: item['workingDirectory'] as String?,
          activate: activate,
        );
        return true;
      case 'ssh':
        final hostId = item['hostId'];
        if (hostId is! int) return false;
        return _restoreSshSession(hostId, activate: activate);
      default:
        return false;
    }
  }

  ShellProfile? _findShellProfile(Object? profileId) {
    if (profileId is! int) return null;
    final state = context.read<ShellProfileBloc>().state;
    if (state is! ShellProfileLoaded) return null;
    for (final profile in state.profiles) {
      if (profile.id == profileId) return profile;
    }
    return null;
  }

  Future<bool> _restoreSshSession(int hostId, {required bool activate}) async {
    try {
      final database = context.read<AppDatabase>();
      final host = await (database.select(
        database.sshHosts,
      )..where((t) => t.id.equals(hostId))).getSingleOrNull();
      if (host == null) return false;

      SshKeyData? keyData;
      final identityType = SshIdentityType.fromValue(host.identityType);
      if (identityType == SshIdentityType.key) {
        final keyId = host.identityKeyId;
        if (keyId == null) return false;
        keyData = await _loadSshKeyData(keyId);
      }

      if (!mounted) return false;
      final plugin = _createTerminalPlugin();
      final manager = PluginManager(_sshHostSpec(host, keyData: keyData));
      final tabItem = PluginTab(plugin, manager);
      _terminalTabBloc.add(TerminalTabOpenTab(tabItem, activate: activate));
      return true;
    } catch (_) {
      return false;
    }
  }

  SSHHostSpec _sshHostSpec(SshHost host, {SshKeyData? keyData}) {
    final credentials = context.read<SshCredentialRepository>();
    final keys = context.read<SshHostKeyStore>();
    final navigator = Navigator.of(context, rootNavigator: true);
    return SSHHostSpec(
      host,
      keyData: keyData,
      passwordProvider: () => credentials.readHostPassword(host),
      verifyHostKey: (type, fingerprint) => keys.verify(
        host.hostname!,
        host.port!,
        type,
        fingerprint,
        onFirstUse: (key) => navigator.mounted
            ? showSshHostKeyConfirmation(navigator.context, key)
            : Future.value(false),
      ),
    );
  }

  Future<void> _saveOpenTabsToDisk() async {
    final settingsState = _terminalSettingsBloc.state;
    final prefs = _sharedPreferences;
    if (settingsState is! TerminalSettingsLoaded ||
        !settingsState.restoreTerminalTabs) {
      await prefs.remove(_persistedTabsKey);
      return;
    }

    final tabState = _terminalTabBloc.state;
    if (tabState is! TerminalTabLoaded) return;

    final tabs = tabState.allTabs.whereType<PluginTab>().toList();
    if (tabs.isEmpty) {
      await prefs.remove(_persistedTabsKey);
      return;
    }

    final activeTab = tabState.activeTab;
    final activeIndex = tabs.indexWhere((tab) => identical(tab, activeTab));
    final payload = <String, Object?>{
      'activeIndex': activeIndex >= 0 ? activeIndex : 0,
      'tabs': tabs.map(_encodeTab).whereType<Map<String, Object?>>().toList(),
    };
    await prefs.setString(_persistedTabsKey, jsonEncode(payload));
  }

  // TODO(upstream): gsmlg-app/web-terminal#7 - persist mobile local tabs.
  Map<String, Object?>? _encodeTab(PluginTab tab) {
    final hostSpec = tab.manager.hostSpec;
    if (hostSpec is SSHHostSpec) {
      return {'type': 'ssh', 'hostId': hostSpec.record.id};
    }
    if (hostSpec is LocalHostSpec) {
      return {
        'type': 'local',
        'profileId': tab.shellProfileId,
        'workingDirectory': tab.currentWorkingDirectory,
      };
    }
    return null;
  }

  // TODO(upstream): gsmlg-app/web-terminal#5 - implement the source SFTP action.
  void _openSftpSession() {
    // SFTP is planned for future release
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SFTP support coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showTabSwitcher() async {
    final state = _terminalTabBloc.state;
    if (state is! TerminalTabLoaded) return;
    final sessions = _buildSessionList(state);
    if (sessions.isEmpty) return;
    final currentId = state.activeTab?.hashCode.toString();
    final result = await showTabSwitcher(
      context,
      sessions: sessions,
      currentSessionId: currentId,
      onReorder: (sessionIds) {
        _terminalTabBloc.add(TerminalTabReorderSessions(sessionIds));
      },
      onRename: (sessionId, title) {
        _terminalTabBloc.add(TerminalTabRenameSession(sessionId, title));
      },
    );
    if (!mounted || result == null) return;
    switch (result) {
      case TabSwitcherSelect(:final sessionId):
        _terminalTabBloc.add(TerminalTabSelectSession(sessionId));
        _requestTerminalFocus();
      case TabSwitcherClose(:final sessionId):
        _terminalTabBloc.add(TerminalTabCloseSession(sessionId));
        _requestTerminalFocus();
      case TabSwitcherCloseSelected(:final sessionIds):
        for (final sessionId in sessionIds) {
          _terminalTabBloc.add(TerminalTabCloseSession(sessionId));
        }
        _requestTerminalFocus();
    }
  }

  /// Signals the active TerminalView to request focus after a tab switch.
  void _requestTerminalFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _terminalFocusNotifier.value++;
    });
  }

  void _openNewTabFromActiveSession() {
    final tabState = _terminalTabBloc.state;
    final activeTab = tabState is TerminalTabLoaded ? tabState.activeTab : null;
    if (activeTab is PluginTab && activeTab.manager.hostSpec is SSHHostSpec) {
      if (!_checkMaxShellsLimit()) return;
      final sshHostSpec = activeTab.manager.hostSpec as SSHHostSpec;
      final plugin = _createTerminalPlugin();
      final tabItem = PluginTab(plugin, activeTab.manager);
      _terminalTabBloc.add(TerminalTabOpenTab(tabItem));
      _requestTerminalFocus();

      _analytics.trackSessionCreated(
        SessionType.ssh,
        metadata: {
          'host': sshHostSpec.record.hostname ?? 'unknown',
          'auth_type': sshHostSpec.keyData != null ? 'key' : 'password',
        },
      );
      return;
    }

    _openLocalShell();
  }

  /// Handles tab management shortcuts at the TerminalView level.
  /// This runs before the terminal processes the key, so Ctrl+T, Ctrl+Shift+T,
  /// Cmd+T, etc. are intercepted without being sent to the shell.
  KeyEventResult _handleTerminalKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;
    final ctrl = HardwareKeyboard.instance.isControlPressed;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final meta = HardwareKeyboard.instance.isMetaPressed;
    final isApple =
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS;

    // New tab: Ctrl+T, Ctrl+Shift+T, or Cmd+T (macOS/iOS)
    if (key == LogicalKeyboardKey.keyT && (ctrl || (isApple && meta))) {
      _openNewTabFromActiveSession();
      return KeyEventResult.handled;
    }

    // Close active tab: Cmd+W (macOS/iOS) or Ctrl+Shift+W (Linux/Win)
    if (key == LogicalKeyboardKey.keyW &&
        ((isApple && meta && !shift) || (ctrl && shift))) {
      final state = _terminalTabBloc.state;
      if (state is TerminalTabLoaded && state.activeTab != null) {
        _terminalTabBloc.add(
          TerminalTabCloseSession(state.activeTab.hashCode.toString()),
        );
        _requestTerminalFocus();
      }
      return KeyEventResult.handled;
    }

    final mod = isApple ? meta : ctrl;
    if (!mod) return KeyEventResult.ignored;

    // Tab switcher: Ctrl+Shift+P (Linux/Win) / Cmd+Shift+P (macOS)
    if (key == LogicalKeyboardKey.keyP && shift) {
      _showTabSwitcher();
      return KeyEventResult.handled;
    }

    // Next tab: Ctrl+Shift+] (Linux/Win) / Cmd+Shift+] (macOS)
    // Shift+] produces } (braceRight)
    if (key == LogicalKeyboardKey.braceRight && shift) {
      _terminalTabBloc.add(TerminalTabNextTab());
      _requestTerminalFocus();
      return KeyEventResult.handled;
    }

    // Previous tab: Ctrl+Shift+[ (Linux/Win) / Cmd+Shift+[ (macOS)
    // Shift+[ produces { (braceLeft)
    if (key == LogicalKeyboardKey.braceLeft && shift) {
      _terminalTabBloc.add(TerminalTabPreviousTab());
      _requestTerminalFocus();
      return KeyEventResult.handled;
    }

    // Go to tab 1-9: Ctrl+1-9 (Linux/Win) / Cmd+1-9 (macOS)
    if (!shift) {
      const digitKeys = [
        LogicalKeyboardKey.digit1,
        LogicalKeyboardKey.digit2,
        LogicalKeyboardKey.digit3,
        LogicalKeyboardKey.digit4,
        LogicalKeyboardKey.digit5,
        LogicalKeyboardKey.digit6,
        LogicalKeyboardKey.digit7,
        LogicalKeyboardKey.digit8,
        LogicalKeyboardKey.digit9,
      ];
      final digitIndex = digitKeys.indexOf(key);
      if (digitIndex >= 0) {
        _terminalTabBloc.add(TerminalTabGoToTab(digitIndex));
        _requestTerminalFocus();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  List<SessionInfo> _buildSessionList(TerminalTabLoaded state) {
    return state.allTabs.map((tab) {
      String name = 'Terminal';
      bool isRunning = false;
      if (tab is PluginTab) {
        name = tab.displayTitle;
        isRunning = tab.manager.isConnected;
      }
      return SessionInfo(
        id: tab.hashCode.toString(),
        name: name,
        isRunning: isRunning,
        onClose: () {
          _terminalTabBloc.add(
            TerminalTabCloseSession(tab.hashCode.toString()),
          );
        },
      );
    }).toList();
  }

  String _getCurrentSessionName(TerminalTabLoaded state) {
    final activeTab = state.activeTab;
    if (activeTab == null) return 'Terminal';
    if (activeTab is PluginTab) {
      return activeTab.displayTitle;
    }
    return 'Terminal';
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = GlobalShortcuts(
      child: GlobalActions(
        child: SafeArea(
          child: BlocBuilder<TerminalTabBloc, TerminalTabState>(
            builder: (context, state) {
              if (state is! TerminalTabLoaded) {
                return const Center(child: CircularProgressIndicator());
              }

              final activePlugin = state.activeTab is PluginTab
                  ? (state.activeTab as PluginTab).plugin
                  : null;

              return Column(
                children: [
                  // AppBar for session management — listen to active
                  // plugin title so it updates on connection status change.
                  if (activePlugin != null)
                    ValueListenableBuilder<String?>(
                      valueListenable: activePlugin.title,
                      builder: (context, _, _) => TerminalAppBar(
                        currentSessionName: _getCurrentSessionName(state),
                        sessions: _buildSessionList(state),
                        onShowTabSwitcher: _showTabSwitcher,
                        onNewLocalShell: _openLocalShell,
                        onNewSshSession: _openSshSession,
                        onNewSftpSession: _openSftpSession,
                      ),
                    )
                  else
                    TerminalAppBar(
                      currentSessionName: _getCurrentSessionName(state),
                      sessions: _buildSessionList(state),
                      onShowTabSwitcher: _showTabSwitcher,
                      onNewLocalShell: _openLocalShell,
                      onNewSshSession: _openSshSession,
                      onNewSftpSession: _openSftpSession,
                    ),
                  // Terminal content area
                  Expanded(
                    child: TerminalShortcutHandler(
                      onKeyEvent: _handleTerminalKeyEvent,
                      focusNotifier: _terminalFocusNotifier,
                      child: _buildTerminalContent(state),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    if (defaultTargetPlatform == TargetPlatform.windows) {
      widget = VirtualWindowFrame(child: widget);
    }

    // Wrap with Actions to handle keyboard shortcuts
    widget = Actions(
      actions: {
        ToggleFullscreenIntent: CallbackAction<ToggleFullscreenIntent>(
          onInvoke: (_) {
            _terminalTabBloc.add(TerminalTabToggleFullscreen());
            return null;
          },
        ),
      },
      child: Focus(
        autofocus: true,
        onKeyEvent: _handleTerminalKeyEvent,
        child: widget,
      ),
    );

    return BlocBuilder<TerminalTabBloc, TerminalTabState>(
      buildWhen: (previous, current) {
        // Only rebuild when fullscreen state changes
        if (previous is TerminalTabLoaded && current is TerminalTabLoaded) {
          return previous.isFullscreen != current.isFullscreen;
        }
        return true;
      },
      builder: (context, state) {
        final isFullscreen = state is TerminalTabLoaded
            ? state.isFullscreen
            : false;

        return AppAdaptiveScaffold(
          navigationRestoreInHeader: true,
          selectedIndex: Destinations.indexOf(
            const Key(ToolboxScreen.name),
            context,
          ),
          onSelectedIndexChange: (idx) =>
              Destinations.changeHandler(idx, context),
          destinations: Destinations.navs(context),
          navigationVisible:
              !isFullscreen &&
              (!AppAdaptiveScaffold.appSmallBreakpoint.isActive(context) ||
                  MediaQuery.viewInsetsOf(context).bottom == 0),
          body: (context) => ContextMenuOverlay(child: widget),
        );
      },
    );
  }

  Widget _buildTerminalContent(TerminalTabLoaded state) {
    final activeTab = state.activeTab;

    if (activeTab == null) {
      // No active tab, show empty state
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.terminal,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No active session',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _openLocalShell,
              icon: const Icon(Icons.add),
              label: const Text('Open Local Shell'),
            ),
          ],
        ),
      );
    }

    // Show the active tab's content
    final content = activeTab.content.value;
    if (content != null) {
      return content;
    }

    return const Center(child: CircularProgressIndicator());
  }
}

class _TerminalLifecycleObserver extends WidgetsBindingObserver {
  final Future<void> Function() onAppExit;

  _TerminalLifecycleObserver({required this.onAppExit});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        unawaited(onAppExit());
        break;
      case AppLifecycleState.resumed:
        break;
    }
  }
}
