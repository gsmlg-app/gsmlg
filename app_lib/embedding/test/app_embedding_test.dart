import 'dart:io';
import 'dart:typed_data';

import 'package:app_embedding/app_embedding.dart';
import 'package:test/test.dart';

void main() {
  group('EmbeddingTask', () {
    test('formats queries with the task instruction', () {
      expect(
        EmbeddingTask.search.formatQuery('red planet'),
        'task: search result | query: red planet',
      );
      expect(
        EmbeddingTask.codeRetrieval.formatQuery('parse json'),
        'task: code retrieval | query: parse json',
      );
    });

    test('formats documents with a title or none', () {
      expect(
        EmbeddingTask.formatDocument('Mars is red.'),
        'title: none | text: Mars is red.',
      );
      expect(
        EmbeddingTask.formatDocument('Mars is red.', title: ' '),
        'title: none | text: Mars is red.',
      );
      expect(
        EmbeddingTask.formatDocument('x', title: 'main.dart'),
        'title: main.dart | text: x',
      );
    });
  });

  group('EmbeddingGemmaModel', () {
    test('lists the tokenizer and both graph files for a variant', () {
      final files = EmbeddingGemmaModel.filesFor(EmbeddingVariant.q4);
      expect(files.map((f) => f.path), [
        'tokenizer.json',
        'onnx/model_q4.onnx',
        'onnx/model_q4.onnx_data',
      ]);
      for (final variant in EmbeddingVariant.values) {
        final paths = EmbeddingGemmaModel.filesFor(
          variant,
        ).map((f) => f.path).toList();
        expect(paths, containsAll([variant.graphPath, variant.dataPath]));
      }
      expect(
        files.every((f) => RegExp(r'^[0-9a-f]{64}$').hasMatch(f.sha256)),
        isTrue,
      );
    });

    test('download URLs are pinned to the mirror revision', () {
      expect(
        EmbeddingGemmaModel.urlFor(EmbeddingGemmaModel.tokenizer).toString(),
        'https://huggingface.co/gsmlg/embeddinggemma-2/resolve/'
        '${EmbeddingGemmaModel.revision}/tokenizer.json',
      );
    });
  });

  group('TextEmbedder.truncate', () {
    test('keeps leading dimensions and re-normalizes', () {
      final vector = Float32List(768)
        ..[0] = 3
        ..[1] = 4
        ..[600] = 12;
      final truncated = TextEmbedder.truncate(vector, 128);
      expect(truncated.length, 128);
      expect(truncated[0], closeTo(0.6, 1e-6));
      expect(truncated[1], closeTo(0.8, 1e-6));
    });

    test('returns the full vector unchanged at 768', () {
      final vector = Float32List(768)..[0] = 1;
      expect(TextEmbedder.truncate(vector, 768), same(vector));
    });

    test('rejects dimensions outside the Matryoshka set', () {
      expect(
        () => TextEmbedder.truncate(Float32List(768)..[0] = 1, 300),
        throwsArgumentError,
      );
    });
  });

  // Runs only against a downloaded model, e.g.
  // EMBEDDINGGEMMA_DIR=/path/to/embeddinggemma-2 dart test
  final modelDir = Platform.environment['EMBEDDINGGEMMA_DIR'];
  group('EmbeddingGemma 2 q4 model', () {
    late TextEmbedder embedder;
    setUpAll(() async => embedder = await TextEmbedder.load(modelDir!));
    tearDownAll(() => embedder.close());

    test('tokenizes like the Hugging Face tokenizer', () {
      final ids = embedder.tokenIds(
        'task: search result | query: Which planet is known as the Red Planet?',
      );
      expect(ids.take(6), [2, 8071, 236787, 3927, 1354, 1109]);
      expect(ids.skip(ids.length - 3), [38342, 236881, 1]);
    });

    test('ranks documents like the Python ONNX Runtime reference', () async {
      final query = await embedder.embedQuery(
        'Which planet is known as the Red Planet?',
      );
      final docs = [
        "Venus is often called Earth's twin because of its similar size and proximity.",
        'Mars, known for its reddish appearance, is often referred to as the Red Planet.',
        '火星因其红色外观而被称为红色星球。',
      ];
      final similarities = [
        for (final doc in docs)
          TextEmbedder.similarity(query, await embedder.embedDocument(doc)),
      ];
      // Reference: Python onnxruntime + tokenizers on the same files.
      expect(similarities[0], closeTo(0.6845, 1e-3));
      expect(similarities[1], closeTo(0.8542, 1e-3));
      expect(similarities[2], closeTo(0.7985, 1e-3));
      expect(query.length, 768);
    });

    test('caps long inputs and keeps the end token', () async {
      final capped = await TextEmbedder.load(modelDir!, maxTokens: 8);
      try {
        final ids = capped.tokenIds('word ' * 100);
        expect(ids.length, 8);
        expect(ids.last, 1);
        expect((await capped.embedText('word ' * 100)).length, 768);
      } finally {
        await capped.close();
      }
    });

    test('truncated query embeddings stay unit length', () async {
      final small = await embedder.embedQuery('red planet', dimensions: 256);
      expect(small.length, 256);
      expect(TextEmbedder.similarity(small, small), closeTo(1, 1e-5));
    });
  }, skip: modelDir == null ? 'Set EMBEDDINGGEMMA_DIR to run model tests' : null);
}
