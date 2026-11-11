import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dart_sentencepiece_tokenizer/dart_sentencepiece_tokenizer.dart';
import 'package:lib_onnx/lib_onnx.dart';
import 'package:path/path.dart' as p;

import 'embedding_model.dart';
import 'embedding_task.dart';

/// Text embeddings from a local EmbeddingGemma 2 model directory laid out as
/// the mirror is (`tokenizer.json`, `onnx/<variant>.onnx[_data]`).
///
/// Inference runs in lib_onnx's native worker, off the calling isolate; the
/// tokenizer is parsed in a background isolate. Vectors are L2-normalized, so
/// a dot product is their cosine similarity.
class TextEmbedder {
  TextEmbedder._(this._runtime, this._session, this._tokenizer, this.maxTokens);

  final OnnxRuntime _runtime;
  final InferenceSession _session;
  final SentencePieceTokenizer _tokenizer;

  /// Longer inputs keep their first `maxTokens - 1` tokens and the final
  /// end-of-sequence token.
  final int maxTokens;

  static const _adapter = EmbeddingAdapter(
    hiddenDim: EmbeddingGemmaModel.dimensions,
    hasEmbeddedPooling: true,
  );
  static const _modalities = [
    'image_features',
    'video_features',
    'audio_features',
  ];

  static Future<TextEmbedder> load(
    String modelDirectory, {
    EmbeddingVariant variant = EmbeddingVariant.q4,
    int maxTokens = 2048,
    SessionOptions? options,
  }) async {
    if (maxTokens < 2) {
      throw ArgumentError.value(maxTokens, 'maxTokens', 'must be at least 2');
    }
    final tokenizerPath = p.join(
      modelDirectory,
      EmbeddingGemmaModel.tokenizer.path,
    );
    final tokenizer = await Isolate.run(
      () => TokenizerJsonLoader.fromJsonFile(tokenizerPath),
    );
    final runtime = await OnnxRuntime.createAsync();
    try {
      final session = await InferenceSession.loadFile(
        p.join(modelDirectory, variant.graphPath),
        runtime: runtime,
        options: options ?? SessionOptions.cpuOnly(),
      );
      return TextEmbedder._(runtime, session, tokenizer, maxTokens);
    } catch (_) {
      await runtime.close();
      rethrow;
    }
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
    final ids = tokenIds(text);
    final length = ids.length;
    final inputs = <String, OnnxTensor>{
      'input_ids': OnnxTensor.fromInt64([1, length], ids),
      'attention_mask': OnnxTensor.fromInt64([
        1,
        length,
      ], Int64List(length)..fillRange(0, length, 1)),
      // Text-only: the multimodal graph takes empty modality features.
      for (final name in _modalities)
        name: OnnxTensor.fromFloat32([0, 512], Float32List(0)),
    };
    Map<String, OnnxTensor>? outputs;
    try {
      outputs = await _session.run(inputs);
      final vector = _adapter
          .extractEmbeddings(modelOutput: outputs['sentence_embedding']!)
          .single;
      return truncate(vector, dimensions);
    } finally {
      for (final tensor in [...inputs.values, ...?outputs?.values]) {
        tensor.dispose();
      }
    }
  }

  /// Token ids for [text], capped at [maxTokens].
  Int64List tokenIds(String text) {
    final ids = _tokenizer.encode(text).ids;
    if (ids.length <= maxTokens) return Int64List.fromList(ids);
    return Int64List.fromList([...ids.take(maxTokens - 1), ids.last]);
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
    EmbeddingAdapter.normalizeL2(result);
    return result;
  }

  /// Cosine similarity of two embeddings of equal dimension.
  static double similarity(Float32List a, Float32List b) {
    if (a.length != b.length || a.isEmpty) {
      throw ArgumentError('Embeddings must have the same nonzero dimension');
    }
    var dot = 0.0, na = 0.0, nb = 0.0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      na += a[i] * a[i];
      nb += b[i] * b[i];
    }
    return dot / math.sqrt(na * nb);
  }

  Future<void> close() async {
    await _session.close();
    await _runtime.close();
  }
}
