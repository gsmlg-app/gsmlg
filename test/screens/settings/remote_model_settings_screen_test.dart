import 'dart:convert';

import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_chat/app_chat.dart';
import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/settings/remote_model_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('RemoteModelSettingsScreen', () {
    late AppDatabase database;
    late SharedPreferences preferences;
    late _MemoryVaultRepository vault;
    ChatSettingsBloc? chatSettingsBloc;
    late AccountsBloc accountsBloc;
    late String baseUrl;
    late String providerModelsKey;
    late String visibleModelsKey;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferences = await SharedPreferences.getInstance();
      database = AppDatabase.forTesting();
      vault = _MemoryVaultRepository();
      baseUrl = 'http://localhost:11434/v1';
      providerModelsKey = 'remote_provider_models_openAi_0_$baseUrl';
      visibleModelsKey = 'remote_visible_models_openAi_0_$baseUrl';

      await preferences.setStringList('remote_model_provider_profiles', [
        jsonEncode({
          'id': 'openai',
          'name': 'Team OpenAI',
          'baseUrl': baseUrl,
          'defaultModel': 'gpt-4.1-mini',
          'accountId': null,
          'useDummyToken': true,
          'isBuiltIn': false,
          'remoteProvider': 'openAi',
        }),
      ]);
      await preferences.setString(
        'remote_model_provider_selected_openai',
        'stale-selected',
      );
      await preferences.setStringList(providerModelsKey, [
        'old-disabled',
        'old-visible',
      ]);
      await preferences.setStringList(visibleModelsKey, ['old-visible']);

      accountsBloc = AccountsBloc(database: database, vault: vault);
    });

    tearDown(() async {
      await chatSettingsBloc?.close();
      await accountsBloc.close();
      await database.close();
      await preferences.clear();
    });

    testWidgets('load models resets provider models and keeps selection', (
      tester,
    ) async {
      chatSettingsBloc = ChatSettingsBloc(
        repository: ChatStorageRepository(database),
        preferences: preferences,
      );

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<SharedPreferences>.value(value: preferences),
            RepositoryProvider<RemoteLlmRepository>(
              create: (_) => _FakeRemoteLlmRepository(vault: vault),
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<ChatSettingsBloc>.value(value: chatSettingsBloc!),
              BlocProvider<AccountsBloc>.value(value: accountsBloc),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocale.localizationsDelegates,
              supportedLocales: AppLocale.supportedLocales,
              home: const RemoteModelSettingsScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('stale-selected'), findsAtLeastNWidgets(1));

      await tester.tap(find.text('Load Models').first);
      await tester.pumpAndSettle();

      expect(preferences.getStringList(providerModelsKey), [
        'new-alpha',
        'new-beta',
      ]);
      expect(preferences.getStringList(visibleModelsKey), [
        'new-alpha',
        'new-beta',
      ]);
      expect(
        preferences.getString('remote_model_provider_selected_openai'),
        'stale-selected',
      );
      expect(find.text('new-alpha'), findsOneWidget);
      expect(find.text('new-beta'), findsOneWidget);
      expect(find.text('old-visible'), findsNothing);
      expect(find.text('old-disabled'), findsNothing);
      expect(find.text('stale-selected'), findsAtLeastNWidgets(1));
    });

    testWidgets('load models keeps the active chat provider selection', (
      tester,
    ) async {
      final activeConfig = ModelConfig(
        inferenceMode: ChatInferenceMode.remote,
        remoteProvider: RemoteLlmProvider.openAi,
        remoteAccountId: ModelConfig.dummyRemoteAccountId,
        remoteBaseUrl: baseUrl,
        remoteModel: 'stale-selected',
      );
      final repository = ChatStorageRepository(database);
      await repository.saveSettings(activeConfig);
      expect(await repository.loadSettings(), activeConfig);
      chatSettingsBloc = ChatSettingsBloc(
        repository: repository,
        preferences: preferences,
      );

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<SharedPreferences>.value(value: preferences),
            RepositoryProvider<RemoteLlmRepository>(
              create: (_) => _FakeRemoteLlmRepository(vault: vault),
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<ChatSettingsBloc>.value(value: chatSettingsBloc!),
              BlocProvider<AccountsBloc>.value(value: accountsBloc),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocale.localizationsDelegates,
              supportedLocales: AppLocale.supportedLocales,
              home: const RemoteModelSettingsScreen(),
            ),
          ),
        ),
      );

      await _pumpUntil(
        tester,
        () =>
            chatSettingsBloc!.state.config == activeConfig &&
            find.text('Active Provider').evaluate().isNotEmpty,
      );
      expect(chatSettingsBloc!.state.config, activeConfig);
      expect(find.text('stale-selected'), findsAtLeastNWidgets(1));

      await tester.tap(find.text('Load Models').first);
      await _pumpUntil(
        tester,
        () =>
            chatSettingsBloc!.state.config == activeConfig &&
            preferences.getStringList(visibleModelsKey)?.join('|') ==
                'new-alpha|new-beta' &&
            preferences.getStringList(providerModelsKey)?.join('|') ==
                'new-alpha|new-beta',
      );
      await tester.pumpAndSettle();

      expect(preferences.getStringList(providerModelsKey), [
        'new-alpha',
        'new-beta',
      ]);
      expect(preferences.getStringList(visibleModelsKey), [
        'new-alpha',
        'new-beta',
      ]);
      expect(find.text('new-alpha'), findsOneWidget);
      expect(find.text('new-beta'), findsOneWidget);
      expect(find.text('old-visible'), findsNothing);
      expect(
        preferences.getString('remote_model_provider_selected_openai'),
        'stale-selected',
      );
      expect(chatSettingsBloc!.state.config, activeConfig);
      expect(find.text('stale-selected'), findsAtLeastNWidgets(1));
    });

    testWidgets(
      'model switch disables chat visibility without removing model',
      (tester) async {
        await preferences.setStringList(visibleModelsKey, [
          'old-disabled',
          'old-visible',
        ]);
        chatSettingsBloc = ChatSettingsBloc(
          repository: ChatStorageRepository(database),
          preferences: preferences,
        );

        await _pumpScreen(
          tester,
          preferences: preferences,
          vault: vault,
          chatSettingsBloc: chatSettingsBloc!,
          accountsBloc: accountsBloc,
        );

        await tester.pumpAndSettle();
        expect(find.text('old-visible'), findsOneWidget);

        await tester.tap(find.text('old-visible'));
        await tester.pumpAndSettle();

        expect(preferences.getStringList(providerModelsKey), [
          'old-disabled',
          'old-visible',
        ]);
        expect(preferences.getStringList(visibleModelsKey), ['old-disabled']);
        expect(find.text('old-visible'), findsOneWidget);
      },
    );

    testWidgets('does not show selected model in provider model switches', (
      tester,
    ) async {
      await preferences.setString(
        'remote_model_provider_selected_openai',
        'old-visible',
      );
      chatSettingsBloc = ChatSettingsBloc(
        repository: ChatStorageRepository(database),
        preferences: preferences,
      );

      await _pumpScreen(
        tester,
        preferences: preferences,
        vault: vault,
        chatSettingsBloc: chatSettingsBloc!,
        accountsBloc: accountsBloc,
      );

      await tester.pumpAndSettle();

      expect(find.text('old-disabled'), findsOneWidget);
      expect(find.text('old-visible'), findsOneWidget);
      expect(find.text('Selected for this provider'), findsNothing);
    });

    testWidgets('selects provider model from dropdown', (tester) async {
      final repository = ChatStorageRepository(database);
      final activeConfig = ModelConfig(
        inferenceMode: ChatInferenceMode.remote,
        remoteProvider: RemoteLlmProvider.openAi,
        remoteAccountId: ModelConfig.dummyRemoteAccountId,
        remoteBaseUrl: baseUrl,
        remoteModel: 'old-visible',
      );
      await repository.saveSettings(activeConfig);
      chatSettingsBloc = ChatSettingsBloc(
        repository: repository,
        preferences: preferences,
      );

      await _pumpScreen(
        tester,
        preferences: preferences,
        vault: vault,
        chatSettingsBloc: chatSettingsBloc!,
        accountsBloc: accountsBloc,
      );

      await _pumpUntil(
        tester,
        () =>
            chatSettingsBloc!.state.config == activeConfig &&
            find.byType(DropdownButton<String>).evaluate().isNotEmpty,
      );

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('old-disabled').last);
      await tester.pumpAndSettle();

      await _pumpUntil(
        tester,
        () => chatSettingsBloc!.state.config.remoteModel == 'old-disabled',
      );

      expect(
        preferences.getString('remote_model_provider_selected_openai'),
        'old-disabled',
      );
      expect(chatSettingsBloc!.state.config.remoteModel, 'old-disabled');
      expect(preferences.getStringList(visibleModelsKey), [
        'old-disabled',
        'old-visible',
      ]);
    });

    testWidgets('switches active provider before selecting a model', (
      tester,
    ) async {
      await preferences.setStringList('remote_model_provider_profiles', [
        jsonEncode({
          'id': 'deepseek',
          'name': 'Team DeepSeek',
          'baseUrl': 'https://api.deepseek.com/v1',
          'defaultModel': 'deepseek-chat',
          'accountId': null,
          'useDummyToken': true,
          'isBuiltIn': false,
          'remoteProvider': 'deepSeek',
        }),
      ]);
      final repository = ChatStorageRepository(database);
      final activeConfig = ModelConfig(
        inferenceMode: ChatInferenceMode.remote,
        remoteProvider: RemoteLlmProvider.openAi,
        remoteAccountId: ModelConfig.dummyRemoteAccountId,
        remoteBaseUrl: baseUrl,
        remoteModel: 'old-visible',
      );
      await repository.saveSettings(activeConfig);
      chatSettingsBloc = ChatSettingsBloc(
        repository: repository,
        preferences: preferences,
      );

      await _pumpScreen(
        tester,
        preferences: preferences,
        vault: vault,
        chatSettingsBloc: chatSettingsBloc!,
        accountsBloc: accountsBloc,
      );

      await _pumpUntil(
        tester,
        () =>
            chatSettingsBloc!.state.config == activeConfig &&
            find.text('Team DeepSeek').evaluate().isNotEmpty,
      );

      await tester.tap(find.text('Use In Chat').last);
      await _pumpUntil(
        tester,
        () =>
            chatSettingsBloc!.state.config.remoteProvider ==
            RemoteLlmProvider.deepSeek,
      );

      expect(chatSettingsBloc!.state.status, ChatSettingsStatus.loaded);
      expect(
        chatSettingsBloc!.state.config.remoteProvider,
        RemoteLlmProvider.deepSeek,
      );
      expect(
        chatSettingsBloc!.state.config.remoteBaseUrl,
        'https://api.deepseek.com/v1',
      );
      expect(chatSettingsBloc!.state.config.remoteModel, isEmpty);
    });

    testWidgets('shows only user-added providers', (tester) async {
      chatSettingsBloc = ChatSettingsBloc(
        repository: ChatStorageRepository(database),
        preferences: preferences,
      );

      await _pumpScreen(
        tester,
        preferences: preferences,
        vault: vault,
        chatSettingsBloc: chatSettingsBloc!,
        accountsBloc: accountsBloc,
      );

      await tester.pumpAndSettle();
      expect(find.text('Team OpenAI'), findsOneWidget);
      expect(find.text('Delete Team OpenAI'), findsOneWidget);
      expect(find.text('OpenRouter'), findsNothing);
      expect(find.text('Groq'), findsNothing);
      expect(find.text('DeepSeek'), findsNothing);
      expect(find.text('Ollama'), findsNothing);
      expect(find.text('LM Studio'), findsNothing);
    });

    testWidgets('adds a user provider from the selected preset', (
      tester,
    ) async {
      await preferences.setStringList('remote_model_provider_profiles', []);
      chatSettingsBloc = ChatSettingsBloc(
        repository: ChatStorageRepository(database),
        preferences: preferences,
      );

      await _pumpScreen(
        tester,
        preferences: preferences,
        vault: vault,
        chatSettingsBloc: chatSettingsBloc!,
        accountsBloc: accountsBloc,
      );

      await tester.tap(find.byTooltip('Add provider'));
      await tester.pumpAndSettle();

      expect(find.text('Provider preset'), findsOneWidget);
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ollama').last);
      await tester.pumpAndSettle();

      expect(find.text('http://localhost:11434/v1'), findsAtLeastNWidgets(1));
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      final saved = preferences.getStringList('remote_model_provider_profiles');
      expect(saved, hasLength(1));
      final provider = jsonDecode(saved!.single) as Map<String, dynamic>;
      expect(provider['id'], isNot('ollama'));
      expect(provider['name'], 'Ollama');
      expect(provider['baseUrl'], 'http://localhost:11434/v1');
      expect(provider['defaultModel'], 'llama3.2');
      expect(provider['useDummyToken'], isTrue);
      expect(provider['isBuiltIn'], isFalse);
      expect(provider['remoteProvider'], 'openAiCompatible');
      expect(find.text('Ollama'), findsOneWidget);
      expect(find.text('Delete Ollama'), findsOneWidget);
    });

    testWidgets('changes an existing provider preset', (tester) async {
      chatSettingsBloc = ChatSettingsBloc(
        repository: ChatStorageRepository(database),
        preferences: preferences,
      );

      await _pumpScreen(
        tester,
        preferences: preferences,
        vault: vault,
        chatSettingsBloc: chatSettingsBloc!,
        accountsBloc: accountsBloc,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Base URL').first);
      await tester.pumpAndSettle();

      expect(find.text('Provider preset'), findsOneWidget);
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('DeepSeek').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Use dummy token'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final saved = preferences.getStringList('remote_model_provider_profiles');
      expect(saved, hasLength(1));
      final provider = jsonDecode(saved!.single) as Map<String, dynamic>;
      expect(provider['id'], 'openai');
      expect(provider['name'], 'DeepSeek');
      expect(provider['baseUrl'], 'https://api.deepseek.com/v1');
      expect(provider['defaultModel'], 'deepseek-chat');
      expect(provider['accountId'], isNull);
      expect(provider['remoteProvider'], 'deepSeek');
      expect(provider['useDummyToken'], isTrue);
    });
  });
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required SharedPreferences preferences,
  required _MemoryVaultRepository vault,
  required ChatSettingsBloc chatSettingsBloc,
  required AccountsBloc accountsBloc,
}) {
  return tester.pumpWidget(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SharedPreferences>.value(value: preferences),
        RepositoryProvider<RemoteLlmRepository>(
          create: (_) => _FakeRemoteLlmRepository(vault: vault),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ChatSettingsBloc>.value(value: chatSettingsBloc),
          BlocProvider<AccountsBloc>.value(value: accountsBloc),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: const RemoteModelSettingsScreen(),
        ),
      ),
    ),
  );
}

Future<void> _pumpUntil(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 50 && !done(); i += 1) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

class _FakeRemoteLlmRepository extends RemoteLlmRepository {
  _FakeRemoteLlmRepository({required super.vault});

  @override
  Future<List<String>> listModels(ModelConfig config) async {
    return const ['new-alpha', 'new-beta'];
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
