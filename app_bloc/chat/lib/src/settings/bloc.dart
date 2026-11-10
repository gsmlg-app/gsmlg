import 'dart:async';
import 'package:app_agent/app_agent.dart';
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
    required AgentRepository agentRepository,
  })  : _repository = repository,
        _preferences = preferences,
        _agentRepository = agentRepository,
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
  static const _activeAgentIdKey = 'chat_active_agent_id';

  final ChatStorageRepository _repository;
  final SharedPreferences _preferences;
  final AgentRepository _agentRepository;
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
      await _agentRepository.importLegacy(_preferences);
      final agents = await _agentRepository.list();
      final activeAgentId = _preferences.getString(_activeAgentIdKey);
      final activeAgent = _agentById(agents, activeAgentId);

      emit(state.copyWith(
        status: ChatSettingsStatus.loaded,
        config: activeAgent?.config ?? config,
        defaultSystemPrompt: activeAgent?.instructions ?? systemPrompt,
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
      final targetAgentId = event.agentId ?? state.activeAgentId;
      final isActive = targetAgentId == state.activeAgentId;

      final agents = await _updateAgent(
        targetAgentId,
        (agent) => agent.copyWith(config: event.config),
      );

      if (isActive) {
        await _repository.saveSettings(event.config);
        emit(state.copyWith(
          status: ChatSettingsStatus.loaded,
          config: event.config,
          agents: agents,
          configChanged: true,
        ));
      } else {
        emit(state.copyWith(
          status: ChatSettingsStatus.loaded,
          agents: agents,
        ));
      }
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
      final targetAgentId = event.agentId ?? state.activeAgentId;
      final isActive = targetAgentId == state.activeAgentId;

      final agents = await _updateAgent(
        targetAgentId,
        (agent) => agent.copyWith(
          instructions: event.prompt,
          clearInstructions: event.prompt == null,
        ),
      );

      if (isActive) {
        await _repository.saveDefaultSystemPrompt(event.prompt);
        emit(state.copyWith(
          status: ChatSettingsStatus.loaded,
          defaultSystemPrompt: event.prompt,
          agents: agents,
        ));
      } else {
        emit(state.copyWith(
          status: ChatSettingsStatus.loaded,
          agents: agents,
        ));
      }
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
    if (name.isEmpty) {
      emit(state.copyWith(
        status: ChatSettingsStatus.error,
        errorMessage: 'Agent name is required',
      ));
      return;
    }

    final existingAgent = _agentById(state.agents, event.id);
    final now = _now();
    final agent = AgentDefinition(
      id: existingAgent?.id ?? event.id ?? _uuid.v4(),
      name: name,
      avatar: _optionalText(event.avatar, existingAgent?.avatar),
      description: _optionalText(event.description, existingAgent?.description),
      config: event.config ?? existingAgent?.config ?? state.config,
      instructions: switch (event.instructions?.trim()) {
        null => existingAgent?.instructions,
        '' => null,
        final prompt => prompt,
      },
      thinkingEnabled: event.thinkingEnabled ??
          existingAgent?.thinkingEnabled ??
          state.thinkingEnabled,
      allowedTools: event.clearAllowedTools
          ? null
          : event.allowedTools ?? existingAgent?.allowedTools,
      createdAt: existingAgent?.createdAt ?? now,
      updatedAt: now,
    );
    final agents = [...state.agents];
    final index = agents.indexWhere((item) => item.id == agent.id);
    if (index == -1) {
      agents.add(agent);
    } else {
      agents[index] = agent;
    }

    await _agentRepository.save(agent);

    final isFirst = state.agents.isEmpty;
    final isActive = event.id == state.activeAgentId || isFirst;

    if (isActive) {
      await _preferences.setString(_activeAgentIdKey, agent.id);
      await _preferences.setBool(_thinkingEnabledKey, agent.thinkingEnabled);
      await _repository.saveSettings(agent.config);
      await _repository.saveDefaultSystemPrompt(agent.instructions);
      emit(state.copyWith(
        status: ChatSettingsStatus.loaded,
        agents: agents,
        activeAgentId: agent.id,
        config: agent.config,
        defaultSystemPrompt: agent.instructions,
        thinkingEnabled: agent.thinkingEnabled,
      ));
    } else {
      emit(state.copyWith(
        status: ChatSettingsStatus.loaded,
        agents: agents,
      ));
    }
  }

  /// Null keeps [existing]; blank text clears the field.
  static String? _optionalText(String? value, String? existing) =>
      switch (value?.trim()) {
        null => existing,
        '' => null,
        final text => text,
      };

  Future<void> _onDeleteAgent(
    ChatSettingsDeleteAgent event,
    Emitter<ChatSettingsState> emit,
  ) async {
    final agents = state.agents
        .where((agent) => agent.id != event.id)
        .toList(growable: false);
    await _agentRepository.delete(event.id);

    if (state.activeAgentId != event.id) {
      emit(state.copyWith(status: ChatSettingsStatus.loaded, agents: agents));
      return;
    }

    await _preferences.remove(_activeAgentIdKey);
    await _preferences.setBool(_thinkingEnabledKey, false);
    final defaultConfig = ModelConfig.platformDefaultConfig;
    await _repository.saveSettings(defaultConfig);
    await _repository.saveDefaultSystemPrompt(null);
    emit(state.copyWith(
      status: ChatSettingsStatus.loaded,
      agents: agents,
      config: defaultConfig,
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
    await _repository.saveDefaultSystemPrompt(agent.instructions);
    emit(state.copyWith(
      status: ChatSettingsStatus.loaded,
      activeAgentId: agent.id,
      config: agent.config,
      defaultSystemPrompt: agent.instructions,
      thinkingEnabled: agent.thinkingEnabled,
      configChanged: true,
    ));
  }

  Future<void> _onToggleThinking(
    ChatSettingsToggleThinking event,
    Emitter<ChatSettingsState> emit,
  ) async {
    final targetAgentId = event.agentId ?? state.activeAgentId;
    final isActive = targetAgentId == state.activeAgentId;

    final agents = await _updateAgent(
      targetAgentId,
      (agent) => agent.copyWith(thinkingEnabled: event.enabled),
    );

    if (isActive) {
      await _preferences.setBool(_thinkingEnabledKey, event.enabled);
      emit(state.copyWith(
        agents: agents,
        thinkingEnabled: event.enabled,
        configChanged: true,
      ));
    } else {
      emit(state.copyWith(
        status: ChatSettingsStatus.loaded,
        agents: agents,
      ));
    }
  }

  Future<void> _onReset(
    ChatSettingsReset event,
    Emitter<ChatSettingsState> emit,
  ) async {
    try {
      final defaultConfig = ModelConfig.platformDefaultConfig;
      await _repository.saveSettings(defaultConfig);
      await _repository.saveDefaultSystemPrompt(null);
      await _preferences.setBool(_thinkingEnabledKey, false);
      final agents = await _updateAgent(
        state.activeAgentId,
        (agent) => agent.copyWith(
          config: defaultConfig,
          clearInstructions: true,
          thinkingEnabled: false,
        ),
      );

      emit(state.copyWith(
        status: ChatSettingsStatus.loaded,
        config: defaultConfig,
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

  /// Applies [update] to the agent with [id], persists it, and returns the
  /// new agent list (unchanged when no agent matches).
  Future<List<AgentDefinition>> _updateAgent(
    String? id,
    AgentDefinition Function(AgentDefinition) update,
  ) async {
    final current = _agentById(state.agents, id);
    if (current == null) return state.agents;
    final updated = update(current).copyWith(updatedAt: _now());
    await _agentRepository.save(updated);
    return state.agents
        .map((agent) => agent.id == updated.id ? updated : agent)
        .toList(growable: false);
  }

  /// Current time at the database's second precision, so in-memory agents
  /// equal what a reload returns.
  static DateTime _now() {
    final seconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }

  AgentDefinition? _agentById(List<AgentDefinition> agents, String? id) {
    if (id == null) return null;
    for (final agent in agents) {
      if (agent.id == id) return agent;
    }
    return null;
  }

  String? _validActiveAgentId(
      List<AgentDefinition> agents, String? activeAgentId) {
    if (activeAgentId == null) return null;
    return agents.any((agent) => agent.id == activeAgentId)
        ? activeAgentId
        : null;
  }
}
