/// A file of the pinned EmbeddingGemma 2 mirror.
class EmbeddingModelFile {
  const EmbeddingModelFile(this.path, this.sha256, this.size);

  /// Path inside the model repository, e.g. `onnx/model_q4.onnx`.
  final String path;
  final String sha256;
  final int size;
}

/// Precision variants published in the mirror. Each graph loads its
/// `.onnx_data` external-data file from the same directory.
enum EmbeddingVariant {
  q4f16('model_q4f16'),
  q4('model_q4'),
  int8('model_quantized'),
  fp16('model_fp16'),
  fp32('model');

  const EmbeddingVariant(this.stem);

  final String stem;

  String get graphPath => 'onnx/$stem.onnx';
  String get dataPath => 'onnx/$stem.onnx_data';
}

/// EmbeddingGemma 2 text model mirrored at [repository] and pinned to
/// [revision]: an unmodified copy of onnx-community/embeddinggemma-2-ONNX
/// (text graph) plus the Google tokenizer files.
abstract final class EmbeddingGemmaModel {
  static const repository = 'gsmlg/embeddinggemma-2';
  static const revision = '604b4b86c6a89a3c6f5ffebd2ce89742edaa6cc5';

  /// Native output size; Matryoshka truncation supports 512, 256 and 128.
  static const dimensions = 768;
  static const matryoshkaDimensions = [768, 512, 256, 128];

  static const tokenizer = EmbeddingModelFile(
    'tokenizer.json',
    '4d777ef5bdc1aa36227abdfb77c3e49e7b9c892d16e1b6bda41c393504828be4',
    32170510,
  );

  static const _variantFiles = {
    EmbeddingVariant.q4f16: [
      EmbeddingModelFile(
        'onnx/model_q4f16.onnx',
        '53feeced79582d661e30adeaa9829cea90d92b1c78347e26fd123773580f71d0',
        495298,
      ),
      EmbeddingModelFile(
        'onnx/model_q4f16.onnx_data',
        'c39fbaa1fb4221f04beb82786a06b81999c514fd39e84fcd58ef79413c87fa56',
        156862464,
      ),
    ],
    EmbeddingVariant.q4: [
      EmbeddingModelFile(
        'onnx/model_q4.onnx',
        'f9eeba97acddf139b8ee2ddf04bc30dceafa88de93fadf74d7644e0d61a477a9',
        490742,
      ),
      EmbeddingModelFile(
        'onnx/model_q4.onnx_data',
        'c3975f2d1ab7a1878ae31a7d7a9b7804a827aff3800b60dfceafce21cac3df49',
        174028800,
      ),
    ],
    EmbeddingVariant.int8: [
      EmbeddingModelFile(
        'onnx/model_quantized.onnx',
        'd06edd601f851c633a2519304cbeb8dc6170d7ceb61b436625c17fb9b6e74953',
        495165,
      ),
      EmbeddingModelFile(
        'onnx/model_quantized.onnx_data',
        '278a7ff1248c3618e4bd11a607fc54f7bdc7778854230f3956d3f86bd9db4f3b',
        313724928,
      ),
    ],
    EmbeddingVariant.fp16: [
      EmbeddingModelFile(
        'onnx/model_fp16.onnx',
        'a49e227d7e0e5f4ee606d79879d084264366367bc6318f344ab179e35d4fd6a4',
        425780,
      ),
      EmbeddingModelFile(
        'onnx/model_fp16.onnx_data',
        'b9dbe09415d77c8686ba6e216a244086f4ada1608238c13f2bfaa587ba627207',
        542085120,
      ),
    ],
    EmbeddingVariant.fp32: [
      EmbeddingModelFile(
        'onnx/model.onnx',
        'bc47de15f81208a5c99e5ab10f746d5e33b51ea228b7dc0bef9c133a94f1c1c3',
        421421,
      ),
      EmbeddingModelFile(
        'onnx/model.onnx_data',
        '9fd452bfc6916e5a92f080f8dada35598ca4512b21c65897d4c5974d5f9630a2',
        1084170240,
      ),
    ],
  };

  /// Every file a [variant] needs, tokenizer included.
  static List<EmbeddingModelFile> filesFor(EmbeddingVariant variant) => [
    tokenizer,
    ..._variantFiles[variant]!,
  ];

  /// Pinned download URL of [file].
  static Uri urlFor(EmbeddingModelFile file) => Uri.https(
    'huggingface.co',
    '/$repository/resolve/$revision/${file.path}',
  );
}
