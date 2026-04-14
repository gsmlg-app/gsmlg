import 'dart:io' show Platform;

import 'package:equatable/equatable.dart';
import 'package:flutter_gemma/flutter_gemma.dart' as gemma;

/// Re-export flutter_gemma's ModelType so consumers (BLoC, UI) can pass
/// the correct native model type without depending on flutter_gemma directly.
typedef NativeModelType = gemma.ModelType;

/// The type of Gemma model to use.
enum GemmaModelType {
  /// Gemma 2B Instruction-tuned model.
  gemma2bIt,

  /// Gemma 7B Instruction-tuned model.
  gemma7bIt,

  /// A custom model loaded from a file path.
  custom,
}

/// Category grouping for model display.
enum ModelCategory {
  gemma,
  qwen,
  deepSeek,
  phi,
  other,
}

/// Information about an available on-device model.
class GemmaModelInfo {
  const GemmaModelInfo({
    required this.id,
    required this.displayName,
    required this.description,
    required this.sizeLabel,
    required this.url,
    required this.modelType,
    this.category = ModelCategory.gemma,
    this.assetPath,
    this.desktopUrl,
    this.desktopSizeLabel,
    this.needsAuth = false,
    this.supportsMultimodal = false,
    this.supportsAudio = false,
    this.supportsThinking = false,
    this.supportsFunctionCalls = false,
  });

  /// Unique identifier, e.g. 'gemma3-1b-int4'.
  final String id;

  /// Human-readable name, e.g. 'Gemma 3 1B-IT INT4'.
  final String displayName;

  /// Short description of the model.
  final String description;

  /// Approximate download size, e.g. '529 MB'.
  final String sizeLabel;

  /// HuggingFace download URL.
  final String url;

  /// Flutter asset path if bundled with the app (null = download only).
  final String? assetPath;

  /// Optional `.litertlm` download URL for desktop platforms.
  /// When provided, desktop platforms use this URL instead of [url].
  final String? desktopUrl;

  /// Approximate download size on desktop (when [desktopUrl] differs from
  /// [url]). Falls back to [sizeLabel] if null.
  final String? desktopSizeLabel;

  /// The model type for flutter_gemma.
  final gemma.ModelType modelType;

  /// Category for grouping in UI.
  final ModelCategory category;

  /// Whether HuggingFace auth token is required.
  final bool needsAuth;

  /// Whether this model supports multimodal (image) input.
  final bool supportsMultimodal;

  /// Whether this model supports audio input (e.g. Gemma 3n E4B).
  final bool supportsAudio;

  /// Whether this model supports thinking/chain-of-thought reasoning.
  final bool supportsThinking;

  /// Whether this model supports function/tool calling.
  final bool supportsFunctionCalls;

  /// Whether this model is bundled as an app asset.
  bool get isBundled => assetPath != null;

  /// Whether this model uses the LiteRT-LM format (`.litertlm`), which is
  /// required on desktop platforms (macOS, Linux, Windows).
  bool get isLiteRtLm => url.endsWith('.litertlm');

  /// Whether a `.litertlm` variant is available (either natively or via
  /// [desktopUrl]).
  bool get hasLiteRtLm => isLiteRtLm || desktopUrl != null;

