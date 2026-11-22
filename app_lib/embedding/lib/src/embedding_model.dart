import 'package:mediapipe_retrieval/mediapipe_retrieval.dart';

/// Official EmbeddingGemma 2 LiteRT-LM variants supported by MediaPipe's
/// Universal Embedder.
enum EmbeddingModelVariant {
  /// Text and image embeddings (440M parameters, ~388 MB `.litertlm`).
  textVision(
    asset: RetrievalModels.embeddingGemma2TextVision,
    bundleName: 'embedding_gemma_2_text_vision',
    supportsAudio: false,
  ),

  /// Full multimodal text, image, and audio embeddings (740M parameters,
  /// ~485 MB `.litertlm`).
  multimodal(
    asset: RetrievalModels.embeddingGemma2,
    bundleName: 'embedding_gemma_2',
    supportsAudio: true,
  );

  const EmbeddingModelVariant({
    required this.asset,
    required this.bundleName,
    required this.supportsAudio,
  });

  /// Pinned Hugging Face download asset (URL + SHA-256) from `mediapipe_retrieval`.
  final DownloadAsset asset;

  /// Model key used under `hooks.user_defines.mediapipe_retrieval.models`.
  final String bundleName;

  /// Whether this variant includes the audio encoder.
  final bool supportsAudio;

  /// Filename of the `.litertlm` model artifact.
  String get fileName => Uri.parse(asset.url).pathSegments.last;
}

/// Constants and pinned official models for EmbeddingGemma 2 via
/// `mediapipe_retrieval`.
abstract final class EmbeddingGemmaModel {
  /// Native output vector size; Matryoshka truncation supports 512, 256, 128.
  static const dimensions = 768;
  static const matryoshkaDimensions = [768, 512, 256, 128];

  /// Default variant covering text and vision without the larger audio encoder.
  static const defaultVariant = EmbeddingModelVariant.textVision;

  /// Returns the pinned official [DownloadAsset] for [variant].
  static DownloadAsset assetFor(EmbeddingModelVariant variant) => variant.asset;
}
