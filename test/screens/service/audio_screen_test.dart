import 'dart:async';
import 'dart:typed_data';

import 'package:app_audio/audio.dart';
import 'package:app_locale/app_locale.dart';
import 'package:audio_bloc/audio_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_bloc/github_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/service/audio/audio_screen.dart';
import 'package:gsmlg/screens/service/service_screen.dart';
import 'package:gsmlg/screens/settings/audio_settings_screen.dart';

class _FakeAudioPlayer implements AudioScreenAudioPlayer {
  final _stateController = StreamController<PlayerState>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _completeController = StreamController<void>.broadcast();

  bool isPlaying = false;
  bool isPaused = false;
  bool isStopped = false;
  Duration? seekPosition;
  Source? playedSource;
  Source? currentSource;
  Duration? mockDuration;

  @override
  Stream<PlayerState> get onPlayerStateChanged => _stateController.stream;

  @override
  Stream<Duration> get onDurationChanged => _durationController.stream;

  @override
  Stream<Duration> get onPositionChanged => _positionController.stream;

  @override
  Stream<void> get onPlayerComplete => _completeController.stream;

  @override
  Future<Duration?> getDuration() async => mockDuration;

  @override
  Future<void> setSource(Source source) async {
    currentSource = source;
  }

  @override
  Future<void> play(Source source) async {
    playedSource = source;
    currentSource = source;
    isPlaying = true;
    isPaused = false;
    isStopped = false;
    _stateController.add(PlayerState.playing);
  }

  @override
  Future<void> resume() async {
    isPlaying = true;
    isPaused = false;
    isStopped = false;
    _stateController.add(PlayerState.playing);
  }

  @override
  Future<void> pause() async {
    isPlaying = false;
    isPaused = true;
    _stateController.add(PlayerState.paused);
  }

  @override
  Future<void> stop() async {
    isPlaying = false;
    isStopped = true;
    _stateController.add(PlayerState.stopped);
  }

  @override
  Future<void> seek(Duration position) async {
    seekPosition = position;
    _positionController.add(position);
  }

  void emitDuration(Duration duration) {
    mockDuration = duration;
    _durationController.add(duration);
  }

  void emitPosition(Duration position) {
    _positionController.add(position);
  }

  void completePlayback() {
    isPlaying = false;
    _completeController.add(null);
    _stateController.add(PlayerState.completed);
  }

  @override
  Future<void> dispose() async {
    if (!_stateController.isClosed) {
      unawaited(_stateController.close());
    }
    if (!_durationController.isClosed) {
      unawaited(_durationController.close());
    }
    if (!_positionController.isClosed) {
      unawaited(_positionController.close());
    }
    if (!_completeController.isClosed) {
      unawaited(_completeController.close());
    }
  }
}

class _FakeAudioRecorder implements AudioScreenAudioRecorder {
  bool permissionGranted = true;
  bool recording = false;
  String? lastStartedPath;
  String? stoppedPath = '/tmp/fake_recording.wav';

  @override
  Future<bool> hasPermission() async => permissionGranted;

  @override
  Future<bool> isRecording() async => recording;

  @override
  Future<void> start({required String path}) async {
    recording = true;
    lastStartedPath = path;
  }

  @override
  Future<String?> stop() async {
    recording = false;
    return stoppedPath;
  }

  @override
  Future<void> dispose() async {}
}

