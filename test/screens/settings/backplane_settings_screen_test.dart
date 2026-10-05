import 'dart:convert';

import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_chat/app_chat.dart';
import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/settings/backplane_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences preferences;
  late BackplaneSettingsBloc backplaneBloc;
  late _AccountsBloc accountsBloc;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    accountsBloc = _AccountsBloc();
  });

  tearDown(() async {
    await backplaneBloc.close();
    await accountsBloc.close();
  });

  testWidgets('shows offline settings and saves a prefixed URL', (
    tester,
  ) async {
    final service = _Service();
    backplaneBloc = BackplaneSettingsBloc(
      preferences: preferences,
      service: service,
    );
    await _pump(tester, backplaneBloc, accountsBloc);

    expect(find.text('Backplane'), findsWidgets);
    expect(find.text('Load Models'), findsOneWidget);
    expect(find.text('Manage Service Accounts'), findsOneWidget);
    expect(find.text('Use for Chat'), findsNothing);

    await tester.enterText(
      find.byType(TextField).first,
      'https://example.com/team',
    );
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(
      BackplaneSettingsBloc.readSettings(preferences).apiBaseUrl,
      'https://example.com/team/v1',
    );
    expect(service.calls, 0);
  });

  testWidgets('missing selected account shows management guidance', (
    tester,
  ) async {
    await preferences.setString(
      BackplaneSettingsBloc.preferencesKey,
      jsonEncode(const BackplaneSettings(accountId: 7).toJson()),
    );
    backplaneBloc = BackplaneSettingsBloc(
      preferences: preferences,
      service: _Service(),
    );
    await _pump(tester, backplaneBloc, accountsBloc);
    expect(
      find.textContaining('selected account is unavailable'),
      findsOneWidget,
    );
    expect(find.text('Manage Service Accounts'), findsOneWidget);
    expect(backplaneBloc.state.settings.accountId, 7);
  });

  testWidgets('selects Backplane and existing provider accounts', (
    tester,
  ) async {
    await accountsBloc.close();
    accountsBloc = _AccountsBloc([
      ServiceAccountTableData(
        id: 8,
        provider: ServiceProvider.backplane,
        name: 'Backplane token',
        description: '',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
      ServiceAccountTableData(
        id: 9,
        provider: ServiceProvider.openai,
        name: 'Existing OpenAI account',
        description: '',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    ]);
    backplaneBloc = BackplaneSettingsBloc(
      preferences: preferences,
      service: _Service(),
    );
    await _pump(tester, backplaneBloc, accountsBloc);

    final accountPicker = find.byType(DropdownButton<int?>).first;
    await tester.tap(accountPicker);
    await tester.pumpAndSettle();
    expect(find.text('Backplane token'), findsOneWidget);
    expect(find.text('Existing OpenAI account'), findsOneWidget);
    await tester.tap(find.text('Backplane token').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(BackplaneSettingsBloc.readSettings(preferences).accountId, 8);

    await tester.tap(accountPicker);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Existing OpenAI account').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(BackplaneSettingsBloc.readSettings(preferences).accountId, 9);
  });

  testWidgets('protocol and MCP toggle persist without enabling discovery', (
    tester,
  ) async {
    final service = _Service();
    backplaneBloc = BackplaneSettingsBloc(
      preferences: preferences,
      service: service,
    );
    await _pump(tester, backplaneBloc, accountsBloc);

    await tester.ensureVisible(find.text('LLM protocol'));
    await tester.tap(find.byType(DropdownButton<RemoteLlmApiType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chat Completions').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Enable MCP tools'));
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final settings = BackplaneSettingsBloc.readSettings(preferences);
    expect(settings.apiType, RemoteLlmApiType.openAiChatCompletions);
    expect(settings.mcpEnabled, isTrue);
    expect(settings.tools, isEmpty);
    expect(service.calls, 0);
  });
}

Future<void> _pump(
  WidgetTester tester,
  BackplaneSettingsBloc backplaneBloc,
  AccountsBloc accountsBloc,
) async {
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<BackplaneSettingsBloc>.value(value: backplaneBloc),
        BlocProvider<AccountsBloc>.value(value: accountsBloc),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocale.localizationsDelegates,
        supportedLocales: AppLocale.supportedLocales,
        home: const BackplaneSettingsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _AccountsBloc extends Bloc<AccountsEvent, AccountsState>
    implements AccountsBloc {
  _AccountsBloc([List<ServiceAccountTableData> accounts = const []])
    : super(AccountsLoaded(accounts: accounts));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Service implements BackplaneServiceRepository {
  int calls = 0;

  @override
  Future<List<String>> loadModels(BackplaneSettings settings) async {
    calls++;
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> refreshTools(
    BackplaneSettings settings,
  ) async {
    calls++;
    return [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
