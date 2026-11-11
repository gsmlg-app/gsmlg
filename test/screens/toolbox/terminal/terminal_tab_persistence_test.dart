import 'dart:convert';
import 'dart:io';

import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/terminal_hosts.dart';
import 'package:terminal_plugin/terminal_plugin.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:terminal_tabs/terminal_tabs.dart';
import 'package:gsmlg/screens/toolbox/terminal/terminal_screen.dart';

const _tabsKey = 'terminal.open_tabs.v1';

class _UnusedVault extends Fake implements VaultRepository {}

class _Profiles extends ShellProfileBloc {
  _Profiles(super.database) {
    emit(ShellProfileLoaded([_profile(11), _profile(22)]));
  }
}

class _Settings extends TerminalSettingsBloc {
  _Settings() : super(vault: _UnusedVault()) {
    emit(const TerminalSettingsLoaded(restoreTerminalTabs: true));
  }
}

class _Tabs extends TerminalTabBloc {
  final opened = <PluginTab>[];

  @override
  void add(TerminalTabEvent event) {
    if (event is TerminalTabOpenTab && event.tabItem is PluginTab) {
      final tab = event.tabItem as PluginTab;
      opened.add(tab);
      // Exercise persistence and host creation without starting shell processes.
      tab.content.value = const SizedBox.shrink();
    }
    super.add(event);
  }
}

class _UnsupportedSpec extends Fake implements HostSpec {}

ShellProfile _profile(int id) => ShellProfile(
  id: id,
  name: 'Profile $id',
  shellType: ShellType.bash.value,
  environmentVariables: '{"PROFILE":"$id"}',
  aliases: '{}',
  fontFamily: 'Profile font $id',
  fontSize: id == 11 ? 16 : 18,
  colorTheme: 'default',
  workingDirectory: '/profile/$id',
  startupCommand: 'echo profile-$id',
  cursorStyle: 0,
  scrollbackLines: 1000,
  isDefault: id == 11,
  inheritCurrentState: false,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

class _Harness {
  _Harness(this.preferences)
    : database = AppDatabase.forTesting(),
      tabs = _Tabs(),
      settings = _Settings() {
    profiles = _Profiles(database);
  }

  final SharedPreferences preferences;
  final AppDatabase database;
  final _Tabs tabs;
  final _Settings settings;
  late final _Profiles profiles;
  bool _closed = false;

  Future<void> start(WidgetTester tester) async {
    tabs.add(TerminalTabStart());
    await tester.pump();
    await tester.pump();
    expect(tabs.state, isA<TerminalTabLoaded>());
  }

  Future<void> seed(
    WidgetTester tester,
    List<HostSpec> specs, {
    int activeIndex = 0,
  }) async {
    for (var index = 0; index < specs.length; index++) {
      final id = index == 0 ? 11 : 22;
      final plugin = TerminalPlugin();
      final tab = PluginTab(
        plugin,
        PluginManager(specs[index]),
        shellProfileId: id,
      );
      plugin.title.value = '/saved/$id';
      tabs.add(TerminalTabOpenTab(tab, activate: index == activeIndex));
    }
    await tester.pump();
    expect((tabs.state as TerminalTabLoaded).tabCount, specs.length);
  }

  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<SharedPreferences>.value(value: preferences),
          RepositoryProvider<AppDatabase>.value(value: database),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<TerminalTabBloc>.value(value: tabs),
            BlocProvider<TerminalSettingsBloc>.value(value: settings),
            BlocProvider<ShellProfileBloc>.value(value: profiles),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocale.localizationsDelegates,
            supportedLocales: AppLocale.supportedLocales,
            home: const TerminalScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();
  }

  Future<void> save(WidgetTester tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();
  }

  Future<void> close(WidgetTester tester) async {
    if (_closed) return;
    _closed = true;
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    for (final tab in tabs.opened) {
      tab.dispose();
      (tab.plugin as TerminalPlugin).terminal.dispose();
    }
    await tester.runAsync(() async {
      await tabs.close();
      await profiles.close();
      await settings.close();
      await database.close();
    });
  }
}

Map<String, dynamic> _saved(SharedPreferences preferences) =>
    jsonDecode(preferences.getString(_tabsKey)!) as Map<String, dynamic>;

void _expectRestoredLocal(PluginTab tab, int id) {
  expect(tab.shellProfileId, id);
  final plugin = tab.plugin as TerminalPlugin;
  expect(plugin.profileFontFamily, 'Profile font $id');
  final spec = tab.manager.hostSpec;
  final Map<String, String> environment;
  final String? initCommands;
  if (Platform.isAndroid) {
    expect(spec, isA<AndroidHostSpec>());
    environment = (spec as AndroidHostSpec).environment;
    initCommands = spec.initCommands;
  } else if (Platform.isIOS) {
    expect(spec, isA<IosHostSpec>());
    environment = (spec as IosHostSpec).environment;
    initCommands = spec.initCommands;
  } else {
    expect(spec, isA<LocalHostSpec>());
    environment = (spec as LocalHostSpec).environment;
    initCommands = spec.initCommands;
    expect(spec.workingDirectory, '/saved/$id');
  }
  expect(environment, {'PROFILE': '$id'});
  expect(initCommands, contains('echo profile-$id'));
}

