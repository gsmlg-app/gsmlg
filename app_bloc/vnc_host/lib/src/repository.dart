import 'dart:convert';
import 'dart:math';

import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:drift/drift.dart';

/// Persists saved VNC host metadata in [AppDatabase] and secrets in
/// [VaultRepository].
class VncHostRepository {
  VncHostRepository({required this.database, required this.vault});

  final AppDatabase database;
  final VaultRepository vault;
  final _random = Random.secure();

  static final _pendingByDatabase = Expando<Future<void>>();

  /// Builds the vault key for host [id], optionally suffixed with a unique
  /// version [token].
  static String passwordKey(int id, {String? token}) =>
      token == null ? 'vnc_host:$id:password' : 'vnc_host:$id:password:$token';

  String _nextPasswordKey(int id) {
    final token = base64UrlEncode(
      List<int>.generate(16, (_) => _random.nextInt(256)),
    ).replaceAll('=', '');
    return passwordKey(id, token: token);
  }

  Future<T> _run<T>(Future<T> Function() operation) {
    final pending = _pendingByDatabase[database] ?? Future<void>.value();
    final result = pending.then((_) => operation());
    final tail = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    _pendingByDatabase[database] = tail;
    tail.then<void>((_) {
      if (identical(_pendingByDatabase[database], tail)) {
        _pendingByDatabase[database] = null;
      }
    });
    return result;
  }

  Future<void> _deleteVaultKeySafely(String? key) async {
    if (key == null) return;
    try {
      await vault.delete(key: key);
    } catch (_) {
      // Swallow vault cleanup errors after DB mutations commit or roll back.
    }
  }

  /// Loads saved hosts ordered by most recently connected (nulls last), then
  /// creation time descending and name ascending.
  Future<List<VncHost>> loadHosts() => _run(() {
    return (database.select(database.vncHosts)..orderBy([
          (t) => OrderingTerm(
            expression: t.lastConnectedAt,
            mode: OrderingMode.desc,
            nulls: NullsOrder.last,
          ),
          (t) => OrderingTerm.desc(t.createdAt),
          (t) => OrderingTerm.asc(t.name),
        ]))
        .get();
  });

  /// Inserts a new VNC host, storing any non-empty [password] in [vault] under
  /// a unique versioned key. Rolls back the database insert and cleans up any
  /// newly written vault key if persistence fails.
  Future<VncHost> addHost({
    required String name,
    required String host,
    int port = 5900,
    VncHostAuthType authType = VncHostAuthType.auto,
    String? username,
    String? password,
    int? sshHostId,
    bool viewOnly = false,
  }) => _run(() async {
    final id = await database
        .into(database.vncHosts)
        .insert(
          VncHostsCompanion.insert(
            name: name,
            host: host,
            port: Value(port),
            authType: Value(authType.value),
            username: Value(username),
            sshHostId: Value(sshHostId),
            viewOnly: Value(viewOnly),
          ),
        );

    if (password != null && password.isNotEmpty) {
      final key = _nextPasswordKey(id);
      var wroteVault = false;
      try {
        await vault.write(key: key, value: password);
        wroteVault = true;
        await (database.update(database.vncHosts)
              ..where((t) => t.id.equals(id)))
            .write(VncHostsCompanion(passwordRef: Value(key)));
      } catch (_) {
        try {
          await (database.delete(
            database.vncHosts,
          )..where((t) => t.id.equals(id))).go();
        } catch (_) {}
        if (wroteVault) {
          await _deleteVaultKeySafely(key);
        }
        rethrow;
      }
    }

    return (database.select(
      database.vncHosts,
    )..where((t) => t.id.equals(id))).getSingle();
  });

  /// Updates an existing VNC host atomically with respect to vault credentials.
  ///
  /// - Throws [ArgumentError] if [clearPassword] is true and a non-empty
  ///   [password] is also provided.
  /// - Preserves the existing `passwordRef` when [password] is null/empty and
  ///   [clearPassword] is false.
  /// - Removes the vault entry after committing `passwordRef = null` when
  ///   [clearPassword] is true.
  /// - Writes a new unique versioned key to [vault] before updating the DB row
  ///   when a non-empty [password] is provided; deletes the old key only after
  ///   the DB update succeeds, and cleans up only the new key on DB failure so
  ///   the existing secret remains intact.
  Future<VncHost> updateHost(
    int id, {
    required String name,
    required String host,
    int port = 5900,
    VncHostAuthType authType = VncHostAuthType.auto,
    String? username,
    String? password,
    bool clearPassword = false,
    int? sshHostId,
    bool viewOnly = false,
  }) => _run(() async {
    if (clearPassword && password != null && password.isNotEmpty) {
      throw ArgumentError(
        'Cannot specify both clearPassword=true and a non-empty password.',
      );
    }

    final existing = await (database.select(
      database.vncHosts,
    )..where((t) => t.id.equals(id))).getSingle();

    String? nextPasswordRef = existing.passwordRef;
    String? newVaultKey;
    String? oldVaultKeyToDelete;

    if (clearPassword) {
      oldVaultKeyToDelete = existing.passwordRef;
      nextPasswordRef = null;
    } else if (password != null && password.isNotEmpty) {
      newVaultKey = _nextPasswordKey(id);
      await vault.write(key: newVaultKey, value: password);
      oldVaultKeyToDelete = existing.passwordRef;
      nextPasswordRef = newVaultKey;
    }

    try {
      await (database.update(
        database.vncHosts,
      )..where((t) => t.id.equals(id))).write(
        VncHostsCompanion(
          name: Value(name),
          host: Value(host),
          port: Value(port),
          authType: Value(authType.value),
          username: Value(username),
          passwordRef: Value(nextPasswordRef),
          sshHostId: Value(sshHostId),
          viewOnly: Value(viewOnly),
        ),
      );
    } catch (_) {
      await _deleteVaultKeySafely(newVaultKey);
      rethrow;
    }

    await _deleteVaultKeySafely(oldVaultKeyToDelete);

    return (database.select(
      database.vncHosts,
    )..where((t) => t.id.equals(id))).getSingle();
  });

  /// Deletes the host row from SQLite first, then removes the latest
  /// associated secret from [vault]. Fetches the current DB row before
  /// deleting so stale [VncHost] snapshots still clean up the vault entry.
  Future<void> deleteHost(VncHost host) => _run(() async {
    final current = await (database.select(
      database.vncHosts,
    )..where((t) => t.id.equals(host.id))).getSingleOrNull();

    await (database.delete(
      database.vncHosts,
    )..where((t) => t.id.equals(host.id))).go();

    final ref = current?.passwordRef ?? host.passwordRef;
    await _deleteVaultKeySafely(ref);
  });

  /// Records the current timestamp as `lastConnectedAt` for [id].
  Future<void> markConnected(int id) => _run(() async {
    await (database.update(database.vncHosts)..where((t) => t.id.equals(id)))
        .write(VncHostsCompanion(lastConnectedAt: Value(DateTime.now())));
  });

  /// Reads the stored password for [host] from [vault], or returns `null` if
  /// no password reference is set.
  Future<String?> readPassword(VncHost host) async {
    final ref = host.passwordRef;
    if (ref == null) {
      return null;
    }
    return vault.read(key: ref);
  }
}
