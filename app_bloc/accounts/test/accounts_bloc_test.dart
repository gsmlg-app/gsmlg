import 'dart:convert';

import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart'
    show TestDefaultBinaryMessengerBinding, TestWidgetsFlutterBinding;
import 'package:test/test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AccountsBloc', () {
    test('refresh marks accounts missing from vault', () async {
      final database = AppDatabase.forTesting();
      final vault = _MemoryVaultRepository();
      final bloc = AccountsBloc(database: database, vault: vault);
      addTearDown(bloc.close);
      addTearDown(database.close);

      final configuredId = await database
          .into(database.serviceAccountTable)
          .insert(
            ServiceAccountTableCompanion.insert(
              provider: ServiceProvider.openai,
              name: 'Configured',
            ),
          );
      final missingId = await database
          .into(database.serviceAccountTable)
          .insert(
            ServiceAccountTableCompanion.insert(
              provider: ServiceProvider.openai,
              name: 'Missing Secret',
            ),
          );
      await vault.write(key: 'service_account_$configuredId', value: 'secret');

      bloc.add(const AccountsRefresh());

      await expectLater(
        bloc.stream,
        emits(
          isA<AccountsLoaded>()
              .having((state) => state.accounts.length, 'accounts', 2)
              .having(
                (state) => state.missingSecretAccountIds,
                'missingSecretAccountIds',
                {missingId},
              ),
        ),
      );
    });

    test('load clears missing marker after secret is stored', () async {
      final database = AppDatabase.forTesting();
      final vault = _MemoryVaultRepository();
      final bloc = AccountsBloc(database: database, vault: vault);
      addTearDown(bloc.close);
      addTearDown(database.close);

      final accountId = await database
          .into(database.serviceAccountTable)
          .insert(
            ServiceAccountTableCompanion.insert(
              provider: ServiceProvider.openai,
              name: 'Backplane',
            ),
          );

      bloc.add(const AccountsLoad());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AccountsLoading>(),
          isA<AccountsLoaded>().having(
            (state) => state.missingSecretAccountIds,
            'missingSecretAccountIds',
            {accountId},
          ),
        ]),
      );

      await vault.write(key: 'service_account_$accountId', value: 'secret');
      bloc.add(const AccountsLoad());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AccountsLoading>(),
          isA<AccountsLoaded>().having(
            (state) => state.missingSecretAccountIds,
            'missingSecretAccountIds',
            isEmpty,
          ),
        ]),
      );
    });

    test(
      'does not persist account metadata when secret storage fails',
      () async {
        final database = AppDatabase.forTesting();
        final bloc = AccountsBloc(
          database: database,
          vault: _ThrowingVaultRepository(),
        );
        addTearDown(bloc.close);
        addTearDown(database.close);

        bloc.add(
          const AccountsAdd(
            provider: ServiceProvider.openai,
            name: 'Backplane',
            apiKey: 'secret',
          ),
        );

        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<AccountsLoading>(),
            isA<AccountsLoaded>()
                .having((state) => state.accounts, 'accounts', isEmpty)
                .having(
                  (state) => state.error,
                  'error',
                  contains('Failed to add account'),
                ),
          ]),
        );
        final accounts = await database
            .select(database.serviceAccountTable)
            .get();
        expect(accounts, isEmpty);
      },
    );
  });
  group('AccountsBloc with secure storage', () {
    late AppDatabase database;
    late AccountsBloc bloc;
    late _MemorySecureStorageChannel storage;

    setUp(() {
      final previousPlatform = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      storage = _MemorySecureStorageChannel();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            _MemorySecureStorageChannel.channel,
            storage.handle,
          );
      database = AppDatabase.forTesting();
      bloc = AccountsBloc(
        database: database,
        vault: SecureStorageVaultRepository(namespace: 'gsmlg'),
      );
      addTearDown(() async {
        await bloc.close();
        await database.close();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              _MemorySecureStorageChannel.channel,
              null,
            );
        debugDefaultTargetPlatformOverride = previousPlatform;
      });
    });

    for (final event in [const AccountsLoad(), const AccountsRefresh()]) {
      test(
        '${event.runtimeType} uses individual reads when readAll fails with -50',
        () async {
          final configuredId = await _insertAccount(database, 'Configured');
          final missingId = await _insertAccount(database, 'Missing');
          final emptyId = await _insertAccount(database, 'Empty');
          final whitespaceId = await _insertAccount(database, 'Whitespace');
          storage.primaryValues[_MemorySecureStorageChannel.vaultStoreKey] =
              jsonEncode({
                'service_account_$configuredId': 'configured-secret',
                'service_account_$emptyId': '',
                'service_account_$whitespaceId': ' ',
                'github_pat': 'unrelated-secret',
              });

          final loaded = await _accountEvent(bloc, event);

          expect(loaded.accounts.map((account) => account.id), [
            configuredId,
            missingId,
            emptyId,
            whitespaceId,
          ]);
          expect(loaded.missingSecretAccountIds, {missingId, emptyId});
          expect(loaded.error, isNull);
          expect(storage.calls, [
            'primary:read:${_MemorySecureStorageChannel.vaultStoreKey}',
            'primary:read:${_MemorySecureStorageChannel.vaultStoreKey}',
            'primary:read:gsmlg_service_account_$missingId',
            'legacy:read:gsmlg_service_account_$missingId',
            'primary:read:${_MemorySecureStorageChannel.vaultStoreKey}',
            'primary:read:${_MemorySecureStorageChannel.vaultStoreKey}',
          ]);
          expect(loaded.props.toString(), isNot(contains('configured-secret')));
          expect(loaded.props.toString(), isNot(contains('unrelated-secret')));
        },
      );

      test(
        '${event.runtimeType} does not access storage for an empty database',
        () async {
          final loaded = await _accountEvent(bloc, event);

          expect(loaded.accounts, isEmpty);
          expect(loaded.missingSecretAccountIds, isEmpty);
          expect(loaded.error, isNull);
          expect(storage.calls, isEmpty);
        },
      );
    }

    for (final legacyMacOs in [false, true]) {
      test(
        'migrates multiple ${legacyMacOs ? 'data-protection' : 'primary'} legacy accounts without deleting unrelated keys',
        () async {
          final firstId = await _insertAccount(database, 'First');
          final secondId = await _insertAccount(database, 'Second');
          final legacyValues = legacyMacOs
              ? storage.legacyValues
              : storage.primaryValues;
          legacyValues.addAll({
            'gsmlg_service_account_$firstId': 'first-secret',
            'gsmlg_service_account_$secondId': 'second-secret',
            'gsmlg_github_pat': 'legacy-pat',
            'other_token': 'other-secret',
          });
          storage.primaryValues[_MemorySecureStorageChannel.vaultStoreKey] =
              jsonEncode({'cloudflare_token': 'existing-secret'});

          final loaded = await _accountEvent(bloc, const AccountsLoad());

          expect(loaded.accounts.length, 2);
          expect(loaded.missingSecretAccountIds, isEmpty);
          expect(loaded.error, isNull);
          expect(
            jsonDecode(
              storage.primaryValues[_MemorySecureStorageChannel.vaultStoreKey]!,
            ),
            {
              'cloudflare_token': 'existing-secret',
              'service_account_$firstId': 'first-secret',
              'service_account_$secondId': 'second-secret',
            },
          );
          expect(legacyValues['gsmlg_github_pat'], 'legacy-pat');
          expect(legacyValues['other_token'], 'other-secret');
          expect(
            legacyValues.containsKey('gsmlg_service_account_$firstId'),
            isFalse,
          );
          expect(
            legacyValues.containsKey('gsmlg_service_account_$secondId'),
            isFalse,
          );
          expect(
            storage.calls.where((call) => call.contains(':delete:')).toList(),
            [
              '${legacyMacOs ? 'legacy' : 'primary'}:delete:gsmlg_service_account_$firstId',
              '${legacyMacOs ? 'legacy' : 'primary'}:delete:gsmlg_service_account_$secondId',
            ],
          );
          expect(
            storage.calls
                .where((call) => call.contains(':read:gsmlg_service_account_'))
                .toList(),
            [
              for (final accountId in [firstId, secondId]) ...[
                'primary:read:gsmlg_service_account_$accountId',
                if (legacyMacOs) 'legacy:read:gsmlg_service_account_$accountId',
                'primary:read:gsmlg_service_account_$accountId',
                'legacy:read:gsmlg_service_account_$accountId',
              ],
            ],
          );
          expect(
            storage.calls.any((call) => call.contains(':readAll:')),
            isFalse,
          );
        },
      );
    }

    for (final inaccessibleLegacy in [false, true]) {
      test(
        'deletes missing account without storage mutations (legacy inaccessible: $inaccessibleLegacy)',
        () async {
          final accountId = await _insertAccount(database, 'Missing');
          storage.primaryValues.addAll({
            _MemorySecureStorageChannel.vaultStoreKey: jsonEncode({
              'github_pat': 'pat',
            }),
            'gsmlg_other_key': 'primary-secret',
          });
          storage.legacyValues['gsmlg_other_key'] = 'legacy-secret';
          if (inaccessibleLegacy) {
            storage.readErrorKey = 'gsmlg_service_account_$accountId';
            storage.readErrorLegacy = true;
            storage.readError = _keychainFailure();
          }
          final beforePrimary = Map<String, String>.from(storage.primaryValues);
          final beforeLegacy = Map<String, String>.from(storage.legacyValues);
          final previous = await _accountEvent(bloc, const AccountsLoad());
          expect(previous.missingSecretAccountIds, {accountId});
          storage.calls.clear();

          final deleted = await _accountEvent(
            bloc,
            AccountsDelete(id: accountId),
          );

          expect(deleted.accounts, isEmpty);
          expect(deleted.error, isNull);
          expect(
            await database.select(database.serviceAccountTable).get(),
            isEmpty,
          );
          expect(storage.primaryValues, beforePrimary);
          expect(storage.legacyValues, beforeLegacy);
          expect(storage.calls, [
            'primary:read:${_MemorySecureStorageChannel.vaultStoreKey}',
            'primary:read:gsmlg_service_account_$accountId',
            'legacy:read:gsmlg_service_account_$accountId',
          ]);
        },
      );
    }

    test('deletes account with empty consolidated credential', () async {
      final accountId = await _insertAccount(database, 'Empty');
      storage.primaryValues[_MemorySecureStorageChannel.vaultStoreKey] =
          jsonEncode({'service_account_$accountId': '', 'github_pat': 'pat'});
      final previous = await _accountEvent(bloc, const AccountsLoad());
      expect(previous.missingSecretAccountIds, {accountId});

      final deleted = await _accountEvent(bloc, AccountsDelete(id: accountId));

      expect(deleted.accounts, isEmpty);
      expect(deleted.error, isNull);
      expect(
        await database.select(database.serviceAccountTable).get(),
        isEmpty,
      );
      expect(
        jsonDecode(
          storage.primaryValues[_MemorySecureStorageChannel.vaultStoreKey]!,
        ),
        {'github_pat': 'pat'},
      );
      expect(storage.calls.where((call) => call.contains(':delete:')), isEmpty);
    });

    test(
      'retains missing account when a primary legacy credential deletion fails',
      () async {
        final accountId = await _insertAccount(database, 'Previously Missing');
        final previous = await _accountEvent(bloc, const AccountsLoad());
        expect(previous.missingSecretAccountIds, {accountId});
        final key = 'gsmlg_service_account_$accountId';
        storage.primaryValues[key] = 'secret';
        final failure = _keychainFailure();
        storage.deleteErrorKey = key;
        storage.deleteError = failure;
        storage.calls.clear();

        final failed = await _accountEvent(bloc, AccountsDelete(id: accountId));

        expect(failed.accounts, previous.accounts);
        expect(failed.error, 'Failed to delete account: $failure');
        expect(
          (await database.select(database.serviceAccountTable).get()).single.id,
          accountId,
        );
        expect(storage.primaryValues[key], 'secret');
        expect(storage.calls, [
          'primary:read:${_MemorySecureStorageChannel.vaultStoreKey}',
          'primary:read:$key',
          'primary:delete:$key',
        ]);
      },
    );

    for (final consolidatedRead in [false, true]) {
      test(
        'retains account on primary deletion read failure (consolidated: $consolidatedRead)',
        () async {
          final accountId = await _insertAccount(database, 'Unavailable');
          final previous = await _accountEvent(bloc, const AccountsLoad());
          final key = consolidatedRead
              ? _MemorySecureStorageChannel.vaultStoreKey
              : 'gsmlg_service_account_$accountId';
          final failure = _keychainFailure();
          storage.readErrorKey = key;
          storage.readError = failure;
          storage.calls.clear();

          final failed = await _accountEvent(
            bloc,
            AccountsDelete(id: accountId),
          );

          expect(failed.accounts, previous.accounts);
          expect(failed.error, 'Failed to delete account: $failure');
          expect(
            (await database.select(database.serviceAccountTable).get())
                .single
                .id,
            accountId,
          );
          expect(storage.primaryValues, isEmpty);
          expect(storage.calls, [
            'primary:read:${_MemorySecureStorageChannel.vaultStoreKey}',
            if (!consolidatedRead) 'primary:read:$key',
          ]);
        },
      );
    }

    test(
      'retains account and consolidated credential on deletion write failure',
      () async {
        final accountId = await _insertAccount(database, 'Configured');
        final raw = jsonEncode({
          'service_account_$accountId': 'secret',
          'github_pat': 'pat',
        });
        storage.primaryValues[_MemorySecureStorageChannel.vaultStoreKey] = raw;
        final previous = await _accountEvent(bloc, const AccountsLoad());
        final failure = _keychainFailure();
        storage.writeError = failure;
        storage.calls.clear();

        final failed = await _accountEvent(bloc, AccountsDelete(id: accountId));

        expect(failed.accounts, previous.accounts);
        expect(failed.error, 'Failed to delete account: $failure');
        expect(
          (await database.select(database.serviceAccountTable).get()).single.id,
          accountId,
        );
        expect(
          storage.primaryValues[_MemorySecureStorageChannel.vaultStoreKey],
          raw,
        );
        expect(storage.calls, [
          'primary:read:${_MemorySecureStorageChannel.vaultStoreKey}',
          'primary:write:${_MemorySecureStorageChannel.vaultStoreKey}',
        ]);
      },
    );

    test('reports a genuine individual read failure on load', () async {
      final accountId = await _insertAccount(database, 'Unavailable');
      storage.readErrorKey = 'gsmlg_service_account_$accountId';
      final failure = PlatformException(
        code: '-25293',
        message: 'Access denied',
      );
      storage.readError = failure;
      final states = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AccountsLoading>(),
          isA<AccountsError>().having(
            (state) => state.message,
            'message',
            failure.toString(),
          ),
        ]),
      );

      bloc.add(const AccountsLoad());

      await states;
      expect(
        storage.calls.last,
        'primary:read:gsmlg_service_account_$accountId',
      );
      expect(storage.calls.any((call) => call.contains(':readAll:')), isFalse);
    });

    test(
      'refresh preserves prior accounts and missing markers on an individual read failure',
      () async {
        final configuredId = await _insertAccount(database, 'Configured');
        await _insertAccount(database, 'Missing');
        storage.primaryValues[_MemorySecureStorageChannel.vaultStoreKey] =
            jsonEncode({'service_account_$configuredId': 'secret'});
        final previous = await _accountEvent(bloc, const AccountsLoad());
        await _insertAccount(database, 'Not Yet Loaded');
        storage.readErrorKey = _MemorySecureStorageChannel.vaultStoreKey;
        final failure = PlatformException(
          code: '-25293',
          message: 'Access denied',
        );
        storage.readError = failure;

        final loaded = await _accountEvent(bloc, const AccountsRefresh());

        expect(loaded.accounts, previous.accounts);
        expect(
          loaded.missingSecretAccountIds,
          previous.missingSecretAccountIds,
        );
        expect(loaded.error, 'Failed to refresh accounts: $failure');
        expect(
          storage.calls.any((call) => call.contains(':readAll:')),
          isFalse,
        );
      },
    );

    test(
      'add, update, API key update and delete reload using individual reads',
      () async {
        final missingId = await _insertAccount(database, 'Missing');
        await _accountEvent(bloc, const AccountsLoad());

        final added = await _accountEvent(
          bloc,
          const AccountsAdd(
            provider: ServiceProvider.openai,
            name: 'Added',
            apiKey: 'added-secret',
          ),
        );
        expect(added.accounts.length, 2);
        expect(added.missingSecretAccountIds, {missingId});
        expect(added.error, isNull);
        final addedId = added.accounts
            .singleWhere((account) => account.name == 'Added')
            .id;
        expect(await bloc.getApiKey(addedId), 'added-secret');

        final updated = await _accountEvent(
          bloc,
          AccountsUpdate(
            id: missingId,
            name: 'Renamed',
            description: 'Updated description',
          ),
        );
        final renamed = updated.accounts.singleWhere(
          (account) => account.id == missingId,
        );
        expect(renamed.name, 'Renamed');
        expect(renamed.description, 'Updated description');
        expect(updated.missingSecretAccountIds, {missingId});
        expect(updated.error, isNull);

        final configured = await _accountEvent(
          bloc,
          AccountsUpdateApiKey(id: missingId, apiKey: 'replacement-secret'),
        );
        expect(configured.missingSecretAccountIds, isEmpty);
        expect(configured.error, isNull);
        expect(await bloc.getApiKey(missingId), 'replacement-secret');

        final deleted = await _accountEvent(bloc, AccountsDelete(id: addedId));
        expect(deleted.accounts.map((account) => account.id), [missingId]);
        expect(deleted.missingSecretAccountIds, isEmpty);
        expect(deleted.error, isNull);
        expect(await bloc.getApiKey(addedId), isNull);

        final empty = await _accountEvent(bloc, AccountsDelete(id: missingId));
        expect(empty.accounts, isEmpty);
        expect(empty.missingSecretAccountIds, isEmpty);
        expect(empty.error, isNull);
        expect(
          storage.calls.any((call) => call.contains(':readAll:')),
          isFalse,
        );
      },
    );
  });
}

