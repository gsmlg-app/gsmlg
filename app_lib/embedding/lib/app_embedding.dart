/// On-device multimodal embeddings and semantic retrieval with EmbeddingGemma 2
/// on Google's official `mediapipe_retrieval` package.
library;

export 'package:mediapipe_retrieval/mediapipe_retrieval.dart'
    show
        ActivationDataType,
        AudioPart,
        ChunkingMode,
        ContentPart,
        Delegate,
        DownloadAsset,
        Embedding,
        ImagePart,
        ModelSource,
        ModelStore,
        RetrievalModels,
        RetrievalRecord,
        RetrievalResult,
        RuntimeUnavailableException,
        SemanticRetriever,
        SemanticRetrieverOptions,
        TaskCapabilities,
        TextPart,
        UniversalEmbedder,
        UniversalEmbedderOptions,
        UniversalEmbedderResult,
        querySemanticRetrieverCapabilities,
        queryUniversalEmbedderCapabilities;

export 'src/embedding_model.dart';
export 'src/embedding_task.dart';
export 'src/text_embedder.dart';
