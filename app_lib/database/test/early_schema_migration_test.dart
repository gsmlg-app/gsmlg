import 'package:app_database/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('upgrades a v3 database (before the chat tables) to v21', () async {
    final database = AppDatabase(NativeDatabase.memory(setup: (sqlite) {
      // v3 had no chat tables; dns_zone_table is recreated at v8.
      sqlite.execute('CREATE TABLE dns_zone_table (id INTEGER PRIMARY KEY)');
      sqlite.execute('PRAGMA user_version = 3');
    }));
    addTearDown(database.close);

    expect(database.schemaVersion, 21);
    await database.into(database.chatConversationTable).insert(
          ChatConversationTableCompanion.insert(
            id: 'c1',
            title: 'Chat',
            agentId: const Value('a1'),
          ),
        );
    final conversation =
        await database.select(database.chatConversationTable).getSingle();
    expect(conversation.agentId, 'a1');
    final columns = await database
        .customSelect(
          "SELECT name FROM pragma_table_info('chat_message_table')",
        )
        .map((row) => row.read<String>('name'))
        .get();
    expect(columns, contains('agent_metadata'));
    expect(await database.select(database.agentDefinitionTable).get(), isEmpty);
  });
}
