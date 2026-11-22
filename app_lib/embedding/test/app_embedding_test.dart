import 'dart:io';
import 'dart:typed_data';

import 'package:app_embedding/app_embedding.dart';
import 'package:flutter_test/flutter_test.dart';

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
    test('exposes pinned official RetrievalModels assets', () {
      expect(
        EmbeddingGemmaModel.assetFor(EmbeddingModelVariant.textVision),
        same(RetrievalModels.embeddingGemma2TextVision),
      );
      expect(
        EmbeddingGemmaModel.assetFor(EmbeddingModelVariant.multimodal),
        same(RetrievalModels.embeddingGemma2),
      );

      for (final variant in EmbeddingModelVariant.values) {
        expect(variant.fileName, endsWith('.litertlm'));
        expect(
          RegExp(r'^[0-9a-f]{64}$').hasMatch(variant.asset.sha256),
          isTrue,
        );
        expect(RetrievalModels.byName[variant.bundleName], same(variant.asset));
      }
    });

    test('flags audio capability per variant', () {
      expect(EmbeddingModelVariant.textVision.supportsAudio, isFalse);
      expect(EmbeddingModelVariant.multimodal.supportsAudio, isTrue);
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

  group('TextEmbedder.similarity', () {
    test('computes cosine similarity for valid vectors', () {
      final a = Float32List.fromList([1, 0, 0]);
      final b = Float32List.fromList([0, 1, 0]);
      final c = Float32List.fromList([3, 4, 0]);
      expect(TextEmbedder.similarity(a, a), closeTo(1.0, 1e-6));
      expect(TextEmbedder.similarity(a, b), closeTo(0.0, 1e-6));
      expect(TextEmbedder.similarity(a, c), closeTo(0.6, 1e-6));
    });

    test('rejects mismatched, empty, zero, or non-finite vectors', () {
      expect(
        () => TextEmbedder.similarity(
          Float32List.fromList([1, 0]),
          Float32List.fromList([1]),
        ),
        throwsArgumentError,
      );
      expect(
        () => TextEmbedder.similarity(Float32List(0), Float32List(0)),
        throwsArgumentError,
      );
      expect(
        () => TextEmbedder.similarity(
          Float32List.fromList([0, 0]),
          Float32List.fromList([1, 0]),
        ),
        throwsArgumentError,
      );
      expect(
        () => TextEmbedder.similarity(
          Float32List.fromList([double.nan, 1]),
          Float32List.fromList([1, 0]),
        ),
        throwsArgumentError,
      );
    });
  });

  group('TextEmbedder.load validation', () {
    test('rejects passing both modelPath and modelBytes', () async {
      await expectLater(
        () => TextEmbedder.load(
          modelPath: '/tmp/model.litertlm',
          modelBytes: Uint8List.fromList([1, 2, 3]),
        ),
        throwsArgumentError,
      );
    });

    test('queries platform capabilities without loading a model', () async {
      final capabilities = await TextEmbedder.queryCapabilities();
      expect(capabilities.supportedDelegates, isNotEmpty);
    });
  });

  // Runs only against a local .litertlm EmbeddingGemma 2 model, e.g.
  // EMBEDDINGGEMMA_MODEL_PATH=/path/to/embeddinggemma-2-text-vision-440m.litertlm flutter test
  final modelPath = Platform.environment['EMBEDDINGGEMMA_MODEL_PATH'];
  group(
    'EmbeddingGemma 2 MediaPipe model',
    () {
      late TextEmbedder embedder;
      setUpAll(
        () async => embedder = await TextEmbedder.load(modelPath: modelPath),
      );
      tearDownAll(() => embedder.close());

      test(
        'ranks semantically matching English and Chinese documents higher',
        () async {
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
          expect(query.length, 768);
          expect(similarities[1], greaterThan(similarities[0]));
          expect(similarities[2], greaterThan(similarities[0]));
        },
      );

      test('truncated query embeddings stay unit length', () async {
        final small = await embedder.embedQuery('red planet', dimensions: 256);
        expect(small.length, 256);
        expect(TextEmbedder.similarity(small, small), closeTo(1, 1e-5));
      });

      test('retrieves matching documents via SemanticRetriever', () async {
        final retriever = await embedder.createRetriever();
        try {
          await retriever.insertDocument(
            'venus',
            "Venus is often called Earth's twin because of its similar size.",
          );
          await retriever.insertDocument(
            'mars',
            'Mars is known as the Red Planet because of its reddish surface.',
          );
          final hits = await retriever.retrieve(
            'Which planet is the Red Planet?',
            limit: 1,
            minSimilarity: 0.0,
          );
          expect(hits.records, isNotEmpty);
          expect(hits.records.first.id, 'mars');
        } finally {
          await retriever.dispose();
        }
      });
    },
    skip: modelPath == null
        ? 'Set EMBEDDINGGEMMA_MODEL_PATH to run model tests'
        : null,
  );
}
