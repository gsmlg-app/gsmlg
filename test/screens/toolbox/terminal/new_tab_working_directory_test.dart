import 'dart:async';
import 'dart:io';

import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _UnusedVault extends Fake implements VaultRepository {}

class _Profiles extends ShellProfileBloc {
  _Profiles(super.database, {required bool inherit}) {
    emit(ShellProfileLoaded([_profile(inherit: inherit)]));
  }
}

class _Settings extends TerminalSettingsBloc {
  _Settings() : super(vault: _UnusedVault()) {
    emit(const TerminalSettingsLoaded());
  }
}

/// Keeps tabs from starting real shell processes.
class _Tabs extends TerminalTabBloc {
  final opened = <PluginTab>[];

  @override
  void add(TerminalTabEvent event) {
    if (event is TerminalTabOpenTab && event.tabItem is PluginTab) {
      final tab = event.tabItem as PluginTab;
      opened.add(tab);
      tab.content.value = const SizedBox.shrink();
    }
    super.add(event);
  }
}

class _ShellSession implements ExecutionSession, WorkingDirectoryAware {
  _ShellSession(this.directory);

  String directory;
  Completer<String?>? cwdResult;

  final _exitCode = Completer<int>();

  @override
  Future<String?> currentWorkingDirectory() async =>
      cwdResult == null ? directory : await cwdResult!.future;

  @override
  Stream<Uint8List> get output => const Stream<Uint8List>.empty();

  @override
  Future<int> get exitCode => _exitCode.future;

  @override
  void ackRead() {}

  @override
  Future<void> close() async {
    if (!_exitCode.isCompleted) _exitCode.complete(0);
  }

  @override
  Future<void> resize(int width, int height) async {}

  @override
  Future<void> write(Uint8List data) async {}
}

