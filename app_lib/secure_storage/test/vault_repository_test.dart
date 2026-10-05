import 'dart:convert';

import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory implementation of VaultRepository for testing.
class InMemoryVaultRepository implements VaultRepository {
  final Map<String, String> _storage = {};

  @override
  Future<void> write({required String key, required String value}) async {
    _storage[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    return _storage[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return _storage.containsKey(key);
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }

  @override
  Future<Map<String, String>> readAll() async {
    return Map.from(_storage);
  }
}

void main() {
  group('VaultRepository', () {
    late VaultRepository vault;

    setUp(() {
      vault = InMemoryVaultRepository();
    });

    test('write and read a secret', () async {
      await vault.write(key: 'api_token', value: 'secret123');
      final result = await vault.read(key: 'api_token');
      expect(result, equals('secret123'));
    });

    test('read returns null for non-existent key', () async {
      final result = await vault.read(key: 'non_existent');
      expect(result, isNull);
    });

    test('write overwrites existing value', () async {
      await vault.write(key: 'token', value: 'first');
      await vault.write(key: 'token', value: 'second');
      final result = await vault.read(key: 'token');
      expect(result, equals('second'));
    });

    test('delete removes a secret', () async {
      await vault.write(key: 'to_delete', value: 'value');
      await vault.delete(key: 'to_delete');
      final result = await vault.read(key: 'to_delete');
      expect(result, isNull);
    });

    test('delete does nothing for non-existent key', () async {
      // Should not throw
      await vault.delete(key: 'non_existent');
    });

    test('containsKey returns true for existing key', () async {
      await vault.write(key: 'exists', value: 'value');
      final result = await vault.containsKey(key: 'exists');
      expect(result, isTrue);
    });

    test('containsKey returns false for non-existent key', () async {
      final result = await vault.containsKey(key: 'non_existent');
      expect(result, isFalse);
    });

    test('deleteAll clears all secrets', () async {
      await vault.write(key: 'key1', value: 'value1');
      await vault.write(key: 'key2', value: 'value2');
      await vault.deleteAll();
      expect(await vault.containsKey(key: 'key1'), isFalse);
      expect(await vault.containsKey(key: 'key2'), isFalse);
    });

    test('readAll returns all stored secrets', () async {
      await vault.write(key: 'a', value: '1');
      await vault.write(key: 'b', value: '2');
      final all = await vault.readAll();
      expect(all, equals({'a': '1', 'b': '2'}));
    });

    test('readAll returns empty map when no secrets', () async {
      final all = await vault.readAll();
      expect(all, isEmpty);
    });
  });

  group('SecureStorageVaultRepository', () {
    for (final existingStore in [false, true]) {
      test(
        'delete missing key does not mutate storage (store: $existingStore)',
        () async {
          final primaryValues = {
            if (existingStore)
              'gsmlg___vault_store__': jsonEncode({'github_pat': 'pat'}),
            'gsmlg_other_key': 'primary-secret',
          };
          final legacyValues = {'gsmlg_other_key': 'legacy-secret'};
          final primary = _MemoryFlutterSecureStorage(
            primaryValues,
            failAbsentDeletes: true,
          );
          final legacy = _MemoryFlutterSecureStorage(
            legacyValues,
            failAbsentDeletes: true,
          );
          final vault = SecureStorageVaultRepository(
            storage: primary,
            legacyMacOsStorage: legacy,
            namespace: 'gsmlg',
          );
          final before = Map<String, String>.from(primaryValues);

          await vault.delete(key: 'service_account_1');

          expect(primaryValues, before);
          expect(legacyValues, {'gsmlg_other_key': 'legacy-secret'});
          expect(primary.calls, [
            'read:gsmlg___vault_store__',
            'read:gsmlg_service_account_1',
          ]);
          expect(legacy.calls, ['read:gsmlg_service_account_1']);
        },
      );
    }

    test(
      'delete removes empty consolidated value and preserves unrelated secrets',
      () async {
        final primaryValues = {
          'gsmlg___vault_store__': jsonEncode({
            'service_account_1': '',
            'github_pat': 'pat',
          }),
          'gsmlg_other_key': 'primary-secret',
        };
        final legacyValues = {'gsmlg_other_key': 'legacy-secret'};
        final primary = _MemoryFlutterSecureStorage(primaryValues);
        final legacy = _MemoryFlutterSecureStorage(legacyValues);
        final vault = SecureStorageVaultRepository(
          storage: primary,
          legacyMacOsStorage: legacy,
          namespace: 'gsmlg',
        );

        await vault.delete(key: 'service_account_1');

        expect(_decodedVaultStore(primaryValues), {'github_pat': 'pat'});
        expect(primaryValues['gsmlg_other_key'], 'primary-secret');
        expect(legacyValues, {'gsmlg_other_key': 'legacy-secret'});
        expect(primary.calls, [
          'read:gsmlg___vault_store__',
          'write:gsmlg___vault_store__',
          'read:gsmlg_service_account_1',
        ]);
        expect(legacy.calls, ['read:gsmlg_service_account_1']);
      },
    );

    for (final legacyMacOs in [false, true]) {
      test(
        'delete removes existing empty legacy value (macOS: $legacyMacOs)',
        () async {
          final primaryValues = {
            'gsmlg___vault_store__': jsonEncode({'github_pat': 'pat'}),
          };
          final legacyValues = <String, String>{};
          final targetValues = legacyMacOs ? legacyValues : primaryValues;
          targetValues.addAll({
            'gsmlg_service_account_1': '',
            'gsmlg_other_key': 'unrelated',
          });
          final primary = _MemoryFlutterSecureStorage(primaryValues);
          final legacy = _MemoryFlutterSecureStorage(legacyValues);
          final vault = SecureStorageVaultRepository(
            storage: primary,
            legacyMacOsStorage: legacy,
            namespace: 'gsmlg',
          );

          await vault.delete(key: 'service_account_1');

          expect(targetValues.containsKey('gsmlg_service_account_1'), isFalse);
          expect(targetValues['gsmlg_other_key'], 'unrelated');
          expect(_decodedVaultStore(primaryValues), {'github_pat': 'pat'});
          expect(
            primary.calls.where((call) => call.startsWith('write:')),
            isEmpty,
          );
          expect(
            primary.calls.where((call) => call.startsWith('delete:')).toList(),
            legacyMacOs ? <String>[] : ['delete:gsmlg_service_account_1'],
          );
          expect(
            legacy.calls.where((call) => call.startsWith('delete:')).toList(),
            legacyMacOs ? ['delete:gsmlg_service_account_1'] : <String>[],
          );
        },
      );
    }

    test('delete propagates primary legacy probe failure', () async {
      final failure = _keychainFailure();
      final primary = _MemoryFlutterSecureStorage({})
        ..readErrorKey = 'gsmlg_service_account_1'
        ..readError = failure;
      final vault = SecureStorageVaultRepository(
        storage: primary,
        namespace: 'gsmlg',
      );

      await expectLater(
        vault.delete(key: 'service_account_1'),
        throwsA(same(failure)),
      );

      expect(primary.calls, [
        'read:gsmlg___vault_store__',
        'read:gsmlg_service_account_1',
      ]);
    });

    test(
      'delete propagates existing primary legacy deletion failure',
      () async {
        final primaryValues = {'gsmlg_service_account_1': 'secret'};
        final failure = _keychainFailure();
        final primary = _MemoryFlutterSecureStorage(primaryValues)
          ..deleteErrorKey = 'gsmlg_service_account_1'
          ..deleteError = failure;
        final vault = SecureStorageVaultRepository(
          storage: primary,
          namespace: 'gsmlg',
        );

        await expectLater(
          vault.delete(key: 'service_account_1'),
          throwsA(same(failure)),
        );

        expect(primaryValues, {'gsmlg_service_account_1': 'secret'});
      },
    );

    test('delete propagates consolidated write failure', () async {
      final primaryValues = {
        'gsmlg___vault_store__': jsonEncode({'service_account_1': 'secret'}),
      };
      final before = Map<String, String>.from(primaryValues);
      final failure = _keychainFailure();
      final primary = _MemoryFlutterSecureStorage(primaryValues)
        ..writeError = failure;
      final vault = SecureStorageVaultRepository(
        storage: primary,
        namespace: 'gsmlg',
      );

      await expectLater(
        vault.delete(key: 'service_account_1'),
        throwsA(same(failure)),
      );

      expect(primaryValues, before);
      expect(primary.calls, [
        'read:gsmlg___vault_store__',
        'write:gsmlg___vault_store__',
      ]);
    });

    test(
      'retains optional legacy policy for existing value deletion failures',
      () async {
        final legacyValues = {'gsmlg_service_account_1': 'secret'};
        final legacy = _MemoryFlutterSecureStorage(legacyValues)
          ..deleteErrorKey = 'gsmlg_service_account_1'
          ..deleteError = _keychainFailure();
        final vault = SecureStorageVaultRepository(
          storage: _MemoryFlutterSecureStorage({}),
          legacyMacOsStorage: legacy,
          namespace: 'gsmlg',
        );

        await vault.delete(key: 'service_account_1');

        expect(legacyValues, {'gsmlg_service_account_1': 'secret'});
        expect(legacy.calls, [
          'read:gsmlg_service_account_1',
          'delete:gsmlg_service_account_1',
        ]);
      },
    );

    test('writes secrets into one namespaced vault item', () async {
      final primaryValues = <String, String>{};
      final vault = SecureStorageVaultRepository(
        storage: _MemoryFlutterSecureStorage(primaryValues),
        legacyMacOsStorage: _MemoryFlutterSecureStorage({}),
        namespace: 'gsmlg',
      );

      await vault.write(key: 'service_account_1', value: 'secret');
      await vault.write(key: 'github_pat', value: 'pat');

      expect(primaryValues.keys, ['gsmlg___vault_store__']);
      expect(_decodedVaultStore(primaryValues), {
        'service_account_1': 'secret',
        'github_pat': 'pat',
      });
      expect(await vault.read(key: 'service_account_1'), 'secret');
      expect(await vault.readAll(), {
        'service_account_1': 'secret',
        'github_pat': 'pat',
      });
    });

    test('migrates legacy primary values on read', () async {
      final primaryValues = {'gsmlg_service_account_1': 'secret'};
      final vault = SecureStorageVaultRepository(
        storage: _MemoryFlutterSecureStorage(primaryValues),
        legacyMacOsStorage: _MemoryFlutterSecureStorage({}),
        namespace: 'gsmlg',
      );

      final value = await vault.read(key: 'service_account_1');

      expect(value, 'secret');
      expect(primaryValues.keys, ['gsmlg___vault_store__']);
      expect(_decodedVaultStore(primaryValues), {
        'service_account_1': 'secret',
      });
    });

    test('migrates legacy macOS data-protection values on read', () async {
      final primaryValues = <String, String>{};
      final legacyValues = {'gsmlg_service_account_1': 'secret'};
      final vault = SecureStorageVaultRepository(
        storage: _MemoryFlutterSecureStorage(primaryValues),
        legacyMacOsStorage: _MemoryFlutterSecureStorage(legacyValues),
        namespace: 'gsmlg',
      );

      final value = await vault.read(key: 'service_account_1');

      expect(value, 'secret');
      expect(primaryValues.keys, ['gsmlg___vault_store__']);
      expect(_decodedVaultStore(primaryValues), {
        'service_account_1': 'secret',
      });
      expect(legacyValues, isEmpty);
    });

    test('ignores legacy macOS storage failures', () async {
      final vault = SecureStorageVaultRepository(
        storage: _MemoryFlutterSecureStorage({}),
        legacyMacOsStorage: _ThrowingFlutterSecureStorage(),
        namespace: 'gsmlg',
      );

      expect(await vault.read(key: 'service_account_1'), isNull);
      expect(await vault.containsKey(key: 'service_account_1'), isFalse);
      await vault.delete(key: 'service_account_1');
      await vault.deleteAll();
    });

    test(
      'emits Darwin plugin compatibility key for data-protection option',
      () {
        final options = const GsmlgMacOsOptions(
          usesDataProtectionKeychain: false,
        ).toMap();

        expect(options['usesDataProtectionKeychain'], 'false');
        expect(options['useDataProtectionKeyChain'], 'false');
      },
    );
  });
}

Map<String, String> _decodedVaultStore(Map<String, String> values) {
  return (jsonDecode(values['gsmlg___vault_store__']!) as Map<String, dynamic>)
      .cast<String, String>();
}

PlatformException _keychainFailure() => PlatformException(
  code: 'Unexpected security result code',
  message: 'Code: -34018, Message: A required entitlement is missing.',
  details: -34018,
);

class _MemoryFlutterSecureStorage extends FlutterSecureStorage {
  _MemoryFlutterSecureStorage(this._values, {this.failAbsentDeletes = false});

  final Map<String, String> _values;
  final bool failAbsentDeletes;
  final calls = <String>[];
  String? readErrorKey;
  PlatformException? readError;
  PlatformException? writeError;
  String? deleteErrorKey;
  PlatformException? deleteError;

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    calls.add('write:$key');
    if (writeError != null) throw writeError!;
    if (value == null) {
      _values.remove(key);
    } else {
      _values[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    calls.add('read:$key');
    if (key == readErrorKey && readError != null) throw readError!;
    return _values[key];
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    calls.add('delete:$key');
    if (key == deleteErrorKey && deleteError != null) throw deleteError!;
    if (failAbsentDeletes && !_values.containsKey(key)) {
      throw _keychainFailure();
    }
    _values.remove(key);
  }

  @override
  Future<bool> containsKey({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _values.containsKey(key);
  }

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _values.clear();
  }

  @override
  Future<Map<String, String>> readAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return Map.unmodifiable(_values);
  }
}

class _ThrowingFlutterSecureStorage extends _MemoryFlutterSecureStorage {
  _ThrowingFlutterSecureStorage() : super({});

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    throw StateError('missing entitlement');
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    throw StateError('missing entitlement');
  }

  @override
  Future<bool> containsKey({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    throw StateError('missing entitlement');
  }

  @override
  Future<Map<String, String>> readAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    throw StateError('missing entitlement');
  }

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    throw StateError('missing entitlement');
  }
}
