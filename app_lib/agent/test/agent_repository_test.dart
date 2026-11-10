import 'dart:convert';

import 'package:app_agent/app_agent.dart';
import 'package:app_database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;
  late AgentRepository repo;

  setUp(() {
    db = AppDatabase.forTesting();
    repo = AgentRepository(db);
  });
  tearDown(() => db.close());

  AgentDefinition sample(String id, {List<String>? tools}) => AgentDefinition(
    id: id,
    name: 'Bot $id',
    avatar: '🤖',
    description: 'desc',
    instructions: 'be nice',
    config: ModelConfig.defaultConfig.copyWith(
      temperature: 0.3,
      remoteModel: 'm-$id',
    ),
    thinkingEnabled: true,
    allowedTools: tools,
    createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(2000),
  );

  test('CRUD round-trips including allowedTools', () async {
    await repo.save(sample('a', tools: ['x', 'y']));
    await repo.save(sample('b'));

    expect(await repo.get('a'), sample('a', tools: ['x', 'y']));
    expect((await repo.get('b'))!.allowedTools, isNull);
    expect((await repo.list()).map((a) => a.id), ['a', 'b']);

    await repo.save(sample('a', tools: []).copyWith(name: 'Renamed'));
    final a = (await repo.get('a'))!;
    expect(a.name, 'Renamed');
    expect(a.allowedTools, isEmpty);

    await repo.delete('a');
    expect(await repo.get('a'), isNull);
  });

  test('wire map round-trips', () {
    final a = sample('a', tools: ['x']);
    expect(AgentDefinition.fromWire(a.toWire()), a);
  });

  test('importLegacy imports once, preserving ids and config', () async {
    final config = {
      'inferenceMode': 'remote',
      'maxTokens': 123,
      'temperature': 0.5,
      'remoteModel': 'gpt-x',
      'remoteAccountId': 7,
    };
    SharedPreferences.setMockInitialValues({
      'chat_agents': [
        jsonEncode({
          'id': 'legacy-1',
          'name': 'One',
          'config': config,
          'systemPrompt': 'sp',
          'thinkingEnabled': true,
        }),
        jsonEncode({'id': 'legacy-2', 'name': 'Two'}),
        'not json',
      ],
    });
    final prefs = await SharedPreferences.getInstance();

    await repo.importLegacy(prefs);
    final agents = await repo.list();
    expect(agents.map((a) => a.id).toSet(), {'legacy-1', 'legacy-2'});
    final one = agents.firstWhere((a) => a.id == 'legacy-1');
    expect(one.instructions, 'sp');
    expect(one.thinkingEnabled, isTrue);
    expect(one.config.maxTokens, 123);
    expect(one.config.remoteModel, 'gpt-x');
    expect(one.config.remoteAccountId, 7);
    expect(one.allowedTools, isNull);

    await repo.delete('legacy-1');
    await repo.importLegacy(prefs);
    expect((await repo.list()).map((a) => a.id), ['legacy-2']);
    expect(prefs.getBool('agents_migrated_v1'), isTrue);
  });

  test('conversations record agentId and filter by it', () async {
    final storage = ChatStorageRepository(db);
    await storage.saveConversation(
      Conversation.create(id: 'c1').copyWith(agentId: 'a'),
    );
    await storage.saveConversation(Conversation.create(id: 'c2'));

    expect((await storage.loadConversation('c1'))!.agentId, 'a');
    expect((await storage.loadConversations()).length, 2);
    expect((await storage.loadConversations(agentId: 'a')).map((c) => c.id), [
      'c1',
    ]);
  });
}
