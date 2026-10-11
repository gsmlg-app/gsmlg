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
        emitsInOrder([
          const AudioSettingsState(status: AudioSettingsStatus.loading),
          const AudioSettingsState(
            settings: AudioSettings(),
            status: AudioSettingsStatus.ready,
          ),
        ]),
      );
      await bloc.close();
    });

    test(
      'saves and persists settings to SharedPreferences with key audio_service_settings',
      () async {
        final bloc = AudioSettingsBloc(preferences: prefs);
        const newSettings = AudioSettings(
          providerType: AudioProviderType.customOpenAi,
          baseUrl: 'https://example.com/v1',
        );
        bloc.add(const AudioSettingsSave(newSettings));
        await expectLater(
          bloc.stream,
          emits(
            const AudioSettingsState(
              settings: newSettings,
              status: AudioSettingsStatus.ready,
            ),
          ),
        );
        expect(
          prefs.getString(AudioSettingsBloc.preferencesKey),
          jsonEncode(newSettings.toJson()),
        );
        expect(AudioSettingsBloc.preferencesKey, 'audio_service_settings');
        await bloc.close();
      },
    );

    test(
      'resets to Backplane defaults with AudioSettingsResetToBackplane',
      () async {
        const customSettings = AudioSettings(
          providerType: AudioProviderType.customOpenAi,
          baseUrl: 'https://example.com/v1',
          ttsModel: 'tts-1-hd',
        );
        await prefs.setString(
          AudioSettingsBloc.preferencesKey,
          jsonEncode(customSettings.toJson()),
        );

        final bloc = AudioSettingsBloc(preferences: prefs);
        bloc.add(const AudioSettingsResetToBackplane());
        await expectLater(
          bloc.stream,
          emits(
            const AudioSettingsState(
              settings: AudioSettings(),
              status: AudioSettingsStatus.ready,
            ),
          ),
        );
        expect(
          prefs.getString(AudioSettingsBloc.preferencesKey),
          jsonEncode(const AudioSettings().toJson()),
        );
        await bloc.close();
      },
    );

    group('readSettings', () {
      test('gracefully handles missing or corrupted JSON', () {
        // Missing (empty prefs)
        expect(AudioSettingsBloc.readSettings(prefs), const AudioSettings());

        // Corrupted JSON
        prefs.setString(AudioSettingsBloc.preferencesKey, 'not-valid-json{[');
        expect(AudioSettingsBloc.readSettings(prefs), const AudioSettings());

        // Empty string
        prefs.setString(AudioSettingsBloc.preferencesKey, '');
        expect(AudioSettingsBloc.readSettings(prefs), const AudioSettings());

        // Valid JSON
        const valid = AudioSettings(
          providerType: AudioProviderType.customOpenAi,
          baseUrl: 'https://custom.api/v1',
          ttsSpeed: 1.5,
        );
        prefs.setString(
          AudioSettingsBloc.preferencesKey,
          jsonEncode(valid.toJson()),
        );
        expect(AudioSettingsBloc.readSettings(prefs), valid);
      });
    });
  });
}
