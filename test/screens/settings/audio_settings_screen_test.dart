import 'dart:convert';

import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_audio/audio.dart';
import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:audio_bloc/audio_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/settings/audio_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences preferences;
  late AudioSettingsBloc audioSettingsBloc;
  late _AccountsBloc accountsBloc;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    audioSettingsBloc = AudioSettingsBloc(preferences: preferences);
    accountsBloc = _AccountsBloc();
  });

  tearDown(() async {
    await audioSettingsBloc.close();
    await accountsBloc.close();
  });

  testWidgets('renders AudioSettingsScreen with Backplane defaults', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pump(tester, audioSettingsBloc, accountsBloc);

    expect(find.byType(AudioSettingsScreen), findsOneWidget);
    expect(find.text('Audio Settings'), findsWidgets);
    expect(find.text('Backplane (Default)'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'https://backplane.gsmlg.net/v1'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(TextField, 'minimax-audio/speech-2.8-turbo'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(DropdownButton<String>, 'alloy'),
      findsOneWidget,
    );
    expect(find.byType(Slider), findsOneWidget);
    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.value, 1.0);
    expect(
      find.widgetWithText(TextField, 'minimax-audio/asr-1.0'),
      findsOneWidget,
    );
    expect(find.byType(DropdownButton<int?>), findsOneWidget);
  });

  testWidgets(
    'switching provider, updating fields, tapping Save updates AudioSettingsBloc',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pump(tester, audioSettingsBloc, accountsBloc);

      // Switch provider to customOpenAi
      final providerPicker = find.byType(DropdownButton<AudioProviderType>);
      await tester.tap(providerPicker);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Custom OpenAI-Compatible').last);
      await tester.pumpAndSettle();

      // Update Base URL
      final urlField = find.widgetWithText(
        TextField,
        'https://backplane.gsmlg.net/v1',
      );
      await tester.enterText(urlField, 'https://custom-openai.example.com/v1');

      // Toggle dummy token and verify service account dropdown is hidden
      final dummySwitch = find.byType(Switch);
      expect(find.byType(DropdownButton<int?>), findsOneWidget);
      await tester.tap(dummySwitch);
      await tester.pumpAndSettle();
      expect(find.byType(DropdownButton<int?>), findsNothing);

      // Update TTS model
      final ttsModelField = find.widgetWithText(
        TextField,
        'minimax-audio/speech-2.8-turbo',
      );
      await tester.enterText(ttsModelField, 'tts-1-hd');

      // Update TTS voice via dropdown
      final voicePicker = find.widgetWithText(DropdownButton<String>, 'alloy');
      await tester.tap(voicePicker);
      await tester.pumpAndSettle();
      await tester.tap(find.text('echo').last);
      await tester.pumpAndSettle();

      // Update ASR model
      final asrModelField = find.widgetWithText(
        TextField,
        'minimax-audio/asr-1.0',
      );
      await tester.enterText(asrModelField, 'whisper-large');

      // Update ASR language
      final asrLanguageField = find.widgetWithText(
        TextField,
        'Language Code (e.g. en, zh)',
      );
      if (asrLanguageField.evaluate().isNotEmpty) {
        await tester.enterText(asrLanguageField, 'en');
      }

      // Tap Save Settings
      await tester.tap(find.text('Save Settings'));
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();

      final saved = audioSettingsBloc.state.settings;
      expect(saved.providerType, AudioProviderType.customOpenAi);
      expect(saved.baseUrl, 'https://custom-openai.example.com/v1');
      expect(saved.useDummyToken, isTrue);
      expect(saved.ttsModel, 'tts-1-hd');
      expect(saved.ttsVoice, 'echo');
      expect(saved.asrModel, 'whisper-large');
      if (asrLanguageField.evaluate().isNotEmpty) {
        expect(saved.asrLanguage, 'en');
      }
      expect(
        AudioSettingsBloc.readSettings(preferences).baseUrl,
        'https://custom-openai.example.com/v1',
      );
      expect(AudioSettingsBloc.readSettings(preferences).useDummyToken, isTrue);
    },
  );

  testWidgets('tapping Reset restores Backplane defaults', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const customSettings = AudioSettings(
      providerType: AudioProviderType.customOpenAi,
      baseUrl: 'https://custom-openai.example.com/v1',
      ttsModel: 'custom-tts',
      ttsVoice: 'nova',
      asrModel: 'custom-whisper',
    );
    await preferences.setString(
      AudioSettingsBloc.preferencesKey,
      jsonEncode(customSettings.toJson()),
    );

    audioSettingsBloc.add(const AudioSettingsLoad());
    await _pump(tester, audioSettingsBloc, accountsBloc);

    expect(find.text('Custom OpenAI-Compatible'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'https://custom-openai.example.com/v1'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextField, 'custom-tts'), findsOneWidget);
    expect(find.widgetWithText(DropdownButton<String>, 'nova'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'custom-whisper'), findsOneWidget);

    // Tap Reset to Backplane Defaults
    await tester.tap(find.text('Reset to Backplane Defaults'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();

    expect(audioSettingsBloc.state.settings, const AudioSettings());
    expect(AudioSettingsBloc.readSettings(preferences), const AudioSettings());
    expect(find.text('Backplane (Default)'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'https://backplane.gsmlg.net/v1'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(TextField, 'minimax-audio/speech-2.8-turbo'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(DropdownButton<String>, 'alloy'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(TextField, 'minimax-audio/asr-1.0'),
      findsOneWidget,
    );
  });

  testWidgets('supports custom stored voice in dropdown', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const customSettings = AudioSettings(ttsVoice: 'custom-voice');
    await preferences.setString(
      AudioSettingsBloc.preferencesKey,
      jsonEncode(customSettings.toJson()),
    );

    audioSettingsBloc.add(const AudioSettingsLoad());
    await _pump(tester, audioSettingsBloc, accountsBloc);

    expect(
      find.widgetWithText(DropdownButton<String>, 'custom-voice'),
      findsOneWidget,
    );
  });
}

Future<void> _pump(
  WidgetTester tester,
  AudioSettingsBloc audioSettingsBloc,
  AccountsBloc accountsBloc,
) async {
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AudioSettingsBloc>.value(value: audioSettingsBloc),
        BlocProvider<AccountsBloc>.value(value: accountsBloc),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocale.localizationsDelegates,
        supportedLocales: AppLocale.supportedLocales,
        home: const AudioSettingsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _AccountsBloc extends Bloc<AccountsEvent, AccountsState>
    implements AccountsBloc {
  _AccountsBloc([List<ServiceAccountTableData> accounts = const []])
    : super(AccountsLoaded(accounts: accounts));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
