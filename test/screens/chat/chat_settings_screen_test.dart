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
import 'package:gsmlg/screens/chat/chat_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ChatSettingsScreen', () {
    late AppDatabase database;
    late SharedPreferences preferences;
    late _MemoryVaultRepository vault;
    late AccountsBloc accountsBloc;
    late ChatSettingsBloc chatSettingsBloc;
    GemmaModelBloc? gemmaModelBloc;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferences = await SharedPreferences.getInstance();
      database = AppDatabase.forTesting();
      vault = _MemoryVaultRepository();
      accountsBloc = AccountsBloc(database: database, vault: vault);
    });

    tearDown(() async {
      await chatSettingsBloc.close();
      await gemmaModelBloc?.close();
      await accountsBloc.close();
      await database.close();
      await preferences.clear();
    });

    testWidgets('selects a configured remote model for an agent', (
      tester,
    ) async {
      final repository = ChatStorageRepository(database);
      const baseUrl = 'https://api.minimax.com/v1';
      await preferences.setStringList('remote_model_provider_profiles', [
        jsonEncode({
          'id': 'minimax',
          'name': 'MiniMax',
          'baseUrl': baseUrl,
          'defaultModel': 'MiniMax-M2.7',
          'useDummyToken': true,
          'remoteProvider': RemoteLlmProvider.openAiCompatible.name,
        }),
      ]);
      await preferences.setString(
        'remote_model_provider_selected_minimax',
        'MiniMax-M2.7',
      );
      await preferences.setStringList(
        'remote_provider_models_openAiCompatible_0_$baseUrl',
        ['MiniMax-M2.7'],
      );

      chatSettingsBloc =
          ChatSettingsBloc(repository: repository, preferences: preferences)
            ..add(const ChatSettingsLoad())
            ..add(
              const ChatSettingsSaveAgent(
                id: 'agent-1',
                name: 'Remote agent',
                systemPrompt: '',
                config: ModelConfig.defaultConfig,
              ),
            );

      await _pumpScreen(
        tester,
        chatSettingsBloc: chatSettingsBloc,
        accountsBloc: accountsBloc,
        preferences: preferences,
        agentId: 'agent-1',
      );

      await _pumpUntil(
        tester,
        () =>
            chatSettingsBloc.state.status == ChatSettingsStatus.loaded &&
            find.text('Model').evaluate().isNotEmpty,
      );

      await tester.tap(find.text('Model'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('MiniMax-M2.7').last);
      await tester.pumpAndSettle();

      await _pumpUntil(
        tester,
        () =>
            chatSettingsBloc.state.config.remoteProvider ==
            RemoteLlmProvider.openAiCompatible,
      );

      expect(
        chatSettingsBloc.state.config.remoteProvider,
        RemoteLlmProvider.openAiCompatible,
      );
      expect(chatSettingsBloc.state.config.remoteBaseUrl, baseUrl);
      expect(chatSettingsBloc.state.config.remoteModel, 'MiniMax-M2.7');
    });

    testWidgets('shows the selected local model in agent settings', (
      tester,
    ) async {
      await preferences.setString('gemma_selected_model_id', 'gemma-4-E4B-it');
      gemmaModelBloc = GemmaModelBloc(
        repository: GemmaRepository(),
        preferences: preferences,
      );

      final repository = ChatStorageRepository(database);
      chatSettingsBloc =
          ChatSettingsBloc(repository: repository, preferences: preferences)
            ..add(const ChatSettingsLoad())
            ..add(
              const ChatSettingsSaveAgent(
                id: 'agent-1',
                name: 'Local agent',
                systemPrompt: '',
                config: ModelConfig(inferenceMode: ChatInferenceMode.local),
              ),
            );

      await _pumpScreen(
        tester,
        chatSettingsBloc: chatSettingsBloc,
        accountsBloc: accountsBloc,
        preferences: preferences,
        gemmaModelBloc: gemmaModelBloc,
        agentId: 'agent-1',
      );

      await _pumpUntil(
        tester,
        () =>
            chatSettingsBloc.state.status == ChatSettingsStatus.loaded &&
            find.text('Model').evaluate().isNotEmpty,
      );

      expect(find.text('Gemma 4 E4B IT'), findsOneWidget);
      expect(find.text('Gemma 2B-IT'), findsNothing);
    });

    testWidgets('lists agents without per-agent settings', (tester) async {
      final repository = ChatStorageRepository(database);
      chatSettingsBloc =
          ChatSettingsBloc(repository: repository, preferences: preferences)
            ..add(const ChatSettingsLoad())
            ..add(
              const ChatSettingsSaveAgent(
                id: 'agent-1',
                name: 'Code reviewer',
                systemPrompt: 'Review code for correctness and missing tests.',
                config: ModelConfig(inferenceMode: ChatInferenceMode.remote),
              ),
            );

      await _pumpScreen(
        tester,
        chatSettingsBloc: chatSettingsBloc,
        accountsBloc: accountsBloc,
        preferences: preferences,
      );

      await _pumpUntil(
        tester,
        () =>
            chatSettingsBloc.state.status == ChatSettingsStatus.loaded &&
            find.text('Add Agent').evaluate().isNotEmpty,
      );

      expect(find.text('Code reviewer'), findsOneWidget);
      expect(find.text('Provider'), findsNothing);
      expect(find.text('Max Tokens'), findsNothing);
      expect(find.text('Default System Prompt'), findsNothing);
    });

    testWidgets('edits and removes an agent from agent settings', (
      tester,
    ) async {
      final repository = ChatStorageRepository(database);
      chatSettingsBloc =
          ChatSettingsBloc(repository: repository, preferences: preferences)
            ..add(const ChatSettingsLoad())
            ..add(
              const ChatSettingsSaveAgent(
                id: 'agent-1',
                name: 'Code reviewer',
                systemPrompt: 'Review code for correctness and missing tests.',
                config: ModelConfig(inferenceMode: ChatInferenceMode.remote),
              ),
            );

      await _pumpScreen(
        tester,
        chatSettingsBloc: chatSettingsBloc,
        accountsBloc: accountsBloc,
        preferences: preferences,
        agentId: 'agent-1',
      );
      await _pumpUntil(tester, () => find.text('Name').evaluate().isNotEmpty);

      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Agent name'),
        'Bug finder',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(chatSettingsBloc.state.agents.single.name, 'Bug finder');
      expect(chatSettingsBloc.state.activeAgent?.name, 'Bug finder');

      await _pumpUntil(
        tester,
        () => find
            .text('Remove Agent', skipOffstage: false)
            .evaluate()
            .isNotEmpty,
      );
      expect(find.text('Remove Agent', skipOffstage: false), findsOneWidget);

      chatSettingsBloc.add(const ChatSettingsDeleteAgent(id: 'agent-1'));
      await _pumpUntil(tester, () => chatSettingsBloc.state.agents.isEmpty);

      expect(chatSettingsBloc.state.agents, isEmpty);
      expect(chatSettingsBloc.state.activeAgent, isNull);
      expect(chatSettingsBloc.state.defaultSystemPrompt, isNull);
    });

    testWidgets('keeps sampling settings per chat agent', (tester) async {
      final repository = ChatStorageRepository(database);
      chatSettingsBloc = ChatSettingsBloc(
        repository: repository,
        preferences: preferences,
      )..add(const ChatSettingsLoad());

      await _pumpScreen(
        tester,
        chatSettingsBloc: chatSettingsBloc,
        accountsBloc: accountsBloc,
        preferences: preferences,
      );
      await _pumpUntil(
        tester,
        () =>
            chatSettingsBloc.state.status == ChatSettingsStatus.loaded &&
            find.text('Add Agent').evaluate().isNotEmpty,
      );

      chatSettingsBloc.add(
        const ChatSettingsSaveAgent(
          name: 'Reviewer',
          systemPrompt: 'Review code.',
        ),
      );
      await _pumpUntil(
        tester,
        () => chatSettingsBloc.state.activeAgent?.name == 'Reviewer',
      );
      chatSettingsBloc.add(
        ChatSettingsUpdateConfig(
          config: chatSettingsBloc.state.config.copyWith(temperature: 0.2),
        ),
      );
      await _pumpUntil(
        tester,
        () => chatSettingsBloc.state.config.temperature == 0.2,
      );

      chatSettingsBloc.add(
        const ChatSettingsSaveAgent(
          name: 'Writer',
          systemPrompt: 'Write docs.',
        ),
      );
      await _pumpUntil(
        tester,
        () => chatSettingsBloc.state.activeAgent?.name == 'Writer',
      );
      chatSettingsBloc.add(
        ChatSettingsUpdateConfig(
          config: chatSettingsBloc.state.config.copyWith(temperature: 1.2),
        ),
      );
      await _pumpUntil(
        tester,
        () => chatSettingsBloc.state.config.temperature == 1.2,
      );

      final reviewerId = chatSettingsBloc.state.agents
          .singleWhere((agent) => agent.name == 'Reviewer')
          .id;
      chatSettingsBloc.add(ChatSettingsSelectAgent(id: reviewerId));
      await _pumpUntil(
        tester,
        () => chatSettingsBloc.state.activeAgent?.name == 'Reviewer',
      );
      expect(chatSettingsBloc.state.activeAgent?.name, 'Reviewer');
      expect(chatSettingsBloc.state.config.temperature, 0.2);

      final writerId = chatSettingsBloc.state.agents
          .singleWhere((agent) => agent.name == 'Writer')
          .id;
      chatSettingsBloc.add(ChatSettingsSelectAgent(id: writerId));
      await _pumpUntil(
        tester,
        () => chatSettingsBloc.state.activeAgent?.name == 'Writer',
      );
      expect(chatSettingsBloc.state.activeAgent?.name, 'Writer');
      expect(chatSettingsBloc.state.config.temperature, 1.2);
    });
  });
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required ChatSettingsBloc chatSettingsBloc,
  required AccountsBloc accountsBloc,
  required SharedPreferences preferences,
  GemmaModelBloc? gemmaModelBloc,
  String? agentId,
}) {
  Widget child = MaterialApp(
    localizationsDelegates: AppLocale.localizationsDelegates,
    supportedLocales: AppLocale.supportedLocales,
    home: RepositoryProvider<SharedPreferences>.value(
      value: preferences,
      child: ChatSettingsScreen(agentId: agentId),
    ),
  );
  if (gemmaModelBloc != null) {
    child = BlocProvider<GemmaModelBloc>.value(
      value: gemmaModelBloc,
      child: child,
    );
  }

  return tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<ChatSettingsBloc>.value(value: chatSettingsBloc),
        BlocProvider<AccountsBloc>.value(value: accountsBloc),
      ],
      child: child,
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
