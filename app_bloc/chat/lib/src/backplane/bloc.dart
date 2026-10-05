import 'dart:async';
import 'dart:convert';

import 'package:app_chat/app_chat.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'event.dart';
part 'state.dart';

class BackplaneSettingsBloc
    extends Bloc<BackplaneSettingsEvent, BackplaneSettingsState> {
  BackplaneSettingsBloc({
    required SharedPreferences preferences,
    required BackplaneServiceRepository service,
  })  : _preferences = preferences,
        _service = service,
        super(BackplaneSettingsState(settings: readSettings(preferences))) {
    on<BackplaneSave>(_onSave);
    on<BackplaneLoadModels>(_onLoadModels);
    on<BackplaneRefreshTools>(_onRefreshTools);
  }

  static const preferencesKey = 'backplane_settings';
  final SharedPreferences _preferences;
  final BackplaneServiceRepository _service;
  int _generation = 0;
  Future<void> _writeQueue = Future<void>.value();

  Future<void> _serializedWrite(Future<void> Function() write) async {
    final previous = _writeQueue;
    final gate = Completer<void>();
    _writeQueue = gate.future;
    await previous;
    try {
      await write();
    } finally {
      gate.complete();
    }
  }

  static BackplaneSettings readSettings(SharedPreferences preferences) {
    final raw = preferences.getString(preferencesKey);
    if (raw == null) return const BackplaneSettings();
    try {
      return BackplaneSettings.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const BackplaneSettings();
    }
  }

  Future<void> _onSave(
      BackplaneSave event, Emitter<BackplaneSettingsState> emit) async {
    final error = BackplaneSettings.validateUrl(event.serviceUrl);
    if (error != null) {
      emit(state.copyWith(saveError: error));
      return;
    }
    final changed = state.settings.serviceUrl != event.serviceUrl.trim() ||
        state.settings.accountId != event.accountId;
    if (changed) _generation++;
    await _serializedWrite(() async {
      final current = state.settings;
      final settings = current.copyWith(
        serviceUrl: event.serviceUrl.trim(),
        accountId: event.accountId,
        clearAccount: event.accountId == null,
        apiType: event.apiType,
        mcpEnabled: event.mcpEnabled,
        models: changed ? const [] : current.models,
        tools: changed ? const [] : current.tools,
      );
      await _preferences.setString(
          preferencesKey, jsonEncode(settings.toJson()));
      emit(changed
          ? BackplaneSettingsState(settings: settings)
          : state.copyWith(settings: settings));
    });
  }

  Future<void> _onLoadModels(
      BackplaneLoadModels event, Emitter<BackplaneSettingsState> emit) async {
    final generation = _generation;
    final settings = state.settings;
    emit(state.copyWith(modelsLoading: true, clearModelsError: true));
    try {
      final models = await _service.loadModels(settings);
      if (generation != _generation) return;
      await _serializedWrite(() async {
        if (generation != _generation) return;
        final updated = state.settings.copyWith(models: models);
        await _preferences.setString(
            preferencesKey, jsonEncode(updated.toJson()));
        emit(state.copyWith(settings: updated, modelsLoading: false));
      });
    } catch (error) {
      if (generation != _generation) return;
      emit(state.copyWith(modelsLoading: false, modelsError: error.toString()));
    }
  }

  Future<void> _onRefreshTools(
      BackplaneRefreshTools event, Emitter<BackplaneSettingsState> emit) async {
    final generation = _generation;
    final settings = state.settings;
    emit(state.copyWith(toolsLoading: true, clearToolsError: true));
    try {
      final tools = await _service.refreshTools(settings);
      if (generation != _generation) return;
      await _serializedWrite(() async {
        if (generation != _generation) return;
        final updated = state.settings.copyWith(tools: tools);
        await _preferences.setString(
            preferencesKey, jsonEncode(updated.toJson()));
        emit(state.copyWith(settings: updated, toolsLoading: false));
      });
    } catch (error) {
      if (generation != _generation) return;
      emit(state.copyWith(toolsLoading: false, toolsError: error.toString()));
    }
  }
}
