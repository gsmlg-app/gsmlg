import 'dart:async';
import 'dart:typed_data';

import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

class _Vault implements VaultRepository {
  final values = <String, String>{};

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  Future<String?> read({required String key}) async => values[key];
  @override
  Future<void> delete({required String key}) async => values.remove(key);
  @override
  Future<void> deleteAll() async => values.clear();
  @override
  Future<bool> containsKey({required String key}) async =>
      values.containsKey(key);
  @override
  Future<Map<String, String>> readAll() async => Map.of(values);
}

void main() {
  final fingerprint = Uint8List.fromList(List.filled(32, 1));
  final changedFingerprint = Uint8List.fromList(List.filled(32, 2));
  late _Vault vault;
  late SshHostKeyStore store;

  setUp(() {
    vault = _Vault();
    store = SshHostKeyStore(vault: vault);
  });

  test('unknown host requires an explicit trust decision', () async {
    expect(
      await store.verify('host.example', 22, 'ssh-ed25519', fingerprint),
      isFalse,
    );
    expect(vault.values, isEmpty);
  });

  test(
    'accepted fingerprint persists and is reused across instances',
    () async {
      var prompts = 0;
      Future<bool> confirm(SshHostKey key) async {
        prompts++;
        expect(key.fingerprint, startsWith('SHA256:'));
        return true;
      }

      expect(
        await store.verify(
          'HOST.example',
          22,
          'ssh-ed25519',
          fingerprint,
          onFirstUse: confirm,
        ),
        isTrue,
      );
      store = SshHostKeyStore(vault: vault);
      expect(
        await store.verify(
          'host.example',
          22,
          'ssh-ed25519',
          fingerprint,
          onFirstUse: confirm,
        ),
        isTrue,
      );
      expect(prompts, 1);
    },
  );

  test(
    'rejects changed keys without offering to overwrite the saved pin',
    () async {
      await store.verify(
        'host',
        22,
        'ssh-ed25519',
        fingerprint,
        onFirstUse: (_) async => true,
      );
      final original = Map.of(vault.values);
      await expectLater(
        store.verify(
          'host',
          22,
          'ssh-ed25519',
          changedFingerprint,
          onFirstUse: (_) async => fail('Must not prompt for a changed key'),
        ),
        throwsA(isA<SshHostKeyMismatchException>()),
      );
      expect(vault.values, original);
    },
  );

  test(
    'host ports have separate identities and rejected keys are not saved',
    () async {
      await store.verify(
        'host',
        22,
        'ssh-ed25519',
        fingerprint,
        onFirstUse: (_) async => true,
      );
      expect(
        await store.verify(
          'host',
          2222,
          'ssh-ed25519',
          changedFingerprint,
          onFirstUse: (_) async => false,
        ),
        isFalse,
      );
      expect(vault.values.length, 1);
    },
  );

  test(
    'simultaneous first connections cannot replace an accepted key',
    () async {
      final decision = Completer<bool>();
      final first = store.verify(
        'host',
        22,
        'ssh-ed25519',
        fingerprint,
        onFirstUse: (_) => decision.future,
      );
      final second = store.verify(
        'host',
        22,
        'ssh-ed25519',
        changedFingerprint,
        onFirstUse: (_) async => fail('Must not overwrite concurrent trust'),
      );
      final rejection = expectLater(
        second,
        throwsA(isA<SshHostKeyMismatchException>()),
      );
      decision.complete(true);
      expect(await first, isTrue);
      await rejection;
    },
  );

  test('connector without a verifier fails before opening a socket', () async {
    final connector = SSHConnector(
      const SshHost(id: 1, hostname: '127.0.0.1', port: 1, username: 'test'),
    );
    await expectLater(
      connector.createHost(),
      throwsA(isA<SshHostKeyVerificationException>()),
    );
  });
}
