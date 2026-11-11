import 'dart:async';
import 'dart:convert';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/foundation.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

import 'close_confirmation.dart';
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
    if (profileState is! ShellProfileLoaded) {
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
    if (context.read<ShellProfileBloc>().state is! ShellProfileLoaded) return;
    if (!_checkMaxShellsLimit()) return;

    selectProfileAndOpenShell(
      context: context,
      onProfileSelected: (profile) {
        unawaited(_openLocalShellInLiveDirectory(profile));
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
      fileAccess: IoZmodemFileAccess(settings: _zmodemDownloadSettings),
    );
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
    String? groupId,
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
    _terminalTabBloc.add(
      TerminalTabOpenTab(tabItem, activate: activate, groupId: groupId),
    );
    _requestTerminalFocus();

    _analytics.trackSessionCreated(
      SessionType.local,
      metadata: profile != null ? {'profile': profile.name} : null,
    );
  }

  /// Opens a local shell, inheriting the active shell's real directory when
  /// the profile asks for it. The directory comes from the operating system,
  /// so it works even when the shell does not report its directory.
  Future<void> _openLocalShellInLiveDirectory(ShellProfile? profile) async {
    String? liveDirectory;
    if (profile?.inheritCurrentState == true) {
      liveDirectory = await _activeLiveWorkingDirectory();
      if (!mounted) return;
    }
    _openLocalShellWithProfile(
      profile,
      workingDirectoryOverride: liveDirectory,
    );
  }

  Future<String?> _activeLiveWorkingDirectory() async {
    final state = _terminalTabBloc.state;
    if (state is! TerminalTabLoaded) return null;
    final activeTab = state.activeTab;
    if (activeTab is! PluginTab) return null;
    final plugin = activeTab.plugin;
    return plugin is TerminalPlugin ? plugin.liveWorkingDirectory() : null;
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
      _terminalTabBloc.add(
        TerminalTabRestoreGroups(
          _decodeGroups(decoded['groups']),
          ungroupedCollapsed: decoded['ungroupedCollapsed'] == true,
        ),
      );
      var restoredCount = 0;
      for (var i = 0; i < tabData.length; i++) {
        if (!mounted) return restoredCount > 0;
        final item = tabData[i];
        if (item is! Map<String, dynamic>) continue;
        final activate = i == activeIndex;
        final restored = await _restoreTab(item, activate: activate);
        if (restored) restoredCount++;
      }
      _terminalTabBloc.add(TerminalTabFinishGroupRestore());

      if (restoredCount > 0) {
        _requestTerminalFocus();
        return true;
      }
    } catch (_) {
      await prefs.remove(_persistedTabsKey);
    }
    return false;
  }

  List<TabGroup> _decodeGroups(Object? raw) {
    if (raw is! List) return const <TabGroup>[];
    return [
      for (final entry in raw)
        if (entry is Map &&
            entry['id'] is String &&
            entry['name'] is String &&
            (entry['name'] as String).trim().isNotEmpty)
          TabGroup(
            id: entry['id'] as String,
            name: (entry['name'] as String).trim(),
            collapsed: entry['collapsed'] == true,
          ),
    ];
  }

  Future<bool> _restoreTab(
    Map<String, dynamic> item, {
    required bool activate,
  }) async {
    final type = item['type'];
    final groupId = item['groupId'] is String
        ? item['groupId'] as String
        : null;
    switch (type) {
      case 'local':
        final profile = _findShellProfile(item['profileId']);
        _openLocalShellWithProfile(
          profile,
          workingDirectoryOverride: item['workingDirectory'] as String?,
          activate: activate,
          groupId: groupId,
        );
        return true;
      case 'ssh':
      case 'sftp':
        final hostId = item['hostId'];
        if (hostId is! int) return false;
        return _restoreSshSession(
          hostId,
          activate: activate,
          sftp: item['type'] == 'sftp',
          groupId: groupId,
        );
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

  Future<bool> _restoreSshSession(
    int hostId, {
    required bool activate,
    bool sftp = false,
    String? groupId,
  }) async {
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
      final Plugin plugin = sftp
          ? FileManagerPlugin()
          : _createTerminalPlugin();
      final manager = PluginManager(_sshHostSpec(host, keyData: keyData));
      final tabItem = PluginTab(plugin, manager);
      _terminalTabBloc.add(
        TerminalTabOpenTab(tabItem, activate: activate, groupId: groupId),
      );
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

    final grouping = tabState.grouping;
    final tabs = <PluginTab>[];
    final descriptors = <Map<String, Object?>>[];
    for (final tab in tabState.allTabs.whereType<PluginTab>()) {
      final descriptor = _encodeTab(tab);
      if (descriptor == null) continue;
      if (descriptor['type'] == 'local') {
        final plugin = tab.plugin;
        final liveDirectory = plugin is TerminalPlugin
            ? await plugin.liveWorkingDirectory()
            : null;
        if (liveDirectory != null) {
          descriptor['workingDirectory'] = liveDirectory;
        }
      }
      final groupId = grouping.groupIdOf(tab);
      if (groupId != null) descriptor['groupId'] = groupId;
      tabs.add(tab);
      descriptors.add(descriptor);
    }
    if (tabs.isEmpty) {
      await prefs.remove(_persistedTabsKey);
      return;
    }

    final activeTab = tabState.activeTab;
    final activeIndex = tabs.indexWhere((tab) => identical(tab, activeTab));
    final savedGroupIds = {
      for (final descriptor in descriptors) descriptor['groupId'],
    };
    final groups = [
      for (final group in grouping.groups)
        if (savedGroupIds.contains(group.id))
          {'id': group.id, 'name': group.name, 'collapsed': group.collapsed},
    ];
    final payload = <String, Object?>{
      'activeIndex': activeIndex >= 0 ? activeIndex : 0,
      'tabs': descriptors,
      if (groups.isNotEmpty) 'groups': groups,
      if (grouping.ungroupedCollapsed) 'ungroupedCollapsed': true,
    };
    await prefs.setString(_persistedTabsKey, jsonEncode(payload));
  }

  // TODO(upstream): gsmlg-app/web-terminal#7 - persist mobile local tabs.
  Map<String, Object?>? _encodeTab(PluginTab tab) {
    final hostSpec = tab.manager.hostSpec;
    if (hostSpec is SSHHostSpec) {
      return {
        'type': tab.plugin is FileManagerPlugin ? 'sftp' : 'ssh',
        'hostId': hostSpec.record.id,
      };
    }
    if (hostSpec is LocalHostSpec ||
        hostSpec is AndroidHostSpec ||
        hostSpec is IosHostSpec) {
      return {
        'type': 'local',
        'profileId': tab.shellProfileId,
        'workingDirectory': tab.currentWorkingDirectory,
      };
    }
    return null;
  }

  Future<void> _openSftpSession() async {
    if (!_checkMaxShellsLimit()) return;
    final host = await SshHostSelector.show(context);
    if (host == null || !mounted || !_checkMaxShellsLimit()) return;

    try {
      SshKeyData? keyData;
      if (SshIdentityType.fromValue(host.identityType) == SshIdentityType.key) {
        final keyId = host.identityKeyId;
        if (keyId == null) throw StateError('SSH key not found');
        keyData = await _loadSshKeyData(keyId);
      }
      if (!mounted || !_checkMaxShellsLimit()) return;
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

  List<SessionInfo> _buildSessionList(
    TerminalTabLoaded state, {
    Set<TabItem> busyTabs = const <TabItem>{},
  }) {
    return state.allTabs.map((tab) {
      String name = 'Terminal';
      if (tab is PluginTab) {
        name = tab.displayTitle;
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
    final name = activeTab is PluginTab ? activeTab.displayTitle : 'Terminal';
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

  /// Saves open tabs before quitting. A `cd` does not change any app state,
  /// so without this the saved working directories could be stale.
  @override
  Future<AppExitResponse> didRequestAppExit() async {
    await onAppExit();
    return AppExitResponse.exit;
  }
}
