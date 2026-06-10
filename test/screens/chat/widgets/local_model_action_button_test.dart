import 'package:app_chat/app_chat.dart';
import 'package:app_database/app_database.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/chat/widgets/local_model_action_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocalModelActionButton', () {
    late AppDatabase database;
    late SharedPreferences preferences;
    late ChatSettingsBloc chatSettingsBloc;
    late GemmaModelBloc gemmaModelBloc;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferences = await SharedPreferences.getInstance();
      database = AppDatabase.forTesting();
    });

    tearDown(() async {
      await chatSettingsBloc.close();
      await gemmaModelBloc.close();
      await database.close();
      await preferences.clear();
    });

    Future<void> pumpButton(WidgetTester tester) async {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ChatSettingsBloc>.value(value: chatSettingsBloc),
            BlocProvider<GemmaModelBloc>.value(value: gemmaModelBloc),
          ],
          child: const MaterialApp(
            home: Scaffold(body: LocalModelActionButton()),
          ),
        ),
      );
    }

    Future<void> pumpUntil(
      WidgetTester tester,
      bool Function() condition,
    ) async {
      for (var i = 0; i < 50; i++) {
        if (condition()) return;
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(condition(), isTrue);
    }

    void setUpBlocs({
      required ModelConfig agentConfig,
      List<String> installedModels = const ['gemma-4-E4B-it'],
    }) {
      gemmaModelBloc = GemmaModelBloc(
        repository: _FakeGemmaRepository(installedModels),
        preferences: preferences,
      )..add(const GemmaModelListInstalled());
      chatSettingsBloc =
          ChatSettingsBloc(
              repository: ChatStorageRepository(database),
              preferences: preferences,
            )
            ..add(const ChatSettingsLoad())
            ..add(
              ChatSettingsSaveAgent(
                id: 'agent-1',
                name: 'Agent',
                systemPrompt: '',
                config: agentConfig,
              ),
            );
    }

    testWidgets(
      'shows Start when active agent is local with a stale model id',
      (tester) async {
        setUpBlocs(
          agentConfig: const ModelConfig(
            inferenceMode: ChatInferenceMode.local,
            localModelId: 'gemma-3n-E2B-it-int4',
          ),
        );

        await pumpButton(tester);
        await pumpUntil(
          tester,
          () =>
              chatSettingsBloc.state.activeAgentId == 'agent-1' &&
              gemmaModelBloc.state.installedModels.isNotEmpty,
        );
        await tester.pump();

        expect(find.text('Start'), findsOneWidget);
      },
    );

    testWidgets('shows Start when active local agent has no model selected', (
      tester,
    ) async {
      setUpBlocs(
        agentConfig: const ModelConfig(inferenceMode: ChatInferenceMode.local),
      );

      await pumpButton(tester);
      await pumpUntil(
        tester,
        () =>
            chatSettingsBloc.state.activeAgentId == 'agent-1' &&
            gemmaModelBloc.state.installedModels.isNotEmpty,
      );
      await tester.pump();

      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('tapping Start loads the agent model that is installed', (
      tester,
    ) async {
      setUpBlocs(
        agentConfig: const ModelConfig(
          inferenceMode: ChatInferenceMode.local,
          localModelId: 'gemma-4-E4B-it',
        ),
      );

      await pumpButton(tester);
      await pumpUntil(
        tester,
        () =>
            chatSettingsBloc.state.activeAgentId == 'agent-1' &&
            gemmaModelBloc.state.installedModels.isNotEmpty,
      );
      await tester.pump();

      await tester.tap(find.text('Start'));
      await pumpUntil(
        tester,
        () => gemmaModelBloc.state.selectedModelId == 'gemma-4-E4B-it',
      );
    });

    testWidgets('hides the button for remote agents', (tester) async {
      setUpBlocs(
        agentConfig: const ModelConfig(inferenceMode: ChatInferenceMode.remote),
      );

      await pumpButton(tester);
      await pumpUntil(
        tester,
        () =>
            chatSettingsBloc.state.activeAgentId == 'agent-1' &&
            gemmaModelBloc.state.installedModels.isNotEmpty,
      );
      await tester.pump();

      expect(find.text('Start'), findsNothing);
      expect(find.text('Stop'), findsNothing);
    });

    testWidgets('hides the button when no local model is installed', (
      tester,
    ) async {
      setUpBlocs(
        agentConfig: const ModelConfig(inferenceMode: ChatInferenceMode.local),
        installedModels: const [],
      );

      await pumpButton(tester);
      await pumpUntil(
        tester,
        () => chatSettingsBloc.state.activeAgentId == 'agent-1',
      );
      await tester.pump();

      expect(find.text('Start'), findsNothing);
    });
  });
}

class _FakeGemmaRepository extends GemmaRepository {
  _FakeGemmaRepository(this.models);

  final List<String> models;

  @override
  Future<List<String>> listInstalledModels() async => models;

  @override
  Future<void> activateModel(GemmaModelInfo info) async {}

  @override
  Future<void> unloadModel() async {}

  @override
  Future<void> loadModel(
    ModelConfig config, {
    bool supportImage = false,
    bool supportAudio = false,
    bool isThinking = false,
    bool supportsFunctionCalls = false,
  }) async {}
}
