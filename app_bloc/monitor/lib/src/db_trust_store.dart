import 'package:app_database/app_database.dart';
import 'package:monitor_bloc/src/trust_store.dart';

/// Database-backed [TrustStore] implementation that persists pinned
/// certificate fingerprints via [AppDatabase].
class DbTrustStore implements TrustStore {
  DbTrustStore(this._database);

  final AppDatabase _database;

  @override
  Future<String?> getPinnedFingerprint(String hostId) =>
      _database.getPinnedFingerprint(hostId);

  @override
  Future<void> pinFingerprint(String hostId, String fingerprint) =>
      _database.pinFingerprint(hostId, fingerprint);

  @override
  Future<void> removePinnedFingerprint(String hostId) =>
      _database.removePinnedFingerprint(hostId);
}
