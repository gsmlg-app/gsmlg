import 'package:app_audio/audio.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'event.dart';
part 'state.dart';

typedef AudioSettingsProvider = AudioSettings Function();

class AudioServiceBloc extends Bloc<AudioServiceEvent, AudioServiceState> {
  AudioServiceBloc({required this.repository, required this.settingsProvider})
    : super(const AudioServiceState()) {
    on<AudioTtsSynthesize>(_onTtsSynthesize);
    on<AudioTtsSetAudioBytes>(_onTtsSetAudioBytes);
    on<AudioTtsClear>(_onTtsClear);
    on<AudioAsrTranscribeFile>(_onAsrTranscribeFile);
    on<AudioAsrTranscribeBytes>(_onAsrTranscribeBytes);
    on<AudioAsrClear>(_onAsrClear);
  }

  final OpenAiAudioRepository repository;
  final AudioSettingsProvider settingsProvider;

  Future<void> _onTtsSynthesize(
    AudioTtsSynthesize event,
    Emitter<AudioServiceState> emit,
  ) async {
    emit(
      state.copyWith(ttsStatus: TtsStatus.synthesizing, clearTtsError: true),
    );
    try {
      final settings = settingsProvider();
      final bytes = await repository.synthesizeSpeech(
        settings,
        event.text,
        voice: event.voice,
        model: event.model,
      );
      emit(state.copyWith(ttsStatus: TtsStatus.ready, audioBytes: bytes));
    } catch (e) {
      emit(state.copyWith(ttsStatus: TtsStatus.error, ttsError: e.toString()));
    }
  }

  void _onTtsSetAudioBytes(
    AudioTtsSetAudioBytes event,
    Emitter<AudioServiceState> emit,
  ) {
    emit(
      state.copyWith(
        audioBytes: event.bytes,
        clearAudio: event.bytes == null,
        ttsStatus: event.bytes != null ? TtsStatus.ready : TtsStatus.idle,
      ),
    );
  }

  void _onTtsClear(AudioTtsClear event, Emitter<AudioServiceState> emit) {
    emit(
      state.copyWith(
        ttsStatus: TtsStatus.idle,
        clearAudio: true,
        clearTtsError: true,
      ),
    );
  }

  Future<void> _onAsrTranscribeFile(
    AudioAsrTranscribeFile event,
    Emitter<AudioServiceState> emit,
  ) async {
    emit(
      state.copyWith(asrStatus: AsrStatus.transcribing, clearAsrError: true),
    );
    try {
      final settings = settingsProvider();
      final text = await repository.transcribeAudio(
        settings,
        filePath: event.filePath,
      );
      emit(state.copyWith(asrStatus: AsrStatus.success, transcription: text));
    } catch (e) {
      emit(state.copyWith(asrStatus: AsrStatus.error, asrError: e.toString()));
    }
  }

  Future<void> _onAsrTranscribeBytes(
    AudioAsrTranscribeBytes event,
    Emitter<AudioServiceState> emit,
  ) async {
    emit(
      state.copyWith(asrStatus: AsrStatus.transcribing, clearAsrError: true),
    );
    try {
      final settings = settingsProvider();
      final text = await repository.transcribeAudio(
        settings,
        bytes: event.bytes,
        filename: event.filename,
      );
      emit(state.copyWith(asrStatus: AsrStatus.success, transcription: text));
    } catch (e) {
      emit(state.copyWith(asrStatus: AsrStatus.error, asrError: e.toString()));
    }
  }

  void _onAsrClear(AudioAsrClear event, Emitter<AudioServiceState> emit) {
    emit(
      state.copyWith(
        asrStatus: AsrStatus.idle,
        clearTranscription: true,
        clearAsrError: true,
      ),
    );
  }
}
