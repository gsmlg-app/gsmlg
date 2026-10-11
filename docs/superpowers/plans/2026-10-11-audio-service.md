# Audio Service and OpenAI-Compatible ASR / TTS Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an Audio Service to GSMLG providing TTS synthesis and ASR transcription with Backplane as default and custom OpenAI-compatible audio support configured via Settings.

**Architecture:** 
- Core models, JSON serialization, and HTTP repository in `app_lib/audio`.
- State management (`AudioSettingsBloc` and `AudioServiceBloc`) in `app_bloc/audio`.
- Dedicated `AudioSettingsScreen` under Settings and `AudioScreen` under Service tab, wired into `MainProvider` and routing.

**Tech Stack:** Flutter, Dart, BLoC, Dio/HTTP, `audioplayers`, `record`, `shared_preferences`, GoRouter, DuskMoon UI.

---

### Task 1: Create `app_lib/audio` package and `AudioSettings` model

**Files:**
- Create: `app_lib/audio/pubspec.yaml`
- Create: `app_lib/audio/lib/audio.dart`
- Create: `app_lib/audio/lib/src/models/audio_settings.dart`
- Create: `app_lib/audio/test/audio_settings_test.dart`
- Modify: `pubspec.yaml`

- [ ] **Step 1: Create `app_lib/audio/pubspec.yaml` and update root `pubspec.yaml`**

```yaml
name: app_audio
description: Core audio models and OpenAI-compatible ASR/TTS repository.
publish_to: "none"
version: 1.0.0

environment:
  sdk: ">=3.12.0 <4.0.0"

dependencies:
  equatable: ^2.1.0
  flutter:
    sdk: flutter
  dio: any
  http: any
  path: any
  app_database: any
  app_secure_storage: any

dev_dependencies:
  flutter_test:
    sdk: flutter
  test: any
```

Add `app_lib/audio` to root `pubspec.yaml` `workspace:` list and `app_audio: any` to `dependencies:`.

- [ ] **Step 2: Write failing test for `AudioSettings`**

```dart
// app_lib/audio/test/audio_settings_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app_audio/audio.dart';

void main() {
  group('AudioSettings', () {
    test('defaults to Backplane configuration', () {
      const settings = AudioSettings();
      expect(settings.providerType, AudioProviderType.backplane);
      expect(settings.baseUrl, 'https://backplane.gsmlg.net/v1');
      expect(settings.ttsModel, 'tts-1');
      expect(settings.ttsVoice, 'alloy');
      expect(settings.asrModel, 'whisper-1');
      expect(settings.useDummyToken, isFalse);
    });

    test('serializes to and from json', () {
      const settings = AudioSettings(
        providerType: AudioProviderType.customOpenAi,
        baseUrl: 'https://custom.api/v1',
        accountId: 42,
        useDummyToken: false,
        ttsModel: 'tts-1-hd',
        ttsVoice: 'echo',
        ttsSpeed: 1.25,
        ttsResponseFormat: 'wav',
        asrModel: 'whisper-large',
        asrLanguage: 'en',
      );

      final json = settings.toJson();
      final reconstructed = AudioSettings.fromJson(json);

      expect(reconstructed, equals(settings));
    });
  });
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `flutter test app_lib/audio/test/audio_settings_test.dart`
Expected: FAIL (missing files)

- [ ] **Step 4: Implement `AudioSettings` and export in `app_audio`**

Create `app_lib/audio/lib/src/models/audio_settings.dart`:
```dart
import 'package:equatable/equatable.dart';

enum AudioProviderType {
  backplane,
  customOpenAi,
}

class AudioSettings extends Equatable {
  const AudioSettings({
    this.providerType = AudioProviderType.backplane,
    this.baseUrl = 'https://backplane.gsmlg.net/v1',
    this.accountId,
    this.useDummyToken = false,
    this.ttsModel = 'tts-1',
    this.ttsVoice = 'alloy',
    this.ttsSpeed = 1.0,
    this.ttsResponseFormat = 'mp3',
    this.asrModel = 'whisper-1',
    this.asrLanguage,
  });

  final AudioProviderType providerType;
  final String baseUrl;
  final int? accountId;
  final bool useDummyToken;
  final String ttsModel;
  final String ttsVoice;
  final double ttsSpeed;
  final String ttsResponseFormat;
  final String asrModel;
  final String? asrLanguage;

  static const defaultBackplaneUrl = 'https://backplane.gsmlg.net/v1';

  AudioSettings copyWith({
    AudioProviderType? providerType,
    String? baseUrl,
    int? accountId,
    bool clearAccount = false,
    bool? useDummyToken,
    String? ttsModel,
    String? ttsVoice,
    double? ttsSpeed,
    String? ttsResponseFormat,
    String? asrModel,
    String? asrLanguage,
    bool clearLanguage = false,
  }) {
    return AudioSettings(
      providerType: providerType ?? this.providerType,
      baseUrl: baseUrl ?? this.baseUrl,
      accountId: clearAccount ? null : accountId ?? this.accountId,
      useDummyToken: useDummyToken ?? this.useDummyToken,
      ttsModel: ttsModel ?? this.ttsModel,
      ttsVoice: ttsVoice ?? this.ttsVoice,
      ttsSpeed: ttsSpeed ?? this.ttsSpeed,
      ttsResponseFormat: ttsResponseFormat ?? this.ttsResponseFormat,
      asrModel: asrModel ?? this.asrModel,
      asrLanguage: clearLanguage ? null : asrLanguage ?? this.asrLanguage,
    );
  }

