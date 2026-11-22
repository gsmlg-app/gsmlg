import 'package:app_agent/app_agent.dart';
import 'package:app_database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSemanticIndex implements MemorySemanticIndex {
  bool ready = true;
  final Map<String, MemoryEntry> indexed = {};

  @override
  bool get isReady => ready;

  @override
  Future<void> upsert(MemoryEntry entry) async {
    indexed[entry.id] = entry;
  }

  @override
  Future<void> delete(String id) async {
    indexed.remove(id);
  }

  @override
  Future<List<MemorySemanticHit>?> search({
    required String query,
    required Set<String> scopes,
    required int limit,
  }) async {
    if (!ready) return null;
    final lower = query.toLowerCase();
    final hits = <MemorySemanticHit>[];
    for (final entry in indexed.values) {
      if (!scopes.contains(entry.scope)) continue;
      // Simulate semantic match even when exact word differs.
      final text = entry.content.toLowerCase();
      final score =
          (lower.contains('red planet') && text.contains('mars')) ||
              text.contains(lower)
          ? 0.92
          : 0.1;
      if (score >= 0.5) {
        hits.add(MemorySemanticHit(entryId: entry.id, score: score));
      }
    }
    hits.sort((a, b) => b.score.compareTo(a.score));
    return hits.take(limit).toList();
  }

  @override
  Future<void> dispose() async {
    ready = false;
  }
}

void main() {
  group('ScopedMemoryProvider', () {
    late ScopedMemoryProvider provider;

    setUp(() {
      provider = ScopedMemoryProvider();
    });

    test('stores memory entry and computes SHA-256 hash', () async {
      final res = await provider.executeTool(
        toolName: 'memory_store',
        arguments: {
          'content': 'The server port is 8080.',
          'scope': 'global',
          'provenance': 'user_fact',
        },
        sessionId: 'session_1',
      );

      expect(res['status'], equals('stored'));
      expect(res['id'], startsWith('mem_'));
      expect(res['contentHash'], isNotEmpty);
      expect(res['provenance'], equals('user_fact'));
    });

    test('searches memories respecting scope boundaries', () async {
      await provider.executeTool(
        toolName: 'memory_store',
        arguments: {
          'content': 'Secret key for session 1 is ALPHA',
          'scope': 'conversation:session_1',
        },
        sessionId: 'session_1',
      );

      await provider.executeTool(
        toolName: 'memory_store',
        arguments: {
          'content': 'Secret key for session 2 is BETA',
          'scope': 'conversation:session_2',
        },
        sessionId: 'session_2',
      );

      await provider.executeTool(
        toolName: 'memory_store',
        arguments: {
          'content': 'Company headquarters is in Mountain View',
          'scope': 'global',
        },
        sessionId: 'session_1',
      );

      final searchRes = await provider.executeTool(
        toolName: 'memory_search',
        arguments: {'query': 'secret'},
        sessionId: 'session_1',
      );

      expect(searchRes['searchMode'], 'keyword_fallback');
      final results = searchRes['results'] as List;
      expect(results.length, equals(1));
      expect(results.first['content'], contains('ALPHA'));

      final globalSearch = await provider.executeTool(
        toolName: 'memory_search',
        arguments: {'query': 'headquarters'},
        sessionId: 'session_2',
      );
      final globalResults = globalSearch['results'] as List;
      expect(globalResults.length, equals(1));
      expect(globalResults.first['content'], contains('Mountain View'));
    });

    test('updates and deletes memory entries', () async {
      final storeRes = await provider.executeTool(
        toolName: 'memory_store',
        arguments: {'content': 'Temporary note', 'scope': 'global'},
        sessionId: 'session_1',
      );
      final id = storeRes['id'] as String;

      final updateRes = await provider.executeTool(
        toolName: 'memory_update',
        arguments: {
          'id': id,
          'content': 'Updated durable note',
          'provenance': 'user_fact',
        },
        sessionId: 'session_1',
      );
      expect(updateRes['updated'], isTrue);
      expect(updateRes['provenance'], 'user_fact');

      final searchUpdated = await provider.executeTool(
        toolName: 'memory_search',
        arguments: {'query': 'durable'},
        sessionId: 'session_1',
      );
      expect((searchUpdated['results'] as List).length, 1);

      final delRes = await provider.executeTool(
        toolName: 'memory_delete',
        arguments: {'id': id},
        sessionId: 'session_1',
      );
      expect(delRes['deleted'], isTrue);

      final searchRes = await provider.executeTool(
        toolName: 'memory_search',
        arguments: {'query': 'durable'},
        sessionId: 'session_1',
      );
      expect((searchRes['results'] as List), isEmpty);
    });

    test(
      'persists across provider restarts with DriftMemoryStore and uses semantic index',
      () async {
        final db = AppDatabase.forTesting();
        addTearDown(db.close);

        final semantic = _FakeSemanticIndex();
        final first = ScopedMemoryProvider(
          store: DriftMemoryStore(db),
          semanticIndex: semantic,
          defaultAgentId: 'agent-1',
        );

        await first.executeTool(
          toolName: 'memory_store',
          arguments: {
            'content': 'Mars is known for its rusty iron-oxide surface.',
            'scope': 'agent:agent-1',
            'provenance': 'user_fact',
          },
          sessionId: 's1',
        );

        // Re-open with a fresh ScopedMemoryProvider backed by the same DB.
        final second = ScopedMemoryProvider(
          store: DriftMemoryStore(db),
          semanticIndex: semantic,
          defaultAgentId: 'agent-1',
        );

        final semanticRes = await second.executeTool(
          toolName: 'memory_search',
          arguments: {'query': 'Which planet is the Red Planet?'},
          sessionId: 's2',
        );
        expect(semanticRes['searchMode'], 'semantic');
        expect((semanticRes['results'] as List).length, 1);
        expect(
          (semanticRes['results'] as List).first['content'],
          contains('Mars'),
        );

        // Agent-2 must not see agent-1's private agent-scoped memory.
        final otherAgent = ScopedMemoryProvider(
          store: DriftMemoryStore(db),
          semanticIndex: semantic,
          defaultAgentId: 'agent-2',
        );
        final deniedRes = await otherAgent.executeTool(
          toolName: 'memory_search',
          arguments: {'query': 'Red Planet', 'scope': 'agent:agent-1'},
          sessionId: 's2',
        );
        expect(deniedRes['searchMode'], 'scope_denied');
        expect((deniedRes['results'] as List), isEmpty);

        // When semantic index becomes unavailable, falls back to keyword search.
        semantic.ready = false;
        final fallbackRes = await second.executeTool(
          toolName: 'memory_search',
          arguments: {'query': 'iron-oxide'},
          sessionId: 's2',
        );
        expect(fallbackRes['searchMode'], 'keyword_fallback');
        expect((fallbackRes['results'] as List).length, 1);
      },
    );
  });
}