Future<int> _insertAccount(AppDatabase database, String name) {
  return database
      .into(database.serviceAccountTable)
      .insert(
        ServiceAccountTableCompanion.insert(
          provider: ServiceProvider.openai,
          name: name,
        ),
      );
}

PlatformException _keychainFailure() => PlatformException(
  code: 'Unexpected security result code',
  message: 'Code: -34018, Message: A required entitlement is missing.',
  details: -34018,
);

Future<AccountsLoaded> _accountEvent(
  AccountsBloc bloc,
  AccountsEvent event,
) async {
  final nextState = bloc.stream.firstWhere(
    (state) => state is! AccountsLoading,
  );
  bloc.add(event);
  final state = await nextState;
  expect(state, isA<AccountsLoaded>());
  return state as AccountsLoaded;
}

class _MemorySecureStorageChannel {
  static const channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  static const vaultStoreKey = 'gsmlg___vault_store__';

  final primaryValues = <String, String>{};
  final legacyValues = <String, String>{};
  final calls = <String>[];
  String? readErrorKey;
  bool readErrorLegacy = false;
  PlatformException? readError;
  PlatformException? writeError;
  String? deleteErrorKey;
  PlatformException? deleteError;

  Future<Object?> handle(MethodCall call) async {
    final arguments = call.arguments as Map;
    final options = arguments['options'] as Map;
    final legacy = options['usesDataProtectionKeychain'] == 'true';
    final values = legacy ? legacyValues : primaryValues;
    final key = arguments['key'] as String?;
    calls.add('${legacy ? 'legacy' : 'primary'}:${call.method}:${key ?? ''}');

    switch (call.method) {
      case 'readAll':
        throw PlatformException(
          code: '-50',
          message: 'Unexpected security result code',
        );
      case 'read':
        if (legacy == readErrorLegacy &&
            key == readErrorKey &&
            readError != null) {
          throw readError!;
        }
        return values[key];
      case 'write':
        if (!legacy && writeError != null) throw writeError!;
        values[key!] = arguments['value'] as String;
        return null;
      case 'delete':
        if (!legacy && key == deleteErrorKey && deleteError != null) {
          throw deleteError!;
        }
        if (!values.containsKey(key)) throw _keychainFailure();
        values.remove(key);
        return null;
      default:
        throw StateError('Unexpected storage method: ${call.method}');
    }
  }
}

class _MemoryVaultRepository implements VaultRepository {
  final Map<String, String> _storage = {};

  @override
  Future<bool> containsKey({required String key}) async {
    return _storage.containsKey(key);
  }

  @override
  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }

  @override
  Future<String?> read({required String key}) async {
    return _storage[key];
  }

  @override
  Future<Map<String, String>> readAll() async {
    return Map.unmodifiable(_storage);
  }

  @override
  Future<void> write({required String key, required String value}) async {
    _storage[key] = value;
  }
}

class _ThrowingVaultRepository implements VaultRepository {
  @override
  Future<bool> containsKey({required String key}) async => false;

  @override
  Future<void> delete({required String key}) async {}

  @override
  Future<void> deleteAll() async {}

  @override
  Future<String?> read({required String key}) async => null;

  @override
  Future<Map<String, String>> readAll() async => const {};

  @override
  Future<void> write({required String key, required String value}) {
    throw StateError('secret storage unavailable');
  }
}
