import 'dart:convert';
import 'dart:math';

import 'package:app_database/app_database.dart';
import 'package:app_security/app_security.dart';
import 'package:drift/drift.dart';

import 'secure_storage_vault_repository.dart';
import 'vault_repository.dart';

/// Keeps SSH secrets in the platform vault and opaque references in SQLite.
class SshCredentialRepository {
  SshCredentialRepository(this.database, {VaultRepository? vault})
    : _vault = vault ?? SecureStorageVaultRepository(namespace: 'ssh');

  final AppDatabase database;
  final VaultRepository _vault;
  final _random = Random.secure();
  static final _pendingByDatabase = Expando<Future<void>>();

  static const _prefix = 'vault:ssh:';

  Future<T> _run<T>(Future<T> Function() operation) {
    final pending = _pendingByDatabase[database] ?? Future<void>.value();
    final result = pending.then((_) => operation());
    final tail = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace stackTrace) {},
    );
    _pendingByDatabase[database] = tail;
    tail.then<void>((_) {
      if (identical(_pendingByDatabase[database], tail)) {
        _pendingByDatabase[database] = null;
      }
    });
    return result;
  }

  bool _isReference(String? value) => value?.startsWith(_prefix) ?? false;

  Future<String?> _store(String? value, List<String> written) async {
    if (value == null) return null;
    final token = base64Url.encode(
      List<int>.generate(24, (_) => _random.nextInt(256)),
    );
    final reference = '$_prefix$token';
    written.add(reference);
    await _vault.write(key: reference, value: value);
    return reference;
  }

  Future<void> _deleteReference(String? reference) async {
    if (!_isReference(reference)) return;
    try {
      await _vault.delete(key: reference!);
    } catch (_) {
      // A failed cleanup must not destroy the still-referenced credential.
    }
  }

  Future<T> _persist<T>(Future<T> Function(List<String>) operation) async {
    final written = <String>[];
    try {
      await database.customStatement('PRAGMA secure_delete = ON');
      return await database.transaction(() => operation(written));
    } catch (_) {
      for (final reference in written) {
        await _deleteReference(reference);
      }
      rethrow;
    }
  }

  Future<String?> _readStored(String? reference) async {
    if (reference == null) return null;
    if (!_isReference(reference)) {
      throw StateError('SSH credential has not been migrated');
    }
    final secret = await _vault.read(key: reference);
    if (secret == null) {
      throw StateError('SSH credential is missing from vault');
    }
    return secret;
  }

  String? _legacyPrivateKey(String? content, String? salt) {
    if (content == null || salt == null || content.startsWith('-----BEGIN ')) {
      return content;
    }
    try {
      final bytes = base64.decode(content);
      if (bytes.isEmpty || bytes.length % 16 != 0) return content;
    } on FormatException {
      return content;
    }
    return AesHelper('Web Terminal').decrypt64WithSalt(content, salt);
  }

  Future<SshHost> _migrateHost(SshHost row) async {
    if ((row.password == null || _isReference(row.password)) &&
        row.salt == null) {
      return row;
    }
    return _persist((written) async {
      final reference = _isReference(row.password)
          ? row.password
          : await _store(row.password, written);
      await (database.update(
        database.sshHosts,
      )..where((table) => table.id.equals(row.id))).write(
        SshHostsCompanion(password: Value(reference), salt: const Value(null)),
      );
      return row.copyWith(password: Value(reference), salt: const Value(null));
    });
  }

  Future<SshKey> _migrateKey(SshKey row) async {
    if ((row.content == null || _isReference(row.content)) &&
        (row.password == null || _isReference(row.password)) &&
        row.salt == null) {
      return row;
    }
    return _persist((written) async {
      final content = _isReference(row.content)
          ? row.content
          : await _store(_legacyPrivateKey(row.content, row.salt), written);
      final password = _isReference(row.password)
          ? row.password
          : await _store(row.password, written);
      await (database.update(
        database.sshKeys,
      )..where((table) => table.id.equals(row.id))).write(
        SshKeysCompanion(
          content: Value(content),
          password: Value(password),
          salt: const Value(null),
        ),
      );
      return row.copyWith(
        content: Value(content),
        password: Value(password),
        salt: const Value(null),
      );
    });
  }

  Future<void> migrateHosts() => _run(() async {
    for (final row in await database.select(database.sshHosts).get()) {
      await _migrateHost(row);
    }
  });

  Future<void> migrateKeys() => _run(() async {
    for (final row in await database.select(database.sshKeys).get()) {
      await _migrateKey(row);
    }
  });

  Future<String?> readHostPassword(SshHost host) => _run(() async {
    final row = await (database.select(
      database.sshHosts,
    )..where((table) => table.id.equals(host.id))).getSingle();
    return _readStored((await _migrateHost(row)).password);
  });

  Future<String> readPrivateKey(SshKey key) => _run(() async {
    final row = await (database.select(
      database.sshKeys,
    )..where((table) => table.id.equals(key.id))).getSingle();
    final content = await _readStored((await _migrateKey(row)).content);
    if (content == null) throw StateError('SSH private key is missing');
    return content;
  });

  Future<String?> readKeyPassphrase(SshKey key) => _run(() async {
    final row = await (database.select(
      database.sshKeys,
    )..where((table) => table.id.equals(key.id))).getSingle();
    return _readStored((await _migrateKey(row)).password);
  });

  Future<int> addHost(SshHostsCompanion host) => _run(
    () => _persist((written) async {
      final reference = await _store(host.password.value, written);
      return database
          .into(database.sshHosts)
          .insert(
            host.copyWith(password: Value(reference), salt: const Value(null)),
          );
    }),
  );

  Future<void> updateHost(int id, SshHostsCompanion changes) => _run(() async {
    final current = await (database.select(
      database.sshHosts,
    )..where((table) => table.id.equals(id))).getSingle();
    final password = changes.password.value;
    final preserved = password == null || password.isEmpty
        ? await _migrateHost(current)
        : current;
    await _persist((written) async {
      final reference = password == null || password.isEmpty
          ? preserved.password
          : await _store(password, written);
      await (database.update(
        database.sshHosts,
      )..where((table) => table.id.equals(id))).write(
        changes.copyWith(password: Value(reference), salt: const Value(null)),
      );
    });
    if (password != null && password.isNotEmpty) {
      await _deleteReference(current.password);
    }
  });

  Future<int> addKey(SshKeysCompanion key) => _run(
    () => _persist((written) async {
      final content = await _store(key.content.value, written);
      final password = await _store(key.password.value, written);
      return database
          .into(database.sshKeys)
          .insert(
            key.copyWith(
              content: Value(content),
              password: Value(password),
              salt: const Value(null),
            ),
          );
    }),
  );

  Future<void> deleteHost(SshHost host) => _run(() async {
    final query = database.select(database.sshHosts)
      ..where((table) => table.id.equals(host.id));
    final current = await query.getSingleOrNull();
    if (current == null) throw Exception('Failed to delete ssh host');
    await database.customStatement('PRAGMA secure_delete = ON');
    await (database.delete(
      database.sshHosts,
    )..where((table) => table.id.equals(host.id))).go();
    await _deleteReference(current.password);
  });

  Future<void> deleteKey(SshKey key) => _run(() async {
    final query = database.select(database.sshKeys)
      ..where((table) => table.id.equals(key.id));
    final current = await query.getSingleOrNull();
    if (current == null) throw Exception('Failed to delete ssh key');
    await database.customStatement('PRAGMA secure_delete = ON');
    await (database.delete(
      database.sshKeys,
    )..where((table) => table.id.equals(key.id))).go();
    await _deleteReference(current.content);
    await _deleteReference(current.password);
  });
}
