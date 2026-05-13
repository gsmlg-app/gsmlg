import 'dart:async';
import 'dart:convert';

import 'package:app_chat/app_chat.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

part 'event.dart';
part 'state.dart';

/// BLoC for managing chat settings (model configuration and system prompt).
class ChatSettingsBloc extends Bloc<ChatSettingsEvent, ChatSettingsState> {
  ChatSettingsBloc({
    required ChatStorageRepository repository,
    required SharedPreferences preferences,
  })  : _repository = repository,
        _preferences = preferences,
        super(const ChatSettingsState()) {
    on<ChatSettingsLoad>(_onLoad);
    on<ChatSettingsUpdateConfig>(_onUpdateConfig);
    on<ChatSettingsUpdateSystemPrompt>(_onUpdateSystemPrompt);
    on<ChatSettingsSaveAgent>(_onSaveAgent);
    on<ChatSettingsDeleteAgent>(_onDeleteAgent);
    on<ChatSettingsSelectAgent>(_onSelectAgent);
    on<ChatSettingsToggleThinking>(_onToggleThinking);
    on<ChatSettingsReset>(_onReset);
  }

  static const _thinkingEnabledKey = 'chat_thinking_enabled';
  static const _agentsKey = 'chat_agents';
  static const _activeAgentIdKey = 'chat_active_agent_id';

  final ChatStorageRepository _repository;
  final SharedPreferences _preferences;
  final _uuid = const Uuid();

  Future<void> _onLoad(
    ChatSettingsLoad event,
    Emitter<ChatSettingsState> emit,
  ) async {
    emit(state.copyWith(status: ChatSettingsStatus.loading));

    try {
      final config = await _repository.loadSettings();
      final systemPrompt = await _repository.loadDefaultSystemPrompt();
      final thinkingEnabled =
          _preferences.getBool(_thinkingEnabledKey) ?? false;
      final agents = _loadAgents();
      final activeAgentId = _preferences.getString(_activeAgentIdKey);
      final activeAgent = _agentById(agents, activeAgentId);

      emit(state.copyWith(
        status: ChatSettingsStatus.loaded,
        config: activeAgent?.config ?? config,
        defaultSystemPrompt: activeAgent?.systemPrompt ?? systemPrompt,
        agents: agents,
        activeAgentId: _validActiveAgentId(agents, activeAgentId),
        thinkingEnabled: activeAgent?.thinkingEnabled ?? thinkingEnabled,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatSettingsStatus.error,
        errorMessage: 'Failed to load settings: $e',
      ));
    }
  }

  Future<void> _onUpdateConfig(
    ChatSettingsUpdateConfig event,
    Emitter<ChatSettingsState> emit,
  ) async {
    // Validate the config
    final errors = event.config.validate();
    if (errors.isNotEmpty) {
      emit(state.copyWith(
        status: ChatSettingsStatus.error,
        errorMessage: errors.join(', '),
      ));
      return;
    }

    try {
      await _repository.saveSettings(event.config);
      final agents = _replaceActiveAgent(
        (agent) => agent.copyWith(config: event.config),
      );
      await _saveAgents(agents);
      emit(state.copyWith(
        status: ChatSettingsStatus.loaded,
        config: event.config,
        agents: agents,
        configChanged: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatSettingsStatus.error,
        errorMessage: 'Failed to save settings: $e',
      ));
    }
  }

  Future<void> _onUpdateSystemPrompt(
    ChatSettingsUpdateSystemPrompt event,
    Emitter<ChatSettingsState> emit,
  ) async {
    try {
      await _repository.saveDefaultSystemPrompt(event.prompt);
      final agents = _replaceActiveAgent(
        (agent) => agent.copyWith(
          systemPrompt: event.prompt,
          clearSystemPrompt: event.prompt == null,
        ),
      );
      await _saveAgents(agents);
      emit(state.copyWith(
        status: ChatSettingsStatus.loaded,
        defaultSystemPrompt: event.prompt,
        agents: agents,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatSettingsStatus.error,
        errorMessage: 'Failed to save system prompt: $e',
      ));
    }
  }