  /// The download URL appropriate for the current platform.
  ///
  /// On desktop, returns [desktopUrl] if available, otherwise [url].
  /// On mobile, always returns [url].
  String get downloadUrl {
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      return desktopUrl ?? url;
    }
    return url;
  }

  /// The size label appropriate for the current platform.
  String get effectiveSizeLabel {
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      return desktopSizeLabel ?? sizeLabel;
    }
    return sizeLabel;
  }

  // ---------------------------------------------------------------------------
  // Gemma models
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // Platform support:
  //   _mobileOnly       = {android, ios}
  //   _allNativePlatforms = {android, ios, macos, linux, windows}
  //
  // Desktop (LiteRT-LM gRPC server) requires .litertlm format and does NOT
  // support vision/multimodal model sections — the server crashes with
  // "Unknown model type: tf_lite_end_of_vision".
  // ---------------------------------------------------------------------------

  static const _gemma4e2b = GemmaModelInfo(
    id: 'gemma-4-E2B-it',
    displayName: 'Gemma 4 E2B IT',
    description: 'Next-gen multimodal + function calls + thinking, 2.4B params',
    sizeLabel: '2.4 GB',
    url:
        'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm',
    modelType: gemma.ModelType.gemmaIt,

    needsAuth: false,
    supportsMultimodal: true,
    supportsThinking: true,
    supportsFunctionCalls: true,
  );

  static const _gemma4e4b = GemmaModelInfo(
    id: 'gemma-4-E4B-it',
    displayName: 'Gemma 4 E4B IT',
    description: 'Next-gen multimodal + function calls + thinking, 4.3B params',
    sizeLabel: '4.3 GB',
    url:
        'https://huggingface.co/litert-community/gemma-4-E4B-it-litert-lm/resolve/main/gemma-4-E4B-it.litertlm',
    modelType: gemma.ModelType.gemmaIt,

    needsAuth: false,
    supportsMultimodal: true,
    supportsThinking: true,
    supportsFunctionCalls: true,
  );

  static const _gemma3n2b = GemmaModelInfo(
    id: 'gemma-3n-E2B-it-int4',
    displayName: 'Gemma 3n E2B IT',
    description: 'Multimodal + function calls, 2B params',
    sizeLabel: '3.1 GB',
    url:
        'https://huggingface.co/google/gemma-3n-E2B-it-litert-preview/resolve/main/gemma-3n-E2B-it-int4.task',
    desktopUrl:
        'https://huggingface.co/google/gemma-3n-E2B-it-litert-lm/resolve/main/gemma-3n-E2B-it-int4.litertlm',
    desktopSizeLabel: '3.7 GB',
    modelType: gemma.ModelType.gemmaIt,

    needsAuth: true,
    supportsMultimodal: true,
    supportsFunctionCalls: true,
  );

  static const _gemma3n4b = GemmaModelInfo(
    id: 'gemma-3n-E4B-it-int4',
    displayName: 'Gemma 3n E4B IT',
    description: 'Multimodal + audio + function calls, 4B params',
    sizeLabel: '6.5 GB',
    url:
        'https://huggingface.co/google/gemma-3n-E4B-it-litert-preview/resolve/main/gemma-3n-E4B-it-int4.task',
    desktopUrl:
        'https://huggingface.co/google/gemma-3n-E4B-it-litert-lm/resolve/main/gemma-3n-E4B-it-int4.litertlm',
    desktopSizeLabel: '4.9 GB',
    modelType: gemma.ModelType.gemmaIt,

    needsAuth: true,
    supportsMultimodal: true,
    supportsAudio: true,
    supportsFunctionCalls: true,
  );

  static const _gemma3_1b = GemmaModelInfo(
    id: 'gemma3-1b-it-int4',
    displayName: 'Gemma 3 1B IT',
    description: 'Best balance of quality and size',
    sizeLabel: '529 MB',
    url:
        'https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/gemma3-1b-it-int4.task',
    desktopUrl:
        'https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/gemma3-1b-it-int4.litertlm',
    modelType: gemma.ModelType.gemmaIt,

    needsAuth: true,
  );

  static const _gemma3_270m = GemmaModelInfo(
    id: 'gemma3-270m-it-q8',
    displayName: 'Gemma 3 270M IT',
    description: 'Ultra-compact text-only model',
    sizeLabel: '270 MB',
    url:
        'https://huggingface.co/litert-community/gemma-3-270m-it/resolve/main/gemma3-270m-it-q8.task',
    desktopUrl:
        'https://huggingface.co/litert-community/gemma-3-270m-it/resolve/main/gemma3-270m-it-q8.litertlm',
    desktopSizeLabel: '304 MB',
    modelType: gemma.ModelType.gemmaIt,

    needsAuth: true,
  );

  static const _functionGemma270m = GemmaModelInfo(
    id: 'functiongemma-270M-it',
    displayName: 'FunctionGemma 270M IT',
    description: 'Tool/function calling specialist',
    sizeLabel: '284 MB',
    url:
        'https://huggingface.co/sasha-denisov/function-gemma-270M-it/resolve/main/functiongemma-270M-it.task',
    modelType: gemma.ModelType.functionGemma,

    supportsFunctionCalls: true,
  );

  // ---------------------------------------------------------------------------
  // Qwen models
  // ---------------------------------------------------------------------------

  static const _qwen3_06b = GemmaModelInfo(
    id: 'Qwen3-0.6B',
    displayName: 'Qwen3 0.6B',
    description: 'Function calls, LiteRT-LM format',
    sizeLabel: '586 MB',
    url:
        'https://huggingface.co/litert-community/Qwen3-0.6B/resolve/main/Qwen3-0.6B.litertlm',
    modelType: gemma.ModelType.qwen,
    category: ModelCategory.qwen,

    supportsFunctionCalls: true,
  );

  static const _qwen25_15b = GemmaModelInfo(
    id: 'Qwen2.5-1.5B-Instruct',
    displayName: 'Qwen 2.5 1.5B Instruct',
    description: 'Function calls, high quality',
    sizeLabel: '1.6 GB',
    url:
        'https://huggingface.co/litert-community/Qwen2.5-1.5B-Instruct/resolve/main/Qwen2.5-1.5B-Instruct_multi-prefill-seq_q8_ekv1280.task',
    desktopUrl:
        'https://huggingface.co/litert-community/Qwen2.5-1.5B-Instruct/resolve/main/Qwen2.5-1.5B-Instruct_multi-prefill-seq_q8_ekv4096.litertlm',
    modelType: gemma.ModelType.qwen,
    category: ModelCategory.qwen,

    supportsFunctionCalls: true,
  );

  static const _qwen25_05b = GemmaModelInfo(
    id: 'Qwen2.5-0.5B-Instruct',
    displayName: 'Qwen 2.5 0.5B Instruct',
    description: 'Compact, function calls',
    sizeLabel: '500 MB',
    url:
        'https://huggingface.co/litert-community/Qwen2.5-0.5B-Instruct/resolve/main/Qwen2.5-0.5B-Instruct_multi-prefill-seq_q8_ekv1280.task',
    modelType: gemma.ModelType.qwen,
    category: ModelCategory.qwen,

    supportsFunctionCalls: true,
  );

  // ---------------------------------------------------------------------------
  // DeepSeek
  // ---------------------------------------------------------------------------

  static const _deepseekR1 = GemmaModelInfo(
    id: 'deepseek_q8_ekv1280',
    displayName: 'DeepSeek R1 Distill Qwen 1.5B',
    description: 'Chain-of-thought reasoning model',
    sizeLabel: '1.7 GB',
    url:
        'https://huggingface.co/litert-community/DeepSeek-R1-Distill-Qwen-1.5B/resolve/main/deepseek_q8_ekv1280.task',
    desktopUrl:
        'https://huggingface.co/litert-community/DeepSeek-R1-Distill-Qwen-1.5B/resolve/main/DeepSeek-R1-Distill-Qwen-1.5B_multi-prefill-seq_q8_ekv4096.litertlm',
    desktopSizeLabel: '1.8 GB',
    modelType: gemma.ModelType.deepSeek,
    category: ModelCategory.deepSeek,

    supportsThinking: true,
  );

  // ---------------------------------------------------------------------------
  // Phi
  // ---------------------------------------------------------------------------

  static const _phi4Mini = GemmaModelInfo(
    id: 'Phi-4-mini-instruct',
    displayName: 'Phi-4 Mini Instruct',
    description: 'Microsoft, function calls, 3.8B params',
    sizeLabel: '3.9 GB',
    url:
        'https://huggingface.co/litert-community/Phi-4-mini-instruct/resolve/main/Phi-4-mini-instruct_multi-prefill-seq_q8_ekv4096.task',
    desktopUrl:
        'https://huggingface.co/litert-community/Phi-4-mini-instruct/resolve/main/Phi-4-mini-instruct_multi-prefill-seq_q8_ekv4096.litertlm',
    modelType: gemma.ModelType.general,
    category: ModelCategory.phi,

    supportsFunctionCalls: true,
  );

  // ---------------------------------------------------------------------------
  // Other models
  // ---------------------------------------------------------------------------

  static const _fastVLM = GemmaModelInfo(
    id: 'FastVLM-0.5B',
    displayName: 'FastVLM 0.5B (Vision)',
    description: 'Vision-language model, image understanding',
    sizeLabel: '500 MB',
    url:
        'https://huggingface.co/litert-community/FastVLM-0.5B/resolve/main/FastVLM-0.5B.litertlm',
    modelType: gemma.ModelType.general,
    category: ModelCategory.other,

    supportsMultimodal: true,
  );

  static const _smolLM = GemmaModelInfo(
    id: 'SmolLM-135M-Instruct',
    displayName: 'SmolLM 135M Instruct',
    description: 'Ultra-small, fastest inference',
    sizeLabel: '135 MB',
    url:
        'https://huggingface.co/litert-community/SmolLM-135M-Instruct/resolve/main/SmolLM-135M-Instruct_multi-prefill-seq_q8_ekv1280.task',
    modelType: gemma.ModelType.general,
    category: ModelCategory.other,

  );

  // ---------------------------------------------------------------------------
  // Per-platform model lists
  //
  // Mobile (Android/iOS): all models, supports .task and .litertlm formats.
  // Desktop (macOS/Linux/Windows): .litertlm only, no multimodal/vision
  //   models (LiteRT-LM server crashes on vision sections).
  // ---------------------------------------------------------------------------

  /// Models available on mobile platforms (Android, iOS).
  static const mobileModels = <GemmaModelInfo>[
    // Gemma
    _gemma4e2b,
    _gemma4e4b,
    _gemma3n2b,
    _gemma3n4b,
    _gemma3_1b,
    _gemma3_270m,
    _functionGemma270m,
    // Qwen
    _qwen3_06b,
    _qwen25_15b,
    _qwen25_05b,
    // DeepSeek
    _deepseekR1,
    // Phi
    _phi4Mini,
    // Other
    _fastVLM,
    _smolLM,
  ];

  /// Models available on desktop platforms (macOS, Linux, Windows).
  ///
  /// Requirements:
  /// - Must have a `.litertlm` variant (native or via [desktopUrl]).
  /// - Must NOT be multimodal (LiteRT-LM server crashes on vision sections).
  static const desktopModels = <GemmaModelInfo>[
    // Gemma (text-only with .litertlm)
    _gemma3_1b,
    _gemma3_270m,
    // Qwen
    _qwen3_06b,
    _qwen25_15b,
    // DeepSeek
    _deepseekR1,
    // Phi
    _phi4Mini,
  ];

  /// All known models across all platforms.
  static const availableModels = <GemmaModelInfo>[
    _gemma4e2b,
    _gemma4e4b,
    _gemma3n2b,
    _gemma3n4b,
    _gemma3_1b,
    _gemma3_270m,
    _functionGemma270m,
    _qwen3_06b,
    _qwen25_15b,
    _qwen25_05b,
    _deepseekR1,
    _phi4Mini,
    _fastVLM,
    _smolLM,
  ];

  /// The default bundled model.
  static const defaultModel = _gemma3_1b;

  /// Models for the current platform.
  static List<GemmaModelInfo> get platformModels {
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      return desktopModels;
    }
    return mobileModels;
  }

  /// The smallest model that does not require authentication and is
  /// compatible with the current platform.
  /// Used for auto-download when no models are installed.
  static GemmaModelInfo? get smallestFreeModel {
    final candidates = platformModels.where((m) => !m.needsAuth).toList();
    if (candidates.isEmpty) return null;
    return candidates.first;
  }

  /// Look up a model by its ID or installed filename.
  /// Searches [platformModels] first, then falls back to [availableModels]
  /// so installed-but-incompatible models can still be identified.
  static GemmaModelInfo? findById(String id) {
    // Search platform models first for the common case
    final result = _findInList(id, platformModels);
    if (result != null) return result;
    // Fall back to all models (e.g. model installed from another platform)
    return _findInList(id, availableModels);
  }

  static GemmaModelInfo? _findInList(String id, List<GemmaModelInfo> models) {
    for (final model in models) {
      if (model.id == id) return model;
      if (id.contains(model.id) || model.id.contains(id)) return model;
      final urlFilename =
          Uri.parse(model.downloadUrl).pathSegments.lastOrNull ?? '';
      if (urlFilename.isNotEmpty && id == urlFilename) return model;
    }
    return null;
  }

  /// Whether this model is in the current platform's model list.
  bool get isCurrentPlatformCompatible => platformModels.contains(this);
}

