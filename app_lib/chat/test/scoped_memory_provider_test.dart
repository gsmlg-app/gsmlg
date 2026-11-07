import 'package:app_chat/app_chat.dart';
import 'package:test/test.dart';

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
      // Store in session_1
      await provider.executeTool(
        toolName: 'memory_store',
        arguments: {
          'content': 'Secret key for session 1 is ALPHA',
          'scope': 'conversation:session_1',
        },
        sessionId: 'session_1',
      );

      // Store in session_2
      await provider.executeTool(
        toolName: 'memory_store',
        arguments: {
          'content': 'Secret key for session 2 is BETA',
          'scope': 'conversation:session_2',
        },
        sessionId: 'session_2',
      );

      // Store in global
      await provider.executeTool(
        toolName: 'memory_store',
        arguments: {
          'content': 'Company headquarters is in Mountain View',
          'scope': 'global',
        },
        sessionId: 'session_1',
      );

      // Search from session_1: should find session_1 memory and global memory, but NOT session_2 memory!
      final searchRes = await provider.executeTool(
        toolName: 'memory_search',
        arguments: {'query': 'secret'},
        sessionId: 'session_1',
      );

      final results = searchRes['results'] as List;
      expect(results.length, equals(1));
      expect(results.first['content'], contains('ALPHA'));

      // Search global
      final globalSearch = await provider.executeTool(
        toolName: 'memory_search',
        arguments: {'query': 'headquarters'},
        sessionId: 'session_2',
      );
      final globalResults = globalSearch['results'] as List;
      expect(globalResults.length, equals(1));
      expect(globalResults.first['content'], contains('Mountain View'));
    });

    test('deletes memory entry by id', () async {
      final storeRes = await provider.executeTool(
        toolName: 'memory_store',
        arguments: {
          'content': 'Temporary note',
          'scope': 'global',
        },
        sessionId: 'session_1',
      );
      final id = storeRes['id'] as String;

      final delRes = await provider.executeTool(
        toolName: 'memory_delete',
        arguments: {'id': id},
        sessionId: 'session_1',
      );

      expect(delRes['deleted'], isTrue);

      final searchRes = await provider.executeTool(
        toolName: 'memory_search',
        arguments: {'query': 'Temporary'},
        sessionId: 'session_1',
      );
      expect((searchRes['results'] as List), isEmpty);
    });
  });
}
