import 'dart:async';

import 'package:app_chat/app_chat.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'event.dart';
part 'state.dart';

/// BLoC for managing chat settings (model configuration and system prompt).
class ChatSettingsBloc extends Bloc<ChatSettingsEvent, ChatSettingsState> {
  ChatSettingsBloc({
    required ChatStorageRepository repository,
  })  : _repository = repository,
        super(const ChatSettingsState()) {
    on<ChatSettingsLoad>(_onLoad);
    on<ChatSettingsUpdateConfig>(_onUpdateConfig);
    on<ChatSettingsUpdateSystemPrompt>(_onUpdateSystemPrompt);
    on<ChatSettingsReset>(_onReset);
  }

  final ChatStorageRepository _repository;

  Future<void> _onLoad(
    ChatSettingsLoad event,
    Emitter<ChatSettingsState> emit,
  ) async {
    emit(state.copyWith(status: ChatSettingsStatus.loading));

    try {
      final config = await _repository.loadSettings();
      final systemPrompt = await _repository.loadDefaultSystemPrompt();

      emit(state.copyWith(
        status: ChatSettingsStatus.loaded,
        config: config,
        defaultSystemPrompt: systemPrompt,
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
      emit(state.copyWith(
        status: ChatSettingsStatus.loaded,
        config: event.config,
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
      emit(state.copyWith(
        status: ChatSettingsStatus.loaded,
        defaultSystemPrompt: event.prompt,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatSettingsStatus.error,
        errorMessage: 'Failed to save system prompt: $e',
      ));
    }
  }

  Future<void> _onReset(
    ChatSettingsReset event,
    Emitter<ChatSettingsState> emit,
  ) async {
    try {
      await _repository.saveSettings(ModelConfig.defaultConfig);
      await _repository.saveDefaultSystemPrompt(null);

      emit(state.copyWith(
        status: ChatSettingsStatus.loaded,
        config: ModelConfig.defaultConfig,
        clearSystemPrompt: true,
        configChanged: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatSettingsStatus.error,
        errorMessage: 'Failed to reset settings: $e',
      ));
    }
  }
}
