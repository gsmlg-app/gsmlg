import 'dart:async';
import 'dart:convert';

import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  test('save is offline and connection changes invalidate both catalogs',
      () async {
    await preferences.setString(
        BackplaneSettingsBloc.preferencesKey,
        jsonEncode(const BackplaneSettings(
          accountId: 1,
          models: ['old'],
          tools: [
            {'name': 'old_tool'}
          ],
        ).toJson()));
    final service = _FakeService();
    final bloc =
        BackplaneSettingsBloc(preferences: preferences, service: service);
    addTearDown(bloc.close);

    final saved =
        bloc.stream.firstWhere((state) => state.settings.accountId == 2);
    bloc.add(const BackplaneSave(
      serviceUrl: 'https://example.com/prefix/',
      accountId: 2,
      apiType: RemoteLlmApiType.openAiResponses,
      mcpEnabled: false,
    ));
    final state = await saved;
    expect(state.settings.apiBaseUrl, 'https://example.com/prefix/v1');
    expect(state.settings.mcpUrl, 'https://example.com/prefix/mcp');
    expect(state.settings.models, isEmpty);
    expect(state.settings.tools, isEmpty);
    expect(service.modelCalls, 0);
    expect(service.toolCalls, 0);
  });

  test('parallel discovery merges catalogs and retains same-connection save',
      () async {
    final models = Completer<List<String>>();
    final tools = Completer<List<Map<String, dynamic>>>();
    final service = _FakeService(models: models.future, tools: tools.future);
    final bloc =
        BackplaneSettingsBloc(preferences: preferences, service: service);
    addTearDown(bloc.close);

    bloc.add(const BackplaneLoadModels());
    bloc.add(const BackplaneRefreshTools());
    await bloc.stream
        .firstWhere((state) => state.modelsLoading && state.toolsLoading);
    bloc.add(const BackplaneSave(
      serviceUrl: 'https://backplane.gsmlg.net',
      accountId: null,
      apiType: RemoteLlmApiType.openAiChatCompletions,
      mcpEnabled: true,
    ));
    final saved =
        await bloc.stream.firstWhere((state) => state.settings.mcpEnabled);
    expect(saved.modelsLoading, isTrue);
    expect(saved.toolsLoading, isTrue);
    models.complete(['alpha']);
    final modelsLoaded = await bloc.stream
        .firstWhere((state) => state.settings.models.isNotEmpty);
    expect(modelsLoaded.modelsLoading, isFalse);
    expect(modelsLoaded.toolsLoading, isTrue);
    tools.complete([
      {'name': 'lookup'}
    ]);
    final state = await bloc.stream.firstWhere((state) =>
        !state.modelsLoading &&
        !state.toolsLoading &&
        state.settings.models.isNotEmpty &&
        state.settings.tools.isNotEmpty);
    expect(state.settings.apiType, RemoteLlmApiType.openAiChatCompletions);
    expect(state.settings.mcpEnabled, isTrue);
    expect(BackplaneSettingsBloc.readSettings(preferences).models, ['alpha']);
    expect(BackplaneSettingsBloc.readSettings(preferences).tools.single['name'],
        'lookup');
  });

  for (final pendingModels in [true, false]) {
    test(
        'same-connection save preserves pending ${pendingModels ? 'models' : 'tools'} and discovery errors',
        () async {
      const initial = BackplaneSettings(
        models: ['cached'],
        tools: [
          {'name': 'cached_tool'}
        ],
      );
      await preferences.setString(
          BackplaneSettingsBloc.preferencesKey, jsonEncode(initial.toJson()));
      final models = Completer<List<String>>();
      final tools = Completer<List<Map<String, dynamic>>>();
      final service = _FakeService(models: models.future, tools: tools.future);
      final bloc =
          BackplaneSettingsBloc(preferences: preferences, service: service);
      addTearDown(bloc.close);

      bloc.add(const BackplaneLoadModels());
      bloc.add(const BackplaneRefreshTools());
      await bloc.stream
          .firstWhere((state) => state.modelsLoading && state.toolsLoading);
      if (pendingModels) {
        tools.completeError(StateError('tools denied'));
      } else {
        models.completeError(StateError('models denied'));
      }
      final failed = await bloc.stream.firstWhere(
          (state) => state.modelsError != null || state.toolsError != null);
      bloc.add(const BackplaneSave(
        serviceUrl: 'https://backplane.gsmlg.net',
        accountId: null,
        apiType: RemoteLlmApiType.openAiChatCompletions,
        mcpEnabled: true,
      ));
      final saved =
          await bloc.stream.firstWhere((state) => state.settings.mcpEnabled);
      expect(saved.modelsLoading, pendingModels);
      expect(saved.toolsLoading, !pendingModels);
      expect(saved.modelsError, failed.modelsError);
      expect(saved.toolsError, failed.toolsError);
      expect(saved.settings.models, initial.models);
      expect(saved.settings.tools, initial.tools);
      expect(service.modelCalls, 1);
      expect(service.toolCalls, 1);

      if (pendingModels) {
        models.completeError(StateError('models denied'));
      } else {
        tools.completeError(StateError('tools denied'));
      }
      final finished = await bloc.stream.firstWhere(
          (state) => state.modelsError != null && state.toolsError != null);
      expect(finished.modelsLoading, isFalse);
      expect(finished.toolsLoading, isFalse);
    });
  }

  test('old discovery cannot repopulate catalogs after account change',
      () async {
    final models = Completer<List<String>>();
    final tools = Completer<List<Map<String, dynamic>>>();
    final bloc = BackplaneSettingsBloc(
      preferences: preferences,
      service: _FakeService(models: models.future, tools: tools.future),
    );
    addTearDown(bloc.close);

    bloc.add(const BackplaneLoadModels());
    bloc.add(const BackplaneRefreshTools());
    await bloc.stream
        .firstWhere((state) => state.modelsLoading && state.toolsLoading);
    bloc.add(const BackplaneSave(
      serviceUrl: 'https://new.example.com',
      accountId: 3,
      apiType: RemoteLlmApiType.openAiResponses,
      mcpEnabled: false,
    ));
    final saved =
        await bloc.stream.firstWhere((state) => state.settings.accountId == 3);
    expect(saved.modelsLoading, isFalse);
    expect(saved.toolsLoading, isFalse);
    expect(saved.modelsError, isNull);
    expect(saved.toolsError, isNull);
    models.complete(['stale']);
    tools.complete([
      {'name': 'stale'}
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.state.settings.models, isEmpty);
    expect(bloc.state.settings.tools, isEmpty);
    expect(BackplaneSettingsBloc.readSettings(preferences).models, isEmpty);
  });

  test('model and tool failures stay independent', () async {
    final bloc = BackplaneSettingsBloc(
      preferences: preferences,
      service: _FakeService(modelError: StateError('models denied')),
    );
    addTearDown(bloc.close);
    bloc.add(const BackplaneLoadModels());
    await bloc.stream.firstWhere((state) => state.modelsError != null);
    bloc.add(const BackplaneRefreshTools());
    final state = await bloc.stream
        .firstWhere((state) => state.settings.tools.isNotEmpty);
    expect(state.modelsError, contains('models denied'));
    expect(state.settings.tools.single['name'], 'lookup');
  });

  for (final status in [401, 403]) {
    test('model HTTP $status does not erase MCP tools', () async {
      final bloc = BackplaneSettingsBloc(
        preferences: preferences,
        service: _FakeService(
            modelError: RemoteLlmException(
          'Failed to load models ($status)',
        )),
      );
      addTearDown(bloc.close);
      bloc.add(const BackplaneLoadModels());
      await bloc.stream.firstWhere((state) => state.modelsError != null);
      bloc.add(const BackplaneRefreshTools());
      final state = await bloc.stream
          .firstWhere((state) => state.settings.tools.isNotEmpty);
      expect(state.modelsError, contains('$status'));
      expect(state.settings.models, isEmpty);
      expect(state.settings.tools.single['name'], 'lookup');
    });
  }

  test('empty model catalog does not erase MCP tools', () async {
    final bloc = BackplaneSettingsBloc(
      preferences: preferences,
      service: _FakeService(models: Future.value([])),
    );
    addTearDown(bloc.close);
    bloc.add(const BackplaneRefreshTools());
    await bloc.stream.firstWhere((state) => state.settings.tools.isNotEmpty);
    bloc.add(const BackplaneLoadModels());
    await bloc.stream.firstWhere(
        (state) => !state.modelsLoading && state.toolsError == null);
    expect(bloc.state.settings.models, isEmpty);
    expect(bloc.state.settings.tools.single['name'], 'lookup');
  });
}

class _FakeService implements BackplaneServiceRepository {
  _FakeService({this.models, this.tools, this.modelError});

  final Future<List<String>>? models;
  final Future<List<Map<String, dynamic>>>? tools;
  final Object? modelError;
  int modelCalls = 0;
  int toolCalls = 0;

  @override
  Future<List<String>> loadModels(BackplaneSettings settings) async {
    modelCalls++;
    if (modelError != null) throw modelError!;
    return models ?? ['alpha'];
  }

  @override
  Future<List<Map<String, dynamic>>> refreshTools(
      BackplaneSettings settings) async {
    toolCalls++;
    return tools ??
        [
          {'name': 'lookup'}
        ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
