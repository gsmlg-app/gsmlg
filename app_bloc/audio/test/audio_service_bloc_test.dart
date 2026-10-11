import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:audio_bloc/audio_bloc.dart';
import 'package:app_audio/audio.dart';

class _FakeAudioRepository extends OpenAiAudioRepository {
  _FakeAudioRepository({
    this.synthesizeResult,
    this.synthesizeError,
    this.transcribeResult,
    this.transcribeError,
  });

  Uint8List? synthesizeResult;
  Exception? synthesizeError;
  String? transcribeResult;
  Exception? transcribeError;

  @override
  Future<Uint8List> synthesizeSpeech(
    AudioSettings settings,
    String text, {
    String? model,
    String? voice,
    double? speed,
    String? format,
  }) async {
    if (synthesizeError != null) {
      throw synthesizeError!;
    }
    return synthesizeResult ?? Uint8List.fromList([1, 2, 3]);
  }

  @override
  Future<String> transcribeAudio(
    AudioSettings settings, {
    List<int>? bytes,
    String? filename,
    String? filePath,
    String? model,
    String? language,
  }) async {
    if (transcribeError != null) {
      throw transcribeError!;
    }
    return transcribeResult ?? 'Transcribed text';
  }
}

void main() {
  group('AudioServiceBloc', () {
    group('TTS', () {
      test(
        'synthesizes speech: emits synthesizing then ready with audioBytes',
        () async {
          final expectedBytes = Uint8List.fromList([10, 20, 30]);
          final repo = _FakeAudioRepository(synthesizeResult: expectedBytes);
          final bloc = AudioServiceBloc(
            repository: repo,
            settingsProvider: () => const AudioSettings(),
          );

          bloc.add(const AudioTtsSynthesize('Testing voice'));

          await expectLater(
            bloc.stream,
            emitsInOrder([
              predicate<AudioServiceState>(
                (s) =>
                    s.ttsStatus == TtsStatus.synthesizing && s.ttsError == null,
              ),
              predicate<AudioServiceState>(
                (s) =>
                    s.ttsStatus == TtsStatus.ready &&
                    s.audioBytes == expectedBytes,
              ),
            ]),
          );
          await bloc.close();
        },
      );

      test(
        'synthesizes speech error: emits synthesizing then error with message',
        () async {
          final repo = _FakeAudioRepository(
            synthesizeError: Exception('TTS network failed'),
          );
          final bloc = AudioServiceBloc(
            repository: repo,
            settingsProvider: () => const AudioSettings(),
          );

          bloc.add(const AudioTtsSynthesize('Testing voice'));

          await expectLater(
            bloc.stream,
            emitsInOrder([
              predicate<AudioServiceState>(
                (s) => s.ttsStatus == TtsStatus.synthesizing,
              ),
              predicate<AudioServiceState>(
                (s) =>
                    s.ttsStatus == TtsStatus.error &&
                    s.ttsError != null &&
                    s.ttsError!.contains('TTS network failed'),
              ),
            ]),
          );
          await bloc.close();
        },
      );

      test('clears TTS: resets to idle and clears audio bytes', () async {
        final repo = _FakeAudioRepository();
        final bloc = AudioServiceBloc(
          repository: repo,
          settingsProvider: () => const AudioSettings(),
        );

        bloc.add(const AudioTtsSynthesize('Testing voice'));
        await expectLater(
          bloc.stream,
          emitsThrough(
            predicate<AudioServiceState>((s) => s.ttsStatus == TtsStatus.ready),
          ),
        );

        bloc.add(const AudioTtsClear());
        await expectLater(
          bloc.stream,
          emits(
            predicate<AudioServiceState>(
              (s) =>
                  s.ttsStatus == TtsStatus.idle &&
                  s.audioBytes == null &&
                  s.ttsError == null,
            ),
          ),
        );
        await bloc.close();
      });
    });

    group('ASR', () {
      test(
        'transcribes file: emits transcribing then success with transcription',
        () async {
          final repo = _FakeAudioRepository(transcribeResult: 'Hello world');
          final bloc = AudioServiceBloc(
            repository: repo,
            settingsProvider: () => const AudioSettings(),
          );

          bloc.add(const AudioAsrTranscribeFile('/tmp/audio.wav'));

          await expectLater(
            bloc.stream,
            emitsInOrder([
              predicate<AudioServiceState>(
                (s) =>
                    s.asrStatus == AsrStatus.transcribing && s.asrError == null,
              ),
              predicate<AudioServiceState>(
                (s) =>
                    s.asrStatus == AsrStatus.success &&
                    s.transcription == 'Hello world',
              ),
            ]),
          );
          await bloc.close();
        },
      );

      test(
        'transcribes bytes: emits transcribing then success with transcription',
        () async {
          final repo = _FakeAudioRepository(
            transcribeResult: 'Transcribed from bytes',
          );
          final bloc = AudioServiceBloc(
            repository: repo,
            settingsProvider: () => const AudioSettings(),
          );

          bloc.add(
            const AudioAsrTranscribeBytes([1, 2, 3, 4], filename: 'custom.wav'),
          );

          await expectLater(
            bloc.stream,
            emitsInOrder([
              predicate<AudioServiceState>(
                (s) =>
                    s.asrStatus == AsrStatus.transcribing && s.asrError == null,
              ),
              predicate<AudioServiceState>(
                (s) =>
                    s.asrStatus == AsrStatus.success &&
                    s.transcription == 'Transcribed from bytes',
              ),
            ]),
          );
          await bloc.close();
        },
      );

      test(
        'transcribes error: emits transcribing then error with message',
        () async {
          final repo = _FakeAudioRepository(
            transcribeError: Exception('ASR request failed'),
          );
          final bloc = AudioServiceBloc(
            repository: repo,
            settingsProvider: () => const AudioSettings(),
          );

          bloc.add(const AudioAsrTranscribeFile('/tmp/audio.wav'));

          await expectLater(
            bloc.stream,
            emitsInOrder([
              predicate<AudioServiceState>(
                (s) => s.asrStatus == AsrStatus.transcribing,
              ),
              predicate<AudioServiceState>(
                (s) =>
                    s.asrStatus == AsrStatus.error &&
                    s.asrError != null &&
                    s.asrError!.contains('ASR request failed'),
              ),
            ]),
          );
          await bloc.close();
        },
      );

      test('clears ASR: resets to idle and clears transcription', () async {
        final repo = _FakeAudioRepository(transcribeResult: 'Some text');
        final bloc = AudioServiceBloc(
          repository: repo,
          settingsProvider: () => const AudioSettings(),
        );

        bloc.add(const AudioAsrTranscribeFile('/tmp/audio.wav'));
        await expectLater(
          bloc.stream,
          emitsThrough(
            predicate<AudioServiceState>(
              (s) => s.asrStatus == AsrStatus.success,
            ),
          ),
        );

        bloc.add(const AudioAsrClear());
        await expectLater(
          bloc.stream,
          emits(
            predicate<AudioServiceState>(
              (s) =>
                  s.asrStatus == AsrStatus.idle &&
                  s.transcription == null &&
                  s.asrError == null,
            ),
          ),
        );
        await bloc.close();
      });
    });
  });
}