  Map<String, dynamic> toJson() => {
    'providerType': providerType.name,
    'baseUrl': baseUrl,
    'accountId': accountId,
    'useDummyToken': useDummyToken,
    'ttsModel': ttsModel,
    'ttsVoice': ttsVoice,
    'ttsSpeed': ttsSpeed,
    'ttsResponseFormat': ttsResponseFormat,
    'asrModel': asrModel,
    'asrLanguage': asrLanguage,
  };

  factory AudioSettings.fromJson(Map<String, dynamic> json) {
    return AudioSettings(
      providerType: AudioProviderType.values.firstWhere(
        (type) => type.name == json['providerType'],
        orElse: () => AudioProviderType.backplane,
      ),
      baseUrl: json['baseUrl'] as String? ?? defaultBackplaneUrl,
      accountId: json['accountId'] as int?,
      useDummyToken: json['useDummyToken'] as bool? ?? false,
      ttsModel: json['ttsModel'] as String? ?? 'tts-1',
      ttsVoice: json['ttsVoice'] as String? ?? 'alloy',
      ttsSpeed: (json['ttsSpeed'] as num?)?.toDouble() ?? 1.0,
      ttsResponseFormat: json['ttsResponseFormat'] as String? ?? 'mp3',
      asrModel: json['asrModel'] as String? ?? 'whisper-1',
      asrLanguage: json['asrLanguage'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    providerType,
    baseUrl,
    accountId,
    useDummyToken,
    ttsModel,
    ttsVoice,
    ttsSpeed,
    ttsResponseFormat,
    asrModel,
    asrLanguage,
  ];
}
```

Export in `app_lib/audio/lib/audio.dart`:
```dart
library app_audio;

export 'src/models/audio_settings.dart';
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test app_lib/audio/test/audio_settings_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add app_lib/audio pubspec.yaml
git commit -m "feat(audio): add app_audio package and AudioSettings model"
```

---

### Task 2: Implement `OpenAiAudioRepository` in `app_lib/audio`

**Files:**
- Create: `app_lib/audio/lib/src/repositories/audio_repository.dart`
- Create: `app_lib/audio/test/audio_repository_test.dart`
- Modify: `app_lib/audio/lib/audio.dart`

- [ ] **Step 1: Write failing unit test for `OpenAiAudioRepository`**

```dart
// app_lib/audio/test/audio_repository_test.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:app_audio/audio.dart';

void main() {
  group('OpenAiAudioRepository', () {
    test('synthesizes speech returning audio bytes', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/audio/speech'));
        expect(request.method, 'POST');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['input'], 'Hello world');
        expect(body['voice'], 'alloy');
        return http.Response.bytes(Uint8List.fromList([1, 2, 3, 4]), 200);
      });

      final repo = OpenAiAudioRepository(httpClient: mockClient);
      const settings = AudioSettings(useDummyToken: true);

      final bytes = await repo.synthesizeSpeech(settings, 'Hello world');
      expect(bytes, Uint8List.fromList([1, 2, 3, 4]));
    });

    test('transcribes audio returning text', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/audio/transcriptions'));
        expect(request.method, 'POST');
        return http.Response(jsonEncode({'text': 'Recognized transcript'}), 200);
      });

      final repo = OpenAiAudioRepository(httpClient: mockClient);
      const settings = AudioSettings(useDummyToken: true);

      final text = await repo.transcribeAudio(
        settings,
        bytes: [0, 0, 0],
        filename: 'test.wav',
      );
      expect(text, 'Recognized transcript');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test app_lib/audio/test/audio_repository_test.dart`
Expected: FAIL

- [ ] **Step 3: Implement `OpenAiAudioRepository`**

Create `app_lib/audio/lib/src/repositories/audio_repository.dart`:
```dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/vault_repository.dart';
import '../models/audio_settings.dart';

class OpenAiAudioRepository {
  OpenAiAudioRepository({
    AppDatabase? database,
    VaultRepository? vault,
    http.Client? httpClient,
  })  : _database = database,
        _vault = vault,
        _httpClient = httpClient ?? http.Client();

  final AppDatabase? _database;
  final VaultRepository? _vault;
  final http.Client _httpClient;

  Future<String?> resolveToken(AudioSettings settings) async {
    if (settings.useDummyToken) return null;
    final accountId = settings.accountId;
    if (accountId == null) return null;

    if (_vault != null) {
      return (await _vault.read(key: 'service_account_$accountId'))?.trim();
    }
    return null;
  }

  Uri _resolveEndpoint(String baseUrl, String path) {
    final cleanBase = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$cleanBase/$path');
  }

