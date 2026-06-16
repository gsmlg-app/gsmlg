import 'dart:io';

import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';
import 'package:gsmlg/screens/toolbox/tts_dataset/tts_dataset_project_screen.dart';
import 'package:gsmlg/screens/toolbox/tts_dataset/tts_dataset_screen.dart';
import 'package:path/path.dart' as p;
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

    testWidgets('shows only project list controls on the dataset screen', (
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
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Create project'), findsNothing);
      expect(find.text('Training text'), findsNothing);
      expect(find.text('Validate'), findsNothing);
      expect(find.text('Export ZIP'), findsNothing);
    });

    testWidgets('FAB opens a two-field create project form', (tester) async {
      await tester.pumpWidget(
        RepositoryProvider<TtsDatasetRepository>.value(
          value: repository,
          child: BlocProvider<TtsDatasetBloc>.value(
            value: bloc,
            child: _localizedApp(const TtsDatasetScreen()),
          ),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Create project'), findsAtLeastNWidgets(1));
      expect(find.text('Project name'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English (US)'), findsOneWidget);
      expect(find.text('Chinese (Mandarin)'), findsOneWidget);
      expect(find.text('Speaker'), findsNothing);
      expect(find.text('License'), findsNothing);
    });

    testWidgets('creates a project and keeps the root screen list-only', (
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

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create project').last);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();

      expect(find.text('My voice'), findsOneWidget);
      expect(find.text('Training text'), findsNothing);
      expect(find.text('Record audio'), findsNothing);
    });

    testWidgets('opens a project screen with prompt recording actions', (
      tester,
    ) async {
      final detail = await repository.createProject(
        name: 'My voice',
        targetProfile: TtsDatasetTargetProfiles.qwen3Tts12HzRaw,
        language: 'English (US)',
        speakerDisplayName: 'My voice',
        datasetLicense: 'private',
        consentStatus: ConsentStatus.granted,
        rootPath: '/tmp/my_voice',
        defaultNoiseReductionMode: NoiseReductionMode.medium,
        starterPrompts: englishStarterPrompts,
      );
      final router = _ttsDatasetRouter(detail.project.id);

      await tester.pumpWidget(
        RepositoryProvider<TtsDatasetRepository>.value(
          value: repository,
          child: BlocProvider<TtsDatasetBloc>.value(
            value: bloc,
            child: _localizedRouterApp(router),
          ),
        ),
      );

      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('My voice'));
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();
      expect(bloc.state.selectedProject?.project.id, detail.project.id);

      expect(find.byType(TtsDatasetProjectScreen), findsOneWidget);
      expect(find.text('Training text'), findsOneWidget);
      expect(
        find.text('She said she would be here by noon.'),
        findsAtLeastNWidgets(1),
      );
      expect(find.byTooltip('Record audio'), findsWidgets);
      expect(find.byTooltip('Clear recording'), findsWidgets);
      expect(find.byTooltip('Play recording'), findsWidgets);
    });

    testWidgets('plays recorded audio through the project audio player', (
      tester,
    ) async {
      final tempDir = Directory.systemTemp.createTempSync(
        'tts_dataset_playback_test_',
      );
      addTearDown(() => tempDir.delete(recursive: true));
      final projectRoot = Directory(p.join(tempDir.path, 'project'));
      Directory(p.join(projectRoot.path, 'wavs')).createSync(recursive: true);
      final wavFile = File(p.join(projectRoot.path, 'wavs', 'utt000001.wav'));
      wavFile.writeAsBytesSync(_tinyWavBytes);
      final detail = await repository.createProject(
        name: 'My voice',
        targetProfile: TtsDatasetTargetProfiles.qwen3Tts12HzRaw,
        language: 'English (US)',
        speakerDisplayName: 'My voice',
        datasetLicense: 'private',
        consentStatus: ConsentStatus.granted,
        rootPath: projectRoot.path,
        defaultNoiseReductionMode: NoiseReductionMode.medium,
        starterPrompts: englishStarterPrompts,
      );
      await repository.addManualClip(
        projectId: detail.project.id,
        speakerId: detail.speaker.id,
        promptId: detail.prompts.first.id,
        rawPath: 'wavs/utt000001.wav',
        processedPath: 'wavs/utt000001.wav',
        exportWavPath: 'wavs/utt000001.wav',
        rawText: detail.prompts.first.rawText,
        normalizedText: detail.prompts.first.normalizedText,
        language: detail.prompts.first.language,
        durationMs: 1000,
        sampleRate: 24000,
        channels: 1,
        bitDepth: 16,
        noiseReductionMode: NoiseReductionMode.medium,
        status: ClipStatus.accepted,
      );
      await repository.updatePromptStatus(
        detail.prompts.first.id,
        PromptStatus.recorded,
      );
      final playedPaths = <String>[];
      bloc.add(TtsDatasetOpenProject(projectId: detail.project.id));
      await _waitForSelectedProject(tester, bloc, detail.project.id);

      await tester.pumpWidget(
        RepositoryProvider<TtsDatasetRepository>.value(
          value: repository,
          child: BlocProvider<TtsDatasetBloc>.value(
            value: bloc,
            child: _localizedApp(
              TtsDatasetProjectScreen(
                projectId: detail.project.id,
                playRecording: (path) async {
                  playedPaths.add(path);
                  return true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byTooltip('Play recording').first);
      await tester.pump();

      expect(playedPaths, [wavFile.path]);
    });

    testWidgets('removes a project from the project list', (tester) async {
      final detail = await repository.createProject(
        name: 'My voice',
        targetProfile: TtsDatasetTargetProfiles.qwen3Tts12HzRaw,
        language: 'English (US)',
        speakerDisplayName: 'My voice',
        datasetLicense: 'private',
        consentStatus: ConsentStatus.granted,
        rootPath: '/tmp/my_voice',
        defaultNoiseReductionMode: NoiseReductionMode.medium,
        starterPrompts: englishStarterPrompts,
      );

      await tester.pumpWidget(
        RepositoryProvider<TtsDatasetRepository>.value(
          value: repository,
          child: BlocProvider<TtsDatasetBloc>.value(
            value: bloc,
            child: _localizedApp(const TtsDatasetScreen()),
          ),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();

      expect(find.text('My voice'), findsOneWidget);
      expect(find.byTooltip('Remove project'), findsOneWidget);

      await tester.tap(find.byTooltip('Remove project'));
      await tester.pumpAndSettle();
      expect(find.text('Remove project'), findsAtLeastNWidgets(1));
      await tester.tap(find.text('Remove project').last);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();

      expect(find.text('My voice'), findsNothing);
      expect(find.text('No projects yet'), findsOneWidget);
      expect(await repository.loadProject(detail.project.id), isNull);
    });

    testWidgets('exports a selected project as a zip file', (tester) async {
      final tempDir = Directory.systemTemp.createTempSync(
        'tts_dataset_export_action_test_',
      );
      addTearDown(() => tempDir.delete(recursive: true));
      final projectRoot = Directory(p.join(tempDir.path, 'project'));
      Directory(p.join(projectRoot.path, 'raw')).createSync(recursive: true);
      Directory(p.join(projectRoot.path, 'wavs')).createSync(recursive: true);
      File(
        p.join(projectRoot.path, 'raw', 'utt000001_original.wav'),
      ).writeAsBytesSync(_tinyWavBytes);
      File(
        p.join(projectRoot.path, 'wavs', 'utt000001.wav'),
      ).writeAsBytesSync(_tinyWavBytes);
      final detail = await repository.createProject(
        name: 'My voice',
        targetProfile: TtsDatasetTargetProfiles.qwen3Tts12HzRaw,
        language: 'English (US)',
        speakerDisplayName: 'My voice',
        datasetLicense: 'private',
        consentStatus: ConsentStatus.granted,
        rootPath: projectRoot.path,
        defaultNoiseReductionMode: NoiseReductionMode.medium,
        starterPrompts: englishStarterPrompts,
      );
      final clip = await repository.addManualClip(
        projectId: detail.project.id,
        speakerId: detail.speaker.id,
        promptId: detail.prompts.first.id,
        rawPath: 'raw/utt000001_original.wav',
        processedPath: 'wavs/utt000001.wav',
        exportWavPath: 'wavs/utt000001.wav',
        rawText: detail.prompts.first.rawText,
        normalizedText: detail.prompts.first.normalizedText,
        language: detail.prompts.first.language,
        durationMs: 1000,
        sampleRate: 24000,
        channels: 1,
        bitDepth: 16,
        noiseReductionMode: NoiseReductionMode.medium,
        status: ClipStatus.accepted,
      );
      await repository.selectReferenceClip(detail.project.id, clip.id);
      final outputPath = p.join(tempDir.path, 'my_voice.zip');

      await tester.pumpWidget(
        RepositoryProvider<TtsDatasetRepository>.value(
          value: repository,
          child: BlocProvider<TtsDatasetBloc>.value(
            value: bloc,
            child: _localizedApp(
              TtsDatasetScreen(exportPathProvider: (_) async => outputPath),
            ),
          ),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Export ZIP'));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pumpAndSettle();

      expect(File(outputPath).existsSync(), isTrue);
      expect(bloc.state.exportResult?.outputPath, outputPath);
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

Widget _localizedRouterApp(GoRouter router) {
  return MaterialApp.router(
    localizationsDelegates: AppLocale.localizationsDelegates,
    supportedLocales: AppLocale.supportedLocales,
    routerConfig: router,
  );
}

Future<void> _waitForSelectedProject(
  WidgetTester tester,
  TtsDatasetBloc bloc,
  String projectId,
) async {
  await tester.runAsync(() async {
    for (var attempt = 0; attempt < 50; attempt++) {
      if (bloc.state.selectedProject?.project.id == projectId) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  });
  await tester.pump();
  expect(bloc.state.selectedProject?.project.id, projectId);
}

GoRouter _ttsDatasetRouter(
  String projectId, {
  TtsDatasetAudioRecorderFactory? recorderFactory,
  TtsDatasetPlayRecording? playRecording,
}) {
  return GoRouter(
    initialLocation: '/${TtsDatasetScreen.path}',
    routes: [
      GoRoute(
        name: TtsDatasetScreen.name,
        path: '/${TtsDatasetScreen.path}',
        builder: (context, state) => const TtsDatasetScreen(),
        routes: [
          GoRoute(
            name: TtsDatasetProjectScreen.name,
            path: TtsDatasetProjectScreen.path,
            builder: (context, state) => TtsDatasetProjectScreen(
              projectId: state.pathParameters['projectId'] ?? projectId,
              recorderFactory: recorderFactory,
              playRecording: playRecording,
            ),
          ),
        ],
      ),
    ],
  );
}

const _tinyWavBytes = <int>[
  0x52,
  0x49,
  0x46,
  0x46,
  0x24,
  0x00,
  0x00,
  0x00,
  0x57,
  0x41,
  0x56,
  0x45,
  0x66,
  0x6d,
  0x74,
  0x20,
  0x10,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x01,
  0x00,
  0xc0,
  0x5d,
  0x00,
  0x00,
  0x80,
  0xbb,
  0x00,
  0x00,
  0x02,
  0x00,
  0x10,
  0x00,
  0x64,
  0x61,
  0x74,
  0x61,
  0x00,
  0x00,
  0x00,
  0x00,
];
