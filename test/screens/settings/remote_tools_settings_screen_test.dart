import 'dart:convert';

import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_chat/app_chat.dart';
import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/settings/remote_tools_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('RemoteToolsSettingsScreen', () {
    late SharedPreferences preferences;
    late AccountsBloc accountsBloc;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferences = await SharedPreferences.getInstance();
      accountsBloc = _FakeAccountsBloc(const AccountsLoaded(accounts: []));
    });

    tearDown(() async {
      await accountsBloc.close();
      await preferences.clear();
    });

    testWidgets('renders saved MCP services and toggles enabled state', (
      tester,
    ) async {
      await preferences.setStringList('remote_mcp_profiles', [
        jsonEncode({
          'id': 'filesystem',
          'name': 'Filesystem MCP',
          'url': 'https://mcp.example.com/http',
          'transport': 'http',
          'enabled': true,
          'accountId': null,
        }),
      ]);

      await _pumpScreen(
        tester,
        preferences: preferences,
        accountsBloc: accountsBloc,
      );

      expect(find.text('Remote Tools'), findsAtLeastNWidgets(1));
      expect(find.text('Filesystem MCP'), findsOneWidget);
      expect(find.textContaining('HTTP'), findsOneWidget);

      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      final saved = preferences.getStringList('remote_mcp_profiles');
      final profile = jsonDecode(saved!.single) as Map<String, dynamic>;
      expect(profile['enabled'], isFalse);
    });

    testWidgets('preserves MCP tool schemas when toggling a service', (
      tester,
    ) async {
      await preferences.setStringList('remote_mcp_profiles', [
        jsonEncode({
          'id': 'docs',
          'name': 'Docs MCP',
          'url': 'https://mcp.example.com/http',
          'transport': 'http',
          'enabled': true,
          'accountId': null,
          'tools': [
            {
              'name': 'search_docs',
              'description': 'Search documentation',
              'inputSchema': {
                'type': 'object',
                'properties': {
                  'query': {'type': 'string'},
                },
                'required': ['query'],
              },
            },
          ],
        }),
      ]);

      await _pumpScreen(
        tester,
        preferences: preferences,
        accountsBloc: accountsBloc,
      );

      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      final saved = preferences.getStringList('remote_mcp_profiles');
      final profile = jsonDecode(saved!.single) as Map<String, dynamic>;
      final tools = profile['tools'] as List<dynamic>;
      final tool = tools.single as Map<String, dynamic>;
      expect(tool['inputSchema'], {
        'type': 'object',
        'properties': {
          'query': {'type': 'string'},
        },
        'required': ['query'],
      });
    });

    testWidgets('renders service account auth for an MCP service', (
      tester,
    ) async {
      const accountId = 1;
      await accountsBloc.close();
      accountsBloc = _FakeAccountsBloc(
        AccountsLoaded(
          accounts: [
            ServiceAccountTableData(
              id: accountId,
              provider: ServiceProvider.openai,
              name: 'Work Token',
              description: '',
              createdAt: DateTime(2026),
              updatedAt: DateTime(2026),
            ),
          ],
        ),
      );
      await preferences.setStringList('remote_mcp_profiles', [
        jsonEncode({
          'id': 'docs',
          'name': 'Docs MCP',
          'url': 'https://mcp.example.com/http',
          'transport': 'http',
          'enabled': true,
          'accountId': accountId,
        }),
      ]);

      await _pumpScreen(
        tester,
        preferences: preferences,
        accountsBloc: accountsBloc,
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Docs MCP'), findsOneWidget);
      expect(find.textContaining('Work Token'), findsOneWidget);
    });

    testWidgets('does not expose secret editing on MCP detail screen', (
      tester,
    ) async {
      const accountId = 1;
      await accountsBloc.close();
      accountsBloc = _FakeAccountsBloc(
        AccountsLoaded(
          accounts: [
            ServiceAccountTableData(
              id: accountId,
              provider: ServiceProvider.openai,
              name: 'Work Token',
              description: '',
              createdAt: DateTime(2026),
              updatedAt: DateTime(2026),
            ),
          ],
        ),
      );
      await preferences.setStringList('remote_mcp_profiles', [
        jsonEncode({
          'id': 'docs',
          'name': 'Docs MCP',
          'url': 'https://mcp.example.com/http',
          'transport': 'http',
          'enabled': true,
          'accountId': accountId,
        }),
      ]);

      await _pumpScreen(
        tester,
        preferences: preferences,
        accountsBloc: accountsBloc,
        home: const RemoteToolSettingsScreen(profileId: 'docs'),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Auth Account'), findsOneWidget);
      expect(find.text('Auth Type'), findsOneWidget);
      expect(find.text('Change Secret'), findsNothing);
      expect(find.text('Manage Service Accounts'), findsOneWidget);
    });

    testWidgets('shows a clear error when selected MCP account has no secret', (
      tester,
    ) async {
      const accountId = 1;
      await accountsBloc.close();
      accountsBloc = _FakeAccountsBloc(
        AccountsLoaded(
          accounts: [
            ServiceAccountTableData(
              id: accountId,
              provider: ServiceProvider.openai,
              name: 'Backplane',
              description: '',
              createdAt: DateTime(2026),
              updatedAt: DateTime(2026),
            ),
          ],
        ),
      );
      await preferences.setStringList('remote_mcp_profiles', [
        jsonEncode({
          'id': 'docs',
          'name': 'Docs MCP',
          'url': 'https://mcp.example.com/http',
          'transport': 'http',
          'enabled': true,
          'accountId': accountId,
        }),
      ]);

      await _pumpScreen(
        tester,
        preferences: preferences,
        accountsBloc: accountsBloc,
        home: const RemoteToolSettingsScreen(profileId: 'docs'),
      );
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byTooltip('Refresh tools'));
      await tester.pump();

      expect(
        find.textContaining(
          'Service account "Backplane" has no secret. Update it in Service Accounts.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('adds an HTTP MCP service', (tester) async {
      await _pumpScreen(
        tester,
        preferences: preferences,
        accountsBloc: accountsBloc,
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byTooltip('Add MCP service'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(
        find.widgetWithText(TextField, 'Name'),
        'Docs MCP',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Endpoint URL'),
        'https://mcp.example.com/http',
      );
      await tester.tap(find.text('Add'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Docs MCP'), findsOneWidget);
      final saved = preferences.getStringList('remote_mcp_profiles');
      final profile = jsonDecode(saved!.single) as Map<String, dynamic>;
      expect(profile['name'], 'Docs MCP');
      expect(profile['url'], 'https://mcp.example.com/http');
      expect(profile['transport'], 'http');
      expect(profile['enabled'], isTrue);
      expect(profile['accountId'], isNull);
    });

    testWidgets('adds an HTTP MCP service with custom header auth', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        preferences: preferences,
        accountsBloc: accountsBloc,
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byTooltip('Add MCP service'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(
        find.widgetWithText(TextField, 'Name'),
        'Secure Docs MCP',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Endpoint URL'),
        'https://mcp.example.com/http',
      );
      await tester.tap(
        find.byType(DropdownButtonFormField<RemoteAuthType>).first,
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Custom header').last);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(
        find.widgetWithText(TextField, 'Header name'),
        'X-MCP-Key',
      );
      await tester.tap(find.text('Add'));
      await tester.pump(const Duration(milliseconds: 300));

      final saved = preferences.getStringList('remote_mcp_profiles');
      final profile = jsonDecode(saved!.single) as Map<String, dynamic>;
      expect(profile['authType'], 'customHeader');
      expect(profile['authHeaderName'], 'X-MCP-Key');
    });

    testWidgets('lists MCP server tools on the detail screen', (tester) async {
      await preferences.setStringList('remote_mcp_profiles', [
        jsonEncode({
          'id': 'docs',
          'name': 'Docs MCP',
          'url': 'https://mcp.example.com/http',
          'transport': 'http',
          'enabled': true,
          'accountId': null,
          'tools': [
            {'name': 'search_docs', 'description': 'Search documentation'},
            {'name': 'read_doc', 'description': 'Read a document'},
          ],
        }),
      ]);

      await _pumpScreen(
        tester,
        preferences: preferences,
        accountsBloc: accountsBloc,
        home: const RemoteToolSettingsScreen(profileId: 'docs'),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Docs MCP'), findsAtLeastNWidgets(1));
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
      await tester.pumpAndSettle();

      expect(find.text('search_docs'), findsOneWidget);
      expect(find.text('Search documentation'), findsOneWidget);
      expect(find.text('read_doc'), findsOneWidget);
      expect(find.text('Read a document'), findsOneWidget);
    });
  });
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required SharedPreferences preferences,
  required AccountsBloc accountsBloc,
  Widget home = const RemoteToolsSettingsScreen(),
}) {
  return tester.pumpWidget(
    RepositoryProvider<SharedPreferences>.value(
      value: preferences,
      child: BlocProvider<AccountsBloc>.value(
        value: accountsBloc,
        child: MaterialApp(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: home,
        ),
      ),
    ),
  );
}

class _FakeAccountsBloc extends Bloc<AccountsEvent, AccountsState>
    implements AccountsBloc {
  _FakeAccountsBloc(super.initialState);

  @override
  Future<String?> getApiKey(int accountId) async {
    return null;
  }
}
