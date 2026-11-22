import 'dart:async';
import 'dart:convert';

import 'package:app_database/app_database.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../services/tool_executor.dart';
import 'memory_semantic_index.dart';

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

  factory MemoryEntry.fromJson(Map<String, dynamic> json) => MemoryEntry(
    id: json['id'] as String,
    scope: json['scope'] as String,
    content: json['content'] as String,
    provenance: (json['provenance'] as String?) ?? 'agent_inference',
    sourceId: json['sourceId'] as String?,
    contentHash: json['contentHash'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    metadata: json['metadata'] is Map
        ? Map<String, dynamic>.from(json['metadata'] as Map)
        : const {},
  );

  MemoryEntry copyWith({
    String? content,
    String? provenance,
    Map<String, dynamic>? metadata,
    DateTime? updatedAt,
  }) {
    final nextContent = content ?? this.content;
    return MemoryEntry(
      id: id,
      scope: scope,
      content: nextContent,
      provenance: provenance ?? this.provenance,
      sourceId: sourceId,
      contentHash: sha256.convert(utf8.encode(nextContent)).toString(),
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toSummary({double? score}) => {
    'id': id,
    'scope': scope,
    'content': content,
    'provenance': provenance,
    if (sourceId != null) 'sourceId': sourceId,
    'contentHash': contentHash,
    if (score != null) 'score': double.parse(score.toStringAsFixed(4)),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    if (metadata.isNotEmpty) 'metadata': metadata,
  };
}

/// Durable storage abstraction for [MemoryEntry] records.
abstract interface class MemoryStore {
  Future<MemoryEntry> store(MemoryEntry entry);

  Future<MemoryEntry?> update({
    required String id,
    required String content,
    String? provenance,
    Map<String, dynamic>? metadata,
  });

  Future<bool> delete(String id);

  Future<MemoryEntry?> getById(String id);

  Future<List<MemoryEntry>> listByScopes(Set<String> scopes);
}

/// In-memory [MemoryStore] used in unit tests and ephemeral runs.
class InMemoryMemoryStore implements MemoryStore {
  InMemoryMemoryStore([Iterable<MemoryEntry>? initialEntries]) {
    if (initialEntries != null) {
      for (final entry in initialEntries) {
        _entries[entry.id] = entry;
      }
    }
  }

  final Map<String, MemoryEntry> _entries = {};

  @override
  Future<MemoryEntry> store(MemoryEntry entry) async {
    _entries[entry.id] = entry;
    return entry;
  }

  @override
  Future<MemoryEntry?> update({
    required String id,
    required String content,
    String? provenance,
    Map<String, dynamic>? metadata,
  }) async {
    final existing = _entries[id];
    if (existing == null) return null;
    final updated = existing.copyWith(
      content: content,
      provenance: provenance,
      metadata: metadata,
    );
    _entries[id] = updated;
    return updated;
  }

  @override
  Future<bool> delete(String id) async => _entries.remove(id) != null;

  @override
  Future<MemoryEntry?> getById(String id) async => _entries[id];

  @override
  Future<List<MemoryEntry>> listByScopes(Set<String> scopes) async =>
      _entries.values.where((e) => scopes.contains(e.scope)).toList();
}

/// SQLite-backed [MemoryStore] persisting memories in Drift's `agent_memory_table`.
class DriftMemoryStore implements MemoryStore {
  DriftMemoryStore(this._db);

  final AppDatabase _db;

  MemoryEntry _fromRow(AgentMemoryTableData row) {
    Map<String, dynamic> decodedMetadata = const {};
    try {
      final parsed = jsonDecode(row.metadataJson);
      if (parsed is Map) {
        decodedMetadata = Map<String, dynamic>.from(parsed);
      }
    } catch (_) {}
    return MemoryEntry(
      id: row.id,
      scope: row.scope,
      content: row.content,
      provenance: row.provenance,
      sourceId: row.sourceId,
      contentHash: row.contentHash,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      metadata: decodedMetadata,
    );
  }

  @override
  Future<MemoryEntry> store(MemoryEntry entry) async {
    await _db
        .into(_db.agentMemoryTable)
        .insertOnConflictUpdate(
          AgentMemoryTableCompanion.insert(
            id: entry.id,
            scope: entry.scope,
            content: entry.content,
            provenance: Value(entry.provenance),
            sourceId: Value(entry.sourceId),
            contentHash: entry.contentHash,
            metadataJson: Value(jsonEncode(entry.metadata)),
            createdAt: Value(entry.createdAt),
            updatedAt: Value(entry.updatedAt),
          ),
        );
    return entry;
  }

  @override
  Future<MemoryEntry?> update({
    required String id,
    required String content,
    String? provenance,
    Map<String, dynamic>? metadata,
  }) async {
    final existing = await getById(id);
    if (existing == null) return null;
    final updated = existing.copyWith(
      content: content,
      provenance: provenance,
      metadata: metadata,
    );
    await store(updated);
    return updated;
  }

  @override
  Future<bool> delete(String id) async {
    final count = await (_db.delete(
      _db.agentMemoryTable,
    )..where((t) => t.id.equals(id))).go();
    return count > 0;
  }

  @override
  Future<MemoryEntry?> getById(String id) async {
    final row = await (_db.select(
      _db.agentMemoryTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<List<MemoryEntry>> listByScopes(Set<String> scopes) async {
    if (scopes.isEmpty) return const [];
    final rows =
        await (_db.select(_db.agentMemoryTable)
              ..where((t) => t.scope.isIn(scopes.toList(growable: false)))
              ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
            .get();
    return [for (final row in rows) _fromRow(row)];
  }
}

/// Bridge interface so agent isolates can delegate persistent memory operations
/// to the single main-isolate store and MediaPipe vector index.
abstract interface class AgentMemoryGateway {
  Future<Map<String, dynamic>> executeMemoryTool({
    required String toolName,
    required Map<String, dynamic> arguments,
    required String sessionId,
    String? agentId,
  });
}

/// Provider for scoped, provenance-tracked memory retrieval and updates.
class ScopedMemoryProvider implements AgentMemoryGateway {
  ScopedMemoryProvider({
    List<MemoryEntry>? initialEntries,
    MemoryStore? store,
    MemorySemanticIndex? semanticIndex,
    AgentMemoryGateway? remoteGateway,
    this.defaultAgentId,
  }) : _store = store ?? InMemoryMemoryStore(initialEntries),
       _semanticIndex = semanticIndex,
       _remoteGateway = remoteGateway;

  final MemoryStore _store;
  final MemorySemanticIndex? _semanticIndex;
  final AgentMemoryGateway? _remoteGateway;
  final String? defaultAgentId;

  static const _searchTool = 'memory_search';
  static const _storeTool = 'memory_store';
  static const _updateTool = 'memory_update';
  static const _deleteTool = 'memory_delete';

  /// Canonical list of memory tool definitions exposed to agents and editor UI.
  static const List<ChatToolDefinition> defaultToolDefinitions = [
    ChatToolDefinition(
      name: _searchTool,
      description:
          'Search persistent memory within allowed scopes using on-device '
          'semantic retrieval (with keyword fallback) and provenance.',
      parameters: {
        'type': 'object',
        'properties': {
          'query': {
            'type': 'string',
            'description':
                'The search keywords or natural-language query to find relevant memories.',
          },
          'scope': {
            'type': 'string',
            'description':
                'Optional scope filter (e.g., "conversation:123", "agent:abc", "global").',
          },
          'limit': {
            'type': 'integer',
            'description': 'Maximum number of memories to return (default 10).',
          },
        },
        'required': ['query'],
      },
    ),
    ChatToolDefinition(
      name: _storeTool,
      description:
          'Store a new fact, observation, or inference into persistent memory '
          'with scope and provenance.',
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
                'Target scope (e.g., "conversation:123", "agent:abc", "global"). '
                'Defaults to the current conversation scope.',
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
    ChatToolDefinition(
      name: _updateTool,
      description: 'Update an existing persistent memory entry by ID.',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {
            'type': 'string',
            'description': 'The memory entry ID to update.',
          },
          'content': {
            'type': 'string',
            'description': 'The updated memory content.',
          },
          'provenance': {
            'type': 'string',
            'enum': ['user_fact', 'agent_inference', 'tool_observation'],
            'description': 'Optional updated provenance.',
          },
        },
        'required': ['id', 'content'],
      },
    ),
    ChatToolDefinition(
      name: _deleteTool,
      description: 'Delete a persistent memory entry by ID.',
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

  bool handlesTool(String toolName) =>
      {_searchTool, _storeTool, _updateTool, _deleteTool}.contains(toolName);

  List<ChatToolDefinition> get toolDefinitions => defaultToolDefinitions;

  @override
  Future<Map<String, dynamic>> executeMemoryTool({
    required String toolName,
    required Map<String, dynamic> arguments,
    required String sessionId,
    String? agentId,
  }) async {
    final result = await executeTool(
      toolName: toolName,
      arguments: arguments,
      sessionId: sessionId,
      agentId: agentId,
    );
    return result is Map<String, dynamic> ? result : {'result': result};
  }

  Future<dynamic> executeTool({
    required String toolName,
    required Map<String, dynamic> arguments,
    required String sessionId,
    String? agentId,
  }) async {
    final effectiveAgentId = agentId ?? defaultAgentId;
    final remote = _remoteGateway;
    if (remote != null) {
      return remote.executeMemoryTool(
        toolName: toolName,
        arguments: arguments,
        sessionId: sessionId,
        agentId: effectiveAgentId,
      );
    }

    switch (toolName) {
      case _searchTool:
        return _search(arguments, sessionId, effectiveAgentId);
      case _storeTool:
        return _storeEntry(arguments, sessionId, effectiveAgentId);
      case _updateTool:
        return _updateEntry(arguments, sessionId, effectiveAgentId);
      case _deleteTool:
        return _deleteEntry(arguments, sessionId, effectiveAgentId);
      default:
        return {'error': 'Unknown memory tool: $toolName'};
    }
  }

  Set<String> _allowedScopes(String sessionId, String? agentId) => {
    'global',
    if (sessionId.isNotEmpty) 'conversation:$sessionId',
    if (agentId != null && agentId.isNotEmpty) 'agent:$agentId',
  };

  Future<Map<String, dynamic>> _search(
    Map<String, dynamic> args,
    String sessionId,
    String? agentId,
  ) async {
    final rawQuery = (args['query'] as String?)?.trim() ?? '';
    final requestedScope = (args['scope'] as String?)?.trim();
    final limit = ((args['limit'] as num?)?.toInt() ?? 10).clamp(1, 50);

    final allowed = _allowedScopes(sessionId, agentId);
    final targetScopes = (requestedScope != null && requestedScope.isNotEmpty)
        ? {if (allowed.contains(requestedScope)) requestedScope}
        : allowed;

    if (targetScopes.isEmpty) {
      return {
        'query': rawQuery,
        'searchMode': 'scope_denied',
        'total': 0,
        'results': const <Map<String, dynamic>>[],
      };
    }

    final candidates = await _store.listByScopes(targetScopes);
    final byId = {for (final entry in candidates) entry.id: entry};

    // 1. Semantic search when MediaPipe Retrieval index is ready and query is non-empty.
    final semanticIndex = _semanticIndex;
    if (semanticIndex != null && rawQuery.isNotEmpty && candidates.isNotEmpty) {
      final hits = await semanticIndex.search(
        query: rawQuery,
        scopes: targetScopes,
        limit: limit,
      );
      if (hits != null && hits.isNotEmpty) {
        final results = <Map<String, dynamic>>[];
        for (final hit in hits) {
          final entry = byId[hit.entryId];
          if (entry != null) {
            results.add(entry.toSummary(score: hit.score));
          }
        }
        if (results.isNotEmpty) {
          return {
            'query': rawQuery,
            'searchMode': 'semantic',
            'total': results.length,
            'results': results,
          };
        }
      }
    }

    // 2. Keyword ranking fallback (always available offline without model weights).
    final query = rawQuery.toLowerCase();
    final queryTokens = query
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    final scored = <({MemoryEntry entry, int score})>[];
    for (final entry in candidates) {
      final text = entry.content.toLowerCase();
      var score = 0;
      for (final token in queryTokens) {
        if (text.contains(token)) {
          score += 10;
          if (text.startsWith(token)) score += 5;
        }
      }
      if (score > 0 || queryTokens.isEmpty) {
        scored.add((entry: entry, score: score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    final results = scored
        .take(limit)
        .map((s) => s.entry.toSummary())
        .toList(growable: false);

    return {
      'query': query,
      'searchMode': 'keyword_fallback',
      'total': results.length,
      'results': results,
    };
  }

  Future<Map<String, dynamic>> _storeEntry(
    Map<String, dynamic> args,
    String sessionId,
    String? agentId,
  ) async {
    final content = (args['content'] as String).trim();
    final requestedScope = (args['scope'] as String?)?.trim();
    final scope = (requestedScope != null && requestedScope.isNotEmpty)
        ? requestedScope
        : (sessionId.isNotEmpty ? 'conversation:$sessionId' : 'global');
    final provenance = (args['provenance'] as String?) ?? 'agent_inference';

    final entry = MemoryEntry.create(
      scope: scope,
      content: content,
      provenance: provenance,
      sourceId: sessionId.isNotEmpty ? sessionId : agentId,
    );

    await _store.store(entry);
    await _semanticIndex?.upsert(entry);

    return {
      'status': 'stored',
      'id': entry.id,
      'contentHash': entry.contentHash,
      'scope': entry.scope,
      'provenance': entry.provenance,
    };
  }

  Future<Map<String, dynamic>> _updateEntry(
    Map<String, dynamic> args,
    String sessionId,
    String? agentId,
  ) async {
    final id = args['id'] as String;
    final content = (args['content'] as String).trim();
    final provenance = args['provenance'] as String?;

    final existing = await _store.getById(id);
    if (existing == null) {
      return {'id': id, 'updated': false, 'error': 'Memory entry not found'};
    }
    if (!_allowedScopes(sessionId, agentId).contains(existing.scope)) {
      return {
        'id': id,
        'updated': false,
        'error': 'Memory entry is outside allowed scopes',
      };
    }

    final updated = await _store.update(
      id: id,
      content: content,
      provenance: provenance,
    );
    if (updated == null) {
      return {'id': id, 'updated': false, 'error': 'Memory entry not found'};
    }
    await _semanticIndex?.upsert(updated);
    return {
      'status': 'updated',
      'updated': true,
      'id': updated.id,
      'contentHash': updated.contentHash,
      'scope': updated.scope,
      'provenance': updated.provenance,
    };
  }

  Future<Map<String, dynamic>> _deleteEntry(
    Map<String, dynamic> args,
    String sessionId,
    String? agentId,
  ) async {
    final id = args['id'] as String;
    final existing = await _store.getById(id);
    if (existing != null &&
        !_allowedScopes(sessionId, agentId).contains(existing.scope)) {
      return {
        'id': id,
        'deleted': false,
        'error': 'Memory entry is outside allowed scopes',
      };
    }
    final removed = await _store.delete(id);
    if (removed) {
      await _semanticIndex?.delete(id);
    }
    return {'id': id, 'deleted': removed};
  }
}