  Future<Uint8List> synthesizeSpeech(
    AudioSettings settings,
    String text, {
    String? model,
    String? voice,
    double? speed,
    String? format,
  }) async {
    final uri = _resolveEndpoint(settings.baseUrl, 'audio/speech');
    final token = await resolveToken(settings);

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'model': model ?? settings.ttsModel,
      'input': text,
      'voice': voice ?? settings.ttsVoice,
      'speed': speed ?? settings.ttsSpeed,
      'response_format': format ?? settings.ttsResponseFormat,
    });

    final response = await _httpClient.post(uri, headers: headers, body: body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    }

    throw HttpException(
      'TTS request failed [${response.statusCode}]: ${response.body}',
      uri: uri,
    );
  }

  Future<String> transcribeAudio(
    AudioSettings settings, {
    List<int>? bytes,
    String? filename,
    String? filePath,
    String? model,
    String? language,
  }) async {
    final uri = _resolveEndpoint(settings.baseUrl, 'audio/transcriptions');
    final token = await resolveToken(settings);

    final request = http.MultipartRequest('POST', uri);
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['model'] = model ?? settings.asrModel;
    final effectiveLanguage = language ?? settings.asrLanguage;
    if (effectiveLanguage != null && effectiveLanguage.isNotEmpty) {
      request.fields['language'] = effectiveLanguage;
    }
    request.fields['response_format'] = 'json';

    if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
    } else if (bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename ?? 'audio.wav',
          contentType: MediaType('audio', 'wav'),
        ),
      );
    } else {
      throw ArgumentError('Either filePath or bytes must be provided.');
    }

    final streamedResponse = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['text'] as String? ?? '';
    }

    throw HttpException(
      'ASR request failed [${response.statusCode}]: ${response.body}',
      uri: uri,
    );
  }
}
```

Export in `app_lib/audio/lib/audio.dart`:
```dart
export 'src/repositories/audio_repository.dart';
```

- [ ] **Step 4: Run unit tests**

Run: `flutter test app_lib/audio/test/audio_repository_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app_lib/audio
git commit -m "feat(audio): implement OpenAiAudioRepository"
```

---

### Task 3: Create `app_bloc/audio` package and `AudioSettingsBloc`

**Files:**
- Create: `app_bloc/audio/pubspec.yaml`
- Create: `app_bloc/audio/lib/audio_bloc.dart`
- Create: `app_bloc/audio/lib/src/settings/bloc.dart`
- Create: `app_bloc/audio/lib/src/settings/event.dart`
- Create: `app_bloc/audio/lib/src/settings/state.dart`
- Create: `app_bloc/audio/test/audio_settings_bloc_test.dart`
- Modify: `pubspec.yaml`

- [ ] **Step 1: Create `app_bloc/audio/pubspec.yaml` and update root `pubspec.yaml`**

```yaml
name: audio_bloc
description: Audio BLoC state management for settings, TTS, and ASR.
publish_to: "none"
version: 1.0.0

environment:
  sdk: ">=3.12.0 <4.0.0"

dependencies:
  bloc: ^9.2.1
  flutter_bloc: ^9.1.1
  equatable: ^2.1.0
  flutter:
    sdk: flutter
  shared_preferences: ^2.5.6
  audioplayers: ^6.8.1
  record: ^7.1.1
  path: any
  path_provider: any
  app_audio: any

dev_dependencies:
  flutter_test:
    sdk: flutter
  test: any
```

Add `app_bloc/audio` to root `pubspec.yaml` `workspace:` list and `audio_bloc: any` to `dependencies:`.

- [ ] **Step 2: Write failing unit test for `AudioSettingsBloc`**

```dart
// app_bloc/audio/test/audio_settings_bloc_test.dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_bloc/audio_bloc.dart';
import 'package:app_audio/audio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioSettingsBloc', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('loads default settings when empty', () async {
      final bloc = AudioSettingsBloc(preferences: prefs);
      bloc.add(const AudioSettingsLoad());
      await expectLater(
        bloc.stream,
        emits(const AudioSettingsState(settings: AudioSettings(), status: AudioSettingsStatus.ready)),
      );
    });

    test('saves and persists settings', () async {
      final bloc = AudioSettingsBloc(preferences: prefs);
      const newSettings = AudioSettings(
        providerType: AudioProviderType.customOpenAi,
        baseUrl: 'https://example.com/v1',
      );
      bloc.add(const AudioSettingsSave(newSettings));
      await expectLater(
        bloc.stream,
        emits(const AudioSettingsState(settings: newSettings, status: AudioSettingsStatus.ready)),
      );
      expect(prefs.getString('audio_service_settings'), jsonEncode(newSettings.toJson()));
    });
  });
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `flutter test app_bloc/audio/test/audio_settings_bloc_test.dart`
Expected: FAIL

- [ ] **Step 4: Implement `AudioSettingsBloc`**

Create `app_bloc/audio/lib/src/settings/event.dart`:
```dart
part of 'bloc.dart';

sealed class AudioSettingsEvent extends Equatable {
  const AudioSettingsEvent();

  @override
  List<Object?> get props => [];
}

final class AudioSettingsLoad extends AudioSettingsEvent {
  const AudioSettingsLoad();
}

final class AudioSettingsSave extends AudioSettingsEvent {
  const AudioSettingsSave(this.settings);
  final AudioSettings settings;

  @override
  List<Object?> get props => [settings];
}

final class AudioSettingsResetToBackplane extends AudioSettingsEvent {
  const AudioSettingsResetToBackplane();
}
```

Create `app_bloc/audio/lib/src/settings/state.dart`:
```dart
part of 'bloc.dart';

enum AudioSettingsStatus { initial, loading, ready, failure }

class AudioSettingsState extends Equatable {
  const AudioSettingsState({
    this.settings = const AudioSettings(),
    this.status = AudioSettingsStatus.initial,
    this.errorMessage,
  });

  final AudioSettings settings;
  final AudioSettingsStatus status;
  final String? errorMessage;

  AudioSettingsState copyWith({
    AudioSettings? settings,
    AudioSettingsStatus? status,
    String? errorMessage,
  }) {
    return AudioSettingsState(
      settings: settings ?? this.settings,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [settings, status, errorMessage];
}
```

Create `app_bloc/audio/lib/src/settings/bloc.dart`:
```dart
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_audio/audio.dart';

part 'event.dart';
part 'state.dart';

class AudioSettingsBloc extends Bloc<AudioSettingsEvent, AudioSettingsState> {
  AudioSettingsBloc({required SharedPreferences preferences})
      : _preferences = preferences,
        super(const AudioSettingsState()) {
    on<AudioSettingsLoad>(_onLoad);
    on<AudioSettingsSave>(_onSave);
    on<AudioSettingsResetToBackplane>(_onReset);
  }

  static const preferencesKey = 'audio_service_settings';
  final SharedPreferences _preferences;

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
    final settings = readSettings(_preferences);
    emit(state.copyWith(settings: settings, status: AudioSettingsStatus.ready));
  }

  Future<void> _onSave(
    AudioSettingsSave event,
    Emitter<AudioSettingsState> emit,
  ) async {
    try {
      await _preferences.setString(
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
    await _preferences.setString(
      preferencesKey,
      jsonEncode(defaultSettings.toJson()),
    );
    emit(
      state.copyWith(
        settings: defaultSettings,
        status: AudioSettingsStatus.ready,
      ),
    );
  }
}
```

