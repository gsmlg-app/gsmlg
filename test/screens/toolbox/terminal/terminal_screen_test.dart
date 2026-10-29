import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/terminal_hosts.dart';
import 'package:terminal_plugin/terminal_plugin.dart';
import 'package:terminal_plugin/src/terminal_extra_keys.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:terminal_tabs/terminal_tabs.dart';
import 'package:gsmlg/screens/toolbox/terminal/terminal_screen.dart';
import 'package:xterm/xterm.dart';

class _FakeVaultRepository implements VaultRepository {
  final _storage = <String, String>{};

  @override
  Future<bool> containsKey({required String key}) async {
    return _storage.containsKey(key);
  }

  @override
  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }

  @override
  Future<String?> read({required String key}) async {
    return _storage[key];
  }

  @override
  Future<Map<String, String>> readAll() async {
    return Map.of(_storage);
  }

  @override
  Future<void> write({required String key, required String value}) async {
    _storage[key] = value;
  }
}

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets(
      '${platform.name} terminal keys meet the keyboard and navigation returns after dismissal',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 844);
        tester.view.viewPadding = const FakeViewPadding(top: 47, bottom: 34);
        tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetViewPadding);
        addTearDown(tester.view.resetPadding);
        addTearDown(tester.view.resetViewInsets);

        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final database = AppDatabase.forTesting();
        addTearDown(database.close);
        final tabBloc = TerminalTabBloc()..add(TerminalTabStart());
        addTearDown(tabBloc.close);
        await tester.pump();
        final plugin = TerminalPlugin();
        addTearDown(plugin.terminal.dispose);
        final tab = TabItem(content: TerminalTabView(plugin));
        addTearDown(tab.dispose);
        tabBloc.add(TerminalTabOpenTab(tab));
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
        });

        await tester.pumpWidget(
          MultiRepositoryProvider(
            providers: [
              RepositoryProvider<SharedPreferences>.value(value: prefs),
              RepositoryProvider<AppDatabase>.value(value: database),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider<TerminalTabBloc>.value(value: tabBloc),
                BlocProvider<TerminalSettingsBloc>(
                  create: (context) =>
                      TerminalSettingsBloc(vault: _FakeVaultRepository()),
                ),
                BlocProvider<ShellProfileBloc>(
                  create: (context) => ShellProfileBloc(database),
                ),
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
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(TerminalExtraKeys), findsNothing);
        final terminalState = tester.state<TerminalViewState>(
          find.byType(TerminalView),
        );
        await tester.tap(find.byType(TerminalView));
        await tester.pump(const Duration(milliseconds: 300));

        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        tester.view.padding = const FakeViewPadding(top: 47);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(TerminalExtraKeys), findsOneWidget);
        expect(
          tester.getBottomRight(find.byType(TerminalExtraKeys)).dy,
          closeTo(844 - 300, 1),
        );
        expect(find.byType(NavigationBar), findsNothing);
        expect(
          tester.state<TerminalViewState>(find.byType(TerminalView)),
          same(terminalState),
        );
        expect(
          tester.widget<TerminalTabView>(find.byType(TerminalTabView)).plugin,
          same(plugin),
        );

        tester.view.viewInsets = FakeViewPadding.zero;
        tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(TerminalExtraKeys), findsNothing);
        expect(
          tester.state<TerminalViewState>(find.byType(TerminalView)),
          same(terminalState),
        );
        expect(
          tester.widget<TerminalTabView>(find.byType(TerminalTabView)).plugin,
          same(plugin),
        );
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(platform),
    );
  }

  testWidgets(
    'disposes without looking up providers from a deactivated context',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final database = AppDatabase.forTesting();
      addTearDown(database.close);

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<SharedPreferences>.value(value: prefs),
            RepositoryProvider<AppDatabase>.value(value: database),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<TerminalTabBloc>(
                create: (context) => TerminalTabBloc(),
              ),
              BlocProvider<TerminalSettingsBloc>(
                create: (context) =>
                    TerminalSettingsBloc(vault: _FakeVaultRepository()),
              ),
              BlocProvider<ShellProfileBloc>(
                create: (context) => ShellProfileBloc(database),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocale.localizationsDelegates,
              supportedLocales: AppLocale.supportedLocales,
              home: const TerminalScreen(),
            ),
          ),
        ),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Ctrl+T on an active SSH tab opens a new SSH tab reusing the same connection',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final database = AppDatabase.forTesting();
      addTearDown(database.close);

      final tabBloc = TerminalTabBloc()..add(TerminalTabStart());
      addTearDown(tabBloc.close);
      await tester.pump();

      final sshSpec = SSHHostSpec(
        SshHost(
          id: 1,
          host: 'prod-1',
          hostname: '10.100.10.24',
          port: 22,
          username: 'gao',
          identityType: 0,
        ),
        passwordProvider: () => 'secret',
        verifyHostKey: (_, _) async => true,
      );
      final sshManager = _NoConnectionPluginManager(sshSpec);
      final firstSshTab = PluginTab(TerminalPlugin(), sshManager);
      tabBloc.add(TerminalTabOpenTab(firstSshTab));

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<SharedPreferences>.value(value: prefs),
            RepositoryProvider<AppDatabase>.value(value: database),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<TerminalTabBloc>.value(value: tabBloc),
              BlocProvider<TerminalSettingsBloc>(
                create: (context) =>
                    TerminalSettingsBloc(vault: _FakeVaultRepository()),
              ),
              BlocProvider<ShellProfileBloc>(
                create: (context) => ShellProfileBloc(database),
              ),
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

      final loadedBefore = tabBloc.state as TerminalTabLoaded;
      expect(loadedBefore.tabCount, 1);
      expect(loadedBefore.activeTab, same(firstSshTab));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyT);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyT);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      final loadedAfter = tabBloc.state as TerminalTabLoaded;
      expect(loadedAfter.tabCount, 2);
      final secondTab = loadedAfter.activeTab as PluginTab;
      expect(secondTab, isNot(same(firstSshTab)));
      expect(secondTab.manager, same(sshManager));
      expect(secondTab.manager.hostSpec, same(sshSpec));
      await tester.pumpWidget(const SizedBox.shrink());
      firstSshTab.dispose();
      secondTab.dispose();
      await tester.pump();
    },
  );
}

// This shortcut test checks manager reuse without opening a real SSH socket.
class _NoConnectionPluginManager extends PluginManager {
  _NoConnectionPluginManager(super.hostSpec);

  @override
  Future<void> connect() async {}
}
