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
      mOptions: MacOsOptions(
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

  /// Optional namespace prefix for keys to avoid collisions.
  final String? namespace;

  /// Returns the namespaced key if a namespace is set.
  String _prefixedKey(String key) {
    if (namespace != null && namespace!.isNotEmpty) {
      return '${namespace}_$key';
    }
    return key;
  }

  @override
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: _prefixedKey(key), value: value);
  }

  @override
  Future<String?> read({required String key}) async {
    final prefixedKey = _prefixedKey(key);
    final value = await _storage.read(key: prefixedKey);
    if (value != null) return value;
    return _readLegacyMacOsValue(prefixedKey);
  }

  @override
  Future<void> delete({required String key}) async {
    final prefixedKey = _prefixedKey(key);
    await _storage.delete(key: prefixedKey);
    await _deleteLegacyMacOsValue(prefixedKey);
  }

  @override
  Future<bool> containsKey({required String key}) async {
    final prefixedKey = _prefixedKey(key);
    if (await _storage.containsKey(key: prefixedKey)) return true;
    return _containsLegacyMacOsValue(prefixedKey);
  }

  @override
  Future<void> deleteAll() async {
    if (namespace != null && namespace!.isNotEmpty) {
      // Only delete keys with our namespace prefix
      final all = await _storage.readAll();
      for (final key in all.keys) {
        if (key.startsWith('${namespace}_')) {
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
    final all = await _storage.readAll();
    if (namespace != null && namespace!.isNotEmpty) {
      // Only return keys with our namespace prefix, stripped of prefix
      final prefix = '${namespace}_';
      return Map.fromEntries(
        all.entries
            .where((e) => e.key.startsWith(prefix))
            .map((e) => MapEntry(e.key.substring(prefix.length), e.value)),
      );
    }
    return all;
  }

  Future<String?> _readLegacyMacOsValue(String prefixedKey) async {
    final legacyStorage = _legacyMacOsStorage;
    if (legacyStorage == null) return null;

    try {
      final value = await legacyStorage.read(key: prefixedKey);
      if (value == null) return null;
      await _storage.write(key: prefixedKey, value: value);
      await _deleteLegacyMacOsValue(prefixedKey);
      return value;
    } catch (_) {
      return null;
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
