import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_chat/app_chat.dart';
import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/chat/chat_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ChatSettingsScreen', () {
    late AppDatabase database;
    late SharedPreferences preferences;
    late _MemoryVaultRepository vault;
    late AccountsBloc accountsBloc;
    late ChatSettingsBloc chatSettingsBloc;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferences = await SharedPreferences.getInstance();
      database = AppDatabase.forTesting();
      vault = _MemoryVaultRepository();
      accountsBloc = AccountsBloc(database: database, vault: vault);
    });

    tearDown(() async {
      await chatSettingsBloc.close();
      await accountsBloc.close();
      await database.close();
      await preferences.clear();
    });

    testWidgets('changes the active remote LLM provider', (tester) async {
      final repository = ChatStorageRepository(database);
      await repository.saveSettings(
        const ModelConfig(
          inferenceMode: ChatInferenceMode.remote,
          remoteProvider: RemoteLlmProvider.openAi,
          remoteAccountId: ModelConfig.dummyRemoteAccountId,
          remoteBaseUrl: 'https://api.openai.com/v1',
          remoteModel: 'gpt-4.1-mini',
          remoteThinkingEffort: RemoteThinkingEffort.max,
        ),
      );
      chatSettingsBloc = ChatSettingsBloc(
        repository: repository,
        preferences: preferences,
      )..add(const ChatSettingsLoad());

      await _pumpScreen(
        tester,
        chatSettingsBloc: chatSettingsBloc,
        accountsBloc: accountsBloc,
      );

      await _pumpUntil(
        tester,
        () =>
            chatSettingsBloc.state.status == ChatSettingsStatus.loaded &&
            find.text('Provider').evaluate().isNotEmpty,
      );

      expect(find.text('OpenAI'), findsOneWidget);

      await tester.tap(find.text('Provider'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('DeepSeek').last);
      await tester.pumpAndSettle();

      await _pumpUntil(
        tester,
        () =>
            chatSettingsBloc.state.config.remoteProvider ==
            RemoteLlmProvider.deepSeek,
      );

      expect(
        chatSettingsBloc.state.config.remoteProvider,
        RemoteLlmProvider.deepSeek,
      );
      expect(
        chatSettingsBloc.state.config.remoteBaseUrl,
        'https://api.deepseek.com/v1',
      );
      expect(chatSettingsBloc.state.config.remoteModel, 'deepseek-chat');
      expect(
        chatSettingsBloc.state.config.remoteThinkingEffort,
        RemoteThinkingEffort.max,
      );
      expect(find.text('DeepSeek'), findsOneWidget);
    });
  });
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required ChatSettingsBloc chatSettingsBloc,
  required AccountsBloc accountsBloc,
}) {
  return tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<ChatSettingsBloc>.value(value: chatSettingsBloc),
        BlocProvider<AccountsBloc>.value(value: accountsBloc),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocale.localizationsDelegates,
        supportedLocales: AppLocale.supportedLocales,
        home: const ChatSettingsScreen(),
      ),
    ),
  );
}

Future<void> _pumpUntil(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 50 && !done(); i += 1) {
    await tester.pump(const Duration(milliseconds: 20));
  }
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