Export in `app_bloc/audio/lib/audio_bloc.dart`:
```dart
library audio_bloc;

export 'src/settings/bloc.dart';
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test app_bloc/audio/test/audio_settings_bloc_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add app_bloc/audio pubspec.yaml
git commit -m "feat(audio): add AudioSettingsBloc"
```

---

### Task 4: Implement `AudioServiceBloc` in `app_bloc/audio`

**Files:**
- Create: `app_bloc/audio/lib/src/service/bloc.dart`
- Create: `app_bloc/audio/lib/src/service/event.dart`
- Create: `app_bloc/audio/lib/src/service/state.dart`
- Create: `app_bloc/audio/test/audio_service_bloc_test.dart`
- Modify: `app_bloc/audio/lib/audio_bloc.dart`

- [ ] **Step 1: Write failing unit test for `AudioServiceBloc`**

```dart
// app_bloc/audio/test/audio_service_bloc_test.dart
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:audio_bloc/audio_bloc.dart';
import 'package:app_audio/audio.dart';

class _FakeAudioRepository extends OpenAiAudioRepository {
  @override
  Future<Uint8List> synthesizeSpeech(
    AudioSettings settings,
    String text, {
    String? model,
    String? voice,
    double? speed,
    String? format,
  }) async {
    return Uint8List.fromList([1, 2, 3]);
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
    return 'Transcribed text';
  }
}

void main() {
  group('AudioServiceBloc', () {
    test('synthesizes speech and updates state', () async {
      final repo = _FakeAudioRepository();
      final bloc = AudioServiceBloc(
        repository: repo,
        settingsProvider: () => const AudioSettings(),
      );

      bloc.add(const AudioTtsSynthesize('Testing voice'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<AudioServiceState>((s) => s.ttsStatus == TtsStatus.synthesizing),
          predicate<AudioServiceState>((s) =>
              s.ttsStatus == TtsStatus.ready && s.audioBytes?.length == 3),
        ]),
      );
    });

    test('transcribes audio file and updates state', () async {
      final repo = _FakeAudioRepository();
      final bloc = AudioServiceBloc(
        repository: repo,
        settingsProvider: () => const AudioSettings(),
      );

      bloc.add(const AudioAsrTranscribeFile('/tmp/sample.wav'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<AudioServiceState>((s) => s.asrStatus == AsrStatus.transcribing),
          predicate<AudioServiceState>((s) =>
              s.asrStatus == AsrStatus.success && s.transcription == 'Transcribed text'),
        ]),
      );
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test app_bloc/audio/test/audio_service_bloc_test.dart`
Expected: FAIL

- [ ] **Step 3: Implement `AudioServiceBloc` events, state, and bloc**

Create `app_bloc/audio/lib/src/service/event.dart`:
```dart
part of 'bloc.dart';

sealed class AudioServiceEvent extends Equatable {
  const AudioServiceEvent();

  @override
  List<Object?> get props => [];
}

final class AudioTtsSynthesize extends AudioServiceEvent {
  const AudioTtsSynthesize(this.text, {this.voice, this.model});
  final String text;
  final String? voice;
  final String? model;

  @override
  List<Object?> get props => [text, voice, model];
}

final class AudioTtsSetAudioBytes extends AudioServiceEvent {
  const AudioTtsSetAudioBytes(this.bytes);
  final Uint8List? bytes;

  @override
  List<Object?> get props => [bytes];
}

final class AudioTtsClear extends AudioServiceEvent {
  const AudioTtsClear();
}

final class AudioAsrTranscribeFile extends AudioServiceEvent {
  const AudioAsrTranscribeFile(this.filePath);
  final String filePath;

  @override
  List<Object?> get props => [filePath];
}

final class AudioAsrTranscribeBytes extends AudioServiceEvent {
  const AudioAsrTranscribeBytes(this.bytes, {this.filename});
  final List<int> bytes;
  final String? filename;

  @override
  List<Object?> get props => [bytes, filename];
}

final class AudioAsrClear extends AudioServiceEvent {
  const AudioAsrClear();
}
```

Create `app_bloc/audio/lib/src/service/state.dart`:
```dart
part of 'bloc.dart';

enum TtsStatus { idle, synthesizing, ready, error }
enum AsrStatus { idle, recording, transcribing, success, error }

class AudioServiceState extends Equatable {
  const AudioServiceState({
    this.ttsStatus = TtsStatus.idle,
    this.audioBytes,
    this.ttsError,
    this.asrStatus = AsrStatus.idle,
    this.recordingPath,
    this.transcription,
    this.asrError,
  });

  final TtsStatus ttsStatus;
  final Uint8List? audioBytes;
  final String? ttsError;

  final AsrStatus asrStatus;
  final String? recordingPath;
  final String? transcription;
  final String? asrError;

  AudioServiceState copyWith({
    TtsStatus? ttsStatus,
    Uint8List? audioBytes,
    bool clearAudio = false,
    String? ttsError,
    bool clearTtsError = false,
    AsrStatus? asrStatus,
    String? recordingPath,
    String? transcription,
    bool clearTranscription = false,
    String? asrError,
    bool clearAsrError = false,
  }) {
    return AudioServiceState(
      ttsStatus: ttsStatus ?? this.ttsStatus,
      audioBytes: clearAudio ? null : audioBytes ?? this.audioBytes,
      ttsError: clearTtsError ? null : ttsError ?? this.ttsError,
      asrStatus: asrStatus ?? this.asrStatus,
      recordingPath: recordingPath ?? this.recordingPath,
      transcription: clearTranscription ? null : transcription ?? this.transcription,
      asrError: clearAsrError ? null : asrError ?? this.asrError,
    );
  }

  @override
  List<Object?> get props => [
    ttsStatus,
    audioBytes,
    ttsError,
    asrStatus,
    recordingPath,
    transcription,
    asrError,
  ];
}
```

