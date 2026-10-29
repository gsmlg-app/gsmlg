import 'dart:convert';
import 'dart:typed_data';

import 'package:app_secure_storage/app_secure_storage.dart';

class SshHostKey {
  final String hostname;
  final int port;
  final String type;
  final String fingerprint;

  const SshHostKey({
    required this.hostname,
    required this.port,
    required this.type,
    required this.fingerprint,
  });
}

class SshHostKeyVerificationException implements Exception {
  final String message;

  const SshHostKeyVerificationException(this.message);

  @override
  String toString() => message;
}

class SshHostKeyMismatchException extends SshHostKeyVerificationException {
  final SshHostKey received;
  final String savedFingerprint;

  SshHostKeyMismatchException(this.received, this.savedFingerprint)
    : super(
        'SSH host key changed for ${received.hostname}:${received.port}. '
        'Saved: $savedFingerprint; received: ${received.fingerprint}. '
        'Connection refused.',
      );
}

class SshHostKeyStore {
  SshHostKeyStore({VaultRepository? vault})
    : _vault =
          vault ?? SecureStorageVaultRepository(namespace: 'ssh-host-keys');

  final VaultRepository _vault;
  final _pending = <String, Future<bool>>{};

  Future<bool> verify(
    String hostname,
    int port,
    String type,
    Uint8List sha256Fingerprint, {
    Future<bool> Function(SshHostKey key)? onFirstUse,
  }) async {
    if (sha256Fingerprint.length != 32) {
      throw const SshHostKeyVerificationException(
        'Invalid SHA-256 host fingerprint',
      );
    }
    final normalizedHost = hostname.trim().toLowerCase();
    final storageKey = base64Url.encode(
      utf8.encode(jsonEncode([normalizedHost, port])),
    );
    final hostKey = SshHostKey(
      hostname: hostname,
      port: port,
      type: type,
      fingerprint:
          'SHA256:${base64Encode(sha256Fingerprint).replaceAll('=', '')}',
    );
    final previous = _pending[storageKey];
    final verification = () async {
      if (previous != null) {
        try {
          await previous;
        } catch (_) {
          // Re-read the persisted pin after the preceding decision.
        }
      }
      final saved = await _vault.read(key: storageKey);
      final value = jsonEncode({
        'type': type,
        'fingerprint': hostKey.fingerprint,
      });
      if (saved != null) {
        if (saved == value) return true;
        final savedData = jsonDecode(saved) as Map<String, dynamic>;
        throw SshHostKeyMismatchException(
          hostKey,
          savedData['fingerprint'] as String,
        );
      }
      if (onFirstUse == null || !await onFirstUse(hostKey)) return false;
      await _vault.write(key: storageKey, value: value);
      return true;
    }();
    _pending[storageKey] = verification;
    try {
      return await verification;
    } finally {
      if (identical(_pending[storageKey], verification)) {
        _pending.remove(storageKey);
      }
    }
  }
}
