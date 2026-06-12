import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';
import 'package:gsmlg/screens/toolbox/tts_dataset/tts_dataset_screen.dart';
import 'package:tts_dataset/tts_dataset.dart';
import 'package:tts_dataset_bloc/tts_dataset_bloc.dart';

void main() {
  group('TtsDatasetScreen', () {
    late AppDatabase database;
    late TtsDatasetRepository repository;
    late TtsDatasetBloc bloc;

    setUp(() {
      database = AppDatabase.forTesting();
      repository = TtsDatasetRepository(database);
      bloc = TtsDatasetBloc(repository: repository);
    });

    tearDown(() async {
      await bloc.close();
      await database.close();
    });

    testWidgets('toolbox includes a TTS Dataset tile', (tester) async {
      await tester.pumpWidget(_localizedApp(const ToolboxScreen()));

      expect(find.text('TTS Dataset'), findsOneWidget);
    });

    testWidgets('renders project creation, validation, and export controls', (
      tester,
    ) async {
      await tester.pumpWidget(
        RepositoryProvider<TtsDatasetRepository>.value(
          value: repository,
          child: BlocProvider<TtsDatasetBloc>.value(
            value: bloc,
            child: _localizedApp(const TtsDatasetScreen()),
          ),
        ),
      );

      expect(find.byType(TtsDatasetScreen), findsOneWidget);
      expect(find.text('TTS Dataset'), findsAtLeastNWidgets(1));
      expect(find.text('Create project'), findsOneWidget);
      expect(find.text('Validate'), findsOneWidget);
      expect(find.text('Export ZIP'), findsOneWidget);
    });
  });
}

Widget _localizedApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocale.localizationsDelegates,
    supportedLocales: AppLocale.supportedLocales,
    home: child,
  );
}