Create `app_bloc/audio/lib/src/service/bloc.dart`:
```dart
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app_audio/audio.dart';

part 'event.dart';
part 'state.dart';

typedef AudioSettingsProvider = AudioSettings Function();

class AudioServiceBloc extends Bloc<AudioServiceEvent, AudioServiceState> {
  AudioServiceBloc({
    required OpenAiAudioRepository repository,
    required AudioSettingsProvider settingsProvider,
  })  : _repository = repository,
        _settingsProvider = settingsProvider,
        super(const AudioServiceState()) {
    on<AudioTtsSynthesize>(_onTtsSynthesize);
    on<AudioTtsClear>(_onTtsClear);
    on<AudioAsrTranscribeFile>(_onAsrTranscribeFile);
    on<AudioAsrTranscribeBytes>(_onAsrTranscribeBytes);
    on<AudioAsrClear>(_onAsrClear);
  }

  final OpenAiAudioRepository _repository;
  final AudioSettingsProvider _settingsProvider;

  Future<void> _onTtsSynthesize(
    AudioTtsSynthesize event,
    Emitter<AudioServiceState> emit,
  ) async {
    emit(state.copyWith(ttsStatus: TtsStatus.synthesizing, clearTtsError: true));
    try {
      final settings = _settingsProvider();
      final bytes = await _repository.synthesizeSpeech(
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

  void _onTtsClear(AudioTtsClear event, Emitter<AudioServiceState> emit) {
    emit(state.copyWith(ttsStatus: TtsStatus.idle, clearAudio: true, clearTtsError: true));
  }

  Future<void> _onAsrTranscribeFile(
    AudioAsrTranscribeFile event,
    Emitter<AudioServiceState> emit,
  ) async {
    emit(state.copyWith(asrStatus: AsrStatus.transcribing, clearAsrError: true));
    try {
      final settings = _settingsProvider();
      final text = await _repository.transcribeAudio(
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
    emit(state.copyWith(asrStatus: AsrStatus.transcribing, clearAsrError: true));
    try {
      final settings = _settingsProvider();
      final text = await _repository.transcribeAudio(
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
    emit(state.copyWith(asrStatus: AsrStatus.idle, clearTranscription: true, clearAsrError: true));
  }
}
```

Export in `app_bloc/audio/lib/audio_bloc.dart`:
```dart
export 'src/service/bloc.dart';
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test app_bloc/audio/test/audio_service_bloc_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app_bloc/audio
git commit -m "feat(audio): implement AudioServiceBloc"
```

---

### Task 5: Add Localization Keys and Generate L10n

**Files:**
- Modify: `app_lib/locale/lib/arb/app_en.arb`

- [ ] **Step 1: Add audio service and audio settings keys to `app_en.arb`**

Add the following keys to `app_lib/locale/lib/arb/app_en.arb`:
```arb
  "audioServiceTitle": "Audio",
  "audioServiceDescription": "ASR speech recognition and TTS speech synthesis",
  "audioTtsTab": "Text to Speech (TTS)",
  "audioAsrTab": "Speech to Text (ASR)",
  "audioTextInputHint": "Enter text to convert to speech…",
  "audioSynthesizeButton": "Synthesize",
  "audioSynthesizing": "Synthesizing audio…",
  "audioVoiceLabel": "Voice",
  "audioModelLabel": "Model",
  "audioPlayButton": "Play",
  "audioPauseButton": "Pause",
  "audioStopButton": "Stop",
  "audioSaveButton": "Export Audio",
  "audioRecordButton": "Record",
  "audioStopRecordButton": "Stop & Transcribe",
  "audioUploadButton": "Pick Audio File",
  "audioTranscribing": "Transcribing audio…",
  "audioTranscriptionResult": "Transcription Result",
  "audioCopySuccess": "Copied to clipboard",
  "audioClear": "Clear",
  "audioSettingsTitle": "Audio Settings",
  "audioSettingsProvider": "Provider",
  "audioSettingsBackplanePreset": "Backplane (Default)",
  "audioSettingsCustomOpenAi": "Custom OpenAI-Compatible",
  "audioSettingsBaseUrl": "Base URL",
  "audioSettingsAccount": "Service Account",
  "audioSettingsUseDummyToken": "Use dummy token (for unauthenticated local APIs)",
  "audioSettingsTtsModel": "Default TTS Model",
  "audioSettingsTtsVoice": "Default TTS Voice",
  "audioSettingsTtsSpeed": "Speech Speed",
  "audioSettingsTtsFormat": "Audio Format",
  "audioSettingsAsrModel": "Default ASR Model",
  "audioSettingsAsrLanguage": "Language Code (e.g. en, zh)",
  "audioSettingsResetButton": "Reset to Backplane Defaults",
  "audioSettingsSaveButton": "Save Settings"
```

- [ ] **Step 2: Run `melos run gen-l10n`**

Run: `melos run gen-l10n`
Expected: Localization files regenerated without error.

- [ ] **Step 3: Commit**

