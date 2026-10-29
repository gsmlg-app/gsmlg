import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/toolbox/terminal/terminal_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:terminal_plugin/terminal_plugin.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:xterm/xterm.dart';

void main() {
  testWidgets(
    'terminal workspace supplies the overlay for right-click actions',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final database = AppDatabase.forTesting();
      addTearDown(database.close);
      final tabs = TerminalTabBloc()..add(TerminalTabStart());
      addTearDown(tabs.close);
      await tester.pump();
      final plugin = TerminalPlugin();
      addTearDown(plugin.terminal.dispose);
      plugin.terminal.write('terminal context menu regression');
      await tester.pump(const Duration(milliseconds: 20));
      final tab = TabItem(content: TerminalTabView(plugin));
      addTearDown(tab.dispose);
      tabs.add(TerminalTabOpenTab(tab));

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<SharedPreferences>.value(value: prefs),
            RepositoryProvider<AppDatabase>.value(value: database),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<TerminalTabBloc>.value(value: tabs),
              BlocProvider<TerminalSettingsBloc>(
                create: (_) => TerminalSettingsBloc(vault: _MemoryVault()),
              ),
              BlocProvider<ShellProfileBloc>(
                create: (_) => ShellProfileBloc(database),
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
      expect(find.byType(ContextMenuOverlay), findsOneWidget);
      expect(find.byType(TerminalContextMenu), findsNothing);

      await tester.tap(
        find.byType(TerminalView),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await tester.pump();
      await tester.pump();

      expect(find.byType(TerminalContextMenu), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Paste'), findsOneWidget);
      expect(find.text('Select All'), findsOneWidget);
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
