import 'dart:io';

import 'package:app_database/app_database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('upgrades schema 18 preserving app data and reopens SSH profiles',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('gsmlg-terminal-db-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/app.sqlite');
    // Model the previous full application schema by removing only terminal tables.
    final legacy = AppDatabase(NativeDatabase(file));
    await legacy.customStatement(
      "INSERT INTO chat_conversation_table (id, title, created_at, updated_at) "
      "VALUES ('saved-chat', 'Existing conversation', 1767225600, 1767225600)",
    );
    await legacy.customStatement('DROP TABLE ssh_hosts');
    await legacy.customStatement('DROP TABLE ssh_keys');
    await legacy.customStatement('DROP TABLE shell_profiles');
    await legacy.customStatement('PRAGMA user_version = 18');
    await legacy.close();
    final database = AppDatabase(NativeDatabase(file));
    expect(await database.select(database.sshHosts).get(), isEmpty);
    final keyId = await database.into(database.sshKeys).insert(
          SshKeysCompanion.insert(name: const Value('my key')),
        );
    await database.into(database.sshHosts).insert(
          SshHostsCompanion.insert(
            hostname: const Value('example.test'),
            identityKeyId: Value(keyId),
          ),
        );
    await database.into(database.shellProfiles).insert(
          ShellProfilesCompanion.insert(name: 'My shell'),
        );
    final conversation =
        await database.select(database.chatConversationTable).getSingle();
    expect(conversation.id, 'saved-chat');
    expect(conversation.title, 'Existing conversation');
    expect(
        (await database.customSelect('PRAGMA user_version').getSingle())
            .read<int>('user_version'),
        19);
    await database.close();

    final reopened = AppDatabase(NativeDatabase(file));
    addTearDown(reopened.close);
    final host = await reopened.select(reopened.sshHosts).getSingle();
    expect(host.hostname, 'example.test');
    expect(host.identityKeyId, keyId);
    final profile = await reopened.select(reopened.shellProfiles).getSingle();
    expect(profile.name, 'My shell');
    expect(profile.scrollbackLines, 10000);
    expect(profile.inheritCurrentState, isFalse);
  });

  test('fresh database creates terminal and existing app tables', () async {
    final database = AppDatabase.forTesting();
    addTearDown(database.close);
    expect(await database.select(database.sshKeys).get(), isEmpty);
    expect(await database.select(database.sshHosts).get(), isEmpty);
    expect(await database.select(database.shellProfiles).get(), isEmpty);
    expect(
        await database.select(database.chatConversationTable).get(), isEmpty);
  });
}
