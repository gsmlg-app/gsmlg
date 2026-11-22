import 'dart:io';

import 'package:hive_ce/hive_ce.dart';

import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:terminal_core/terminal_core.dart'
    show ExecutionSession, WorkingDirectoryAware;
import 'package:terminal_hosts/terminal_hosts.dart';
import 'package:terminal_plugin/terminal_plugin.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:terminal_tabs/terminal_tabs.dart';
import 'package:gsmlg/screens/toolbox/terminal/services/session_controller.dart';
import 'package:gsmlg/screens/toolbox/terminal/services/session_store.dart';
import 'package:gsmlg/screens/toolbox/terminal/terminal_screen.dart';

class _Vault extends Fake implements VaultRepository {}

class _Profiles extends ShellProfileBloc {
  _Profiles(super.database) {
    emit(ShellProfileLoaded([_profile(11), _profile(22)]));
  }
}

class _Settings extends TerminalSettingsBloc {
  _Settings() : super(vault: _Vault()) {
    emit(const TerminalSettingsLoaded());
  }
}

class _DirectorySession extends Fake
    implements ExecutionSession, WorkingDirectoryAware {
  String? directory = '/tmp';

  @override
  Future<String?> currentWorkingDirectory() async => directory;

  @override
  Future<void> close() async {}
}

class _Tabs extends TerminalTabBloc {
  final created = <PluginTab>[];
  @override
  void add(TerminalTabEvent event) {
    final tabs = event is TerminalTabApplySnapshot
        ? event.tabs
        : event is TerminalTabOpenTab
        ? [event.tabItem]
        : [];
    for (final tab in tabs.whereType<PluginTab>()) {
      created.add(tab);
      tab.content.value = const SizedBox();
    }
    super.add(event);
  }
}

ShellProfile _profile(int id) => ShellProfile(
  id: id,
  name: 'Profile $id',
  shellType: ShellType.bash.value,
  environmentVariables: '{"PROFILE":"$id"}',
  aliases: '{}',
  fontFamily: 'Profile font $id',
  fontSize: 16,
  colorTheme: 'default',
  workingDirectory: '/tmp',
  startupCommand: '',
  cursorStyle: 0,
  scrollbackLines: 1000,
  isDefault: id == 11,
  inheritCurrentState: false,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);
Map<String, dynamic> _layout({String directory = '/tmp', int profileId = 11}) =>
    {
      'activeIndex': 1,
      'groups': [
        {'id': 'api', 'name': 'API', 'collapsed': true},
      ],
      'tabs': [
        {
          'type': 'local',
          'profileId': profileId,
          'workingDirectory': directory,
          'groupId': 'api',
          'customTitle': 'server',
        },
        {'type': 'local', 'profileId': 22, 'workingDirectory': '/tmp'},
      ],
    };

