import 'dart:async';

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

  bool isPlaying = false;
  bool isPaused = false;
  bool isStopped = false;
  Duration? seekPosition;
  Source? playedSource;

  @override
  Stream<PlayerState> get onPlayerStateChanged => _stateController.stream;

  @override
  Stream<Duration> get onDurationChanged => _durationController.stream;

  @override
  Stream<Duration> get onPositionChanged => _positionController.stream;

  @override
  Future<void> play(Source source) async {
    playedSource = source;
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
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, 'Hello text to speech');
      await tester.pumpAndSettle();

      // Change voice to echo
      final voiceDropdown = find.byType(DropdownButton<String>);
      expect(voiceDropdown, findsOneWidget);
      await tester.tap(voiceDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('echo').last);
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
  });

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
}

class _TestGitHubBloc extends Bloc<GitHubEvent, GitHubState>
    implements GitHubBloc {
  _TestGitHubBloc() : super(const GitHubInitial());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
