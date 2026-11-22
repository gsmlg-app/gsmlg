import 'dart:async';
import 'dart:developer' as developer;

import 'package:app_embedding/app_embedding.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'memory_provider.dart';

/// One semantic search match returned by a [MemorySemanticIndex].
final class MemorySemanticHit {
  const MemorySemanticHit({required this.entryId, required this.score});

  final String entryId;
  final double score;
}

/// Optional vector index for semantic memory retrieval.
///
/// Implementations return `null` from [search] when the underlying embedding
/// model is unavailable so [ScopedMemoryProvider] falls back to keyword
/// ranking transparently.
abstract interface class MemorySemanticIndex {
  bool get isReady;

  Future<void> upsert(MemoryEntry entry);

  Future<void> delete(String id);

  /// Searches [scopes] semantically, returning best matches first or `null`
  /// when semantic search is unavailable.
  Future<List<MemorySemanticHit>?> search({
    required String query,
    required Set<String> scopes,
    required int limit,
  });

  Future<void> dispose();
}

/// On-device semantic index powered by `app_embedding` (`mediapipe_retrieval`
/// `TextEmbedder` + `SemanticRetriever` running EmbeddingGemma 2).
///
/// The runtime stays dormant until a verified local `.litertlm` model exists
/// (or [ensureLoaded] is called with `allowDownload: true`), avoiding unwanted
/// multi-hundred-megabyte downloads on startup.
class MediaPipeMemorySemanticIndex implements MemorySemanticIndex {
  MediaPipeMemorySemanticIndex({
    this.modelPath,
    this.databasePath,
    this.usePersistentIndex = false,
    this.variant = EmbeddingGemmaModel.defaultVariant,
    this.minSimilarity = 0.25,
    ModelStore? modelStore,
  }) : _modelStore = modelStore;

  final String? modelPath;
  final String? databasePath;
  final bool usePersistentIndex;
  final EmbeddingModelVariant variant;
  final double minSimilarity;
  final ModelStore? _modelStore;

  TextEmbedder? _embedder;
  SemanticRetriever? _retriever;
  Future<bool>? _loading;
  bool _disposed = false;

  @override
  bool get isReady => !_disposed && _retriever != null;

  /// Attempts to initialize the MediaPipe embedder and vector retriever.
  ///
  /// When [allowDownload] is `false` (default), returns `false` if no verified
  /// model is present locally.
  Future<bool> ensureLoaded({bool allowDownload = false}) {
    if (_disposed) return Future.value(false);
    if (_retriever != null) return Future.value(true);
    return _loading ??= _open(allowDownload: allowDownload).whenComplete(() {
      _loading = null;
    });
  }

  Future<bool> _open({required bool allowDownload}) async {
    try {
      String? resolvedPath = modelPath;
      if (resolvedPath == null) {
        final store = _modelStore ?? ModelStore();
        final source = allowDownload
            ? await store.get(variant.asset)
            : await store.find(variant.asset);
        if (source == null) return false;
        resolvedPath = source.path;
      }

      final embedder = await TextEmbedder.load(
        modelPath: resolvedPath,
        variant: variant,
        allowDownload: allowDownload,
        modelStore: _modelStore,
      );
      final effectiveDbPath =
          databasePath ??
          (usePersistentIndex
              ? p.join(
                  (await getApplicationSupportDirectory()).path,
                  'agent_memory_vectors.sqlite',
                )
              : null);
      final SemanticRetriever retriever;
      try {
        retriever = await embedder.createRetriever(
          databasePath: effectiveDbPath,
        );
      } catch (_) {
        await embedder.disposeQuietly();
        rethrow;
      }
      if (_disposed) {
        await retriever.dispose();
        await embedder.disposeQuietly();
        return false;
      }
      _embedder = embedder;
      _retriever = retriever;
      return true;
    } catch (error) {
      developer.log(
        'Semantic memory index unavailable (${error.runtimeType}): $error',
        name: 'app_agent.memory',
      );
      return false;
    }
  }

  @override
  Future<void> upsert(MemoryEntry entry) async {
    if (_disposed) return;
    if (!isReady && !await ensureLoaded()) return;
    final retriever = _retriever;
    if (retriever == null) return;
    try {
      await retriever.insertDocument(
        entry.id,
        entry.content,
        metadata: {
          'scope': entry.scope,
          'provenance': entry.provenance,
          'contentHash': entry.contentHash,
        },
      );
    } catch (error) {
      developer.log(
        'Failed to upsert memory ${entry.id} into semantic index: $error',
        name: 'app_agent.memory',
      );
    }
  }

  @override
  Future<void> delete(String id) async {
    if (_disposed) return;
    final retriever = _retriever;
    if (retriever == null) return;
    try {
      await retriever.delete(id);
    } catch (error) {
      developer.log(
        'Failed to delete memory $id from semantic index: $error',
        name: 'app_agent.memory',
      );
    }
  }

  @override
  Future<List<MemorySemanticHit>?> search({
    required String query,
    required Set<String> scopes,
    required int limit,
  }) async {
    if (_disposed || scopes.isEmpty) return null;
    if (!isReady && !await ensureLoaded()) return null;
    final retriever = _retriever;
    if (retriever == null) return null;

    try {
      final bestById = <String, double>{};
      for (final scope in scopes) {
        final result = await retriever.retrieve(
          query,
          limit: limit,
          minSimilarity: minSimilarity,
          metadataFilter: {'scope': scope},
        );
        for (final record in result.records) {
          final previous = bestById[record.id];
          if (previous == null || record.score > previous) {
            bestById[record.id] = record.score;
          }
        }
      }
      final hits = [
        for (final entry in bestById.entries)
          MemorySemanticHit(entryId: entry.key, score: entry.value),
      ]..sort((a, b) => b.score.compareTo(a.score));
      return hits.take(limit).toList(growable: false);
    } catch (error) {
      developer.log(
        'Semantic memory search failed, falling back to keywords: $error',
        name: 'app_agent.memory',
      );
      return null;
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    final retriever = _retriever;
    final embedder = _embedder;
    _retriever = null;
    _embedder = null;
    if (retriever != null) {
      try {
        await retriever.dispose();
      } catch (_) {}
    }
    if (embedder != null) {
      await embedder.disposeQuietly();
    }
  }
}

extension on TextEmbedder {
  Future<void> disposeQuietly() async {
    try {
      await close();
    } catch (_) {}
  }
}
