# app_embedding

On-device embeddings and semantic retrieval with
[EmbeddingGemma 2](https://huggingface.co/litert-community/embeddinggemma-2-text-vision-440m-litert-lm)
powered by Google's official [`mediapipe_retrieval`](https://pub.dev/packages/mediapipe_retrieval)
package (`UniversalEmbedder` + `SemanticRetriever`).

## Models

`EmbeddingModelVariant` exposes Google's official pinned `.litertlm` artifacts
from `RetrievalModels` (Apache 2.0, verified by SHA-256):

- `EmbeddingModelVariant.textVision` (default): 440M text + image model (~388 MB)
- `EmbeddingModelVariant.multimodal`: 740M text + image + audio model (~485 MB)

Models can be supplied from a local path (`modelPath`), downloaded on demand via
`ModelStore` (`allowDownload: true`), or bundled at build time with
`dart run mediapipe_core:bundle_models`.

## Usage

```dart
final embedder = await TextEmbedder.load(modelPath: '/path/to/model.litertlm');
final query = await embedder.embedQuery('Which planet is red?');
final doc = await embedder.embedDocument('Mars is the red planet.', title: 'Mars');
final score = TextEmbedder.similarity(query, doc);

// Optional: on-device vector index (SQLite or in-memory)
final retriever = await embedder.createRetriever();
await retriever.insertDocument('mars', 'Mars is the red planet.');
final hits = await retriever.retrieve('red planet', limit: 3);
await retriever.dispose();

await embedder.close();
```

- Queries and documents can use EmbeddingGemma 2 task prefixes (`EmbeddingTask`).
- Vectors are 768-d and L2-normalized; pass `dimensions: 512 | 256 | 128` for
  Matryoshka truncation.
- `embedImage` and `embedAudio` embed images and 16 kHz mono audio into the same
  768-d space.
- Inference runs on MediaPipe's background native worker isolate.

## Platforms

Uses Google's MediaPipe 1.2.3 retrieval runtime bundled by `mediapipe_retrieval`'s
native build hook across Android 9+ (arm64/x86_64), iOS 15+, macOS 14+ (arm64),
Linux (x64/arm64), Windows (x64), and supported WebGPU browsers.

## Tests

```bash
flutter test                                                          # unit tests
EMBEDDINGGEMMA_MODEL_PATH=/path/to/model.litertlm flutter test        # plus real-model checks
```
