// ignore_for_file: implementation_imports

import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_chat/app_chat.dart';
import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_picker/src/platform/file_picker_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/settings/model_management_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ModelManagementScreen', () {
    late AppDatabase database;
    late SharedPreferences preferences;
    late AccountsBloc accountsBloc;
    late GemmaModelBloc gemmaModelBloc;
    late ChatSettingsBloc chatSettingsBloc;
    late FilePickerPlatform previousFilePicker;

    setUp(() async {
      previousFilePicker = FilePickerPlatform.instance;
      FilePickerPlatform.instance = _RecordingFilePicker(null);
      SharedPreferences.setMockInitialValues({});
      preferences = await SharedPreferences.getInstance();
      database = AppDatabase.forTesting();
      accountsBloc = AccountsBloc(
        database: database,
        vault: _MemoryVaultRepository(),
      );
      gemmaModelBloc = GemmaModelBloc(
        repository: _FakeGemmaRepository(),
        preferences: preferences,
      );
      chatSettingsBloc = ChatSettingsBloc(
        repository: ChatStorageRepository(database),
        preferences: preferences,
      );
    });

    tearDown(() async {
      await chatSettingsBloc.close();
      await gemmaModelBloc.close();
      await accountsBloc.close();
      await database.close();
      await preferences.clear();
      FilePickerPlatform.instance = previousFilePicker;
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('download dialog offers adding a local GGUF file', (
      tester,
    ) async {
      await _withTargetPlatform(TargetPlatform.macOS, () async {
        await _pumpScreen(
          tester,
          preferences: preferences,
          accountsBloc: accountsBloc,
          gemmaModelBloc: gemmaModelBloc,
          chatSettingsBloc: chatSettingsBloc,
        );

        await tester.tap(find.text('Gemma 4 E2B IT (Default)'));
        await tester.pumpAndSettle();

        expect(find.text('Download Model'), findsOneWidget);
        expect(find.text('Add Local GGUF File'), findsOneWidget);
        expect(find.text('Download from Hugging Face'), findsOneWidget);
      });
    });

    testWidgets('uses unfiltered Android picker for local LiteRT-LM files', (
      tester,
    ) async {
      final filePicker = _RecordingFilePicker(null);
      FilePickerPlatform.instance = filePicker;
      await _withTargetPlatform(TargetPlatform.android, () async {
        await _pumpScreen(
          tester,
          preferences: preferences,
          accountsBloc: accountsBloc,
          gemmaModelBloc: gemmaModelBloc,
          chatSettingsBloc: chatSettingsBloc,
        );

        await tester.tap(find.text('Gemma 4 E2B IT (Default)'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add Local LiteRT-LM File'));
        await tester.pumpAndSettle();

        expect(filePicker.type, FileType.any);
        expect(filePicker.allowedExtensions, isNull);
      });
    });

    testWidgets('waits for dialog close before opening macOS file picker', (
      tester,
    ) async {
      final dialogOpenAtPick = <bool>[];
      final filePicker = _RecordingFilePicker(
        null,
        onPick: () {
          dialogOpenAtPick.add(
            find.text('Download Model').evaluate().isNotEmpty,
          );
        },
      );
      FilePickerPlatform.instance = filePicker;

      await _withTargetPlatform(TargetPlatform.macOS, () async {
        await _pumpScreen(
          tester,
          preferences: preferences,
          accountsBloc: accountsBloc,
          gemmaModelBloc: gemmaModelBloc,
          chatSettingsBloc: chatSettingsBloc,
        );

        await tester.tap(find.text('Gemma 4 E2B IT (Default)'));
        await tester.pumpAndSettle();
        expect(find.text('Download Model'), findsOneWidget);

        await tester.tap(find.text('Add Local GGUF File'));
        await tester.pump();
        expect(dialogOpenAtPick, isEmpty);

        await tester.pumpAndSettle();
        expect(dialogOpenAtPick, [false]);
        expect(filePicker.type, FileType.custom);
        expect(filePicker.allowedExtensions, ['gguf']);
      });
    });

    testWidgets('uses Android LiteRT-LM labels in model settings', (
      tester,
    ) async {
      await _withTargetPlatform(TargetPlatform.android, () async {
        await _pumpScreen(
          tester,
          preferences: preferences,
          accountsBloc: accountsBloc,
          gemmaModelBloc: gemmaModelBloc,
          chatSettingsBloc: chatSettingsBloc,
        );

        expect(
          find.textContaining('LiteRT-LM from Hugging Face'),
          findsWidgets,
        );
        expect(
          find.textContaining('litert-community/gemma-4-E2B-it-litert-lm'),
          findsOneWidget,
        );
        expect(find.textContaining('Q4_K_M GGUF'), findsNothing);
        expect(find.text('2.4 GB'), findsOneWidget);

        await tester.tap(find.text('Gemma 4 E2B IT (Default)'));
        await tester.pumpAndSettle();

        expect(find.text('Format: LiteRT-LM'), findsOneWidget);
        expect(find.text('Add Local LiteRT-LM File'), findsOneWidget);
        expect(find.text('Add Local GGUF File'), findsNothing);
      });
    });

    testWidgets('uses Android runtime setting instead of llama.cpp backend', (
      tester,
    ) async {
      await _withTargetPlatform(TargetPlatform.android, () async {
        await _pumpScreen(
          tester,
          preferences: preferences,
          accountsBloc: accountsBloc,
          gemmaModelBloc: gemmaModelBloc,
          chatSettingsBloc: chatSettingsBloc,
        );
        final runtimeTile = find.text('Runtime');
        await tester.scrollUntilVisible(
          runtimeTile,
          200,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.pumpAndSettle();

        expect(find.text('Runtime'), findsOneWidget);
        expect(find.text('LiteRT-LM'), findsOneWidget);
        expect(find.text('Android LiteRT-LM inference.'), findsOneWidget);
        expect(find.text('Backend'), findsNothing);
        expect(find.text('CPU-only inference.'), findsNothing);
      });
    });

    testWidgets('local model settings can select llama.cpp backend', (
      tester,
    ) async {
      await _withTargetPlatform(TargetPlatform.macOS, () async {
        await _pumpScreen(
          tester,
          preferences: preferences,
          accountsBloc: accountsBloc,
          gemmaModelBloc: gemmaModelBloc,
          chatSettingsBloc: chatSettingsBloc,
        );
        final backendTile = find.text('Backend');
        await tester.scrollUntilVisible(
          backendTile,
          200,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.pumpAndSettle();

        expect(find.text('Inference Settings'), findsOneWidget);
        expect(find.text('Backend'), findsOneWidget);
        expect(
          find.text(
            chatSettingsBloc.state.config
                .withSupportedBackendForCurrentPlatform()
                .backend
                .displayName,
          ),
          findsOneWidget,
        );

        await tester.tap(find.text('Backend'));
        await tester.pumpAndSettle();

        final supportedBackends = supportedGemmaBackendsForCurrentPlatform();
        for (final backend in supportedBackends) {
          expect(
            find.widgetWithText(
              RadioListTile<GemmaBackend>,
              backend.displayName,
            ),
            findsOneWidget,
          );
        }
        for (final backend in GemmaBackend.values.where(
          (backend) => !supportedBackends.contains(backend),
        )) {
          expect(
            find.widgetWithText(
              RadioListTile<GemmaBackend>,
              backend.displayName,
            ),
            findsNothing,
          );
        }

        await tester.tap(
          find.widgetWithText(RadioListTile<GemmaBackend>, 'CPU'),
        );
        await tester.pumpAndSettle();

        expect(chatSettingsBloc.state.config.backend, GemmaBackend.cpu);
      });
    });
  });
}

class _FakeGemmaRepository extends GemmaRepository {
  @override
  Future<List<String>> listInstalledModels() async => const [];
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required SharedPreferences preferences,
  required AccountsBloc accountsBloc,
  required GemmaModelBloc gemmaModelBloc,
  required ChatSettingsBloc chatSettingsBloc,
}) async {
  await tester.pumpWidget(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SharedPreferences>.value(value: preferences),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AccountsBloc>.value(value: accountsBloc),
          BlocProvider<GemmaModelBloc>.value(value: gemmaModelBloc),
          BlocProvider<ChatSettingsBloc>.value(value: chatSettingsBloc),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: const ModelManagementScreen(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _withTargetPlatform(
  TargetPlatform platform,
  Future<void> Function() body,
) async {
  final previousPlatform = debugDefaultTargetPlatformOverride;
  debugDefaultTargetPlatformOverride = platform;
  try {
    await body();
  } finally {
    debugDefaultTargetPlatformOverride = previousPlatform;
  }
}

class _RecordingFilePicker extends FilePickerPlatform {
  _RecordingFilePicker(this.result, {this.onPick});

  final FilePickerResult? result;
  final VoidCallback? onPick;
  FileType? type;
  List<String>? allowedExtensions;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
    bool cancelUploadOnWindowBlur = true,
  }) async {
    onPick?.call();
    this.type = type;
    this.allowedExtensions = allowedExtensions;
    return result;
  }
}

class _MemoryVaultRepository implements VaultRepository {
  final _values = <String, String>{};

  @override
  Future<bool> containsKey({required String key}) async {
    return _values.containsKey(key);
  }

  @override
  Future<void> delete({required String key}) async {
    _values.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _values.clear();
  }

  @override
  Future<String?> read({required String key}) async {
    return _values[key];
  }

  @override
  Future<Map<String, String>> readAll() async {
    return Map.unmodifiable(_values);
  }

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }
}
