import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:app_security/app_security.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

class _Vault implements VaultRepository {
  final values = <String, String>{};
  int writes = 0;
  int? failWrite;

  @override
  Future<void> write({required String key, required String value}) async {
    writes++;
    if (writes == failWrite) throw StateError('Vault unavailable');
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
  late AppDatabase database;
  late _Vault vault;
  late SshCredentialRepository credentials;

  setUp(() {
    database = AppDatabase.forTesting();
    vault = _Vault();
    credentials = SshCredentialRepository(database, vault: vault);
  });

  tearDown(() => database.close());

  test('new host password is stored only in vault', () async {
    await credentials.addHost(
      SshHostsCompanion.insert(password: const Value('secret')),
    );
    final row = await database.select(database.sshHosts).getSingle();
    expect(row.password, startsWith('vault:ssh:'));
    expect(row.salt, isNull);
    expect(vault.values.values, contains('secret'));
    expect(await credentials.readHostPassword(row), 'secret');
  });

  test(
    'new private key and passphrase have independent opaque references',
    () async {
      await credentials.addKey(
        SshKeysCompanion.insert(
          content: const Value('private-key'),
          password: const Value('passphrase'),
        ),
      );
      final row = await database.select(database.sshKeys).getSingle();
      expect(row.content, startsWith('vault:ssh:'));
      expect(row.password, startsWith('vault:ssh:'));
      expect(row.content, isNot(row.password));
      expect(row.salt, isNull);
      expect(await credentials.readPrivateKey(row), 'private-key');
      expect(await credentials.readKeyPassphrase(row), 'passphrase');
    },
  );

  test('legacy host and encrypted key migration is idempotent', () async {
    const pem =
        '-----BEGIN PRIVATE KEY-----\nlegacy\n-----END PRIVATE KEY-----';
    final ciphertext = AesHelper('Web Terminal').encrypt64WithSalt(pem, 'salt');
    await database
        .into(database.sshHosts)
        .insert(
          SshHostsCompanion.insert(password: const Value('legacy-password')),
        );
    await database
        .into(database.sshKeys)
        .insert(
          SshKeysCompanion.insert(
            content: Value(ciphertext),
            password: const Value('legacy-passphrase'),
            salt: const Value('salt'),
          ),
        );
    final legacyHost = await database.select(database.sshHosts).getSingle();
    final legacyKey = await database.select(database.sshKeys).getSingle();
    await credentials.migrateHosts();
    await credentials.migrateKeys();
    final writes = vault.writes;
    await credentials.migrateHosts();
    await credentials.migrateKeys();
    expect(await credentials.readHostPassword(legacyHost), 'legacy-password');
    expect(await credentials.readPrivateKey(legacyKey), pem);
    expect(await credentials.readKeyPassphrase(legacyKey), 'legacy-passphrase');
    expect(vault.writes, writes);
    final migrated = await database.select(database.sshKeys).getSingle();
    expect(migrated.content, isNot(ciphertext));
    expect(migrated.salt, isNull);
  });

  test('partial vault failure retains legacy row and supports retry', () async {
    await database
        .into(database.sshKeys)
        .insert(
          SshKeysCompanion.insert(
            content: const Value('legacy-key'),
            password: const Value('legacy-passphrase'),
          ),
        );
    vault.failWrite = 2;
    await expectLater(credentials.migrateKeys(), throwsStateError);
    var row = await database.select(database.sshKeys).getSingle();
    expect(row.content, 'legacy-key');
    expect(row.password, 'legacy-passphrase');
    expect(vault.values, isEmpty);

    vault.failWrite = null;
    await credentials.migrateKeys();
    row = await database.select(database.sshKeys).getSingle();
    expect(await credentials.readPrivateKey(row), 'legacy-key');
    expect(await credentials.readKeyPassphrase(row), 'legacy-passphrase');
  });

  test('SQL failure after vault write preserves legacy credential', () async {
    await database
        .into(database.sshHosts)
        .insert(
          SshHostsCompanion.insert(password: const Value('legacy-password')),
        );
    await database.customStatement('''
CREATE TRIGGER reject_ssh_update BEFORE UPDATE ON ssh_hosts
BEGIN SELECT RAISE(FAIL, 'blocked update'); END
''');
    await expectLater(credentials.migrateHosts(), throwsA(anything));
    final row = await database.select(database.sshHosts).getSingle();
    expect(row.password, 'legacy-password');
    expect(vault.values, isEmpty);
    await database.customStatement('DROP TRIGGER reject_ssh_update');
    await credentials.migrateHosts();
    expect(await credentials.readHostPassword(row), 'legacy-password');
  });

  test('missing vault secret fails closed', () async {
    await credentials.addHost(
      SshHostsCompanion.insert(password: const Value('secret')),
    );
    final row = await database.select(database.sshHosts).getSingle();
    vault.values.clear();
    await expectLater(credentials.readHostPassword(row), throwsStateError);
    expect(
      (await database.select(database.sshHosts).getSingle()).password,
      row.password,
    );
  });

  test('blank host edits preserve the existing secure password', () async {
    final id = await credentials.addHost(
      SshHostsCompanion.insert(password: const Value('secret')),
    );
    final before = await database.select(database.sshHosts).getSingle();
    await credentials.updateHost(
      id,
      const SshHostsCompanion(host: Value('Renamed'), password: Value('')),
    );
    final after = await database.select(database.sshHosts).getSingle();
    expect(after.host, 'Renamed');
    expect(after.password, before.password);
    expect(await credentials.readHostPassword(after), 'secret');
  });

  test(
    'failed vault update leaves the prior password and metadata intact',
    () async {
      final id = await credentials.addHost(
        SshHostsCompanion.insert(
          host: const Value('Original'),
          password: const Value('secret'),
        ),
      );
      final before = await database.select(database.sshHosts).getSingle();
      vault.failWrite = vault.writes + 1;
      await expectLater(
        credentials.updateHost(
          id,
          const SshHostsCompanion(
            host: Value('Changed'),
            password: Value('replacement'),
          ),
        ),
        throwsStateError,
      );
      final after = await database.select(database.sshHosts).getSingle();
      expect(after, before);
      expect(await credentials.readHostPassword(after), 'secret');
    },
  );

  test(
    'new passwords resembling references are stored literally in vault',
    () async {
      const password = 'vault:ssh:this-is-the-password';
      await credentials.addHost(
        SshHostsCompanion.insert(password: const Value(password)),
      );
      final row = await database.select(database.sshHosts).getSingle();
      expect(row.password, isNot(password));
      expect(await credentials.readHostPassword(row), password);
    },
  );

  test(
    'password replacement deletes only the superseded vault reference',
    () async {
      final id = await credentials.addHost(
        SshHostsCompanion.insert(password: const Value('old-secret')),
      );
      final stale = await database.select(database.sshHosts).getSingle();
      await credentials.updateHost(
        id,
        const SshHostsCompanion(password: Value('new-secret')),
      );
      final current = await database.select(database.sshHosts).getSingle();
      expect(vault.values.containsKey(stale.password), isFalse);
      expect(vault.values[current.password], 'new-secret');
      expect(await credentials.readHostPassword(stale), 'new-secret');
    },
  );

  test(
    'credential rewrites enable secure deletion of SQLite content',
    () async {
      await credentials.addHost(
        SshHostsCompanion.insert(password: const Value('secret')),
      );
      final setting = await database
          .customSelect('PRAGMA secure_delete')
          .getSingle();
      expect(setting.read<int>('secure_delete'), 1);
    },
  );

  test('deleting credentials removes their vault entries', () async {
    await credentials.addHost(
      SshHostsCompanion.insert(password: const Value('secret')),
    );
    await credentials.addKey(
      SshKeysCompanion.insert(
        content: const Value('private-key'),
        password: const Value('passphrase'),
      ),
    );
    await credentials.deleteHost(
      await database.select(database.sshHosts).getSingle(),
    );
    await credentials.deleteKey(
      await database.select(database.sshKeys).getSingle(),
    );
    expect(vault.values, isEmpty);
    expect(await database.select(database.sshHosts).get(), isEmpty);
    expect(await database.select(database.sshKeys).get(), isEmpty);
  });
}
