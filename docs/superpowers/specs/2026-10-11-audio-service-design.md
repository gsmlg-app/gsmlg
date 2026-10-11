# Audio Service and OpenAI-Compatible ASR / TTS Design

## 1. Overview
This specification details the design for adding an **Audio Service** into the GSMLG application. The service provides Text-to-Speech (TTS) synthesis and Automatic Speech Recognition (ASR / transcription) capabilities powered by OpenAI-compatible audio APIs. **Backplane** is supported out-of-the-box as the default, first-party provider alongside custom OpenAI-compatible endpoints.

## 2. Architecture & Directory Layout

The implementation follows the established monorepo architecture (`AGENTS.md`):

```
app_lib/
  audio/                          # Core data models, serialization, and HTTP repository
    lib/
      src/
        models/
          audio_settings.dart     # AudioSettings model & AudioProviderType enum
        repositories/
          audio_repository.dart   # OpenAiAudioRepository (TTS & ASR calls)
      audio.dart                  # Library exports
    test/
      audio_settings_test.dart
      audio_repository_test.dart
app_bloc/
  audio/                          # Audio feature BLoCs
    lib/
      src/
        settings/
          bloc.dart               # AudioSettingsBloc
          event.dart
          state.dart
        service/
          bloc.dart               # AudioServiceBloc (TTS & ASR lifecycle)
          event.dart
          state.dart
      audio_bloc.dart             # Library exports
    test/
      audio_settings_bloc_test.dart
      audio_service_bloc_test.dart
lib/
  screens/
    service/
      audio/
        audio_screen.dart         # Audio Service Screen (TTS and ASR tabs)
    settings/
      audio_settings_screen.dart  # Audio Settings Screen
test/
  screens/
    service/
      audio_screen_test.dart      # UI tests for Audio Service Screen
    settings/
      audio_settings_screen_test.dart # UI tests for Audio Settings Screen
```

## 3. Data Layer (`app_lib/audio`)

### 3.1 Models (`audio_settings.dart`)
- **`AudioProviderType`**:
  - `backplane`: Uses `https://backplane.gsmlg.net/v1` and the configured Backplane service account.
  - `customOpenAi`: Allows custom base URL, authentication headers/token, and models.
- **`AudioSettings`**:
  - `providerType`: `AudioProviderType` (default `AudioProviderType.backplane`).
  - `baseUrl`: `String` (default `'https://backplane.gsmlg.net/v1'`).
  - `accountId`: `int?` (references `ServiceAccountTableData.id` in `app_database`).
  - `useDummyToken`: `bool` (default `false`).
  - `ttsModel`: `String` (default `'tts-1'`).
  - `ttsVoice`: `String` (default `'alloy'`). Supported standard voices: `alloy`, `echo`, `fable`, `onyx`, `nova`, `shimmer`.
  - `ttsSpeed`: `double` (default `1.0`, range `0.25` - `4.0`).
  - `ttsResponseFormat`: `String` (default `'mp3'`). Supported: `mp3`, `wav`, `opus`, `aac`, `flac`.
  - `asrModel`: `String` (default `'whisper-1'`).
  - `asrLanguage`: `String?` (optional ISO language code, e.g. `'en'`, `'zh'`).
  - Includes `toJson()`, `fromJson()`, `copyWith()`, and `defaultBackplaneSettings`.

### 3.2 Repository (`audio_repository.dart`)
- **`OpenAiAudioRepository`**:
  - Accepts `AppDatabase` and `VaultRepository` to resolve Bearer authorization tokens for `accountId`.
  - **`synthesizeSpeech(AudioSettings settings, String text, {String? model, String? voice, double? speed, String? format})`**:
    - Dispatches HTTP `POST {baseUrl}/audio/speech` with JSON body:
      ```json
      {
        "model": "tts-1",
        "input": "text",
        "voice": "alloy",
        "speed": 1.0,
        "response_format": "mp3"
      }
      ```
    - Resolves and sets `Authorization: Bearer <token>` (or omits if using dummy token without header).
    - Returns `Uint8List` representing the audio bytes.
  - **`transcribeAudio(AudioSettings settings, {List<int>? bytes, String? filename, String? filePath, String? model, String? language})`**:
    - Dispatches multipart/form-data HTTP `POST {baseUrl}/audio/transcriptions`.
    - Includes `file` field with audio data, `model` (e.g. `whisper-1`), optional `language`, and `response_format: "json"`.
    - Parses JSON response and returns transcription `String`.

## 4. State Management (`app_bloc/audio`)