  Future<void> _onSaveAgent(
    ChatSettingsSaveAgent event,
    Emitter<ChatSettingsState> emit,
  ) async {
    final name = event.name.trim();
    final prompt = event.systemPrompt.trim();
    if (name.isEmpty) {
      emit(state.copyWith(
        status: ChatSettingsStatus.error,
        errorMessage: 'Agent name is required',
      ));
      return;
    }

    final existingAgent = _agentById(state.agents, event.id);
    final agent = ChatAgent(
      id: existingAgent?.id ?? event.id ?? _uuid.v4(),
      name: name,
      config: event.config ?? existingAgent?.config ?? state.config,
      systemPrompt: prompt.isEmpty ? null : prompt,
      thinkingEnabled: event.thinkingEnabled ??
          existingAgent?.thinkingEnabled ??
          state.thinkingEnabled,
    );
    final agents = [...state.agents];
    final index = agents.indexWhere((item) => item.id == agent.id);
    if (index == -1) {
      agents.add(agent);
    } else {
      agents[index] = agent;
    }

    await _saveAgents(agents);
    await _preferences.setString(_activeAgentIdKey, agent.id);
    await _preferences.setBool(_thinkingEnabledKey, agent.thinkingEnabled);
    await _repository.saveSettings(agent.config);
    await _repository.saveDefaultSystemPrompt(agent.systemPrompt);
    emit(state.copyWith(
      status: ChatSettingsStatus.loaded,
      agents: agents,
      activeAgentId: agent.id,
      config: agent.config,
      defaultSystemPrompt: agent.systemPrompt,
      thinkingEnabled: agent.thinkingEnabled,
    ));
  }

  Future<void> _onDeleteAgent(
    ChatSettingsDeleteAgent event,
    Emitter<ChatSettingsState> emit,
  ) async {
    final agents = state.agents
        .where((agent) => agent.id != event.id)
        .toList(growable: false);
    await _saveAgents(agents);

    if (state.activeAgentId != event.id) {
      emit(state.copyWith(status: ChatSettingsStatus.loaded, agents: agents));
      return;
    }

    await _preferences.remove(_activeAgentIdKey);
    await _preferences.setBool(_thinkingEnabledKey, false);
    await _repository.saveSettings(ModelConfig.defaultConfig);
    await _repository.saveDefaultSystemPrompt(null);
    emit(state.copyWith(
      status: ChatSettingsStatus.loaded,
      agents: agents,
      config: ModelConfig.defaultConfig,
      clearActiveAgent: true,
      clearSystemPrompt: true,
      thinkingEnabled: false,
      configChanged: true,
    ));
  }

  Future<void> _onSelectAgent(
    ChatSettingsSelectAgent event,
    Emitter<ChatSettingsState> emit,
  ) async {
    final agent = _agentById(state.agents, event.id);
    if (agent == null) return;

    await _preferences.setString(_activeAgentIdKey, agent.id);
    await _preferences.setBool(_thinkingEnabledKey, agent.thinkingEnabled);
    await _repository.saveSettings(agent.config);
    await _repository.saveDefaultSystemPrompt(agent.systemPrompt);
    emit(state.copyWith(
      status: ChatSettingsStatus.loaded,
      activeAgentId: agent.id,
      config: agent.config,
      defaultSystemPrompt: agent.systemPrompt,
      thinkingEnabled: agent.thinkingEnabled,
      configChanged: true,
    ));
  }

  Future<void> _onToggleThinking(
    ChatSettingsToggleThinking event,
    Emitter<ChatSettingsState> emit,
  ) async {
    await _preferences.setBool(_thinkingEnabledKey, event.enabled);
    final agents = _replaceActiveAgent(
      (agent) => agent.copyWith(thinkingEnabled: event.enabled),
    );
    await _saveAgents(agents);
    emit(state.copyWith(
      agents: agents,
      thinkingEnabled: event.enabled,
      configChanged: true,
    ));
  }

  Future<void> _onReset(
    ChatSettingsReset event,
    Emitter<ChatSettingsState> emit,
  ) async {
    try {
      await _repository.saveSettings(ModelConfig.defaultConfig);
      await _repository.saveDefaultSystemPrompt(null);
      await _preferences.setBool(_thinkingEnabledKey, false);
      final agents = _replaceActiveAgent(
        (agent) => agent.copyWith(
          config: ModelConfig.defaultConfig,
          clearSystemPrompt: true,
          thinkingEnabled: false,
        ),
      );
      await _saveAgents(agents);

      emit(state.copyWith(
        status: ChatSettingsStatus.loaded,
        config: ModelConfig.defaultConfig,
        agents: agents,
        clearSystemPrompt: true,
        thinkingEnabled: false,
        configChanged: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatSettingsStatus.error,
        errorMessage: 'Failed to reset settings: $e',
      ));
    }
  }

  List<ChatAgent> _loadAgents() {
    final values = _preferences.getStringList(_agentsKey) ?? const <String>[];
    return values
        .map((value) {
          try {
            final json = jsonDecode(value);
            if (json is! Map<String, Object?>) return null;
            return _agentFromJson(json);
          } catch (_) {
            return null;
          }
        })
        .whereType<ChatAgent>()
        .toList(growable: false);
  }

