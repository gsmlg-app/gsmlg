import 'dart:io';
import 'package:app_chat/app_chat.dart';
import 'package:app_database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ChatStorageRepository storage;
  setUp(() {
    db = AppDatabase.forTesting();
    storage = ChatStorageRepository(db);
  });
  tearDown(() => db.close());
  Future<Conversation> create() async {
    await storage.saveConversation(
      Conversation.create(id: 'c').copyWith(title: 'fallback'),
    );
    return (await storage.loadConversation('c'))!;
  }

  test(
    'conditional title writes preserve activity and survive stale saves',
    () async {
      final snapshot = await create();
      expect(
        await storage.updateAutomaticTitle(
          snapshot,
          'Flutter Controller Design',
        ),
        isTrue,
      );
      await storage.saveConversation(snapshot);
      final loaded = (await storage.loadConversation('c'))!;
      expect(loaded.title, 'Flutter Controller Design');
      expect(loaded.updatedAt, snapshot.updatedAt);
      expect(await storage.updateAutomaticTitle(loaded, loaded.title), isFalse);
      expect(await storage.updateAutomaticTitle(snapshot, 'Stale'), isFalse);
    },
  );
  test('manual edits and legacy sources cannot be overwritten', () async {
    final snapshot = await create();
    await storage.updateConversationTitle('c', 'My title');
    expect(await storage.updateAutomaticTitle(snapshot, 'Stale'), isFalse);
    await storage.saveConversation(snapshot);
    expect((await storage.loadConversation('c'))!.title, 'My title');
    expect((await storage.loadConversation('c'))!.titleSource, 'manual');
  });
  test('content edits and message deletion invalidate snapshots', () async {
    await create();
    final message = UserMessage(
      id: 'u',
      content: 'one',
      conversationId: 'c',
      timestamp: DateTime(2026),
    );
    await storage.saveMessage(message);
    final snapshot = (await storage.loadConversation('c'))!;
    await storage.updateMessageContent('u', 'two');
    expect(await storage.updateAutomaticTitle(snapshot, 'Stale'), isFalse);
    final edited = (await storage.loadConversation('c'))!;
    await storage.deleteMessage('u');
    expect(await storage.updateAutomaticTitle(edited, 'Stale'), isFalse);
  });
  test('delete and clear reject delayed title writes', () async {
    await create();
    await storage.saveMessage(
      UserMessage(
        id: 'u',
        content: 'one',
        conversationId: 'c',
        timestamp: DateTime(2026),
      ),
    );
    final snapshot = (await storage.loadConversation('c'))!;
    await storage.clearConversationMessages('c');
    expect(await storage.updateAutomaticTitle(snapshot, 'Delayed'), isFalse);
    await storage.deleteConversation('c');
    expect(await storage.updateAutomaticTitle(snapshot, 'Delayed'), isFalse);
    expect(await storage.loadConversation('c'), isNull);
  });
  test('generated title survives database close and reopen', () async {
    final directory = await Directory.systemTemp.createTemp('title-storage-');
    try {
      final file = File('${directory.path}/chat.sqlite');
      var database = AppDatabase(NativeDatabase(file));
      var repository = ChatStorageRepository(database);
      await repository.saveConversation(Conversation.create(id: 'persist'));
      final snapshot = (await repository.loadConversation('persist'))!;
      expect(
        await repository.updateAutomaticTitle(snapshot, '持久化标题测试'),
        isTrue,
      );
      await database.close();
      database = AppDatabase(NativeDatabase(file));
      repository = ChatStorageRepository(database);
      expect((await repository.loadConversation('persist'))!.title, '持久化标题测试');
      await database.close();
    } finally {
      await directory.delete(recursive: true);
    }
  });
}
