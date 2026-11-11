# app_embedding

On-device text embeddings with [EmbeddingGemma 2](https://huggingface.co/google/embeddinggemma-2)
running on [`lib_onnx`](https://pub.dev/packages/lib_onnx) (ONNX Runtime) and the
pure-Dart [`dart_sentencepiece_tokenizer`](https://pub.dev/packages/dart_sentencepiece_tokenizer).

## Model

`EmbeddingGemmaModel` pins the mirror [`gsmlg/embeddinggemma-2`](https://huggingface.co/gsmlg/embeddinggemma-2)
to an exact revision and lists each file with its SHA-256, so a downloader can fetch and verify:

```dart
for (final file in EmbeddingGemmaModel.filesFor(EmbeddingVariant.q4)) {
  final url = EmbeddingGemmaModel.urlFor(file); // download to <dir>/<file.path>, check file.sha256
}
```

The `q4` variant (≈175 MB) is the default. Keep the repository layout: `tokenizer.json`
and `onnx/<variant>.onnx` with its `.onnx_data` file beside it.

## Usage

```dart
final embedder = await TextEmbedder.load(modelDirectory);
final query = await embedder.embedQuery('Which planet is red?');
final doc = await embedder.embedDocument('Mars is the red planet.', title: 'Mars');
final score = TextEmbedder.similarity(query, doc);
await embedder.close();
```

- Queries and documents get EmbeddingGemma's task prefixes (`EmbeddingTask`).
- Vectors are 768-d and L2-normalized; pass `dimensions: 512 | 256 | 128` for Matryoshka truncation.
- Inference runs in lib_onnx's native worker; the tokenizer is parsed in a background isolate.
- Inputs longer than `maxTokens` (default 2048) are truncated, keeping the end token.

## Platforms

CPU inference wherever lib_onnx 0.3.0 bundles ONNX Runtime: macOS arm64, Android arm64-v8a,
iOS 15.1+. On other targets (for example Windows) the app still builds and
`TextEmbedder.load` throws `UnsupportedError`.

## Tests

```bash
dart test                                        # unit tests
EMBEDDINGGEMMA_DIR=/path/to/embeddinggemma-2 dart test  # plus real-model checks
```

The model tests compare token ids and similarities with Python ONNX Runtime and
Hugging Face `tokenizers` on the same files.
