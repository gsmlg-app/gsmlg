import 'dart:math' as math;
import 'dart:typed_data';

import 'package:mediapipe_retrieval/mediapipe_retrieval.dart';

import 'embedding_model.dart';
import 'embedding_task.dart';

/// On-device embeddings powered by Google's official `mediapipe_retrieval`
/// [UniversalEmbedder] running EmbeddingGemma 2 (`.litertlm`).
///
/// Inference runs off the calling isolate on MediaPipe's native retrieval
/// worker (Android, iOS, macOS, Linux x64/arm64, Windows x64) or via WebGPU
/// in supported browsers. Vectors are L2-normalized by default, so a dot
/// product equals their cosine similarity.
class TextEmbedder {
  TextEmbedder._(this._embedder);

  final UniversalEmbedder _embedder;

  /// The underlying MediaPipe [UniversalEmbedder], for direct access or
  /// integration with [SemanticRetriever].
  UniversalEmbedder get universalEmbedder => _embedder;

  /// The processor delegate fixed when this embedder was created.
  Delegate get delegate => _embedder.delegate;

  /// Queries platform delegate support without loading a model.
  static Future<TaskCapabilities> queryCapabilities() =>
      queryUniversalEmbedderCapabilities();

  /// Loads an EmbeddingGemma 2 model through MediaPipe [UniversalEmbedder].
  ///
  /// Supply at most one of [modelPath] or [modelBytes]; when both are omitted,
  /// [variant] is resolved via [modelStore] (downloading if [allowDownload] is
  /// `true` or reusing a cached/bundled copy).
  ///
  /// [maxInputLength] defaults to `0` (the model's built-in default, ~0.4 GB
  /// memory). Raising it reserves memory for the full length at creation time.
  static Future<TextEmbedder> load({
    String? modelPath,
    Uint8List? modelBytes,
    EmbeddingModelVariant variant = EmbeddingGemmaModel.defaultVariant,
    int maxInputLength = 0,
    int visionTokensPerImage = 0,
    ActivationDataType activationDataType = ActivationDataType.modelDefault,
    bool l2Normalize = true,
    String? cacheDir,
    Delegate? delegate,
    bool allowDownload = false,
    ModelStore? modelStore,
  }) async {
    if (modelPath != null && modelBytes != null) {
      throw ArgumentError('Supply at most one of modelPath and modelBytes.');
    }

    final effectiveDelegate = delegate ?? await _defaultDelegate();

    String? resolvedPath = modelPath;
    Uint8List? resolvedBytes = modelBytes;
    DownloadAsset? pinnedModel;

    if (resolvedPath == null && resolvedBytes == null) {
      if (allowDownload || modelStore != null) {
        final store = modelStore ?? ModelStore();
        final source = allowDownload
            ? await store.get(variant.asset)
            : await store.find(variant.asset);
        if (source != null) {
          resolvedPath = source.path;
          resolvedBytes = source.bytes;
        } else {
          pinnedModel = variant.asset;
        }
      } else {
        pinnedModel = variant.asset;
      }
    }

    final embedder = await UniversalEmbedder.create(
      UniversalEmbedderOptions(
        model: pinnedModel,
        modelPath: resolvedPath,
        modelBytes: resolvedBytes,
        delegate: effectiveDelegate,
        l2Normalize: l2Normalize,
        maxInputLength: maxInputLength,
        visionTokensPerImage: visionTokensPerImage,
        activationDataType: activationDataType,
        cacheDir: cacheDir,
      ),
    );
    return TextEmbedder._(embedder);
  }

  static Future<Delegate> _defaultDelegate() async {
    final capabilities = await queryUniversalEmbedderCapabilities();
    final supported = capabilities.supportedDelegates;
    return supported.isNotEmpty ? supported.first : Delegate.cpu;
  }

  /// Creates an on-device [SemanticRetriever] backed by this embedder.
  ///
  /// Dispose the returned retriever before calling [close] on this embedder.
  Future<SemanticRetriever> createRetriever({
    String? databasePath,
    int embeddingDimension = EmbeddingGemmaModel.dimensions,
    int chunkSize = 512,
    int chunkOverlap = 100,
    ChunkingMode chunkingMode = ChunkingMode.character,
  }) {
    return SemanticRetriever.create(
      SemanticRetrieverOptions(
        embedder: _embedder,
        databasePath: databasePath,
        embeddingDimension: embeddingDimension,
        chunkSize: chunkSize,
        chunkOverlap: chunkOverlap,
        chunkingMode: chunkingMode,
      ),
    );
  }