/// Runs twice in an isolated device app to verify storage across app launches.
Future<String> verifyDeviceTabPersistence(WidgetTester tester) async {
  const phaseKey = 'terminal7.device.phase';
  final preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final phase = preferences.getString(phaseKey);
  final harness = _Harness(preferences);
  await harness.start(tester);
  try {
    if (phase == null) {
      await harness.seed(tester, [
        createDefaultHostSpec(),
        createDefaultHostSpec(),
      ], activeIndex: 1);
      await harness.mount(tester);
      await harness.save(tester);
      await preferences.reload();
      expect((_saved(preferences)['tabs'] as List), hasLength(2));
      expect(_saved(preferences)['activeIndex'], 1);
      await preferences.setString(phaseKey, 'saved');
      return 'saved';
    }
    expect(phase, 'saved');
    expect((_saved(preferences)['tabs'] as List), hasLength(2));
    await harness.mount(tester);
    final state = harness.tabs.state as TerminalTabLoaded;
    expect(state.tabCount, 2);
    final tabs = state.allTabs.cast<PluginTab>();
    _expectRestoredLocal(tabs[0], 11);
    _expectRestoredLocal(tabs[1], 22);
    expect(state.activeTab, same(tabs[1]));
    await preferences.setString(phaseKey, 'restored');
    return 'restored';
  } finally {
    await harness.close(tester);
  }
}

