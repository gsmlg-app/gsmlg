import 'package:app_secure_storage/app_secure_storage.dart';

import 'models/credentials_model.dart';

/// Service for managing API credentials in secure storage.
///
/// This service provides methods to store, retrieve, and delete
/// credentials for DNS providers (Route53, Cloudflare) using
/// the platform's secure storage mechanism.
class CredentialsService {
  CredentialsService(this._vault);

  final VaultRepository _vault;

  /// Key prefix for zone credentials in the vault.
  static const String _keyPrefix = 'zone_credentials_';

  /// Generates a vault key for a zone's credentials.
  String _credentialsKey(int zoneId) => '$_keyPrefix$zoneId';

  /// Stores Route53 credentials for a zone.
  Future<void> saveRoute53Credentials({
    required int zoneId,
    required Route53Credentials credentials,
  }) async {
    await _vault.write(
      key: _credentialsKey(zoneId),
      value: credentials.encode(),
    );
  }

  /// Stores Cloudflare credentials for a zone.
  Future<void> saveCloudflareCredentials({
    required int zoneId,
    required CloudflareCredentials credentials,
  }) async {
    await _vault.write(
      key: _credentialsKey(zoneId),
      value: credentials.encode(),
    );
  }

  /// Stores raw encoded credentials for a zone.
  Future<void> saveCredentials({
    required int zoneId,
    required String encodedCredentials,
  }) async {
    await _vault.write(
      key: _credentialsKey(zoneId),
      value: encodedCredentials,
    );
  }

  /// Retrieves Route53 credentials for a zone.
  ///
  /// Returns null if no credentials are stored for the zone.
  Future<Route53Credentials?> getRoute53Credentials(int zoneId) async {
    final encoded = await _vault.read(key: _credentialsKey(zoneId));
    if (encoded == null) return null;
    return Route53Credentials.decode(encoded);
  }

  /// Retrieves Cloudflare credentials for a zone.
  ///
  /// Returns null if no credentials are stored for the zone.
  Future<CloudflareCredentials?> getCloudflareCredentials(int zoneId) async {
    final encoded = await _vault.read(key: _credentialsKey(zoneId));
    if (encoded == null) return null;
    return CloudflareCredentials.decode(encoded);
  }

  /// Retrieves raw encoded credentials for a zone.
  ///
  /// Returns null if no credentials are stored for the zone.
  Future<String?> getCredentials(int zoneId) async {
    return _vault.read(key: _credentialsKey(zoneId));
  }

  /// Deletes credentials for a zone.
  Future<void> deleteCredentials(int zoneId) async {
    await _vault.delete(key: _credentialsKey(zoneId));
  }

  /// Checks if credentials exist for a zone.
  Future<bool> hasCredentials(int zoneId) async {
    return _vault.containsKey(key: _credentialsKey(zoneId));
  }
}
