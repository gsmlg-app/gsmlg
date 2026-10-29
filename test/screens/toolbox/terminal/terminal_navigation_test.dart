import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_chat/app_chat.dart';
import 'package:app_components/app_components.dart';
import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:audio_bloc/audio_bloc.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:duskmoon_settings/duskmoon_settings.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/settings/settings_routes.dart';
import 'package:gsmlg/screens/settings/terminal/host_management.dart';
import 'package:gsmlg/screens/settings/terminal/shell_profile_edit_screen.dart';
import 'package:gsmlg/screens/settings/terminal/shell_profile_screen.dart';
import 'package:gsmlg/screens/settings/terminal/ssh_key_management.dart';
import 'package:gsmlg/screens/settings/terminal/terminal_env_screen.dart';
import 'package:gsmlg/screens/settings/terminal/terminal_preferences_screen.dart';
import 'package:gsmlg/screens/toolbox/terminal/terminal_screen.dart';
import 'package:gsmlg/screens/toolbox/toolbox_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:ssh_key_bloc/ssh_key_bloc.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:theme_bloc/theme_bloc.dart';

void main() {
  testWidgets(
    'Toolbox opens Terminal and settings navigation preserves its session',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final database = AppDatabase.forTesting();
      addTearDown(database.close);
      final vault = _MemoryVault();
      final credentials = SshCredentialRepository(database, vault: vault);
      final tabs = TerminalTabBloc()..add(TerminalTabStart());
      final existingTab = TabItem(
        content: const Text('Existing terminal session'),
      );
      await tester.pump();
      tabs.add(TerminalTabOpenTab(existingTab));
      addTearDown(tabs.close);
      final router = GoRouter(
        initialLocation: '/toolbox',
        routes: [toolboxRoutes(), settingsRoutes()],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<SharedPreferences>.value(value: prefs),
            RepositoryProvider<AppDatabase>.value(value: database),
            RepositoryProvider<ToolExecutor>(
              create: (_) => ToolExecutor(database: database, vault: vault),
            ),
            RepositoryProvider<SshCredentialRepository>.value(
              value: credentials,
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<TerminalTabBloc>.value(value: tabs),
              BlocProvider<TerminalSettingsBloc>(
                create: (_) =>
                    TerminalSettingsBloc(vault: vault)
                      ..add(const TerminalSettingsLoad()),
              ),
              BlocProvider<ShellProfileBloc>(
                create: (_) => ShellProfileBloc(database),
              ),
              BlocProvider<SshHostBloc>(
                create: (_) => SshHostBloc(database, credentials: credentials),
              ),
              BlocProvider<SshKeyBloc>(
                create: (_) => SshKeyBloc(database, credentials: credentials),
              ),
              BlocProvider<DmThemeBloc>(
                create: (_) => DmThemeBloc(prefs: prefs),
              ),
              BlocProvider<AccountsBloc>(
                create: (_) => AccountsBloc(database: database, vault: vault),
              ),
              BlocProvider<ChatSettingsBloc>(
                create: (_) => ChatSettingsBloc(
                  repository: ChatStorageRepository(database),
                  preferences: prefs,
                ),
              ),
              BlocProvider<GemmaModelBloc>(
                create: (_) => GemmaModelBloc(
                  repository: GemmaRepository(),
                  preferences: prefs,
                ),
              ),
              BlocProvider<AudioSettingsBloc>(
                create: (_) => AudioSettingsBloc(preferences: prefs),
              ),
            ],
            child: MaterialApp.router(
              localizationsDelegates: AppLocale.localizationsDelegates,
              supportedLocales: AppLocale.supportedLocales,
              routerConfig: router,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final tile = find.ancestor(
        of: find.text('Terminal'),
        matching: find.byType(AppGridTile),
      );
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        '/toolbox/terminal',
      );
      expect(find.text('Existing terminal session'), findsOneWidget);
      expect(
        tester
            .widget<AppAdaptiveScaffold>(find.byType(AppAdaptiveScaffold).last)
            .selectedIndex,
        2,
      );

      router.go('/settings');
      await tester.pumpAndSettle();
      final configuration = tester
          .widget<SettingsList>(find.byType(SettingsList))
          .sections
          .where(
            (section) =>
                (section.title as Text?)?.data == 'Terminal Configuration',
          )
          .single;
      final configurationTiles = configuration.tiles
          .cast<SettingsTile>()
          .toList();
      expect(configurationTiles.map((tile) => (tile.title as Text).data), [
        'Terminal Preferences',
        'Environment Variables',
        'Shell Profiles',
        'SSH Host',
        'SSH Key',
      ]);
      expect(
        (tabs.state as TerminalTabLoaded).allTabs.single,
        same(existingTab),
      );

      final destinations = <String, (String, Type)>{
        TerminalPreferencesScreen.name: (
          '/settings/terminal/preferences',
          TerminalPreferencesScreen,
        ),
        TerminalEnvScreen.name: (
          '/settings/terminal/environment',
          TerminalEnvScreen,
        ),
        ShellProfileScreen.name: (
          '/settings/terminal/profiles',
          ShellProfileScreen,
        ),
        SettingsHost.name: ('/settings/terminal/hosts', SettingsHost),
        SettingsSSHKey.name: ('/settings/terminal/keys', SettingsSSHKey),
      };
      var index = 0;
      for (final entry in destinations.entries) {
        configurationTiles[index++].onPressed!(
          tester.element(find.byType(SettingsList)),
        );
        await tester.pumpAndSettle();
        expect(router.routeInformationProvider.value.uri.path, entry.value.$1);
        expect(find.byType(entry.value.$2), findsOneWidget);
        expect(
          tester
              .widget<AppAdaptiveScaffold>(
                find.byType(AppAdaptiveScaffold).last,
              )
              .selectedIndex,
          3,
        );
        expect(tester.takeException(), isNull);
        router.go('/settings');
        await tester.pumpAndSettle();
      }
      expect(
        router.namedLocation(ShellProfileEditScreen.name),
        '/settings/terminal/profiles/edit',
      );
      router.goNamed(TerminalScreen.name);
      await tester.pumpAndSettle();
      expect(find.text('Existing terminal session'), findsOneWidget);
      final loaded = tabs.state as TerminalTabLoaded;
      expect(loaded.tabCount, 1);
      expect(loaded.activeTab, same(existingTab));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );
}

class _MemoryVault implements VaultRepository {
  final _values = <String, String>{};
  @override
  Future<bool> containsKey({required String key}) async =>
      _values.containsKey(key);
  @override
  Future<void> delete({required String key}) async {
    _values.remove(key);
  }

  @override
  Future<void> deleteAll() async => _values.clear();
  @override
  Future<String?> read({required String key}) async => _values[key];
  @override
  Future<Map<String, String>> readAll() async => Map.of(_values);
  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }
}