  Future<void> _saveAgents(List<ChatAgent> agents) {
    final values = agents
        .map((agent) => jsonEncode(_agentToJson(agent)))
        .toList(growable: false);
    return _preferences.setStringList(_agentsKey, values);
  }

  List<ChatAgent> _replaceActiveAgent(ChatAgent Function(ChatAgent) update) {
    final activeAgentId = state.activeAgentId;
    if (activeAgentId == null) return state.agents;

    var changed = false;
    final agents = state.agents.map((agent) {
      if (agent.id != activeAgentId) return agent;
      changed = true;
      return update(agent);
    }).toList(growable: false);

    return changed ? agents : state.agents;
  }

  ChatAgent? _agentById(List<ChatAgent> agents, String? id) {
    if (id == null) return null;
    for (final agent in agents) {
      if (agent.id == id) return agent;
    }
    return null;
  }

  String? _validActiveAgentId(List<ChatAgent> agents, String? activeAgentId) {
    if (activeAgentId == null) return null;
    return agents.any((agent) => agent.id == activeAgentId)
        ? activeAgentId
        : null;
  }

  ChatAgent _agentFromJson(Map<String, Object?> json) {
    return ChatAgent(
      id: json['id'] as String,
      name: json['name'] as String,
      config: _configFromJson(json['config'] as Map<String, Object?>?),
      systemPrompt: json['systemPrompt'] as String?,
      thinkingEnabled: json['thinkingEnabled'] as bool? ?? false,
    );
  }

  Map<String, Object?> _agentToJson(ChatAgent agent) {
    return {
      'id': agent.id,
      'name': agent.name,
      'config': _configToJson(agent.config),
      'systemPrompt': agent.systemPrompt,
      'thinkingEnabled': agent.thinkingEnabled,
    };
  }

  ModelConfig _configFromJson(Map<String, Object?>? json) {
    if (json == null) return ModelConfig.defaultConfig;
    return ModelConfig(
      inferenceMode: _enumFromName(
        ChatInferenceMode.values,
        json['inferenceMode'],
        ModelConfig.defaultConfig.inferenceMode,
      ),
      modelType: _enumFromName(
        GemmaModelType.values,
        json['modelType'],
        ModelConfig.defaultConfig.modelType,
      ),
      customModelPath: json['customModelPath'] as String?,
      maxTokens:
          json['maxTokens'] as int? ?? ModelConfig.defaultConfig.maxTokens,
      temperature: (json['temperature'] as num?)?.toDouble() ??
          ModelConfig.defaultConfig.temperature,
      topK: json['topK'] as int? ?? ModelConfig.defaultConfig.topK,
      backend: _backendFromName(json['backend']),
      remoteProvider: _enumFromName(
        RemoteLlmProvider.values,
        json['remoteProvider'],
        ModelConfig.defaultConfig.remoteProvider,
      ),
      remoteAccountId: json['remoteAccountId'] as int?,
      remoteBaseUrl: json['remoteBaseUrl'] as String? ??
          ModelConfig.defaultConfig.remoteBaseUrl,
      remoteModel: json['remoteModel'] as String? ??
          ModelConfig.defaultConfig.remoteModel,
      remoteStreamingEnabled: json['remoteStreamingEnabled'] as bool? ??
          ModelConfig.defaultConfig.remoteStreamingEnabled,
      remoteThinkingEffort: _enumFromName(
        RemoteThinkingEffort.values,
        json['remoteThinkingEffort'],
        ModelConfig.defaultConfig.remoteThinkingEffort,
      ),
    );
  }

  Map<String, Object?> _configToJson(ModelConfig config) {
    return {
      'inferenceMode': config.inferenceMode.name,
      'modelType': config.modelType.name,
      'customModelPath': config.customModelPath,
      'maxTokens': config.maxTokens,
      'temperature': config.temperature,
      'topK': config.topK,
      'backend': config.backend.name,
      'remoteProvider': config.remoteProvider.name,
      'remoteAccountId': config.remoteAccountId,
      'remoteBaseUrl': config.remoteBaseUrl,
      'remoteModel': config.remoteModel,
      'remoteStreamingEnabled': config.remoteStreamingEnabled,
      'remoteThinkingEffort': config.remoteThinkingEffort.name,
    };
  }

  T _enumFromName<T extends Enum>(List<T> values, Object? name, T fallback) {
    if (name is! String) return fallback;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }

  GemmaBackend _backendFromName(Object? name) {
    if (name == 'gpu') return GemmaBackend.metal;
    return _enumFromName(
      GemmaBackend.values,
      name,
      ModelConfig.defaultConfig.backend,
    );
  }
}