/// The backend to use for inference.
enum GemmaBackend {
  /// GPU acceleration (recommended for performance).
  gpu,

  /// CPU-only inference (fallback).
  cpu,
}

/// Configuration for the Gemma model.
class ModelConfig extends Equatable {
  const ModelConfig({
    this.modelType = GemmaModelType.gemma2bIt,
    this.customModelPath,
    this.maxTokens = 2048,
    this.temperature = 0.8,
    this.topK = 40,
    this.backend = GemmaBackend.gpu,
  });

  /// Creates a default configuration.
  static const ModelConfig defaultConfig = ModelConfig();

  /// The type of model to use.
  final GemmaModelType modelType;

  /// Path to a custom model file (only used when modelType is custom).
  final String? customModelPath;

  /// Maximum number of tokens to generate.
  final int maxTokens;

  /// Temperature for sampling (higher = more random).
  /// Range: 0.0 to 2.0
  final double temperature;

  /// Top-K sampling parameter.
  /// Range: 1 to 100
  final int topK;

  /// The backend to use for inference.
  final GemmaBackend backend;

  @override
  List<Object?> get props => [
        modelType,
        customModelPath,
        maxTokens,
        temperature,
        topK,
        backend,
      ];

  /// Returns the model path for the selected model type.
  String? get effectiveModelPath {
    if (modelType == GemmaModelType.custom) {
      return customModelPath;
    }
    return null;
  }