```bash
git add app_lib/locale
git commit -m "feat(audio): add localization strings for Audio service and settings"
```

---

### Task 6: Register Audio in `MainProvider` and Dependency Injection

**Files:**
- Modify: `app_lib/provider/lib/src/main.dart`
- Modify: `app_lib/provider/pubspec.yaml`
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add `app_audio` and `audio_bloc` to `app_lib/provider/pubspec.yaml`**

Under `dependencies:`:
```yaml
  app_audio: any
  audio_bloc: any
```

- [ ] **Step 2: Update `MainProvider` in `app_lib/provider/lib/src/main.dart`**

Add `OpenAiAudioRepository` to `MultiRepositoryProvider`:
```dart
RepositoryProvider<OpenAiAudioRepository>(
  create: (context) => OpenAiAudioRepository(
    database: database,
    vault: vault,
  ),
),
```

Add `AudioSettingsBloc` and `AudioServiceBloc` to `MultiBlocProvider`:
```dart
BlocProvider<AudioSettingsBloc>(
  create: (context) => AudioSettingsBloc(
    preferences: sharedPrefs,
  )..add(const AudioSettingsLoad()),
),
BlocProvider<AudioServiceBloc>(
  create: (context) => AudioServiceBloc(
    repository: context.read<OpenAiAudioRepository>(),
    settingsProvider: () => context.read<AudioSettingsBloc>().state.settings,
  ),
),
```

- [ ] **Step 3: Run `melos bootstrap` and verify analysis**

Run: `melos bootstrap && melos run analyze:dart`
Expected: Code compiles cleanly.

- [ ] **Step 4: Commit**

```bash
git add app_lib/provider pubspec.yaml
git commit -m "feat(audio): wire OpenAiAudioRepository and Audio BLoCs in MainProvider"
```

---

### Task 7: Implement `AudioSettingsScreen` and Route Integration

**Files:**
- Create: `lib/screens/settings/audio_settings_screen.dart`
- Create: `test/screens/settings/audio_settings_screen_test.dart`
- Modify: `lib/screens/settings/settings_screen.dart`
- Modify: `lib/screens/settings/settings_routes.dart`

- [ ] **Step 1: Write failing widget test for `AudioSettingsScreen`**

```dart
// test/screens/settings/audio_settings_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_bloc/audio_bloc.dart';
import 'package:app_audio/audio.dart';
import 'package:gsmlg/screens/settings/audio_settings_screen.dart';
import 'package:app_locale/app_locale.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders AudioSettingsScreen with Backplane defaults', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final bloc = AudioSettingsBloc(preferences: prefs)..add(const AudioSettingsLoad());

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocale.localizationsDelegates,
        supportedLocales: AppLocale.supportedLocales,
        home: BlocProvider.value(
          value: bloc,
          child: const AudioSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Audio Settings'), findsWidgets);
    expect(find.text('Backplane (Default)'), findsOneWidget);
    expect(find.text('https://backplane.gsmlg.net/v1'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/screens/settings/audio_settings_screen_test.dart`
Expected: FAIL

- [ ] **Step 3: Implement `AudioSettingsScreen`**

