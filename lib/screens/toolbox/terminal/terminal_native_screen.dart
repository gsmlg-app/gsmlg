import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/settings/terminal/session_snapshots_screen.dart';
import 'package:gsmlg/screens/toolbox/terminal/services/session_controller.dart';
import 'package:gsmlg/screens/toolbox/terminal/services/session_store.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';
import 'package:flutter/services.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:file_manager_plugin/file_manager_plugin.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:app_logging/app_logging.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:gsmlg/destination.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/terminal_hosts.dart';
import 'package:terminal_plugin/terminal_plugin.dart';
import 'package:terminal_tabs/terminal_tabs.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xterm/xterm.dart' show TerminalCursorType;

import 'close_confirmation.dart';
import 'widgets/widgets.dart';

part 'session_restoration.dart';

class TerminalScreen extends StatefulWidget {
  static const name = 'TerminalScreen';
  static const path = 'terminal';

  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  late final TerminalTabBloc _terminalTabBloc;
  late final TerminalSettingsBloc _terminalSettingsBloc;
  SessionController? _sessions;
  final _analytics = TerminalAnalytics();
  final _terminalFocusNotifier = ValueNotifier<int>(0);
  StreamSubscription<TerminalTabState>? _stateSubscription;
  StreamSubscription<TerminalSettingsState>? _settingsSubscription;
  StreamSubscription<ShellProfileState>? _profileSubscription;
  bool _restoring = false;
  bool _initialTabsHandled = false;
  bool _handlingInitialTabs = false;
  bool? _previousFullscreenState;
  TerminalPlugin? _previousClipboardPlugin;
  bool? _previousClipboardSetting;
  bool _terminalClipboardRouteVisible = false;
  ModalRoute<dynamic>? _terminalClipboardRoute;

