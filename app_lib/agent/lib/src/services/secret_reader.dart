import 'package:app_secure_storage/vault_repository.dart';

/// Read-only access to stored credentials (e.g. `service_account_<id>`).
///
/// Agent isolates cannot open the platform vault; they receive a bridged
/// implementation instead.
abstract interface class SecretReader {
  Future<String?> read(String key);
}

/// Main-isolate [SecretReader] backed by the secure vault.
class VaultSecretReader implements SecretReader {
  const VaultSecretReader(this._vault);

  final VaultRepository _vault;

  @override
  Future<String?> read(String key) => _vault.read(key: key);
}
