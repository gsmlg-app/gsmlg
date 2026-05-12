import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_chat/app_chat.dart';
import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_bloc/theme_bloc.dart';

void main() {
  group('SettingsScreen', () {
    late AppDatabase database;
    late SharedPreferences sharedPreferences;
    late _MemoryVaultRepository vault;
    late ToolExecutor toolExecutor;
    late DmThemeBloc themeBloc;
    late AccountsBloc accountsBloc;
    late ChatSettingsBloc chatSettingsBloc;
    late GemmaModelBloc gemmaModelBloc;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
      database = AppDatabase.forTesting();
      vault = _MemoryVaultRepository();
      toolExecutor = ToolExecutor(database: database, vault: vault);
      themeBloc = DmThemeBloc(prefs: sharedPreferences);
      accountsBloc = AccountsBloc(database: database, vault: vault);
      chatSettingsBloc = ChatSettingsBloc(
        repository: ChatStorageRepository(database),
        preferences: sharedPreferences,
      );
      gemmaModelBloc = GemmaModelBloc(
        repository: GemmaRepository(),
        preferences: sharedPreferences,
      );
    });

    tearDown(() async {
      await gemmaModelBloc.close();
      await chatSettingsBloc.close();
      await accountsBloc.close();
      await themeBloc.close();
      await database.close();
      await sharedPreferences.clear();
    });

    testWidgets('renders core settings options', (WidgetTester tester) async {
      await _pumpScreen(
        tester,
        sharedPreferences: sharedPreferences,
        toolExecutor: toolExecutor,
        themeBloc: themeBloc,
        accountsBloc: accountsBloc,
        chatSettingsBloc: chatSettingsBloc,
        gemmaModelBloc: gemmaModelBloc,
      );

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.byType(SliverAppBar), findsOneWidget);
      expect(find.text('App Setting'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.brightness_medium), findsOneWidget);
      expect(find.byIcon(Icons.palette), findsOneWidget);
      expect(find.byIcon(Icons.api), findsOneWidget);
    });

    testWidgets('shows Remote Tools under AI Models', (
      WidgetTester tester,
    ) async {
      await sharedPreferences.setStringList('remote_mcp_profiles', [
        '{"id":"docs","name":"Docs MCP","url":"https://mcp.example.com/http","transport":"http","enabled":true,"accountId":null}',
      ]);

      await _pumpScreen(
        tester,
        sharedPreferences: sharedPreferences,
        toolExecutor: toolExecutor,
        themeBloc: themeBloc,
        accountsBloc: accountsBloc,
        chatSettingsBloc: chatSettingsBloc,
        gemmaModelBloc: gemmaModelBloc,
      );

      expect(find.text('AI Models'), findsOneWidget);
      expect(find.text('Remote Tools'), findsOneWidget);
      expect(find.byIcon(Icons.hub_outlined), findsOneWidget);
      expect(find.text('1 service configured'), findsOneWidget);
    });
  });
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required SharedPreferences sharedPreferences,
  required ToolExecutor toolExecutor,
  required DmThemeBloc themeBloc,
  required AccountsBloc accountsBloc,
  required ChatSettingsBloc chatSettingsBloc,
  required GemmaModelBloc gemmaModelBloc,
}) {
  return tester.pumpWidget(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SharedPreferences>.value(value: sharedPreferences),
        RepositoryProvider<ToolExecutor>.value(value: toolExecutor),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<DmThemeBloc>.value(value: themeBloc),
          BlocProvider<AccountsBloc>.value(value: accountsBloc),
          BlocProvider<ChatSettingsBloc>.value(value: chatSettingsBloc),
          BlocProvider<GemmaModelBloc>.value(value: gemmaModelBloc),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    ),
  );
}

class _MemoryVaultRepository implements VaultRepository {
  final _values = <String, String>{};

  @override
  Future<bool> containsKey({required String key}) async {
    return _values.containsKey(key);
  }

  @override
  Future<void> delete({required String key}) async {
    _values.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _values.clear();
  }

  @override
  Future<String?> read({required String key}) async {
    return _values[key];
  }

  @override
  Future<Map<String, String>> readAll() async {
    return Map.unmodifiable(_values);
  }

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }
}