  /// Embeds a query (or either side of a symmetric [task]).
  Future<Float32List> embedQuery(
    String text, {
    EmbeddingTask task = EmbeddingTask.search,
    int dimensions = EmbeddingGemmaModel.dimensions,
  }) => embedText(task.formatQuery(text), dimensions: dimensions);

  /// Embeds a corpus document for asymmetric retrieval tasks.
  Future<Float32List> embedDocument(
    String text, {
    String? title,
    int dimensions = EmbeddingGemmaModel.dimensions,
  }) => embedText(
    EmbeddingTask.formatDocument(text, title: title),
    dimensions: dimensions,
  );

  /// Embeds already-formatted [text] without adding a task prefix.
  Future<Float32List> embedText(
    String text, {
    int dimensions = EmbeddingGemmaModel.dimensions,
  }) async {
    _validateDimensions(dimensions);
    final result = await _embedder.embedText(text);
    return _extractVector(result, dimensions);
  }

  /// Embeds an encoded JPEG or PNG image into the same vector space as text.
  Future<Float32List> embedImage(
    Uint8List imageBytes, {
    int dimensions = EmbeddingGemmaModel.dimensions,
  }) async {
    _validateDimensions(dimensions);
    final result = await _embedder.embedImage(imageBytes);
    return _extractVector(result, dimensions);
  }

  /// Embeds mono 16 kHz PCM audio samples (requires
  /// [EmbeddingModelVariant.multimodal]).
  Future<Float32List> embedAudio(
    Float32List audioData, {
    int dimensions = EmbeddingGemmaModel.dimensions,
  }) async {
    _validateDimensions(dimensions);
    final result = await _embedder.embedAudio(audioData);
    return _extractVector(result, dimensions);
  }

  Float32List _extractVector(UniversalEmbedderResult result, int dimensions) {
    final floatVector = result.embeddings.first.floatEmbedding;
    if (floatVector == null) {
      throw StateError('UniversalEmbedder returned a non-float embedding.');
    }
    return truncate(floatVector, dimensions);
  }

  static void _validateDimensions(int dimensions) {
    if (!EmbeddingGemmaModel.matryoshkaDimensions.contains(dimensions)) {
      throw ArgumentError.value(
        dimensions,
        'dimensions',
        'must be one of ${EmbeddingGemmaModel.matryoshkaDimensions}',
      );
    }
  }

  /// Matryoshka truncation: keeps the leading [dimensions] and re-normalizes.
  static Float32List truncate(Float32List vector, int dimensions) {
    if (!EmbeddingGemmaModel.matryoshkaDimensions.contains(dimensions) ||
        dimensions > vector.length) {
      throw ArgumentError.value(
        dimensions,
        'dimensions',
        'must be one of ${EmbeddingGemmaModel.matryoshkaDimensions}',
      );
    }
    if (dimensions == vector.length) return vector;
    final result = Float32List.fromList(vector.sublist(0, dimensions));
    _normalizeL2(result);
    return result;
  }

  static void _normalizeL2(Float32List vector) {
    var sumSquares = 0.0;
    for (var i = 0; i < vector.length; i++) {
      final value = vector[i];
      sumSquares += value * value;
    }
    final norm = math.sqrt(sumSquares);
    if (norm == 0 || !norm.isFinite) return;
    for (var i = 0; i < vector.length; i++) {
      vector[i] = vector[i] / norm;
    }
  }

  /// Cosine similarity of two embeddings of equal dimension.
  static double similarity(Float32List a, Float32List b) {
    if (a.length != b.length || a.isEmpty) {
      throw ArgumentError('Embeddings must have the same nonzero dimension');
    }
    var dot = 0.0;
    var na = 0.0;
    var nb = 0.0;
    for (var i = 0; i < a.length; i++) {
      final av = a[i];
      final bv = b[i];
      if (!av.isFinite || !bv.isFinite) {
        throw ArgumentError('Embeddings must contain finite values');
      }
      dot += av * bv;
      na += av * av;
      nb += bv * bv;
    }
    if (na == 0 || nb == 0 || !dot.isFinite || !na.isFinite || !nb.isFinite) {
      throw ArgumentError('Embedding norms must be finite and nonzero');
    }
    return (dot / (math.sqrt(na) * math.sqrt(nb))).clamp(-1.0, 1.0);
  }

  /// Releases the underlying MediaPipe runtime resources.
  Future<void> close() => _embedder.dispose();
}
