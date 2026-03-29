/// Interface for storing/loading pinned cert fingerprints.
abstract class TrustStore {
  Future<String?> getPinnedFingerprint(String hostId);
  Future<void> pinFingerprint(String hostId, String fingerprint);
  Future<void> removePinnedFingerprint(String hostId);
}

/// In-memory implementation for M3 (will be replaced with DB-backed in M4).
class InMemoryTrustStore implements TrustStore {
  final Map<String, String> _pins = {};

  @override
  Future<String?> getPinnedFingerprint(String hostId) async => _pins[hostId];

  @override
  Future<void> pinFingerprint(String hostId, String fingerprint) async {
    _pins[hostId] = fingerprint;
  }

  @override
  Future<void> removePinnedFingerprint(String hostId) async {
    _pins.remove(hostId);
  }
}
