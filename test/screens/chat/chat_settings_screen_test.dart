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
  group('ChatAgentsSettingsScreen', () {
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
          'remoteApiType': RemoteLlmApiType.openAiChatCompletions.name,
        }),
      ]);
      await preferences.setString(
        'remote_model_provider_selected_minimax',
        'MiniMax-M2.7',
      );
      await preferences.setStringList(
        'remote_provider_models_openAiCompatible_openAiChatCompletions_0_'
        '$baseUrl',
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
      expect(
        chatSettingsBloc.state.config.remoteApiType,
        RemoteLlmApiType.openAiChatCompletions,
      );
      expect(chatSettingsBloc.state.config.remoteBaseUrl, baseUrl);
      expect(chatSettingsBloc.state.config.remoteModel, 'MiniMax-M2.7');
    });

    testWidgets("shows the agent's own local model in agent settings", (
      tester,
    ) async {
      // The globally selected model must not leak into the agent's label.
      await preferences.setString('gemma_selected_model_id', 'gemma-4-E2B-it');
      gemmaModelBloc = GemmaModelBloc(
        repository: _InstalledModelsGemmaRepository([
          'gemma-4-E2B-it',
          'gemma-4-E4B-it',
        ]),
        preferences: preferences,
      )..add(const GemmaModelListInstalled());

      final repository = ChatStorageRepository(database);
      chatSettingsBloc =
          ChatSettingsBloc(repository: repository, preferences: preferences)
            ..add(const ChatSettingsLoad())
            ..add(
              const ChatSettingsSaveAgent(
                id: 'agent-1',
                name: 'Local agent',
                systemPrompt: '',
                config: ModelConfig(
                  inferenceMode: ChatInferenceMode.local,
                  localModelId: 'gemma-4-E4B-it',
                ),
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
            gemmaModelBloc!.state.installedModels.isNotEmpty &&
            find.text('Model').evaluate().isNotEmpty,
      );

      expect(find.text('Gemma 4 E4B IT'), findsOneWidget);
      expect(find.text('Gemma 4 E2B IT'), findsNothing);
    });

    testWidgets('lists installed local models in the agent model picker', (
      tester,
    ) async {
      gemmaModelBloc = GemmaModelBloc(
        repository: _InstalledModelsGemmaRepository(['gemma-4-E2B-it']),
        preferences: preferences,
      )..add(const GemmaModelListInstalled());

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
            gemmaModelBloc!.state.installedModels.isNotEmpty &&
            find.text('Model').evaluate().isNotEmpty,
      );

      await tester.tap(find.text('Model'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Gemma 4 E2B IT'), findsOneWidget);
      expect(find.text('No configured models'), findsNothing);
    });

    testWidgets('two agents can select different local models', (tester) async {
      gemmaModelBloc = GemmaModelBloc(
        repository: _InstalledModelsGemmaRepository([
          'gemma-4-E2B-it',
          'gemma-4-E4B-it',
        ]),
        preferences: preferences,
      )..add(const GemmaModelListInstalled());

      final repository = ChatStorageRepository(database);
      chatSettingsBloc = ChatSettingsBloc(
        repository: repository,
        preferences: preferences,
      )..add(const ChatSettingsLoad());
      await chatSettingsBloc.stream.firstWhere(
        (state) => state.status == ChatSettingsStatus.loaded,
      );
      chatSettingsBloc.add(
        const ChatSettingsSaveAgent(
          id: 'agent-1',
          name: 'Agent One',
          systemPrompt: '',
          config: ModelConfig(
            inferenceMode: ChatInferenceMode.local,
            temperature: 1.4,
          ),
        ),
      );
      await chatSettingsBloc.stream.firstWhere(
        (state) => state.agents.length == 1,
      );
      chatSettingsBloc.add(
        const ChatSettingsSaveAgent(
          id: 'agent-2',
          name: 'Agent Two',
          systemPrompt: '',
          config: ModelConfig(inferenceMode: ChatInferenceMode.local),
        ),
      );
      await chatSettingsBloc.stream.firstWhere(
        (state) => state.agents.length == 2,
      );

      ChatAgent agentById(String id) =>
          chatSettingsBloc.state.agents.firstWhere((agent) => agent.id == id);

      Future<void> pickModel(String agentId, String modelName) async {
        await _pumpScreen(
          tester,
          chatSettingsBloc: chatSettingsBloc,
          accountsBloc: accountsBloc,
          preferences: preferences,
          gemmaModelBloc: gemmaModelBloc,
          agentId: agentId,
        );
        await _pumpUntil(
          tester,
          () =>
              chatSettingsBloc.state.agents.length == 2 &&
              gemmaModelBloc!.state.installedModels.isNotEmpty &&
              find.text('Model').evaluate().isNotEmpty,
        );
        expect(
          chatSettingsBloc.state.agents.map((agent) => agent.id),
          containsAll(['agent-1', 'agent-2']),
        );
        await tester.tap(find.text('Model'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        await tester.tap(find.widgetWithText(ListTile, modelName));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
      }

      await pickModel('agent-1', 'Gemma 4 E2B IT');
      await _pumpUntil(
        tester,
        () => agentById('agent-1').config.localModelId == 'gemma-4-E2B-it',
      );

      await pickModel('agent-2', 'Gemma 4 E4B IT');
      await _pumpUntil(
        tester,
        () => agentById('agent-2').config.localModelId == 'gemma-4-E4B-it',
      );

      // Each agent keeps its own local model.
      expect(agentById('agent-1').config.localModelId, 'gemma-4-E2B-it');
      expect(agentById('agent-2').config.localModelId, 'gemma-4-E4B-it');

      // Picking a model must not reset the agent's other settings.
      expect(agentById('agent-1').config.temperature, 1.4);
    });

    testWidgets('removes missing local models from the agent model picker', (
      tester,
    ) async {
      await preferences.setString('gemma_selected_model_id', 'gemma-4-E4B-it');
      gemmaModelBloc = GemmaModelBloc(
        repository: _InstalledModelsGemmaRepository(['gemma-4-E2B-it']),
        preferences: preferences,
      )..add(const GemmaModelListInstalled());

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
            gemmaModelBloc!.state.installedModels.isNotEmpty &&
            find.text('Model').evaluate().isNotEmpty,
      );

      await tester.tap(find.text('Model'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.widgetWithText(ListTile, 'Gemma 4 E2B IT'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Gemma 4 E4B IT'), findsNothing);
    });

    testWidgets('removes missing remote models from the agent model picker', (
      tester,
    ) async {
      final repository = ChatStorageRepository(database);
      const baseUrl = 'https://api.minimax.com/v1';
      await preferences.setStringList('remote_model_provider_profiles', [
        jsonEncode({
          'id': 'minimax',
          'name': 'MiniMax',
          'baseUrl': baseUrl,
          'defaultModel': 'Old-M2',
          'useDummyToken': true,
          'remoteProvider': RemoteLlmProvider.openAiCompatible.name,
          'remoteApiType': RemoteLlmApiType.openAiChatCompletions.name,
        }),
      ]);
      await preferences.setString(
        'remote_model_provider_selected_minimax',
        'Old-M2',
      );
      await preferences.setStringList(
        'remote_provider_models_openAiCompatible_openAiChatCompletions_0_'
        '$baseUrl',
        ['New-M2'],
      );

      chatSettingsBloc =
          ChatSettingsBloc(repository: repository, preferences: preferences)
            ..add(const ChatSettingsLoad())
            ..add(
              ChatSettingsSaveAgent(
                id: 'agent-1',
                name: 'Remote agent',
                systemPrompt: '',
                config: ModelConfig.defaultConfig.copyWith(
                  inferenceMode: ChatInferenceMode.remote,
                  remoteProvider: RemoteLlmProvider.openAiCompatible,
                  remoteApiType: RemoteLlmApiType.openAiChatCompletions,
                  remoteAccountId: ModelConfig.dummyRemoteAccountId,
                  remoteBaseUrl: baseUrl,
                  remoteModel: 'Old-M2',
                ),
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.widgetWithText(ListTile, 'New-M2'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Old-M2'), findsNothing);
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
        () => chatSettingsBloc.state.agents.any(
          (agent) => agent.name == 'Writer',
        ),
      );
      final writerId = chatSettingsBloc.state.agents
          .singleWhere((agent) => agent.name == 'Writer')
          .id;
      chatSettingsBloc.add(ChatSettingsSelectAgent(id: writerId));
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
      child: ChatAgentsSettingsScreen(agentId: agentId),
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

class _InstalledModelsGemmaRepository extends GemmaRepository {
  _InstalledModelsGemmaRepository(this.models);

  final List<String> models;

  @override
  Future<List<String>> listInstalledModels() async => models;
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