void main() {
  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  for (final source in ['Android', 'iOS', 'desktop']) {
    testWidgets('$source local tabs save and restore profiles and active tab', (
      tester,
    ) async {
      HostSpec spec() => switch (source) {
        'Android' => AndroidHostSpec(
          environment: const {'SECRET': 'do-not-store'},
        ),
        'iOS' => IosHostSpec(environment: const {'SECRET': 'do-not-store'}),
        _ => LocalHostSpec(environment: const {'SECRET': 'do-not-store'}),
      };
      final original = _Harness(preferences);
      await original.start(tester);
      addTearDown(() => original.close(tester));
      await original.seed(tester, [spec(), spec()], activeIndex: 1);
      await original.mount(tester);
      await original.save(tester);
      final payload = _saved(preferences);
      expect(payload, {
        'activeIndex': 1,
        'tabs': [
          {'type': 'local', 'profileId': 11, 'workingDirectory': '/saved/11'},
          {'type': 'local', 'profileId': 22, 'workingDirectory': '/saved/22'},
        ],
      });
      expect(jsonEncode(payload), isNot(contains('do-not-store')));

      await original.close(tester);
      final restored = _Harness(preferences);
      await restored.start(tester);
      addTearDown(() => restored.close(tester));
      await restored.mount(tester);
      final state = restored.tabs.state as TerminalTabLoaded;
      expect(state.tabCount, 2);
      final tabs = state.allTabs.cast<PluginTab>();
      _expectRestoredLocal(tabs[0], 11);
      _expectRestoredLocal(tabs[1], 22);
      expect(state.activeTab, same(tabs[1]));
      expect(tester.takeException(), isNull);
    });
  }

  for (final activeIndex in [1, 2]) {
    testWidgets(
      'filtered tab preserves supported selection for index $activeIndex',
      (tester) async {
        final harness = _Harness(preferences);
        await harness.start(tester);
        addTearDown(() => harness.close(tester));
        await harness.seed(tester, [
          LocalHostSpec(),
          _UnsupportedSpec(),
          LocalHostSpec(),
        ], activeIndex: activeIndex);
        await harness.mount(tester);
        await harness.save(tester);
        expect((_saved(preferences)['tabs'] as List), hasLength(2));
        expect(_saved(preferences)['activeIndex'], activeIndex == 2 ? 1 : 0);
      },
    );
  }

  testWidgets('SSH descriptors retain host identity without credentials', (
    tester,
  ) async {
    final harness = _Harness(preferences);
    await harness.start(tester);
    addTearDown(() => harness.close(tester));
    await harness.seed(tester, [
      SSHHostSpec(
        SshHost(id: 3, hostname: 'example.invalid', username: 'private-user'),
        passwordProvider: () => 'private-password',
      ),
    ]);
    await harness.mount(tester);
    await harness.save(tester);
    expect(_saved(preferences), {
      'activeIndex': 0,
      'tabs': [
        {'type': 'ssh', 'hostId': 3},
      ],
    });
  });

  group('tab groups', () {
    testWidgets('groups round-trip through save and restore', (tester) async {
      final original = _Harness(preferences);
      await original.start(tester);
      addTearDown(() => original.close(tester));
      await original.seed(tester, [LocalHostSpec(), LocalHostSpec()]);
      final seeded = (original.tabs.state as TerminalTabLoaded).allTabs;
      original.tabs.add(
        TerminalTabCreateGroup(seeded[0].hashCode.toString(), 'web'),
      );
      original.tabs.add(TerminalTabToggleGroupCollapsed(null));
      await tester.pump();
      await original.mount(tester);
      await original.save(tester);

      final payload = _saved(preferences);
      final groupId =
          (original.tabs.state as TerminalTabLoaded).grouping.groups.single.id;
      expect(payload['groups'], [
        {'id': groupId, 'name': 'web', 'collapsed': false},
      ]);
      expect(payload['ungroupedCollapsed'], isTrue);
      final savedTabs = payload['tabs'] as List;
      expect((savedTabs[0] as Map)['groupId'], groupId);
      expect((savedTabs[1] as Map).containsKey('groupId'), isFalse);

      await original.close(tester);
      final restored = _Harness(preferences);
      await restored.start(tester);
      addTearDown(() => restored.close(tester));
      await restored.mount(tester);

      final state = restored.tabs.state as TerminalTabLoaded;
      expect(state.tabCount, 2);
      final tabs = state.allTabs;
      expect(state.grouping.groupOf(tabs[0])?.name, 'web');
      expect(state.grouping.groupIdOf(tabs[1]), isNull);
      expect(state.grouping.ungroupedCollapsed, isTrue);
    });

    testWidgets('several groups survive restore and the next save', (
      tester,
    ) async {
      await preferences.setString(
        _tabsKey,
        jsonEncode({
          'activeIndex': 0,
          'groups': [
            {'id': 'a', 'name': 'api', 'collapsed': false},
            {'id': 'b', 'name': 'web', 'collapsed': true},
          ],
          'tabs': [
            {
              'type': 'local',
              'profileId': 11,
              'workingDirectory': '/a',
              'groupId': 'a',
            },
            {
              'type': 'local',
              'profileId': 22,
              'workingDirectory': '/b',
              'groupId': 'b',
            },
            {
              'type': 'local',
              'profileId': 11,
              'workingDirectory': '/c',
              'groupId': 'a',
            },
          ],
        }),
      );
      final harness = _Harness(preferences);
      await harness.start(tester);
      addTearDown(() => harness.close(tester));
      await harness.mount(tester);

      final state = harness.tabs.state as TerminalTabLoaded;
      final tabs = state.allTabs;
      expect(state.grouping.groups.map((TabGroup g) => g.name), ['api', 'web']);
      expect(state.grouping.groupOf(tabs[0])?.name, 'api');
      expect(state.grouping.groupOf(tabs[1])?.name, 'web');
      expect(state.grouping.groupOf(tabs[2])?.name, 'api');

      await harness.save(tester);
      expect(_saved(preferences)['groups'], [
        {'id': 'a', 'name': 'api', 'collapsed': false},
        {'id': 'b', 'name': 'web', 'collapsed': true},
      ]);
    });

    testWidgets('old payload without groups restores tabs ungrouped', (
      tester,
    ) async {
      await preferences.setString(
        _tabsKey,
        jsonEncode({
          'activeIndex': 0,
          'tabs': [
            {'type': 'local', 'profileId': 11, 'workingDirectory': '/a'},
            {'type': 'local', 'profileId': 22, 'workingDirectory': '/b'},
          ],
        }),
      );
      final harness = _Harness(preferences);
      await harness.start(tester);
      addTearDown(() => harness.close(tester));
      await harness.mount(tester);

      final state = harness.tabs.state as TerminalTabLoaded;
      expect(state.tabCount, 2);
      expect(state.grouping.groups, isEmpty);
      expect(state.grouping.membership, isEmpty);
    });

    testWidgets('unknown groupId and malformed groups restore ungrouped', (
      tester,
    ) async {
      await preferences.setString(
        _tabsKey,
        jsonEncode({
          'activeIndex': 0,
          'groups': 'oops',
          'tabs': [
            {
              'type': 'local',
              'profileId': 11,
              'workingDirectory': '/a',
              'groupId': 'missing',
            },
            {
              'type': 'local',
              'profileId': 22,
              'workingDirectory': '/b',
              'groupId': 7,
            },
          ],
        }),
      );
      final harness = _Harness(preferences);
      await harness.start(tester);
      addTearDown(() => harness.close(tester));
      await harness.mount(tester);

      final state = harness.tabs.state as TerminalTabLoaded;
      expect(state.tabCount, 2);
      expect(state.grouping.groups, isEmpty);
      expect(state.grouping.membership, isEmpty);
      expect(preferences.getString(_tabsKey), isNotNull);
    });

    testWidgets('group entries with bad fields are skipped', (tester) async {
      await preferences.setString(
        _tabsKey,
        jsonEncode({
          'activeIndex': 0,
          'groups': [
            'junk',
            {'id': 1, 'name': 'bad'},
            {'id': 'ok', 'name': 'api'},
          ],
          'tabs': [
            {
              'type': 'local',
              'profileId': 11,
              'workingDirectory': '/a',
              'groupId': 'ok',
            },
          ],
        }),
      );
      final harness = _Harness(preferences);
      await harness.start(tester);
      addTearDown(() => harness.close(tester));
      await harness.mount(tester);

      final state = harness.tabs.state as TerminalTabLoaded;
      expect(state.grouping.groups, [const TabGroup(id: 'ok', name: 'api')]);
      expect(state.grouping.groupOf(state.allTabs.single)?.name, 'api');
    });
  });
}
