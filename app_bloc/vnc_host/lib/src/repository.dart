import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:drift/drift.dart';

/// Persists saved VNC host metadata in [AppDatabase] and secrets in
/// [VaultRepository].
class VncHostRepository {
  const VncHostRepository({required this.database, required this.vault});

  final AppDatabase database;
  final VaultRepository vault;

  static String passwordKey(int id) => 'vnc_host:$id:password';

  /// Loads saved hosts ordered by most recently connected (nulls last), then
  /// creation time descending and name ascending.
  Future<List<VncHost>> loadHosts() {
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
  }

  /// Inserts a new VNC host, storing any non-empty [password] in [vault] under
  /// `passwordKey(id)`. Rolls back the database insert if vault persistence
  /// fails so the database and vault stay consistent.
  Future<VncHost> addHost({
    required String name,
    required String host,
    int port = 5900,
    VncHostAuthType authType = VncHostAuthType.auto,
    String? username,
    String? password,
    int? sshHostId,
    bool viewOnly = false,
  }) async {
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
      final key = passwordKey(id);
      try {
        await vault.write(key: key, value: password);
        await (database.update(database.vncHosts)
              ..where((t) => t.id.equals(id)))
            .write(VncHostsCompanion(passwordRef: Value(key)));
      } catch (_) {
        try {
          await (database.delete(
            database.vncHosts,
          )..where((t) => t.id.equals(id))).go();
        } catch (_) {}
        try {
          await vault.delete(key: key);
        } catch (_) {}
        rethrow;
      }
    }

    return (database.select(
      database.vncHosts,
    )..where((t) => t.id.equals(id))).getSingle();
  }

  /// Updates an existing VNC host.
  ///
  /// - Preserves the existing `passwordRef` when [password] is null/empty and
  ///   [clearPassword] is false.
  /// - Removes the vault entry and clears `passwordRef` when [clearPassword]
  ///   is true.
  /// - Writes [password] to [vault] at `passwordKey(id)` when a non-empty
  ///   [password] is provided and [clearPassword] is false.
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
  }) async {
    final existing = await (database.select(
      database.vncHosts,
    )..where((t) => t.id.equals(id))).getSingle();

    String? nextPasswordRef = existing.passwordRef;
    String? keyToDeleteAfterUpdate;
    var wroteNewVaultKey = false;

    if (clearPassword) {
      keyToDeleteAfterUpdate = existing.passwordRef;
      nextPasswordRef = null;
    } else if (password != null && password.isNotEmpty) {
      final key = passwordKey(id);
      await vault.write(key: key, value: password);
      wroteNewVaultKey = existing.passwordRef == null;
      if (existing.passwordRef != null && existing.passwordRef != key) {
        keyToDeleteAfterUpdate = existing.passwordRef;
      }
      nextPasswordRef = key;
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
      if (wroteNewVaultKey && nextPasswordRef != null) {
        try {
          await vault.delete(key: nextPasswordRef);
        } catch (_) {}
      }
      rethrow;
    }

    if (keyToDeleteAfterUpdate != null) {
      try {
        await vault.delete(key: keyToDeleteAfterUpdate);
      } catch (_) {
        // Swallow vault cleanup errors after DB update has committed.
      }
    }

    return (database.select(
      database.vncHosts,
    )..where((t) => t.id.equals(id))).getSingle();
  }

  /// Deletes the host row from SQLite first, then removes any associated
  /// secret from [vault]. Vault delete errors are swallowed cleanly.
  Future<void> deleteHost(VncHost host) async {
    await (database.delete(
      database.vncHosts,
    )..where((t) => t.id.equals(host.id))).go();

    final ref = host.passwordRef;
    if (ref != null) {
      try {
        await vault.delete(key: ref);
      } catch (_) {
        // Swallow vault cleanup errors after DB row deletion.
      }
    }
  }

  /// Records the current timestamp as `lastConnectedAt` for [id].
  Future<void> markConnected(int id) async {
    await (database.update(database.vncHosts)..where((t) => t.id.equals(id)))
        .write(VncHostsCompanion(lastConnectedAt: Value(DateTime.now())));
  }

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