  /// Returns a human-readable model name.
  String get modelDisplayName {
    return switch (modelType) {
      GemmaModelType.gemma2bIt => 'Gemma 2B-IT',
      GemmaModelType.gemma7bIt => 'Gemma 7B-IT',
      GemmaModelType.custom => customModelPath ?? 'Custom Model',
    };
  }

  ModelConfig copyWith({
    GemmaModelType? modelType,
    String? customModelPath,
    int? maxTokens,
    double? temperature,
    int? topK,
    GemmaBackend? backend,
  }) {
    return ModelConfig(
      modelType: modelType ?? this.modelType,
      customModelPath: customModelPath ?? this.customModelPath,
      maxTokens: maxTokens ?? this.maxTokens,
      temperature: temperature ?? this.temperature,
      topK: topK ?? this.topK,
      backend: backend ?? this.backend,
    );
  }

  /// Validates the configuration and returns errors if any.
  List<String> validate() {
    final errors = <String>[];

    if (maxTokens < 1 || maxTokens > 8192) {
      errors.add('Max tokens must be between 1 and 8192');
    }

    if (temperature < 0.0 || temperature > 2.0) {
      errors.add('Temperature must be between 0.0 and 2.0');
    }

    if (topK < 1 || topK > 100) {
      errors.add('Top-K must be between 1 and 100');
    }

    if (modelType == GemmaModelType.custom &&
        (customModelPath == null || customModelPath!.isEmpty)) {
      errors.add('Custom model path is required when using custom model type');
    }

    return errors;
  }

  /// Returns true if the configuration is valid.
  bool get isValid => validate().isEmpty;
}