  @override
  void initState() {
    super.initState();
    _terminalTabBloc = context.read<TerminalTabBloc>();
    _terminalSettingsBloc = context.read<TerminalSettingsBloc>();
    try {
      _sessions = context.read<SessionController?>();
    } on ProviderNotFoundException {
      _sessions = null;
    }
    _sessions?.addListener(_onSessionsChanged);
    _terminalTabBloc.add(TerminalTabStart());
    // Listen for state changes to open initial tab when loaded
    _stateSubscription = _terminalTabBloc.stream.listen(_onStateChanged);
    _settingsSubscription = _terminalSettingsBloc.stream.listen(
      _onSettingsChanged,
    );
    _profileSubscription = context.read<ShellProfileBloc>().stream.listen(
      _onProfileChanged,
    );
    // Also check immediately in case state is already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryRestoreOrOpenInitialTabs();
    });
  }

  void _onStateChanged(TerminalTabState state) {
    final active = _activeClipboardPlugin(state);
    if (!identical(active, _previousClipboardPlugin)) {
      _previousClipboardPlugin?.invalidateIsolatedClipboardContext();
      active?.invalidateIsolatedClipboardContext();
      _previousClipboardPlugin = active;
    }
    if (_initialTabsHandled && !_handlingInitialTabs) {
      _sessions?.markReady();
    }
    _tryRestoreOrOpenInitialTabs();
    _trackFullscreenChange(state);
  }

  void _onSettingsChanged(TerminalSettingsState state) {
    final allowed =
        state is TerminalSettingsLoaded && state.allowRemoteClipboardWrites;
    if (_previousClipboardSetting != allowed) {
      _activeClipboardPlugin(
        _terminalTabBloc.state,
      )?.invalidateIsolatedClipboardContext();
      _previousClipboardSetting = allowed;
    }
    _tryRestoreOrOpenInitialTabs();
    _onSessionsChanged();
  }

  void _onProfileChanged(ShellProfileState state) {
    _tryRestoreOrOpenInitialTabs();
    _onSessionsChanged();
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
      _sessions?.markReady();
      _onSessionsChanged();
      return;
    }
    // TODO(upstream): gsmlg-app/web-terminal#6 - wait for profile readiness.
    final profileState = context.read<ShellProfileBloc>().state;
    if (profileState is! ShellProfileLoaded) {
      return;
    }

    _handlingInitialTabs = true;
    _initialTabsHandled = true;
    try {
      _openLocalShellWithProfile(profileState.defaultProfile);
    } finally {
      _handlingInitialTabs = false;
      _onSessionsChanged();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    final visible = route?.isCurrent ?? true;
    if (_terminalClipboardRouteVisible != visible ||
        !identical(_terminalClipboardRoute, route)) {
      _terminalClipboardRoute = route;
      _terminalClipboardRouteVisible = visible;
      _activeClipboardPlugin(
        _terminalTabBloc.state,
      )?.invalidateIsolatedClipboardContext();
    }
    _sessions?.setTerminalRouteVisible(visible);
  }

  @override
  void dispose() {
    _terminalClipboardRouteVisible = false;
    _activeClipboardPlugin(
      _terminalTabBloc.state,
    )?.invalidateIsolatedClipboardContext();
    _sessions?.setTerminalRouteVisible(false);
    _sessions?.removeListener(_onSessionsChanged);
    _stateSubscription?.cancel();
    _settingsSubscription?.cancel();
    _profileSubscription?.cancel();
    _terminalFocusNotifier.dispose();
    // The application owns the tabs and their connections across route changes.
    super.dispose();
  }

  /// Opens a local shell after choosing a profile, in [groupId] if given.
  void _openLocalShell({String? groupId}) {
    if (context.read<ShellProfileBloc>().state is! ShellProfileLoaded) return;

    final state = _terminalTabBloc.state;
    final active = state is TerminalTabLoaded ? state.activeTab : null;
    final source = active is PluginTab ? active : null;
    final plugin = source?.plugin;
    final sourceSession = plugin is TerminalPlugin ? plugin.session : null;
    final cachedDirectory = source == null
        ? null
        : _sessions?.cachedDirectory(source) ?? source.currentWorkingDirectory;
    selectProfileAndOpenShell(
      context: context,
      onProfileSelected: (profile) {
        unawaited(
          _openLocalShellInLiveDirectory(
            profile,
            source: source,
            sourceSession: sourceSession,
            cachedDirectory: cachedDirectory,
            groupId: groupId,
          ),
        );
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

  TerminalPlugin? _activeClipboardPlugin(TerminalTabState state) {
    final tab = state is TerminalTabLoaded ? state.activeTab : null;
    final plugin = tab is PluginTab ? tab.plugin : null;
    return plugin is TerminalPlugin ? plugin : null;
  }

  TerminalPlugin _createTerminalPlugin([
    ShellProfile? profile,
    String? startDirectory,
  ]) {
    final effectiveProfile = profile ?? _getDefaultShellProfile();
    late final TerminalPlugin plugin;
    plugin = TerminalPlugin(
      isExperimentalClipboardTabActive: () =>
          mounted &&
          _terminalClipboardRouteVisible &&
          (_terminalClipboardRoute?.isCurrent ?? false) &&
          identical(_activeClipboardPlugin(_terminalTabBloc.state), plugin),
      profileFontSize: effectiveProfile?.fontSize ?? 14.0,
      profileFontFamily: effectiveProfile?.fontFamily ?? 'Source Code Pro',
      profileCursorType:
          TerminalCursorType.values[(effectiveProfile?.cursorStyle ?? 0).clamp(
            0,
            TerminalCursorType.values.length - 1,
          )],
      scrollbackLines: effectiveProfile?.scrollbackLines ?? 10000,
      fileAccess: IoZmodemFileAccess(settings: _zmodemDownloadSettings),
      remoteClipboardWritesAllowed: () {
        final state = _terminalSettingsBloc.state;
        return state is TerminalSettingsLoaded &&
            state.allowRemoteClipboardWrites;
      },
      startDirectory: startDirectory,
    );
    return plugin;
  }

  /// Current `sz` download settings, read when a transfer starts.
  ZmodemDownloadSettings _zmodemDownloadSettings() {
    final state = _terminalSettingsBloc.state;
    if (state is! TerminalSettingsLoaded) {
      return (mode: ZmodemDownloadMode.saveToFolder, directory: null);
    }
    return (
      mode: ZmodemDownloadMode.values.byName(state.downloadMode.name),
      directory: state.downloadDirectory,
    );
  }

  void _openLocalShellWithProfile(
    ShellProfile? profile, {
    String? workingDirectoryOverride,
    bool activate = true,
    bool inheritFromActive = true,
    String? groupId,
  }) {
    final tabItem = _localTab(
      profile,
      workingDirectoryOverride,
      inheritFromActive: inheritFromActive,
    );
    _terminalTabBloc.add(
      TerminalTabOpenTab(tabItem, activate: activate, groupId: groupId),
    );
    _requestTerminalFocus();

    _analytics.trackSessionCreated(
      SessionType.local,
      metadata: profile != null ? {'profile': profile.name} : null,
    );
  }

  PluginTab _localTab(
    ShellProfile? profile,
    String? workingDirectoryOverride, {
    bool inheritFromActive = true,
  }) {
    final inheritedWorkingDirectory =
        workingDirectoryOverride ??
        (inheritFromActive ? _getInheritedWorkingDirectory(profile) : null);
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
    return PluginTab(plugin, manager, shellProfileId: profile?.id);
  }

  /// Opens a local shell, inheriting the active shell's real directory when
  /// the profile asks for it. The directory comes from the operating system,
  /// so it works even when the shell does not report its directory.
  Future<void> _openLocalShellInLiveDirectory(
    ShellProfile? profile, {
    required PluginTab? source,
    required ExecutionSession? sourceSession,
    required String? cachedDirectory,
    String? groupId,
  }) async {
    String? liveDirectory;
    if (profile?.inheritCurrentState == true) {
      final plugin = source?.plugin;
      if (plugin is TerminalPlugin &&
          sourceSession != null &&
          identical(plugin.session, sourceSession)) {
        liveDirectory = await _queryDirectoryForOpen(plugin);
      }
      if (!mounted) return;
      if (plugin is TerminalPlugin &&
          !identical(plugin.session, sourceSession)) {
        liveDirectory = null;
      }
      liveDirectory ??= cachedDirectory;
    }
    _openLocalShellWithProfile(
      profile,
      workingDirectoryOverride: liveDirectory,
      inheritFromActive: false,
      groupId: groupId,
    );
  }

  Future<String?> _queryDirectoryForOpen(TerminalPlugin plugin) => plugin
      .liveWorkingDirectory()
      .timeout(const Duration(seconds: 2), onTimeout: () => null);

  String? _getInheritedWorkingDirectory(ShellProfile? profile) {
    if (profile?.inheritCurrentState != true) return null;
    final state = _terminalTabBloc.state;
    if (state is! TerminalTabLoaded || state.activeTab is! PluginTab) {
      return null;
    }
    final directory = (state.activeTab as PluginTab).currentWorkingDirectory;
    return directory.isNotEmpty ? directory : null;
  }

  Future<void> _openSshSession() async {
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

  ShellProfile? _findShellProfile(Object? profileId) {
    if (profileId is! int) return null;
    final state = context.read<ShellProfileBloc>().state;
    if (state is! ShellProfileLoaded) return null;
    for (final profile in state.profiles) {
      if (profile.id == profileId) return profile;
    }
    return null;
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

  Future<void> _openSftpSession() async {
    final host = await SshHostSelector.show(context);
    if (host == null || !mounted) return;

    try {
      SshKeyData? keyData;
      if (SshIdentityType.fromValue(host.identityType) == SshIdentityType.key) {
        final keyId = host.identityKeyId;
        if (keyId == null) throw StateError('SSH key not found');
        keyData = await _loadSshKeyData(keyId);
      }
      if (!mounted) return;
      PluginManager? manager;
      final state = _terminalTabBloc.state;
      if (state is TerminalTabLoaded && state.activeTab is PluginTab) {
        final activeManager = (state.activeTab as PluginTab).manager;
        final spec = activeManager.hostSpec;
        if (activeManager.isConnected &&
            spec is SSHHostSpec &&
            spec.record == host) {
          manager = activeManager;
        }
      }
      manager ??= PluginManager(_sshHostSpec(host, keyData: keyData));
      final tab = PluginTab(FileManagerPlugin(), manager);
      _terminalTabBloc.add(TerminalTabOpenTab(tab));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${context.l10n.error}: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  TabSwitcherData _buildSwitcherData(
    TerminalTabLoaded state,
    Set<TabItem> busyTabs,
  ) {
    return TabSwitcherData(
      sessions: _buildSessionList(state, busyTabs: busyTabs),
      currentSessionId: state.activeTab?.hashCode.toString(),
      groups: [
        for (final group in state.grouping.groups)
          TabSwitcherGroup(
            id: group.id,
            name: group.name,
            collapsed: group.collapsed,
          ),
      ],
      ungroupedCollapsed: state.grouping.ungroupedCollapsed,
    );
  }

  Future<void> _closeGroup(String groupId) async {
    final state = _terminalTabBloc.state;
    if (state is! TerminalTabLoaded) return;
    final tabs = [
      for (final tab in state.allTabs)
        if (state.grouping.groupIdOf(tab) == groupId) tab,
    ];
    if (tabs.isEmpty) return;
    if (!await confirmCloseGroup(context, tabs) || !mounted) return;
    final current = _terminalTabBloc.state;
    if (current is! TerminalTabLoaded) return;
    for (final tab in tabs) {
      if (!current.allTabs.contains(tab)) continue;
      _terminalTabBloc.add(TerminalTabCloseSession(tab.hashCode.toString()));
    }
  }

  Future<void> _showTabSwitcher({bool currentGroupOnly = false}) async {
    final state = _terminalTabBloc.state;
    if (state is! TerminalTabLoaded) return;
    final busyTabs = (await findBusyTabs(state.allTabs)).toSet();
    if (!mounted) return;
    final latest = _terminalTabBloc.state;
    if (latest is! TerminalTabLoaded || latest.allTabs.isEmpty) return;
    final data = ValueNotifier<TabSwitcherData>(
      _buildSwitcherData(latest, busyTabs),
    );
    final subscription = _terminalTabBloc.stream.listen((next) {
      if (next is TerminalTabLoaded) {
        data.value = _buildSwitcherData(next, busyTabs);
      }
    });
    final TabSwitcherResult? result;
    try {
      result = await showTabSwitcher(
        context,
        data: data,
        currentGroupOnly: currentGroupOnly,
        callbacks: TabSwitcherCallbacks(
          onRename: (sessionId, title) {
            _terminalTabBloc.add(TerminalTabRenameSession(sessionId, title));
          },
          onMoveBefore: (sessionId, targetSessionId) {
            _terminalTabBloc.add(
              TerminalTabMoveTabBefore(sessionId, targetSessionId),
            );
          },
          onCreateGroup: (sessionId, name) {
            _terminalTabBloc.add(TerminalTabCreateGroup(sessionId, name));
          },
          onMoveToGroup: (sessionId, groupId) {
            _terminalTabBloc.add(TerminalTabMoveToGroup(sessionId, groupId));
          },
          onUngroup: (sessionId) {
            _terminalTabBloc.add(TerminalTabUngroup(sessionId));
          },
          onRenameGroup: (groupId, name) {
            _terminalTabBloc.add(TerminalTabRenameGroup(groupId, name));
          },
          onMoveGroupBefore: (groupId, targetGroupId) {
            _terminalTabBloc.add(
              TerminalTabMoveGroupBefore(groupId, targetGroupId),
            );
          },
          onToggleCollapsed: (groupId) {
            _terminalTabBloc.add(TerminalTabToggleGroupCollapsed(groupId));
          },
          onCloseGroup: (groupId) => unawaited(_closeGroup(groupId)),
          onMoveSessionsToGroup: (sessionIds, groupId) {
            _terminalTabBloc.add(
              TerminalTabMoveSessionsToGroup(sessionIds, groupId),
            );
          },
          onCreateGroupWithSessions: (sessionIds, name) {
            _terminalTabBloc.add(
              TerminalTabCreateGroupWithSessions(sessionIds, name),
            );
          },
          onUngroupSessions: (sessionIds) {
            _terminalTabBloc.add(TerminalTabUngroupSessions(sessionIds));
          },
        ),
      );
    } finally {
      await subscription.cancel();
      data.dispose();
    }
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

  Future<void> _closeActiveTab() async {
    final state = _terminalTabBloc.state;
    final activeTab = state is TerminalTabLoaded ? state.activeTab : null;
    if (activeTab == null) return;
    if (!await confirmCloseTab(context, activeTab)) {
      _requestTerminalFocus();
      return;
    }
    if (!mounted) return;
    final current = _terminalTabBloc.state;
    if (current is! TerminalTabLoaded || !current.allTabs.contains(activeTab)) {
      return;
    }
    _terminalTabBloc.add(
      TerminalTabCloseSession(activeTab.hashCode.toString()),
    );
    _requestTerminalFocus();
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
    final groupId = activeTab != null && tabState is TerminalTabLoaded
        ? tabState.grouping.groupIdOf(activeTab)
        : null;
    if (activeTab is PluginTab && activeTab.manager.hostSpec is SSHHostSpec) {
      unawaited(_openSshTabBeside(activeTab, groupId: groupId));
      return;
    }

    _openLocalShell(groupId: groupId);
  }

  /// Opens another shell on [activeTab]'s connection, in the remote
  /// directory its shell is in now.
  Future<void> _openSshTabBeside(PluginTab activeTab, {String? groupId}) async {
    final activePlugin = activeTab.plugin;
    final sourceSession = activePlugin is TerminalPlugin
        ? activePlugin.session
        : null;
    final directory = activePlugin is TerminalPlugin && sourceSession != null
        ? await _queryDirectoryForOpen(activePlugin)
        : null;
    if (!mounted) return;
    final state = _terminalTabBloc.state;
    if (state is! TerminalTabLoaded ||
        !state.allTabs.contains(activeTab) ||
        (activePlugin is TerminalPlugin &&
            !identical(sourceSession, activePlugin.session))) {
      return;
    }
    final sshHostSpec = activeTab.manager.hostSpec as SSHHostSpec;
    final plugin = _createTerminalPlugin(
      null,
      directory ??
          (activePlugin is TerminalPlugin
              ? _sessions?.cachedDirectory(activeTab)
              : null),
    );
    final tabItem = PluginTab(plugin, activeTab.manager);
    _terminalTabBloc.add(TerminalTabOpenTab(tabItem, groupId: groupId));
    _requestTerminalFocus();

    _analytics.trackSessionCreated(
      SessionType.ssh,
      metadata: {
        'host': sshHostSpec.record.hostname ?? 'unknown',
        'auth_type': sshHostSpec.keyData != null ? 'key' : 'password',
      },
    );
  }

  /// Handles tab management shortcuts at the TerminalView level.
  /// This runs before the terminal processes the key, so Ctrl+T, Ctrl+Shift+T,
  /// Cmd+T, etc. are intercepted without being sent to the shell.
  KeyEventResult _handleTerminalKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    final ctrl = HardwareKeyboard.instance.isControlPressed;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final meta = HardwareKeyboard.instance.isMetaPressed;
    final isApple =
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS;

    if (event is KeyRepeatEvent &&
        key != LogicalKeyboardKey.bracketRight &&
        key != LogicalKeyboardKey.braceRight &&
        key != LogicalKeyboardKey.bracketLeft &&
        key != LogicalKeyboardKey.braceLeft) {
      return KeyEventResult.ignored;
    }

    // New tab: Cmd+T (macOS/iOS) or Ctrl+T / Ctrl+Shift+T (other platforms)
    if (key == LogicalKeyboardKey.keyT && (isApple ? meta : ctrl)) {
      _openNewTabFromActiveSession();
      return KeyEventResult.handled;
    }

    // Close active tab: Cmd+W (macOS/iOS) or Ctrl+Shift+W (Linux/Win)
    if (key == LogicalKeyboardKey.keyW &&
        ((isApple && meta && !shift) || (ctrl && shift))) {
      unawaited(_closeActiveTab());
      return KeyEventResult.handled;
    }

    final mod = isApple ? meta : ctrl;
    if (!mod) return KeyEventResult.ignored;

    // Tab switcher: Ctrl+Shift+P (Linux/Win) / Cmd+Shift+P (macOS)
    if (key == LogicalKeyboardKey.keyP && shift) {
      _showTabSwitcher();
      return KeyEventResult.handled;
    }

    // Current group only: Ctrl+Shift+O (Linux/Win) / Cmd+Shift+O (macOS)
    if (key == LogicalKeyboardKey.keyO && shift) {
      _showTabSwitcher(currentGroupOnly: true);
      return KeyEventResult.handled;
    }

    // Next tab: Cmd+] / Cmd+Shift+] (Apple), Ctrl+Shift+] elsewhere.
    if ((isApple || shift) &&
        (key == LogicalKeyboardKey.bracketRight ||
            (shift && key == LogicalKeyboardKey.braceRight))) {
      _terminalTabBloc.add(TerminalTabNextTab());
      _requestTerminalFocus();
      return KeyEventResult.handled;
    }

    // Previous tab: Cmd+[ / Cmd+Shift+[ (Apple), Ctrl+Shift+[ elsewhere.
    if ((isApple || shift) &&
        (key == LogicalKeyboardKey.bracketLeft ||
            (shift && key == LogicalKeyboardKey.braceLeft))) {
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

  List<SessionInfo> _buildSessionList(
    TerminalTabLoaded state, {
    Set<TabItem> busyTabs = const <TabItem>{},
  }) {
    return state.allTabs.map((tab) {
      String name = 'Terminal';
      if (tab is PluginTab) {
        name = tab.displayTitle;
      } else if (tab is UnavailableSessionTab) {
        name = tab.label;
      }
      final isRunning = busyTabs.contains(tab);
      return SessionInfo(
        id: tab.hashCode.toString(),
        name: name,
        isRunning: isRunning,
        groupId: state.grouping.groupIdOf(tab),
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
    final name = activeTab is PluginTab
        ? activeTab.displayTitle
        : activeTab is UnavailableSessionTab
        ? activeTab.label
        : 'Terminal';
    final group = state.grouping.groupOf(activeTab);
    return group == null ? name : '${group.name} · $name';
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

              final activeTab = state.activeTab;
              final activePlugin = activeTab is PluginTab
                  ? activeTab.plugin
                  : null;

              return Column(
                children: [
                  if (activeTab is PluginTab)
                    ValueListenableBuilder<Widget?>(
                      valueListenable: activeTab.title,
                      builder: (context, _, _) => TerminalAppBar(
                        terminalActions: activePlugin is TerminalPlugin
                            ? TerminalClipboardMenu(plugin: activePlugin)
                            : null,
                        currentSessionName: _getCurrentSessionName(state),
                        sessions: _buildSessionList(state),
                        onShowTabSwitcher: _showTabSwitcher,
                        onNewLocalShell: _openLocalShell,
                        onNewSshSession: _openSshSession,
                        onNewSftpSession: _openSftpSession,
                        onSaveWorkspace: _sessions == null
                            ? null
                            : () => _saveSnapshot(),
                        onSaveGroup:
                            _sessions == null || state.grouping.groups.isEmpty
                            ? null
                            : () => _saveSnapshot(groupOnly: true),
                        onManageSnapshots: _sessions == null
                            ? null
                            : () =>
                                  context.goNamed(SessionSnapshotsScreen.name),
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
                      onSaveWorkspace: _sessions == null
                          ? null
                          : () => _saveSnapshot(),
                      onSaveGroup:
                          _sessions == null || state.grouping.groups.isEmpty
                          ? null
                          : () => _saveSnapshot(groupOnly: true),
                      onManageSnapshots: _sessions == null
                          ? null
                          : () => context.goNamed(SessionSnapshotsScreen.name),
                    ),
                  _sessionBanner(),
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
      return BlocBuilder<ShellProfileBloc, ShellProfileState>(
        builder: (context, profileState) {
          if (profileState is ShellProfileError) {
            return Center(
              child: Text('${context.l10n.error}: ${profileState.error}'),
            );
          }
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
        },
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
