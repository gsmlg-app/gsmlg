import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_chat/app_chat.dart';
import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:chat_bloc/chat_bloc.dart';
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

    setUp(() async {
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
    });

    tearDown(() async {
      await gemmaModelBloc.close();
      await accountsBloc.close();
      await database.close();
      await preferences.clear();
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
            ],
            child: const MaterialApp(home: ModelManagementScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Gemma 4 E4B IT (Default)'));
      await tester.pumpAndSettle();

      expect(find.text('Download Model'), findsOneWidget);
      expect(find.text('Add Local GGUF File'), findsOneWidget);
      expect(find.text('Download from Hugging Face'), findsOneWidget);
    });
  });
}

class _FakeGemmaRepository extends GemmaRepository {
  @override
  Future<List<String>> listInstalledModels() async => const [];
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
