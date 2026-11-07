import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../services/tool_executor.dart';

/// Represents a single persistent memory entry with provenance and hash.
class MemoryEntry {
  MemoryEntry({
    required this.id,
    required this.scope,
    required this.content,
    required this.provenance,
    this.sourceId,
    required this.contentHash,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  final String id;
  final String scope;
  final String content;
  final String provenance; // 'user_fact', 'agent_inference', 'tool_observation'
  final String? sourceId;
  final String contentHash;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  factory MemoryEntry.create({
    required String scope,
    required String content,
    String provenance = 'agent_inference',
    String? sourceId,
    Map<String, dynamic> metadata = const {},
  }) {
    final now = DateTime.now();
    final id = 'mem_${now.microsecondsSinceEpoch}';
    final hash = sha256.convert(utf8.encode(content)).toString();
    return MemoryEntry(
      id: id,
      scope: scope,
      content: content,
      provenance: provenance,
      sourceId: sourceId,
      contentHash: hash,
      createdAt: now,
      updatedAt: now,
      metadata: metadata,
    );
  }

  Map<String, dynamic> toSummary() => {
    'id': id,
    'scope': scope,
    'content': content,
    'provenance': provenance,
    if (sourceId != null) 'sourceId': sourceId,
    'contentHash': contentHash,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

/// Provider for scoped, provenance-tracked memory retrieval and updates.
class ScopedMemoryProvider {
  ScopedMemoryProvider({List<MemoryEntry>? initialEntries}) {
    if (initialEntries != null) {
      for (final e in initialEntries) {
        _entries[e.id] = e;
      }
    }
  }

  final Map<String, MemoryEntry> _entries = {};

  static const _searchTool = 'memory_search';
  static const _storeTool = 'memory_store';
  static const _deleteTool = 'memory_delete';

  bool handlesTool(String toolName) =>
      {_searchTool, _storeTool, _deleteTool}.contains(toolName);

  List<ChatToolDefinition> get toolDefinitions => [
    const ChatToolDefinition(
      name: _searchTool,
      description:
          'Search persistent memory within allowed scopes with text keyword ranking and provenance.',
      parameters: {
        'type': 'object',
        'properties': {
          'query': {
            'type': 'string',
            'description':
                'The search keywords or query to find relevant memories.',
          },
          'scope': {
            'type': 'string',
            'description':
                'Optional scope filter (e.g., "conversation:123", "global").',
          },
          'limit': {
            'type': 'integer',
            'description': 'Maximum number of memories to return (default 10).',
          },
        },
        'required': ['query'],
      },
    ),
    const ChatToolDefinition(
      name: _storeTool,
      description:
          'Store a new fact, observation, or inference into persistent memory with scope and provenance.',
      parameters: {
        'type': 'object',
        'properties': {
          'content': {
            'type': 'string',
            'description': 'The detailed text content of the memory.',
          },
          'scope': {
            'type': 'string',
            'description':
                'Target scope (e.g., "conversation:123", "global"). Defaults to "global".',
          },
          'provenance': {
            'type': 'string',
            'enum': ['user_fact', 'agent_inference', 'tool_observation'],
            'description':
                'Source type of the memory (default "agent_inference").',
          },
        },
        'required': ['content'],
      },
    ),
    const ChatToolDefinition(
      name: _deleteTool,
      description: 'Delete a memory entry by ID.',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {
            'type': 'string',
            'description': 'The memory entry ID to delete.',
          },
        },
        'required': ['id'],
      },
    ),
  ];

  Future<dynamic> executeTool({
    required String toolName,
    required Map<String, dynamic> arguments,
    required String sessionId,
  }) async {
    switch (toolName) {
      case _searchTool:
        return _search(arguments, sessionId);
      case _storeTool:
        return _store(arguments, sessionId);
      case _deleteTool:
        return _delete(arguments);
      default:
        return {'error': 'Unknown memory tool: $toolName'};
    }
  }

  Future<dynamic> _search(Map<String, dynamic> args, String sessionId) async {
    final query = (args['query'] as String).toLowerCase();
    final requestedScope = args['scope'] as String?;
    final limit = (args['limit'] as num?)?.toInt() ?? 10;

    final sessionScope = 'conversation:$sessionId';
    final queryTokens = query
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    // 1. Visibility filtering: only include allowed scopes (requested scope or session scope + global)
    final candidateEntries = _entries.values.where((entry) {
      if (requestedScope != null) {
        return entry.scope == requestedScope;
      }
      return entry.scope == sessionScope || entry.scope == 'global';
    }).toList();

    // 2. Text search ranking fallback
    final scored = <Map<String, dynamic>>[];
    for (final entry in candidateEntries) {
      final text = entry.content.toLowerCase();
      var score = 0;
      for (final token in queryTokens) {
        if (text.contains(token)) {
          score += 10;
          if (text.startsWith(token)) score += 5;
        }
      }
      if (score > 0 || queryTokens.isEmpty) {
        scored.add({'entry': entry.toSummary(), 'score': score});
      }
    }

    scored.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    final results = scored.take(limit).map((s) => s['entry']).toList();

    return {'query': query, 'total': results.length, 'results': results};
  }

  Future<dynamic> _store(Map<String, dynamic> args, String sessionId) async {
    final content = args['content'] as String;
    final scope =
        (args['scope'] as String?) ??
        (sessionId.isNotEmpty ? 'conversation:$sessionId' : 'global');
    final provenance = (args['provenance'] as String?) ?? 'agent_inference';

    final entry = MemoryEntry.create(
      scope: scope,
      content: content,
      provenance: provenance,
      sourceId: sessionId,
    );

    _entries[entry.id] = entry;

    return {
      'status': 'stored',
      'id': entry.id,
      'contentHash': entry.contentHash,
      'scope': entry.scope,
      'provenance': entry.provenance,
    };
  }

  Future<dynamic> _delete(Map<String, dynamic> args) async {
    final id = args['id'] as String;
    final removed = _entries.remove(id);
    return {'id': id, 'deleted': removed != null};
  }
}
