import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'vault_repository.dart';

/// Implementation of [VaultRepository] using flutter_secure_storage.
///
/// This implementation provides secure storage using platform-native
/// mechanisms:
/// - iOS/macOS: Keychain Services
/// - Android: platform-native encrypted storage
/// - Linux: libsecret
/// - Windows: Windows Credential Manager
/// - Web: Uses encrypted local storage (less secure than native platforms)
class SecureStorageVaultRepository implements VaultRepository {
  SecureStorageVaultRepository({
    FlutterSecureStorage? storage,
    FlutterSecureStorage? legacyMacOsStorage,
    this.namespace,
  }) : _storage = storage ?? _createDefaultStorage(),
       _legacyMacOsStorage =
           legacyMacOsStorage ??
           (storage == null
               ? _createDefaultStorage(usesDataProtectionKeychain: true)
               : null);

  /// Creates default FlutterSecureStorage with platform-specific options.
  static FlutterSecureStorage _createDefaultStorage({
    bool usesDataProtectionKeychain = false,
  }) {
    return FlutterSecureStorage(
      aOptions: AndroidOptions(
        // Keep the legacy Android namespace so existing stored secrets remain
        // readable after flutter_secure_storage upgrades.
        // ignore: deprecated_member_use
        sharedPreferencesName: 'gsmlg_secure_prefs',
        preferencesKeyPrefix: 'gsmlg_',
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
        accountName: 'gsmlg_vault',
      ),
      mOptions: GsmlgMacOsOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
        accountName: 'gsmlg_vault',
        // The macOS data-protection keychain requires Keychain Sharing
        // entitlements. Standard Keychain storage avoids errSecMissingEntitlement
        // for local/ad-hoc builds while still using the platform Keychain.
        usesDataProtectionKeychain: usesDataProtectionKeychain,
      ),
      lOptions: LinuxOptions(),
      wOptions: WindowsOptions(),
    );
  }

  final FlutterSecureStorage _storage;
  final FlutterSecureStorage? _legacyMacOsStorage;
  Future<void> _mutationQueue = Future.value();

  /// Optional namespace prefix for keys to avoid collisions.
  final String? namespace;

  static const String _vaultStoreKey = '__vault_store__';

  /// Returns the namespaced key if a namespace is set.
  String _prefixedKey(String key) {
    if (namespace != null && namespace!.isNotEmpty) {
      return '${namespace}_$key';
    }
    return key;
  }

  String get _prefixedVaultStoreKey => _prefixedKey(_vaultStoreKey);

  @override
  Future<void> write({required String key, required String value}) async {
    await _withSerializedMutation(() async {
      final values = await _readVaultValues();
      values[key] = value;
      await _writeVaultValues(values);
      await _deleteLegacyValue(_prefixedKey(key));
    });
  }

  @override
  Future<String?> read({required String key}) async {
    final values = await _readVaultValues();
    if (values.containsKey(key)) return values[key];

    final prefixedKey = _prefixedKey(key);
    final value = await _readLegacyValue(prefixedKey);
    if (value == null) return null;

    await _withSerializedMutation(() async {
      final latestValues = await _readVaultValues();
      latestValues[key] = value;
      await _writeVaultValues(latestValues);
      await _deleteLegacyValue(prefixedKey);
    });
    return value;
  }

  @override
  Future<void> delete({required String key}) async {
    await _withSerializedMutation(() async {
      final values = await _readVaultValues();
      values.remove(key);
      await _writeVaultValues(values);
      await _deleteLegacyValue(_prefixedKey(key));
    });
  }

  @override
  Future<bool> containsKey({required String key}) async {
    final values = await _readVaultValues();
    if (values.containsKey(key)) return true;

    final prefixedKey = _prefixedKey(key);
    if (await _storage.containsKey(key: prefixedKey)) return true;
    return _containsLegacyMacOsValue(prefixedKey);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.delete(key: _prefixedVaultStoreKey);
    if (namespace != null && namespace!.isNotEmpty) {
      // Only delete keys with our namespace prefix
      final all = await _storage.readAll();
      for (final key in all.keys) {
        if (key.startsWith('${namespace}_') && key != _prefixedVaultStoreKey) {
          await _storage.delete(key: key);
        }
      }
    } else {
      await _storage.deleteAll();
    }
    await _deleteAllLegacyMacOsValues();
  }

  @override
  Future<Map<String, String>> readAll() async {
    final values = await _readVaultValues();
    final legacyValues = await _readLegacyValues();
    if (legacyValues.isEmpty) return values;

    final mergedValues = {...legacyValues, ...values};
    await _withSerializedMutation(() async {
      await _writeVaultValues(mergedValues);
      await _deleteLegacyValues(legacyValues.keys);
    });
    return mergedValues;
  }

  Future<T> _withSerializedMutation<T>(Future<T> Function() action) {
    final result = _mutationQueue.then((_) => action());
    _mutationQueue = result.then<void>((_) {}, onError: (_) {});
    return result;
  }

  Future<Map<String, String>> _readVaultValues() async {
    final raw = await _storage.read(key: _prefixedVaultStoreKey);
    if (raw == null || raw.isEmpty) return <String, String>{};

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Secure vault data is not a JSON object.');
    }

    return decoded.map((key, value) {
      if (value is! String) {
        throw const FormatException('Secure vault values must be strings.');
      }
      return MapEntry(key, value);
    });
  }

  Future<void> _writeVaultValues(Map<String, String> values) {
    return _storage.write(
      key: _prefixedVaultStoreKey,
      value: jsonEncode(values),
    );
  }

  Future<String?> _readLegacyValue(String prefixedKey) async {
    final value = await _storage.read(key: prefixedKey);
    if (value != null) return value;
    return _readLegacyMacOsValue(prefixedKey);
  }

  Future<Map<String, String>> _readLegacyValues() async {
    final all = await _storage.readAll();
    final values = <String, String>{};

    if (namespace != null && namespace!.isNotEmpty) {
      // Only return keys with our namespace prefix, stripped of prefix
      final prefix = '${namespace}_';
      values.addEntries(
        all.entries
            .where(
              (e) =>
                  e.key.startsWith(prefix) && e.key != _prefixedVaultStoreKey,
            )
            .map((e) => MapEntry(e.key.substring(prefix.length), e.value)),
      );
    } else {
      values.addEntries(
        all.entries.where((e) => e.key != _prefixedVaultStoreKey),
      );
    }

    values.addAll(await _readLegacyMacOsValues());
    return values;
  }

  Future<void> _deleteLegacyValue(String prefixedKey) async {
    if (prefixedKey != _prefixedVaultStoreKey) {
      await _storage.delete(key: prefixedKey);
    }
    await _deleteLegacyMacOsValue(prefixedKey);
  }

  Future<void> _deleteLegacyValues(Iterable<String> keys) async {
    for (final key in keys) {
      await _deleteLegacyValue(_prefixedKey(key));
    }
  }

  Future<String?> _readLegacyMacOsValue(String prefixedKey) async {
    final legacyStorage = _legacyMacOsStorage;
    if (legacyStorage == null) return null;

    try {
      return await legacyStorage.read(key: prefixedKey);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, String>> _readLegacyMacOsValues() async {
    final legacyStorage = _legacyMacOsStorage;
    if (legacyStorage == null) return const <String, String>{};

    try {
      final all = await legacyStorage.readAll();
      if (namespace != null && namespace!.isNotEmpty) {
        final prefix = '${namespace}_';
        return Map.fromEntries(
          all.entries
              .where(
                (e) =>
                    e.key.startsWith(prefix) && e.key != _prefixedVaultStoreKey,
              )
              .map((e) => MapEntry(e.key.substring(prefix.length), e.value)),
        );
      }
      return Map.fromEntries(
        all.entries.where((e) => e.key != _prefixedVaultStoreKey),
      );
    } catch (_) {
      return const <String, String>{};
    }
  }

  Future<bool> _containsLegacyMacOsValue(String prefixedKey) async {
    final legacyStorage = _legacyMacOsStorage;
    if (legacyStorage == null) return false;

    try {
      return await legacyStorage.containsKey(key: prefixedKey);
    } catch (_) {
      return false;
    }
  }

  Future<void> _deleteLegacyMacOsValue(String prefixedKey) async {
    final legacyStorage = _legacyMacOsStorage;
    if (legacyStorage == null) return;

    try {
      await legacyStorage.delete(key: prefixedKey);
    } catch (_) {
      // Legacy data-protection keychain access can fail without entitlements.
    }
  }

  Future<void> _deleteAllLegacyMacOsValues() async {
    final legacyStorage = _legacyMacOsStorage;
    if (legacyStorage == null) return;

    try {
      if (namespace == null || namespace!.isEmpty) {
        await legacyStorage.deleteAll();
        return;
      }

      final all = await legacyStorage.readAll();
      for (final key in all.keys) {
        if (key.startsWith('${namespace}_')) {
          await legacyStorage.delete(key: key);
        }
      }
    } catch (_) {
      // Legacy data-protection keychain access can fail without entitlements.
    }
  }
}

class GsmlgMacOsOptions extends MacOsOptions {
  const GsmlgMacOsOptions({
    super.accountName,
    super.groupId,
    super.accessibility,
    super.synchronizable,
    super.label,
    super.description,
    super.comment,
    super.isInvisible,
    super.isNegative,
    super.creationDate,
    super.lastModifiedDate,
    super.resultLimit,
    super.shouldReturnPersistentReference,
    super.authenticationUIBehavior,
    super.accessControlFlags,
    super.usesDataProtectionKeychain,
    super.useSecureEnclave,
  });

  @override
  Map<String, String> toMap() {
    return {
      ...super.toMap(),
      // flutter_secure_storage_darwin 0.2.0 reads this older key spelling.
      'useDataProtectionKeyChain': '$usesDataProtectionKeychain',
    };
  }
}
