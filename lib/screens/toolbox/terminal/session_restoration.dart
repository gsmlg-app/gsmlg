part of 'terminal_native_screen.dart';

extension _SessionRestoration on _TerminalScreenState {
  void _onSessionsChanged() {
    if (!mounted || !_initialTabsHandled || _handlingInitialTabs) return;
    if (context.read<ShellProfileBloc>().state is! ShellProfileLoaded ||
        _terminalSettingsBloc.state is! TerminalSettingsLoaded) {
      return;
    }
    final sessions = _sessions;
    if (sessions == null || _restoring) return;
    final hasStartupPrompt =
        !sessions.startupPromptDismissed && sessions.store.latest != null;
    if (sessions.requestedRestore == null && !hasStartupPrompt) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _restoring) return;
      final requested = sessions.takeRestoreRequest();
      final startupPrompt =
          requested == null && !sessions.startupPromptDismissed;
      final snapshot =
          requested ?? (startupPrompt ? sessions.store.latest : null);
      if (snapshot != null) {
        unawaited(_restoreSnapshot(snapshot, startupPrompt: startupPrompt));
      }
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  Widget _sessionBanner() {
    final sessions = _sessions;
    if (sessions == null) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: sessions,
      builder: (context, _) {
        if (sessions.persistenceError == null) {
          return const SizedBox.shrink();
        }
        return MaterialBanner(
          content: Text(context.l10n.sessionPersistenceError),
          actions: [
            TextButton(
              onPressed: () => sessions.capture(force: true),
              child: Text(context.l10n.retry),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveSnapshot({bool groupOnly = false}) async {
    final sessions = _sessions;
    final state = _terminalTabBloc.state;
    if (sessions == null || state is! TerminalTabLoaded) return;
    final name = TextEditingController();
    String? groupId = state.activeTab == null
        ? null
        : state.grouping.groupIdOf(state.activeTab!);
    if (groupOnly) groupId ??= state.grouping.groups.firstOrNull?.id;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              groupOnly
                  ? context.l10n.sessionSaveGroup
                  : context.l10n.sessionSaveWorkspace,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.sessionSnapshotName,
                  ),
                ),
                if (groupOnly)
                  DropdownButtonFormField<String>(
                    initialValue: groupId,
                    items: [
                      for (final group in state.grouping.groups)
                        DropdownMenuItem(
                          value: group.id,
                          child: Text(group.name),
                        ),
                    ],
                    onChanged: (value) => setState(() => groupId = value),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  if (name.text.trim().isNotEmpty) Navigator.pop(context, true);
                },
                child: Text(context.l10n.save),
              ),
            ],
          );
        },
      ),
    );
    final label = name.text.trim();
    // The route finishes its reverse transition before controllers are disposed.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    name.dispose();
    if (accepted != true || !mounted) return;
    try {
      final layout = sessions.layout(groupOnly: groupOnly, groupId: groupId);
      if ((layout['tabs'] as List).isEmpty) {
        throw StateError(context.l10n.sessionSaveEmpty);
      }
      await sessions.save(label, groupOnly: groupOnly, groupId: groupId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.sessionSaved)));
      }
    } catch (error) {
      _showSessionError(error);
    }
  }

  Future<void> _restoreSnapshot(
    SessionSnapshot snapshot, {
    bool startupPrompt = false,
  }) async {
    if (_restoring) return;
    _restoring = true;
    try {
      final current = _terminalTabBloc.state;
      if (current is! TerminalTabLoaded) return;
      if (startupPrompt) _sessions?.dismissStartupPrompt();
      final groupOnly = snapshot.kind == SessionSnapshotKind.group;
      var append = false;
      String? target = current.activeTab == null
          ? null
          : current.grouping.groupIdOf(current.activeTab!);
      if (groupOnly) target ??= current.grouping.groups.firstOrNull?.id;
      final accepted = await showDialog<bool>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: Text(
                startupPrompt
                    ? context.l10n.sessionRestorePrompt
                    : snapshot.name ?? context.l10n.sessionRestore,
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(context.l10n.sessionRestoreDescription),
                    const SizedBox(height: 16),
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(
                          value: false,
                          label: Text(context.l10n.sessionReplace),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text(context.l10n.sessionAppend),
                        ),
                      ],
                      selected: {append},
                      onSelectionChanged: (value) =>
                          setState(() => append = value.single),
                    ),
                    if (groupOnly && !append)
                      DropdownButtonFormField<String>(
                        initialValue: target ?? '',
                        decoration: InputDecoration(
                          labelText: context.l10n.sessionTargetGroup,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: '',
                            child: Text(context.l10n.sessionNewGroup),
                          ),
                          for (final group in current.grouping.groups)
                            DropdownMenuItem(
                              value: group.id,
                              child: Text(group.name),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => target = value == '' ? null : value),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    startupPrompt
                        ? context.l10n.sessionLater
                        : context.l10n.cancel,
                  ),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(context.l10n.sessionRestore),
                ),
              ],
            ),
          );
        },
      );
      if (accepted != true || !mounted) return;
      final latest = _terminalTabBloc.state as TerminalTabLoaded;
      final replaced = append
          ? <TabItem>[]
          : [
              for (final tab in latest.allTabs)
                if (!groupOnly ||
                    (target != null &&
                        latest.grouping.groupIdOf(tab) == target))
                  tab,
            ];
      final busy = await findBusyTabs(replaced);
      if (!mounted ||
          (busy.isNotEmpty && !await confirmQuitWithBusyTabs(context, busy)) ||
          !mounted) {
        return;
      }
      await _applySnapshot(
        snapshot,
        append: append || (groupOnly && target == null),
        targetGroupId: target,
      );
      _sessions?.dismissStartupPrompt();
      _requestTerminalFocus();
    } catch (error) {
      _showSessionError(error);
    } finally {
      _restoring = false;
    }
  }

  Future<void> _applySnapshot(
    SessionSnapshot snapshot, {
    required bool append,
    String? targetGroupId,
  }) async {
    final layout = snapshot.layout;
    final groupOnly = snapshot.kind == SessionSnapshotKind.group;
    final groups = <TabGroup>[];
    final ids = <String, String>{};
    for (final raw in (layout['groups'] as List? ?? [])) {
      final id =
          'restore-${DateTime.now().microsecondsSinceEpoch}-${groups.length}';
      ids[raw['id'] as String] = id;
      groups.add(
        TabGroup(
          id: id,
          name: raw['name'] as String,
          collapsed: raw['collapsed'] == true,
        ),
      );
    }
    final tabs = <TabItem>[];
    final membership = <TabItem, String>{};
    for (final raw in layout['tabs'] as List) {
      final descriptor = Map<String, dynamic>.from(raw as Map);
      final tab = await _prepareRestoredTab(descriptor);
      tabs.add(tab);
      final id = ids[descriptor['groupId']];
      if (id != null) membership[tab] = id;
    }
    if (!mounted) {
      for (final tab in tabs) {
        tab.dispose();
      }
      return;
    }
    final applied = _terminalTabBloc.stream.firstWhere(
      (state) =>
          state is TerminalTabLoaded && tabs.every(state.allTabs.contains),
    );
    _terminalTabBloc.add(
      TerminalTabApplySnapshot(
        tabs: tabs,
        grouping: TabGrouping(
          groups: groups,
          membership: membership,
          ungroupedCollapsed: layout['ungroupedCollapsed'] == true,
        ),
        activeIndex: layout['activeIndex'] as int? ?? 0,
        append: append,
        groupOnly: groupOnly,
        targetGroupId: targetGroupId,
      ),
    );
    await applied;
    await _sessions?.capture(force: true);
  }

  Future<TabItem> _prepareRestoredTab(Map<String, dynamic> descriptor) async {
    final l10n = context.l10n;
    try {
      final storedDirectory = descriptor['workingDirectory'] as String?;
      final cwd = storedDirectory?.isEmpty == true ? null : storedDirectory;
      final PluginTab tab;
      if (descriptor['type'] == 'local') {
        final profile = _findShellProfile(descriptor['profileId']);
        if (descriptor['profileId'] != null && profile == null) {
          throw StateError(l10n.sessionMissingProfile);
        }
        final directory = cwd == '~'
            ? io.Platform.environment['HOME']
            : cwd?.replaceFirst(
                RegExp(r'^~/'),
                '${io.Platform.environment['HOME']}/',
              );
        if (directory != null && !await io.Directory(directory).exists()) {
          throw StateError(l10n.sessionMissingDirectory);
        }
        if (!mounted) throw StateError('Terminal screen closed');
        tab = _localTab(profile, directory);
      } else {
        final database = context.read<AppDatabase>();
        final host =
            await (database.select(database.sshHosts)..where(
                  (t) => t.id.equals(descriptor['hostId'] as int? ?? -1),
                ))
                .getSingleOrNull();
        if (!mounted) throw StateError('Terminal screen closed');
        if (host == null) throw StateError(l10n.sessionMissingHost);
        SshKeyData? key;
        if (SshIdentityType.fromValue(host.identityType) ==
            SshIdentityType.key) {
          if (host.identityKeyId == null) {
            throw StateError(l10n.sessionMissingHost);
          }
          key = await _loadSshKeyData(host.identityKeyId!);
        }
        if (!mounted) throw StateError('Terminal screen closed');
        final Plugin plugin = descriptor['type'] == 'sftp'
            ? FileManagerPlugin(initialDirectory: cwd == '~' ? null : cwd)
            : _createTerminalPlugin(null, cwd);
        tab = PluginTab(
          plugin,
          PluginManager(_sshHostSpec(host, keyData: key)),
        );
      }
      if (descriptor['customTitle'] case final String title) {
        tab.renameTitle(title);
      }
      if (cwd != null) _sessions?.rememberDirectory(tab, cwd);
      return tab;
    } catch (error) {
      late final UnavailableSessionTab tab;
      tab = UnavailableSessionTab(
        descriptor: descriptor,
        label:
            descriptor['customTitle'] as String? ??
            descriptor['workingDirectory'] as String? ??
            descriptor['type'] as String,
        child: Builder(
          builder: (context) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(context.l10n.sessionUnavailable),
                    const SizedBox(height: 12),
                    SelectableText('$error'),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context
                          .findAncestorStateOfType<_TerminalScreenState>()
                          ?._retryUnavailable(tab),
                      icon: const Icon(Icons.refresh),
                      label: Text(context.l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      return tab;
    }
  }

  Future<void> _retryUnavailable(UnavailableSessionTab tab) async {
    final descriptor = Map<String, dynamic>.from(tab.descriptor);
    final directory = TextEditingController(
      text: descriptor['workingDirectory'] as String?,
    );
    final profiles = context.read<ShellProfileBloc>().state;
    int? profileId = descriptor['profileId'] as int?;
    if (profiles is ShellProfileLoaded &&
        !profiles.profiles.any((p) => p.id == profileId)) {
      profileId = profiles.defaultProfile?.id;
    }
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.retry),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: directory,
                  decoration: InputDecoration(
                    labelText: context.l10n.sessionDirectory,
                  ),
                ),
                if (descriptor['type'] == 'local' &&
                    profiles is ShellProfileLoaded)
                  DropdownButtonFormField<int>(
                    initialValue: profileId,
                    decoration: InputDecoration(
                      labelText: context.l10n.sessionProfile,
                    ),
                    items: [
                      for (final p in profiles.profiles)
                        DropdownMenuItem(value: p.id, child: Text(p.name)),
                    ],
                    onChanged: (value) => setState(() => profileId = value),
                  ),
                if (descriptor['type'] != 'local')
                  TextButton(
                    onPressed: () async {
                      final host = await SshHostSelector.show(context);
                      if (host != null && context.mounted) {
                        setState(() => descriptor['hostId'] = host.id);
                      }
                    },
                    child: Text(
                      '${context.l10n.sessionHost}: ${descriptor['hostId'] ?? ''}',
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
    descriptor['workingDirectory'] = directory.text.trim();
    if (descriptor['type'] == 'local') descriptor['profileId'] = profileId;
    await Future<void>.delayed(const Duration(milliseconds: 300));
    directory.dispose();
    if (accepted != true || !mounted) return;
    final replacement = await _prepareRestoredTab(descriptor);
    if (!mounted) {
      replacement.dispose();
      return;
    }
    final state = _terminalTabBloc.state as TerminalTabLoaded;
    if (!state.allTabs.contains(tab)) {
      replacement.dispose();
      return;
    }
    final group = state.grouping.groupOf(tab);
    _terminalTabBloc.add(
      TerminalTabApplySnapshot(
        tabs: [replacement],
        replaceTab: tab,
        grouping: TabGrouping(
          groups: group == null ? [] : [group],
          membership: group == null ? {} : {replacement: group.id},
        ),
      ),
    );
  }

  void _showSessionError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${context.l10n.error}: $error')));
  }
}