class _TestAudioServiceBloc extends Bloc<AudioServiceEvent, AudioServiceState>
    implements AudioServiceBloc {
  _TestAudioServiceBloc({AudioServiceState? initialState})
    : super(initialState ?? const AudioServiceState()) {
    on<AudioServiceEvent>((event, emit) {
      dispatchedEvents.add(event);
      if (event is AudioTtsSynthesize) {
        emit(state.copyWith(ttsStatus: TtsStatus.synthesizing));
      } else if (event is AudioTtsSetAudioBytes) {
        emit(
          state.copyWith(ttsStatus: TtsStatus.ready, audioBytes: event.bytes),
        );
      } else if (event is AudioAsrClear) {
        emit(state.copyWith(clearTranscription: true));
      } else if (event is AudioTtsClear) {
        emit(state.copyWith(clearAudio: true, ttsStatus: TtsStatus.idle));
      }
    });
  }

  final List<AudioServiceEvent> dispatchedEvents = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestAudioSettingsBloc
    extends Bloc<AudioSettingsEvent, AudioSettingsState>
    implements AudioSettingsBloc {
  _TestAudioSettingsBloc([AudioSettings? settings])
    : super(AudioSettingsState(settings: settings ?? const AudioSettings()));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _buildTestApp({
  required AudioServiceBloc audioServiceBloc,
  AudioSettingsBloc? audioSettingsBloc,
  _FakeAudioPlayer? player,
  _FakeAudioRecorder? recorder,
  Future<String?> Function()? pickAudioFiles,
  Future<void> Function(Uint8List bytes, String filename)? saveAudioBytes,
}) {
  final effectiveSettingsBloc =
      audioSettingsBloc ?? _TestAudioSettingsBloc(const AudioSettings());

  final router = GoRouter(
    initialLocation: '/service/audio',
    routes: [
      GoRoute(
        path: '/service/audio',
        name: AudioScreen.name,
        builder: (context, state) => AudioScreen(
          playerFactory: player != null ? () => player : null,
          recorderFactory: recorder != null ? () => recorder : null,
          pickAudioFiles: pickAudioFiles,
          saveAudioBytes: saveAudioBytes,
        ),
      ),
      GoRoute(
        path: '/settings/audio',
        name: AudioSettingsScreen.name,
        builder: (context, state) =>
            const Scaffold(body: Text('AudioSettingsScreen Destination')),
      ),
    ],
  );

  return MultiBlocProvider(
    providers: [
      BlocProvider<AudioServiceBloc>.value(value: audioServiceBloc),
      BlocProvider<AudioSettingsBloc>.value(value: effectiveSettingsBloc),
    ],
    child: MaterialApp.router(
      localizationsDelegates: AppLocale.localizationsDelegates,
      supportedLocales: AppLocale.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _TestAudioServiceBloc audioServiceBloc;
  late _TestAudioSettingsBloc audioSettingsBloc;
  late _FakeAudioPlayer fakePlayer;
  late _FakeAudioRecorder fakeRecorder;

  setUp(() {
    audioServiceBloc = _TestAudioServiceBloc();
    audioSettingsBloc = _TestAudioSettingsBloc();
    fakePlayer = _FakeAudioPlayer();
    fakeRecorder = _FakeAudioRecorder();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (message) async {
          if (message.method == 'Clipboard.setData') {
            return null;
          }
          return null;
        });
  });

  tearDown(() async {
    await audioServiceBloc.close();
    await audioSettingsBloc.close();
    await fakePlayer.dispose();
    await fakeRecorder.dispose();
  });

  testWidgets('renders AudioScreen with TTS and ASR tabs', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _buildTestApp(
        audioServiceBloc: audioServiceBloc,
        audioSettingsBloc: audioSettingsBloc,
        player: fakePlayer,
        recorder: fakeRecorder,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AudioScreen), findsOneWidget);
    expect(find.text('Audio'), findsWidgets);
    expect(find.text('Text to Speech (TTS)'), findsOneWidget);
    expect(find.text('Speech to Text (ASR)'), findsOneWidget);
    expect(find.text('Synthesize'), findsOneWidget);
  });

  testWidgets('verifies switching between TTS and ASR tabs', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _buildTestApp(
        audioServiceBloc: audioServiceBloc,
        audioSettingsBloc: audioSettingsBloc,
        player: fakePlayer,
        recorder: fakeRecorder,
      ),
    );
    await tester.pumpAndSettle();

    // Starts on TTS tab
    expect(find.text('Synthesize'), findsOneWidget);
    expect(find.text('Record'), findsNothing);

    // Switch to ASR tab
    await tester.tap(find.text('Speech to Text (ASR)'));
    await tester.pumpAndSettle();

    expect(find.text('Record'), findsOneWidget);
    expect(find.text('Pick Audio File'), findsOneWidget);
    expect(find.text('Synthesize'), findsNothing);

    // Switch back to TTS tab
    await tester.tap(find.text('Text to Speech (TTS)'));
    await tester.pumpAndSettle();

    expect(find.text('Synthesize'), findsOneWidget);
    expect(find.text('Record'), findsNothing);
  });

  testWidgets(
    'verifies TTS text input, voice selection, and tapping Synthesize dispatches AudioTtsSynthesize',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _buildTestApp(
          audioServiceBloc: audioServiceBloc,
          audioSettingsBloc: audioSettingsBloc,
          player: fakePlayer,
          recorder: fakeRecorder,
        ),
      );
      await tester.pumpAndSettle();

      // Enter text
      final textInput = find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            w.decoration?.hintText == 'Enter text to convert to speech…',
      );
      expect(textInput, findsOneWidget);
      await tester.enterText(textInput, 'Hello text to speech');
      await tester.pumpAndSettle();

      // Change voice to echo
      final voiceInput = find.widgetWithText(TextField, 'female-tianmei');
      expect(voiceInput, findsOneWidget);
      await tester.enterText(voiceInput, 'echo');
      await tester.pumpAndSettle();

      // Tap Synthesize
      await tester.tap(find.text('Synthesize'));
      await tester.pump();

      expect(
        audioServiceBloc.dispatchedEvents,
        contains(isA<AudioTtsSynthesize>()),
      );
      final synthesizeEvent = audioServiceBloc.dispatchedEvents
          .whereType<AudioTtsSynthesize>()
          .first;
      expect(synthesizeEvent.text, 'Hello text to speech');
      expect(synthesizeEvent.voice, 'echo');
    },
  );

  testWidgets('verifies audio playback controls when audio is ready', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final readyBloc = _TestAudioServiceBloc(
      initialState: AudioServiceState(
        ttsStatus: TtsStatus.ready,
        audioBytes: Uint8List.fromList([1, 2, 3, 4, 5]),
      ),
    );
    addTearDown(() => readyBloc.close());

    bool saveCalled = false;

    await tester.pumpWidget(
      _buildTestApp(
        audioServiceBloc: readyBloc,
        audioSettingsBloc: audioSettingsBloc,
        player: fakePlayer,
        recorder: fakeRecorder,
        saveAudioBytes: (bytes, filename) async {
          saveCalled = true;
        },
      ),
    );
    await tester.pumpAndSettle();

    // Verify playback control buttons: Play, Pause, Stop, Export
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsOneWidget);
    expect(find.byIcon(Icons.stop), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.text('Export Audio'), findsOneWidget);

    // Tap Play
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    expect(fakePlayer.isPlaying, isTrue);

    // Tap Pause
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
    expect(fakePlayer.isPaused, isTrue);

    // Tap Stop
    await tester.tap(find.byIcon(Icons.stop));
    await tester.pump();
    expect(fakePlayer.isStopped, isTrue);

    // Tap Export
    await tester.tap(find.text('Export Audio'));
    await tester.pump();
    expect(saveCalled, isTrue);

    // Test progress bar duration and position updates
    fakePlayer.emitDuration(const Duration(seconds: 4));
    await tester.pump();
    expect(find.text('00:04'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);

    // Position updates to 2 seconds
    fakePlayer.emitPosition(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('00:02'), findsOneWidget);
    expect(find.text('00:04'), findsOneWidget);
    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.value, 2000.0);
    expect(slider.max, 4000.0);

    // Seek to 3 seconds
    slider.onChanged!(3000.0);
    await tester.pump();
    expect(fakePlayer.seekPosition, const Duration(seconds: 3));
    expect(find.text('00:03'), findsOneWidget);

    // Complete playback resets position to 00:00 and retains duration 00:04
    fakePlayer.completePlayback();
    await tester.pump();
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('00:04'), findsOneWidget);
    final completedSlider = tester.widget<Slider>(find.byType(Slider));
    expect(completedSlider.value, 0.0);
    expect(completedSlider.max, 4000.0);
  });

  testWidgets(
    'verifies audio progress bar adapts when duration is not emitted ahead of time',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final readyBloc = _TestAudioServiceBloc(
        initialState: AudioServiceState(
          ttsStatus: TtsStatus.ready,
          audioBytes: Uint8List.fromList([1, 2, 3, 4, 5]),
        ),
      );
      addTearDown(() => readyBloc.close());

      await tester.pumpWidget(
        _buildTestApp(
          audioServiceBloc: readyBloc,
          audioSettingsBloc: audioSettingsBloc,
          player: fakePlayer,
          recorder: fakeRecorder,
        ),
      );
      await tester.pumpAndSettle();

      // Tap Play
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();
      expect(fakePlayer.isPlaying, isTrue);

      // Position advances to 4s without duration emitted
      fakePlayer.emitPosition(const Duration(seconds: 4));
      await tester.pump();
      // Effective duration adapts to 4s, position is 4s
      expect(find.text('00:04'), findsNWidgets(2));
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 4000.0);
      expect(slider.max, 4000.0);

      // Complete playback resets position to 00:00 while keeping total duration 00:04
      fakePlayer.completePlayback();
      await tester.pump();
      expect(find.text('00:00'), findsOneWidget);
      expect(find.text('00:04'), findsOneWidget);
      final resetSlider = tester.widget<Slider>(find.byType(Slider));
      expect(resetSlider.value, 0.0);
      expect(resetSlider.max, 4000.0);
    },
  );

  testWidgets(
    'verifies ASR view renders, transcription result displays with copy button',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final asrResultBloc = _TestAudioServiceBloc(
        initialState: const AudioServiceState(
          asrStatus: AsrStatus.success,
          transcription: 'This is the transcribed audio text result.',
        ),
      );
      addTearDown(() => asrResultBloc.close());

      await tester.pumpWidget(
        _buildTestApp(
          audioServiceBloc: asrResultBloc,
          audioSettingsBloc: audioSettingsBloc,
          player: fakePlayer,
          recorder: fakeRecorder,
        ),
      );
      await tester.pumpAndSettle();

      // Switch to ASR tab
      await tester.tap(find.text('Speech to Text (ASR)'));
      await tester.pumpAndSettle();

      expect(find.text('Transcription Result'), findsOneWidget);
      expect(
        find.text('This is the transcribed audio text result.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.copy), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);

      // Tap Copy button
      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Copied to clipboard'), findsOneWidget);

      // Tap Clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();
      expect(asrResultBloc.dispatchedEvents, contains(isA<AudioAsrClear>()));
    },
  );

  testWidgets(
    'verifies tapping Settings icon in app bar navigates to AudioSettingsScreen',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _buildTestApp(
          audioServiceBloc: audioServiceBloc,
          audioSettingsBloc: audioSettingsBloc,
          player: fakePlayer,
          recorder: fakeRecorder,
        ),
      );
      await tester.pumpAndSettle();

      final settingsButton = find.byIcon(Icons.settings);
      expect(settingsButton, findsOneWidget);

      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      expect(find.text('AudioSettingsScreen Destination'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping Record starts recording with timer indicator, tapping Stop dispatches transcription',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _buildTestApp(
          audioServiceBloc: audioServiceBloc,
          audioSettingsBloc: audioSettingsBloc,
          player: fakePlayer,
          recorder: fakeRecorder,
        ),
      );
      await tester.pumpAndSettle();

      // Switch to ASR tab
      await tester.tap(find.text('Speech to Text (ASR)'));
      await tester.pumpAndSettle();

      // Tap Record
      await tester.tap(find.text('Record'));
      await tester.pump();

      expect(fakeRecorder.recording, isTrue);
      expect(fakeRecorder.lastStartedPath, isNotNull);
      expect(find.text('Stop & Transcribe'), findsOneWidget);
      expect(find.text('Recording 00:00'), findsOneWidget);

      // Advance timer by 3 seconds
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Recording 00:03'), findsOneWidget);

      // Tap Stop & Transcribe
      await tester.tap(find.text('Stop & Transcribe'));
      await tester.pump();

      expect(fakeRecorder.recording, isFalse);
      expect(
        audioServiceBloc.dispatchedEvents,
        contains(isA<AudioAsrTranscribeFile>()),
      );
      final transcribeEvent = audioServiceBloc.dispatchedEvents
          .whereType<AudioAsrTranscribeFile>()
          .first;
      expect(transcribeEvent.filePath, fakeRecorder.stoppedPath);
    },
  );

  testWidgets('displays error banner when ttsError or asrError is present', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final errorBloc = _TestAudioServiceBloc(
      initialState: const AudioServiceState(
        ttsError: 'TTS synthesis error occurred',
        asrError: 'ASR transcription error occurred',
      ),
    );
    addTearDown(() => errorBloc.close());

    await tester.pumpWidget(
      _buildTestApp(
        audioServiceBloc: errorBloc,
        audioSettingsBloc: audioSettingsBloc,
        player: fakePlayer,
        recorder: fakeRecorder,
      ),
    );
    await tester.pumpAndSettle();

    // Verify TTS error is shown in TTS tab
    expect(find.text('TTS synthesis error occurred'), findsOneWidget);

    // Switch to ASR tab
    await tester.tap(find.text('Speech to Text (ASR)'));
    await tester.pumpAndSettle();

    // Verify ASR error is shown in ASR tab
    expect(find.text('ASR transcription error occurred'), findsOneWidget);
  });

  testWidgets('verifies ServiceScreen includes an Audio tile', (tester) async {
    final gitHubBloc = _TestGitHubBloc();
    addTearDown(() => gitHubBloc.close());

    await tester.pumpWidget(
      BlocProvider<GitHubBloc>.value(
        value: gitHubBloc,
        child: MaterialApp(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: const ServiceScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Audio'), findsOneWidget);
    expect(find.byIcon(Icons.graphic_eq), findsOneWidget);
  });

  testWidgets(
    'verifies audio progress bar synchronizes with parsed audio duration and handles dragging smoothly',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final fourSecWav = _createTestWavBytes(4);
      final readyBloc = _TestAudioServiceBloc(
        initialState: AudioServiceState(
          ttsStatus: TtsStatus.ready,
          audioBytes: fourSecWav,
        ),
      );
      addTearDown(() => readyBloc.close());

      await tester.pumpWidget(
        _buildTestApp(
          audioServiceBloc: readyBloc,
          audioSettingsBloc: audioSettingsBloc,
          player: fakePlayer,
          recorder: fakeRecorder,
        ),
      );
      await tester.pumpAndSettle();

      // Before playback starts, duration is immediately 00:04 from parsed bytes,
      // position is 00:00, and slider thumb is at 0.0
      expect(find.text('00:04'), findsOneWidget);
      expect(find.text('00:00'), findsOneWidget);
      var slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 0.0);
      expect(slider.max, 4000.0);

      // Tap Play
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();
      expect(fakePlayer.isPlaying, isTrue);

      // Position updates to 1 second during playback
      fakePlayer.emitPosition(const Duration(seconds: 1));
      await tester.pump();
      expect(find.text('00:01'), findsOneWidget);
      expect(find.text('00:04'), findsOneWidget);
      slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 1000.0);
      expect(slider.max, 4000.0);

      // Position updates to 2 seconds
      fakePlayer.emitPosition(const Duration(seconds: 2));
      await tester.pump();
      expect(find.text('00:02'), findsOneWidget);
      expect(find.text('00:04'), findsOneWidget);
      slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 2000.0);
      expect(slider.max, 4000.0);

      // User starts dragging slider to 3.5 seconds
      slider.onChangeStart!(2000.0);
      slider.onChanged!(3500.0);
      await tester.pump();
      expect(find.text('00:03'), findsOneWidget); // 3500ms is 00:03
      expect(find.text('00:04'), findsOneWidget);

      // While dragging, stream emits 2.5s position - should be ignored!
      fakePlayer.emitPosition(const Duration(milliseconds: 2500));
      await tester.pump();
      slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 3500.0);

      // User finishes dragging at 3.5s
      slider.onChangeEnd!(3500.0);
      await tester.pump();
      expect(fakePlayer.seekPosition, const Duration(milliseconds: 3500));
      expect(find.text('00:03'), findsOneWidget);
    },
  );
}