class _Harness {
  final database = AppDatabase.forTesting();
  final tabs = _Tabs();
  final settings = _Settings();
  late final profiles = _Profiles(database);
  late final SessionController sessions;
  bool closed = false;
  Future<void> init(
    Directory directory, {
    Map<String, dynamic>? previous,
    bool inMemory = false,
  }) async {
    final storage = inMemory
        ? await Hive.openBox<dynamic>('ui-sessions', bytes: Uint8List(0))
        : null;
    if (previous != null) {
      final old = await SessionStore.open(directory, storage: storage);
      await old.record(previous);
      await old.finishExit();
      if (!inMemory) await old.close();
    }
    sessions = SessionController(
      store: await SessionStore.open(directory, storage: storage),
      tabs: tabs,
    );
  }

  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AppDatabase>.value(value: database),
          ChangeNotifierProvider<SessionController>.value(value: sessions),
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
    await tester.pumpAndSettle();
  }

  Future<void> drain(WidgetTester tester) async {
    for (var i = 0; i < 30; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> restore(WidgetTester tester, {bool append = false}) async {
    expect(find.byType(AlertDialog), findsOneWidget);
    if (append) {
      await tester.tap(find.text('Append'));
      await tester.pump();
    }
    await tester.tap(find.widgetWithText(FilledButton, 'Restore'));
    await drain(tester);
    await tester.pumpAndSettle();
  }

  Future<void> close(WidgetTester tester) async {
    if (closed) return;
    closed = true;
    sessions.dispose();
    await drain(tester);
    await tester.runAsync(sessions.store.close);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    if (tabs.state case final TerminalTabLoaded state) {
      for (final tab in state.allTabs.toList()) {
        tab.dispose();
      }
    }
    for (final tab in tabs.created) {
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

/// Device runner uses the same Hive store across launches.
Future<String> verifyDeviceTabPersistence(WidgetTester tester) async {
  final directory = Directory(
    '${(await getApplicationSupportDirectory()).path}/device-session-test',
  );
  final h = _Harness();
  await h.init(directory);
  try {
    await h.mount(tester);
    if (h.sessions.store.latest == null) {
      await h.sessions.store.record(_layout());
      await h.sessions.store.finishExit();
      return 'saved';
    }
    await h.restore(tester);
    expect((h.tabs.state as TerminalTabLoaded).tabCount, 2);
    return 'restored';
  } finally {
    await h.close(tester);
  }
}

void main() {
  _Harness? activeHarness;
  void sessionTest(String name, Future<void> Function(WidgetTester) body) {
    testWidgets(name, (tester) async {
      activeHarness = null;
      try {
        await body(tester);
      } finally {
        await activeHarness?.close(tester);
      }
    });
  }

  Future<_Harness> setup(
    WidgetTester tester, {
    Map<String, dynamic>? previous,
  }) async {
    final directory = await tester.runAsync(
      () => Directory.systemTemp.createTemp('session-ui-'),
    );
    final h = _Harness();
    activeHarness = h;
    await tester.runAsync(
      () => h.init(directory!, previous: previous, inMemory: true),
    );
    addTearDown(() async {
      await h.close(tester);
      await tester.runAsync(() => directory!.delete(recursive: true));
    });
    await h.mount(tester);
    return h;
  }

  sessionTest('startup without history does not show a restore dialog', (
    tester,
  ) async {
    final h = await setup(tester);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(MaterialBanner), findsNothing);
    expect((h.tabs.state as TerminalTabLoaded).tabCount, 1);
  });

  sessionTest('the active title follows the shell directory without OSC', (
    tester,
  ) async {
    final h = await setup(tester);
    final tab = h.tabs.created.single;
    final plugin = tab.plugin as TerminalPlugin;
    final shell = _DirectorySession();
    plugin.terminal.write('\x1b]0;/tmp\x07');
    plugin.session = shell;
    h.sessions.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('${tab.tabNumber} /tmp'), findsOneWidget);

    shell.directory = '/work/current 80x24';
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(h.sessions.cachedDirectory(tab), '/work/current 80x24');
    expect(find.text('${tab.tabNumber} /work/current 80x24'), findsOneWidget);

    shell.directory = null;
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('${tab.tabNumber} /work/current 80x24'), findsOneWidget);
  });

  for (final escape in [false, true]) {
    sessionTest(
      'startup restore dialog dismisses once and preserves history escape=$escape',
      (tester) async {
        final h = await setup(tester, previous: _layout());
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.byType(MaterialBanner), findsNothing);
        expect(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text('Restore tabs from your last session?'),
          ),
          findsOneWidget,
        );
        expect((h.tabs.state as TerminalTabLoaded).tabCount, 1);
        expect(h.sessions.store.current, isNull);
        if (escape) {
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        } else {
          await tester.tap(find.text('Later'));
        }
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(h.sessions.startupPromptDismissed, isTrue);
        h.sessions.dismissStartupPrompt();
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
        await h.mount(tester);
        expect(find.byType(AlertDialog), findsNothing);
        await tester.runAsync(h.sessions.prepareExit);
        await tester.runAsync(h.sessions.finishExit);
        expect(h.sessions.store.history, hasLength(1));
        expect(h.sessions.store.latest!.layout['tabs'], hasLength(2));
      },
    );
  }
  for (final append in [false, true]) {
    sessionTest(
      'workspace restore append=$append preserves profiles, groups and selection',
      (tester) async {
        final h = await setup(tester, previous: _layout());
        await h.restore(tester, append: append);
        final state = h.tabs.state as TerminalTabLoaded;
        expect(state.tabCount, append ? 3 : 2);
        final restored = state.allTabs.whereType<PluginTab>().toList();
        final server = restored.firstWhere(
          (tab) => tab.customTitle == 'server',
        );
        expect(server.shellProfileId, 11);
        expect(
          (server.manager.hostSpec as LocalHostSpec).workingDirectory,
          '/tmp',
        );
        expect(state.grouping.groupOf(server)?.name, 'API');
        expect(state.grouping.groupOf(server)?.collapsed, isTrue);
        expect((state.activeTab as PluginTab).shellProfileId, 22);
        expect(
          h.sessions.store.current!.layout['tabs'],
          hasLength(append ? 3 : 2),
        );
      },
    );
  }
  for (final bad in [
    _layout(directory: '/nonexistent/web-terminal-test'),
    _layout(profileId: 999),
  ]) {
    sessionTest(
      'failed descriptor is retained and other tabs restore: ${bad['tabs']}',
      (tester) async {
        final h = await setup(tester, previous: bad);
        await h.restore(tester);
        final state = h.tabs.state as TerminalTabLoaded;
        expect(state.allTabs.whereType<UnavailableSessionTab>(), hasLength(1));
        expect(state.allTabs.whereType<PluginTab>(), hasLength(1));
        final saved =
            (h.sessions.store.current!.layout['tabs'] as List).first as Map;
        final original = (bad['tabs'] as List).first as Map;
        expect(saved['profileId'], original['profileId']);
        expect(saved['workingDirectory'], original['workingDirectory']);
        final failed = state.allTabs.whereType<UnavailableSessionTab>().single;
        h.tabs.add(TerminalTabSelectSession(failed.hashCode.toString()));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), '/tmp');
        await tester.tap(find.widgetWithText(FilledButton, 'Retry').last);
        await h.drain(tester);
        expect(
          (h.tabs.state as TerminalTabLoaded).allTabs
              .whereType<UnavailableSessionTab>(),
          isEmpty,
        );
      },
    );
  }
  sessionTest(
    'manual group restore replaces selected group and preserves other tabs',
    (tester) async {
      final h = await setup(tester, previous: _layout());
      await h.restore(tester);
      final snapshot = await h.sessions.store.save(
        'saved API',
        h.sessions.layout(
          groupOnly: true,
          groupId:
              (h.tabs.state as TerminalTabLoaded).grouping.groups.single.id,
        ),
        group: true,
      );
      h.sessions.requestRestore(snapshot);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Restore'));
      await h.drain(tester);
      final state = h.tabs.state as TerminalTabLoaded;
      expect(state.tabCount, 2);
      expect(state.grouping.groups, hasLength(1));
      expect(h.sessions.store.saved, hasLength(1));
    },
  );
}