Create `lib/screens/settings/audio_settings_screen.dart`:
```dart
import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_audio/audio.dart';
import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:audio_bloc/audio_bloc.dart';
import 'package:duskmoon_settings/duskmoon_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/settings/account_screen.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';
import 'package:go_router/go_router.dart';

class AudioSettingsScreen extends StatefulWidget {
  static const name = 'AudioSettings';
  static const path = 'audio';

  const AudioSettingsScreen({super.key});

  @override
  State<AudioSettingsScreen> createState() => _AudioSettingsScreenState();
}

class _AudioSettingsScreenState extends State<AudioSettingsScreen> {
  late AudioProviderType _providerType;
  late TextEditingController _baseUrl;
  int? _accountId;
  bool _useDummyToken = false;
  late TextEditingController _ttsModel;
  late String _ttsVoice;
  late double _ttsSpeed;
  late String _ttsFormat;
  late TextEditingController _asrModel;
  late TextEditingController _asrLanguage;

  static const _voices = ['alloy', 'echo', 'fable', 'onyx', 'nova', 'shimmer'];
  static const _formats = ['mp3', 'wav', 'opus', 'aac', 'flac'];

  @override
  void initState() {
    super.initState();
    final settings = context.read<AudioSettingsBloc>().state.settings;
    _providerType = settings.providerType;
    _baseUrl = TextEditingController(text: settings.baseUrl);
    _accountId = settings.accountId;
    _useDummyToken = settings.useDummyToken;
    _ttsModel = TextEditingController(text: settings.ttsModel);
    _ttsVoice = settings.ttsVoice;
    _ttsSpeed = settings.ttsSpeed;
    _ttsFormat = settings.ttsResponseFormat;
    _asrModel = TextEditingController(text: settings.asrModel);
    _asrLanguage = TextEditingController(text: settings.asrLanguage ?? '');
  }

  @override
  void dispose() {
    _baseUrl.dispose();
    _ttsModel.dispose();
    _asrModel.dispose();
    _asrLanguage.dispose();
    super.dispose();
  }

  void _save() {
    final updated = AudioSettings(
      providerType: _providerType,
      baseUrl: _baseUrl.text.trim(),
      accountId: _accountId,
      useDummyToken: _useDummyToken,
      ttsModel: _ttsModel.text.trim().isEmpty ? 'tts-1' : _ttsModel.text.trim(),
      ttsVoice: _ttsVoice,
      ttsSpeed: _ttsSpeed,
      ttsResponseFormat: _ttsFormat,
      asrModel: _asrModel.text.trim().isEmpty ? 'whisper-1' : _asrModel.text.trim(),
      asrLanguage: _asrLanguage.text.trim().isEmpty ? null : _asrLanguage.text.trim(),
    );
    context.read<AudioSettingsBloc>().add(AudioSettingsSave(updated));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.success)),
    );
  }

  void _resetToBackplane() {
    setState(() {
      _providerType = AudioProviderType.backplane;
      _baseUrl.text = AudioSettings.defaultBackplaneUrl;
      _useDummyToken = false;
      _ttsModel.text = 'tts-1';
      _ttsVoice = 'alloy';
      _ttsSpeed = 1.0;
      _ttsFormat = 'mp3';
      _asrModel.text = 'whisper-1';
      _asrLanguage.text = '';
    });
    context.read<AudioSettingsBloc>().add(const AudioSettingsResetToBackplane());
  }

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      navigationRestoreInHeader: true,
      selectedIndex: Destinations.indexOf(
        const Key(SettingsScreen.name),
        context,
      ),
      onSelectedIndexChange: (index) =>
          Destinations.changeHandler(index, context),
      destinations: Destinations.navs(context),
      body: (context) {
        final accountsState = context.watch<AccountsBloc?>()?.state;
        final accounts = accountsState is AccountsLoaded
            ? accountsState.accounts
            : const <ServiceAccountTableData>[];

        return SafeArea(
          child: CustomScrollView(
            slivers: [
              DmNavigationHeader(
                builder: (context, header) => SliverAppBar(
                  leading: header.leading,
                  leadingWidth: header.leadingWidth,
                  automaticallyImplyLeading: header.automaticallyImplyLeading,
                  title: Text(context.l10n.audioSettingsTitle),
                ),
              ),
              SliverFillRemaining(
                child: SettingsList(
                  sections: [
                    SettingsSection(
                      title: Text(context.l10n.audioSettingsProvider),
                      tiles: [
                        SettingsTile(
                          title: Text(context.l10n.audioSettingsProvider),
                          description: DropdownButton<AudioProviderType>(
                            value: _providerType,
                            isExpanded: true,
                            items: [
                              DropdownMenuItem(
                                value: AudioProviderType.backplane,
                                child: Text(context.l10n.audioSettingsBackplanePreset),
                              ),
                              DropdownMenuItem(
                                value: AudioProviderType.customOpenAi,
                                child: Text(context.l10n.audioSettingsCustomOpenAi),
                              ),
                            ],
                            onChanged: (type) {
                              if (type != null) {
                                setState(() {
                                  _providerType = type;
                                  if (type == AudioProviderType.backplane) {
                                    _baseUrl.text = AudioSettings.defaultBackplaneUrl;
                                  }
                                });
                              }
                            },
                          ),
                        ),
                        SettingsTile(
                          title: Text(context.l10n.audioSettingsBaseUrl),
                          description: TextField(
                            controller: _baseUrl,
                            decoration: InputDecoration(
                              hintText: 'https://api.openai.com/v1',
                              labelText: context.l10n.audioSettingsBaseUrl,
                            ),
                          ),
                        ),
                        SettingsTile.switchTile(
                          title: Text(context.l10n.audioSettingsUseDummyToken),
                          initialValue: _useDummyToken,
                          onToggle: (val) => setState(() => _useDummyToken = val),
                        ),
                        if (!_useDummyToken)
                          SettingsTile(
                            title: Text(context.l10n.audioSettingsAccount),
                            description: DropdownButton<int?>(
                              value: _accountId,
                              isExpanded: true,
                              hint: Text(context.l10n.backplaneSelectAccount),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('None'),
                                ),
                                for (final acc in accounts)
                                  DropdownMenuItem<int?>(
                                    value: acc.id,
                                    child: Text(acc.name),
                                  ),
                              ],
                              onChanged: (id) => setState(() => _accountId = id),
                            ),
                          ),
                        SettingsTile.navigation(
                          title: Text(context.l10n.backplaneManageAccounts),
                          onPressed: (_) => context.goNamed(AccountScreen.name),
                        ),
                      ],
                    ),
                    SettingsSection(
                      title: const Text('TTS Configuration'),
                      tiles: [
                        SettingsTile(
                          title: Text(context.l10n.audioSettingsTtsModel),
                          description: TextField(
                            controller: _ttsModel,
                            decoration: InputDecoration(
                              labelText: context.l10n.audioSettingsTtsModel,
                            ),
                          ),
                        ),
                        SettingsTile(
                          title: Text(context.l10n.audioSettingsTtsVoice),
                          description: DropdownButton<String>(
                            value: _voices.contains(_ttsVoice) ? _ttsVoice : _voices.first,
                            isExpanded: true,
                            items: [
                              for (final v in _voices)
                                DropdownMenuItem(value: v, child: Text(v)),
                            ],
                            onChanged: (v) {
                              if (v != null) setState(() => _ttsVoice = v);
                            },
                          ),
                        ),
                        SettingsTile(
                          title: Text('${context.l10n.audioSettingsTtsSpeed}: ${_ttsSpeed.toStringAsFixed(2)}x'),
                          description: Slider(
                            value: _ttsSpeed,
                            min: 0.5,
                            max: 2.0,
                            divisions: 15,
                            label: '${_ttsSpeed.toStringAsFixed(2)}x',
                            onChanged: (val) => setState(() => _ttsSpeed = val),
                          ),
                        ),
                        SettingsTile(
                          title: Text(context.l10n.audioSettingsTtsFormat),
                          description: DropdownButton<String>(
                            value: _formats.contains(_ttsFormat) ? _ttsFormat : _formats.first,
                            isExpanded: true,
                            items: [
                              for (final f in _formats)
                                DropdownMenuItem(value: f, child: Text(f)),
                            ],
                            onChanged: (f) {
                              if (f != null) setState(() => _ttsFormat = f);
                            },
                          ),
                        ),
                      ],
                    ),
                    SettingsSection(
                      title: const Text('ASR Configuration'),
                      tiles: [
                        SettingsTile(
                          title: Text(context.l10n.audioSettingsAsrModel),
                          description: TextField(
                            controller: _asrModel,
                            decoration: InputDecoration(
                              labelText: context.l10n.audioSettingsAsrModel,
                            ),
                          ),
                        ),
                        SettingsTile(
                          title: Text(context.l10n.audioSettingsAsrLanguage),
                          description: TextField(
                            controller: _asrLanguage,
                            decoration: InputDecoration(
                              labelText: context.l10n.audioSettingsAsrLanguage,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SettingsSection(
                      title: const Text('Actions'),
                      tiles: [
                        SettingsTile(
                          leading: const Icon(Icons.save),
                          title: Text(context.l10n.audioSettingsSaveButton),
                          onPressed: (_) => _save(),
                        ),
                        SettingsTile(
                          leading: const Icon(Icons.restore),
                          title: Text(context.l10n.audioSettingsResetButton),
                          onPressed: (_) => _resetToBackplane(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 4: Register route in `lib/screens/settings/settings_routes.dart` and entry in `settings_screen.dart`**

In `settings_routes.dart`:
```dart
GoRoute(
  name: AudioSettingsScreen.name,
  path: AudioSettingsScreen.path,
  pageBuilder: (context, state) => NoTransitionPage<void>(
    key: state.pageKey,
    restorationId: state.pageKey.value,
    child: const AudioSettingsScreen(),
  ),
),
```

In `settings_screen.dart` under the "AI Models" section, add a tile:
```dart
SettingsTile.navigation(
  leading: const Icon(Icons.graphic_eq),
  title: const Text('Audio Settings'),
  value: BlocBuilder<AudioSettingsBloc, AudioSettingsState>(
    builder: (context, state) {
      return Text(state.settings.providerType == AudioProviderType.backplane
          ? 'Backplane'
          : 'OpenAI-Compatible');
    },
  ),
  onPressed: (context) {
    context.goNamed(AudioSettingsScreen.name);
  },
),
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/screens/settings/audio_settings_screen_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib/screens/settings test/screens/settings
git commit -m "feat(settings): add AudioSettingsScreen and navigation"
```

---

### Task 8: Implement `AudioScreen` and Service Route Integration

**Files:**
- Create: `lib/screens/service/audio/audio_screen.dart`
- Create: `test/screens/service/audio_screen_test.dart`
- Modify: `lib/screens/service/service_screen.dart`
- Modify: `lib/screens/service/service_routes.dart`

- [ ] **Step 1: Write failing widget test for `AudioScreen`**

```dart
// test/screens/service/audio_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_bloc/audio_bloc.dart';
import 'package:app_audio/audio.dart';
import 'package:gsmlg/screens/service/audio/audio_screen.dart';
import 'package:app_locale/app_locale.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders AudioScreen with TTS and ASR tabs', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsBloc = AudioSettingsBloc(preferences: prefs)..add(const AudioSettingsLoad());
    final serviceBloc = AudioServiceBloc(
      repository: OpenAiAudioRepository(),
      settingsProvider: () => const AudioSettings(),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocale.localizationsDelegates,
        supportedLocales: AppLocale.supportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: settingsBloc),
            BlocProvider.value(value: serviceBloc),
          ],
          child: const AudioScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Audio'), findsWidgets);
    expect(find.text('Text to Speech (TTS)'), findsOneWidget);
    expect(find.text('Speech to Text (ASR)'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/screens/service/audio_screen_test.dart`
Expected: FAIL

- [ ] **Step 3: Implement `AudioScreen`**

Create `lib/screens/service/audio/audio_screen.dart` with:
- Segmented button for TTS vs ASR.
- TTS tab: Text input, voice selection, "Synthesize" button, AudioPlayer integration for playback and export/save.
- ASR tab: Microphone recording (via `AudioRecorder`) with timer/pulse, audio file picker (via `file_picker`), transcription progress indicator, output display, and copy-to-clipboard button.
- App bar settings icon linking to `AudioSettingsScreen`.

- [ ] **Step 4: Register in `lib/screens/service/service_routes.dart` and `service_screen.dart`**

In `service_routes.dart`:
```dart
GoRoute(
  name: AudioScreen.name,
  path: AudioScreen.path,
  pageBuilder: (context, state) => NoTransitionPage<void>(
    key: state.pageKey,
    restorationId: state.pageKey.value,
    child: const AudioScreen(),
  ),
),
```

In `service_screen.dart`:
Add `AppGridTile` for Audio:
```dart
AppGridTile(
  onTap: () => context.go('/service/audio'),
  child: const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.graphic_eq, size: 48),
      SizedBox(height: 8),
      Text('Audio'),
    ],
  ),
),
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/screens/service/audio_screen_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib/screens/service test/screens/service
git commit -m "feat(service): add AudioScreen with TTS and ASR tabs"
```

---

### Task 9: Full Project Verification & Tests

**Files:**
- Repository-wide verification

- [ ] **Step 1: Run format check across all packages**

Run: `melos run format-check`
Expected: No formatting diffs.

- [ ] **Step 2: Run static analysis across all packages**

Run: `melos run analyze`
Expected: Exit code 0 (no fatal warnings/errors).

- [ ] **Step 3: Run all Dart and Flutter tests**

Run: `melos run test`
Expected: All tests pass.

- [ ] **Step 4: Verify git status and commit any polish**

```bash
git status
```
Ensure working tree is clean.