### 4.1 `AudioSettingsBloc`
- **Events**:
  - `AudioSettingsLoad`: Reads settings from `SharedPreferences` (key `'audio_service_settings'`).
  - `AudioSettingsSave(AudioSettings settings)`: Validates URL and updates preferences.
  - `AudioSettingsResetToBackplane`: Restores default Backplane audio settings.
- **State**:
  - `AudioSettingsState(settings: AudioSettings, status: AudioSettingsStatus, errorMessage: String?)`

### 4.2 `AudioServiceBloc`
- **Dependencies**: `OpenAiAudioRepository`, `AudioPlayer`, `AudioRecorder` (or abstract interfaces for mockability).
- **Events**:
  - `AudioTtsSynthesize(String text, {String? voice, String? model})`: Initiates speech synthesis via repository.
  - `AudioTtsPlay()`: Plays the generated audio bytes.
  - `AudioTtsPause()`: Pauses playback.
  - `AudioTtsStop()`: Stops playback.
  - `AudioTtsClear()`: Discards generated audio.
  - `AudioAsrStartRecording()`: Requests microphone permission and begins audio capture.
  - `AudioAsrStopRecordingAndTranscribe()`: Finalizes recording and invokes transcription.
  - `AudioAsrTranscribeFile(String filePath)`: Transcribes an existing audio file.
  - `AudioAsrClear()`: Resets transcription output.
- **State**:
  - `AudioServiceState`:
    - TTS state: `ttsStatus` (`idle`, `synthesizing`, `ready`, `error`), `audioBytes`, `playbackState` (`stopped`, `playing`, `paused`), `ttsError`.
    - ASR state: `asrStatus` (`idle`, `recording`, `transcribing`, `success`, `error`), `recordingPath`, `transcription`, `asrError`.

## 5. UI & Navigation

### 5.1 Audio Service Screen (`lib/screens/service/audio/audio_screen.dart`)
- **Route**: `AudioScreen.path = 'audio'`, `AudioScreen.name = 'Audio'`. Full path `/service/audio`.
- **Navigation Header**:
  - Title: "Audio".
  - Actions: Settings button that navigates directly to `AudioSettingsScreen`.
- **View switcher**: Segmented button or tab view toggling between **TTS** and **ASR**.
- **TTS View**:
  - Large multiline text input field.
  - Voice dropdown, model input/selector, and "Synthesize" button.
  - Playback controls (Play, Pause, Stop, waveform/scrubber, and file export / save button).
- **ASR View**:
  - Dual intake: Microphone recording with visual status (recording timer/pulse) & audio file picker (`.wav`, `.mp3`, `.m4a`, `.ogg`, `.webm`).
  - Loading spinner during transcription.
  - Output display with a "Copy to Clipboard" action.

### 5.2 Audio Settings Screen (`lib/screens/settings/audio_settings_screen.dart`)
- **Route**: `AudioSettingsScreen.path = 'audio'`, `AudioSettingsScreen.name = 'AudioSettings'`. Full path `/settings/audio`.
- **Settings Sections**:
  - **Connection & Provider**: Switch between **Backplane** and **Custom OpenAI-Compatible**, Base URL field, and Service Account picker.
  - **TTS Defaults**: Model, voice, speed slider, format.
  - **ASR Defaults**: Model, language code.
  - **Actions**: Save and Reset to Backplane Defaults buttons.

### 5.3 Menu & Router Registration
- **`lib/screens/service/service_screen.dart`**:
  - Add `AppGridTile` for Audio navigating to `/service/audio`.
- **`lib/screens/service/service_routes.dart`**:
  - Register `AudioScreen` under `serviceRoutes()`.
- **`lib/screens/settings/settings_screen.dart`**:
  - Add navigation tile in Settings pointing to `AudioSettingsScreen`.
- **`lib/screens/settings/settings_routes.dart`**:
  - Register `AudioSettingsScreen` under `settingsRoutes()`.
- **`app_lib/provider/lib/src/main.dart`**:
  - Provide `OpenAiAudioRepository` in `MultiRepositoryProvider`.
  - Provide `AudioSettingsBloc` and `AudioServiceBloc` in `MultiBlocProvider`.
- **`app_lib/locale/lib/arb/app_en.arb`**:
  - Add localization strings for Audio service, TTS, ASR, and Audio settings; regenerate with `melos run gen-l10n`.

## 6. Verification & Testing
- Unit tests in `app_lib/audio/test/` for serialization and mocked HTTP requests.
- BLoC tests in `app_bloc/audio/test/` for state transitions and error recovery.
- Widget tests in `test/screens/service/audio_screen_test.dart` and `test/screens/settings/audio_settings_screen_test.dart`.
- Static analysis verification with `melos run analyze`.
