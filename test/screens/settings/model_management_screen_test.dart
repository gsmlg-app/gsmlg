import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_chat/app_chat.dart';
import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:file_picker/file_picker.dart';
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
    late FilePicker previousFilePicker;

    setUp(() async {
      previousFilePicker = FilePicker.platform;
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
      FilePicker.platform = previousFilePicker;
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('download dialog offers adding a local GGUF file', (
      tester,
    ) async {
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
            child: const MaterialApp(home: ModelManagementScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Gemma 4 E2B IT (Default)'));
      await tester.pumpAndSettle();

      expect(find.text('Download Model'), findsOneWidget);
      expect(find.text('Add Local GGUF File'), findsOneWidget);
      expect(find.text('Download from Hugging Face'), findsOneWidget);
    });

    testWidgets('uses unfiltered Android picker for local GGUF files', (
      tester,
    ) async {
      final filePicker = _RecordingFilePicker(null);
      FilePicker.platform = filePicker;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

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
            child: const MaterialApp(home: ModelManagementScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Gemma 4 E2B IT (Default)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add Local GGUF File'));
      await tester.pump();

      expect(filePicker.type, FileType.any);
      expect(filePicker.allowedExtensions, isNull);
    });

    testWidgets('local model settings can select llama.cpp backend', (
      tester,
    ) async {
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
            child: const MaterialApp(home: ModelManagementScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Backend'), 200);
      await tester.pumpAndSettle();

      expect(find.text('Inference Settings'), findsOneWidget);
      expect(find.text('Backend'), findsOneWidget);
      expect(
        find.text(defaultGemmaBackendForCurrentPlatform().displayName),
        findsOneWidget,
      );

      await tester.tap(find.text('Backend'));
      await tester.pumpAndSettle();

      final supportedBackends = supportedGemmaBackendsForCurrentPlatform();
      for (final backend in supportedBackends) {
        expect(
          find.widgetWithText(RadioListTile<GemmaBackend>, backend.displayName),
          findsOneWidget,
        );
      }
      for (final backend in GemmaBackend.values.where(
        (backend) => !supportedBackends.contains(backend),
      )) {
        expect(
          find.widgetWithText(RadioListTile<GemmaBackend>, backend.displayName),
          findsNothing,
        );
      }

      await tester.tap(find.widgetWithText(RadioListTile<GemmaBackend>, 'CPU'));
      await tester.pumpAndSettle();

      expect(chatSettingsBloc.state.config.backend, GemmaBackend.cpu);
    });
  });
}

class _FakeGemmaRepository extends GemmaRepository {
  @override
  Future<List<String>> listInstalledModels() async => const [];
}

class _RecordingFilePicker extends FilePicker {
  _RecordingFilePicker(this.result);

  final FilePickerResult? result;
  FileType? type;
  List<String>? allowedExtensions;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
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
