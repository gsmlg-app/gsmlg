import 'package:app_audio/audio.dart';
import 'package:app_database/app_database.dart';
import 'package:app_provider/app_provider.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:audio_bloc/audio_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('MainProvider injects audio repository and blocs', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final database = AppDatabase.forTesting();
    addTearDown(database.close);

    OpenAiAudioRepository? audioRepo;
    AudioSettingsBloc? settingsBloc;
    AudioServiceBloc? serviceBloc;

    await tester.pumpWidget(
      MainProvider(
        sharedPrefs: preferences,
        database: database,
        vault: _UnusedVault(),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              audioRepo = context.read<OpenAiAudioRepository>();
              settingsBloc = context.read<AudioSettingsBloc>();
              serviceBloc = context.read<AudioServiceBloc>();
              return const Scaffold(body: SizedBox());
            },
          ),
        ),
      ),
    );

    expect(audioRepo, isNotNull);
    expect(settingsBloc, isNotNull);
    expect(serviceBloc, isNotNull);
    expect(serviceBloc!.settingsProvider(), const AudioSettings());
  });
}

class _UnusedVault implements VaultRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('Audio provider test must not access secure storage');
}
