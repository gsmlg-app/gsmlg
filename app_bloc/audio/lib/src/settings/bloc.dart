import 'dart:convert';

import 'package:app_audio/audio.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'event.dart';
part 'state.dart';

class AudioSettingsBloc extends Bloc<AudioSettingsEvent, AudioSettingsState> {
  AudioSettingsBloc({required this.preferences})
    : super(const AudioSettingsState()) {
    on<AudioSettingsLoad>(_onLoad);
    on<AudioSettingsSave>(_onSave);
    on<AudioSettingsResetToBackplane>(_onReset);
  }

  static const preferencesKey = 'audio_service_settings';
  final SharedPreferences preferences;

  static AudioSettings readSettings(SharedPreferences prefs) {
    final raw = prefs.getString(preferencesKey);
    if (raw == null || raw.isEmpty) return const AudioSettings();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AudioSettings.fromJson(json);
    } catch (_) {
      return const AudioSettings();
    }
  }

  void _onLoad(AudioSettingsLoad event, Emitter<AudioSettingsState> emit) {
    emit(state.copyWith(status: AudioSettingsStatus.loading));
    final settings = readSettings(preferences);
    emit(state.copyWith(settings: settings, status: AudioSettingsStatus.ready));
  }

  Future<void> _onSave(
    AudioSettingsSave event,
    Emitter<AudioSettingsState> emit,
  ) async {
    try {
      await preferences.setString(
        preferencesKey,
        jsonEncode(event.settings.toJson()),
      );
      emit(
        state.copyWith(
          settings: event.settings,
          status: AudioSettingsStatus.ready,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioSettingsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onReset(
    AudioSettingsResetToBackplane event,
    Emitter<AudioSettingsState> emit,
  ) async {
    const defaultSettings = AudioSettings();
    try {
      await preferences.setString(
        preferencesKey,
        jsonEncode(defaultSettings.toJson()),
      );
      emit(
        state.copyWith(
          settings: defaultSettings,
          status: AudioSettingsStatus.ready,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioSettingsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
