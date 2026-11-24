import 'package:app_database/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VncHostAuthType', () {
    test('fromValue maps known values and falls back to auto', () {
      expect(VncHostAuthType.fromValue(0), VncHostAuthType.auto);
      expect(VncHostAuthType.fromValue(1), VncHostAuthType.none);
      expect(VncHostAuthType.fromValue(2), VncHostAuthType.vncPassword);
      expect(VncHostAuthType.fromValue(30), VncHostAuthType.appleArd);
      expect(VncHostAuthType.fromValue(999), VncHostAuthType.auto);
      expect(VncHostAuthType.fromValue(-1), VncHostAuthType.auto);
    });
  });

  group('VncHosts table', () {
    test('supports insert, query, update, delete, and defaults', () async {
      final db = AppDatabase.forTesting();
      addTearDown(db.close);

      final id = await db.into(db.vncHosts).insert(
            VncHostsCompanion.insert(
              name: 'Mac Mini',
              host: '192.168.1.10',
            ),
          );

      final inserted = await (db.select(db.vncHosts)
            ..where((t) => t.id.equals(id)))
          .getSingle();

      expect(inserted.id, id);
      expect(inserted.name, 'Mac Mini');
      expect(inserted.host, '192.168.1.10');
      expect(inserted.port, 5900);
      expect(inserted.authType, 0);
      expect(inserted.username, isNull);
      expect(inserted.passwordRef, isNull);
      expect(inserted.sshHostId, isNull);
      expect(inserted.viewOnly, isFalse);
      expect(inserted.createdAt, isNotNull);
      expect(inserted.lastConnectedAt, isNull);

      final connectedAt = DateTime.utc(2026, 11, 24, 12, 0, 0);
      await (db.update(db.vncHosts)..where((t) => t.id.equals(id))).write(
        VncHostsCompanion(
          name: const Value('Mac Mini ARD'),
          port: const Value(5901),
          authType: Value(VncHostAuthType.appleArd.value),
          username: const Value('admin'),
          passwordRef: const Value('vnc:password:1'),
          viewOnly: const Value(true),
          lastConnectedAt: Value(connectedAt),
        ),
      );

      final updated = await (db.select(db.vncHosts)
            ..where((t) => t.id.equals(id)))
          .getSingle();

      expect(updated.name, 'Mac Mini ARD');
      expect(updated.port, 5901);
      expect(updated.authType, VncHostAuthType.appleArd.value);
      expect(updated.username, 'admin');
      expect(updated.passwordRef, 'vnc:password:1');
      expect(updated.viewOnly, isTrue);
      expect(
        updated.lastConnectedAt?.millisecondsSinceEpoch,
        connectedAt.millisecondsSinceEpoch,
      );

      final deletedCount =
          await (db.delete(db.vncHosts)..where((t) => t.id.equals(id))).go();
      expect(deletedCount, 1);

      final remaining = await db.select(db.vncHosts).get();
      expect(remaining, isEmpty);
    });

    test('sets sshHostId to null when referenced SshHost is deleted', () async {
      final db = AppDatabase.forTesting();
      addTearDown(db.close);

      await db.customStatement('PRAGMA foreign_keys = ON');

      final sshHostId = await db.into(db.sshHosts).insert(
            SshHostsCompanion.insert(
              host: const Value('Bastion'),
              hostname: const Value('bastion.example.com'),
              port: const Value(22),
            ),
          );

      final vncHostId = await db.into(db.vncHosts).insert(
            VncHostsCompanion.insert(
              name: 'Internal Desktop',
              host: '10.0.0.5',
              sshHostId: Value(sshHostId),
            ),
          );

      final beforeDelete = await (db.select(db.vncHosts)
            ..where((t) => t.id.equals(vncHostId)))
          .getSingle();
      expect(beforeDelete.sshHostId, sshHostId);

      await (db.delete(db.sshHosts)..where((t) => t.id.equals(sshHostId))).go();

      final afterDelete = await (db.select(db.vncHosts)
            ..where((t) => t.id.equals(vncHostId)))
          .getSingle();
      expect(afterDelete.sshHostId, isNull);
    });

    test('upgrades schema v22 to v23 and creates vnc_hosts table', () async {
      final db = AppDatabase(NativeDatabase.memory(setup: (sqlite) {
        sqlite.execute('''
          CREATE TABLE ssh_hosts (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            host TEXT NULL,
            hostname TEXT NULL,
            port INTEGER NULL,
            username TEXT NULL,
            password TEXT NULL,
            salt TEXT NULL,
            identity_key_id INTEGER NULL,
            identity_type INTEGER NULL,
            created_at INTEGER NULL
          )
        ''');
        sqlite.execute('PRAGMA user_version = 22');
      }));
      addTearDown(db.close);

      expect(db.schemaVersion, 23);

      final id = await db.into(db.vncHosts).insert(
            VncHostsCompanion.insert(
              name: 'Migrated VNC',
              host: '127.0.0.1',
            ),
          );

      final row = await (db.select(db.vncHosts)..where((t) => t.id.equals(id)))
          .getSingle();
      expect(row.name, 'Migrated VNC');
      expect(row.port, 5900);

      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.read<int>('user_version'), 23);
    });
  });
}