Uint8List _createTestWavBytes(int seconds) {
  const sampleRate = 16000;
  const numChannels = 1;
  const bitsPerSample = 16;
  final byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
  final blockAlign = numChannels * (bitsPerSample ~/ 8);
  final dataSize = byteRate * seconds;
  final totalSize = 36 + dataSize;

  final b = ByteData(44 + dataSize);
  b.setUint8(0, 0x52);
  b.setUint8(1, 0x49);
  b.setUint8(2, 0x46);
  b.setUint8(3, 0x46);
  b.setUint32(4, totalSize, Endian.little);
  b.setUint8(8, 0x57);
  b.setUint8(9, 0x41);
  b.setUint8(10, 0x56);
  b.setUint8(11, 0x45);
  b.setUint8(12, 0x66);
  b.setUint8(13, 0x6d);
  b.setUint8(14, 0x74);
  b.setUint8(15, 0x20);
  b.setUint32(16, 16, Endian.little);
  b.setUint16(20, 1, Endian.little);
  b.setUint16(22, numChannels, Endian.little);
  b.setUint32(24, sampleRate, Endian.little);
  b.setUint32(28, byteRate, Endian.little);
  b.setUint16(32, blockAlign, Endian.little);
  b.setUint16(34, bitsPerSample, Endian.little);
  b.setUint8(36, 0x64);
  b.setUint8(37, 0x61);
  b.setUint8(38, 0x74);
  b.setUint8(39, 0x61);
  b.setUint32(40, dataSize, Endian.little);

  return b.buffer.asUint8List();
}

class _TestGitHubBloc extends Bloc<GitHubEvent, GitHubState>
    implements GitHubBloc {
  _TestGitHubBloc() : super(const GitHubInitial());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