ShellProfile _profile({required bool inherit}) => ShellProfile(
  id: 1,
  name: 'Default',
  shellType: ShellType.zsh.value,
  environmentVariables: '{}',
  aliases: '{}',
  fontFamily: 'Menlo',
  fontSize: 14,
  colorTheme: 'default',
  workingDirectory: '',
  startupCommand: '',
  cursorStyle: 0,
  scrollbackLines: 1000,
  isDefault: true,
  inheritCurrentState: inherit,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  late SharedPreferences preferences;
  late AppDatabase database;
  late _Tabs tabs;
  late _Settings settings;
  late _Profiles profiles;
  late PluginTab firstTab;
  late _ShellSession shell;

  Future<void> pumpScreen(
    WidgetTester tester, {
    required bool inherit,
    bool ssh = false,
  }) async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    database = AppDatabase.forTesting();
    tabs = _Tabs();
    settings = _Settings();
    profiles = _Profiles(database, inherit: inherit);
    tabs.add(TerminalTabStart());
    await tester.pump();

    final plugin = TerminalPlugin();
    shell = _ShellSession('/Users/me/project/src');
    plugin.session = shell;
    firstTab = PluginTab(
      plugin,
      PluginManager(
        ssh
            ? SSHHostSpec(
                SshHost(id: 3, hostname: 'example.invalid', username: 'me'),
              )
            : LocalHostSpec(workingDirectory: '/Users/me'),
      ),
      shellProfileId: 1,
    );
    tabs.add(TerminalTabOpenTab(firstTab));
    await tester.pump();

    addTearDown(() async {
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
    });

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
  }

  Future<void> pressCmdT(WidgetTester tester) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pump();
    await tester.pump();
  }

  testWidgets(
    'Cmd+T opens the new tab where the current shell is now',
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    (tester) async {
      await pumpScreen(tester, inherit: true);

      await pressCmdT(tester);

      final state = tabs.state as TerminalTabLoaded;
      expect(state.tabCount, 2);
      final spec = (state.activeTab as PluginTab).manager.hostSpec;
      expect(spec, isA<LocalHostSpec>());
      expect((spec as LocalHostSpec).workingDirectory, '/Users/me/project/src');
    },
    skip: !Platform.isMacOS && !Platform.isLinux,
  );

  testWidgets(
    'Cmd+T ignores the current directory when the profile does not inherit',
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    (tester) async {
      await pumpScreen(tester, inherit: false);

      await pressCmdT(tester);

      final state = tabs.state as TerminalTabLoaded;
      expect(state.tabCount, 2);
      final spec = (state.activeTab as PluginTab).manager.hostSpec;
      expect((spec as LocalHostSpec).workingDirectory, isNull);
    },
    skip: !Platform.isMacOS && !Platform.isLinux,
  );

  testWidgets(
    'Cmd+T on an SSH tab opens the same host in the remote directory',
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    (tester) async {
      await pumpScreen(tester, inherit: false, ssh: true);
      shell.directory = '/srv/app/releases';

      await pressCmdT(tester);
      await tester.pump();

      final state = tabs.state as TerminalTabLoaded;
      expect(state.tabCount, 2);
      final newTab = state.activeTab as PluginTab;
      expect(newTab, isNot(same(firstTab)));
      expect(identical(newTab.manager, firstTab.manager), isTrue);
      expect(
        (newTab.plugin as TerminalPlugin).startDirectory,
        '/srv/app/releases',
      );
    },
  );

  testWidgets(
    'Cmd+T on a grouped local tab opens the new tab in that group',
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    (tester) async {
      await pumpScreen(tester, inherit: true, ssh: false);
      tabs.add(TerminalTabCreateGroup(firstTab.hashCode.toString(), 'proj'));
      await tester.pump();
      final groupId = (tabs.state as TerminalTabLoaded).grouping.groupIdOf(
        firstTab,
      );
      expect(groupId, isNotNull);

      await pressCmdT(tester);
      await tester.pump();

      final state = tabs.state as TerminalTabLoaded;
      expect(state.tabCount, 2);
      final newTab = state.activeTab!;
      expect(newTab, isNot(same(firstTab)));
      expect(state.grouping.groupIdOf(newTab), groupId);
    },
  );

  testWidgets(
    'Cmd+T on a grouped SSH tab opens the new tab in that group',
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    (tester) async {
      await pumpScreen(tester, inherit: true, ssh: true);
      tabs.add(TerminalTabCreateGroup(firstTab.hashCode.toString(), 'proj'));
      await tester.pump();
      final groupId = (tabs.state as TerminalTabLoaded).grouping.groupIdOf(
        firstTab,
      );
      expect(groupId, isNotNull);

      await pressCmdT(tester);
      await tester.pump();

      final state = tabs.state as TerminalTabLoaded;
      expect(state.tabCount, 2);
      final newTab = state.activeTab!;
      expect(newTab, isNot(same(firstTab)));
      expect(state.grouping.groupIdOf(newTab), groupId);
    },
  );

  testWidgets(
    'Cmd+T on an ungrouped tab keeps the new tab ungrouped',
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    (tester) async {
      await pumpScreen(tester, inherit: true, ssh: true);

      await pressCmdT(tester);
      await tester.pump();

      final state = tabs.state as TerminalTabLoaded;
      expect(state.tabCount, 2);
      expect(state.grouping.groupIdOf(state.activeTab!), isNull);
    },
  );
  testWidgets(
    'delayed open-beside retains the original SSH connection and group',
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    (tester) async {
      await pumpScreen(tester, inherit: false, ssh: true);
      final sourceId = firstTab.hashCode.toString();
      tabs.add(TerminalTabCreateGroup(sourceId, 'source'));
      await tester.pump();
      final sourceGroup = (tabs.state as TerminalTabLoaded).grouping.groupIdOf(
        firstTab,
      );

      final other = PluginTab(
        TerminalPlugin(),
        PluginManager(LocalHostSpec(workingDirectory: '/different')),
      );
      tabs.add(TerminalTabOpenTab(other, activate: false));
      await tester.pump();

      final cwd = Completer<String?>();
      shell.cwdResult = cwd;
      await pressCmdT(tester);
      expect((tabs.state as TerminalTabLoaded).tabCount, 2);
      tabs.add(TerminalTabSelectSession(other.hashCode.toString()));
      await tester.pump();
      expect((tabs.state as TerminalTabLoaded).activeTab, same(other));

      cwd.complete('/srv/original');
      await tester.pump();
      await tester.pump();
      final state = tabs.state as TerminalTabLoaded;
      expect(state.tabCount, 3);
      final opened = state.activeTab as PluginTab;
      expect(opened.manager, same(firstTab.manager));
      expect(state.grouping.groupIdOf(opened), sourceGroup);
      expect((opened.plugin as TerminalPlugin).startDirectory, '/srv/original');
    },
  );
}
