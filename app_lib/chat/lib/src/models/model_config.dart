import 'dart:io' show Platform, Process;

import 'package:equatable/equatable.dart';
import 'package:flutter_gemma/flutter_gemma.dart' as gemma;

import 'inference.dart';

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

  // ---------------------------------------------------------------------------
  // Platform-effective capabilities
  //
  // These getters account for platform-specific limitations in LiteRT-LM:
  //   Desktop: vision broken (hallucinates), function calling NOT supported.
  //   iOS .litertlm: text only, but iOS also uses .task with full support.
  // ---------------------------------------------------------------------------

  /// Whether vision/multimodal works on the current platform.
  /// Desktop LiteRT-LM: vision is broken (model hallucinates).
  bool get effectiveSupportsMultimodal {
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      return false;
    }
    return supportsMultimodal;
  }

  /// Whether audio input works on the current platform.
  /// Supported on Android and desktop (via LiteRT-LM).
  bool get effectiveSupportsAudio => supportsAudio;

  /// Whether function calling works on the current platform.
  /// Desktop LiteRT-LM: function calling is NOT supported.
  bool get effectiveSupportsFunctionCalls {
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      return false;
    }
    return supportsFunctionCalls;
  }

  /// Whether thinking mode works on the current platform.
  /// Supported on all platforms.
  bool get effectiveSupportsThinking => supportsThinking;

  /// Whether this model is bundled as an app asset.
  bool get isBundled => assetPath != null;

  /// Whether this model uses the LiteRT-LM format (`.litertlm`).
  bool get isLiteRtLm => url.endsWith('.litertlm');

  /// Whether this model uses the GGUF format for llama.cpp.
  bool get isGguf => downloadUrl.endsWith('.gguf');

  /// Whether this model downloads from Hugging Face.
  bool get isHuggingFaceDownload {
    return Uri.parse(downloadUrl).host.toLowerCase() == 'huggingface.co';
  }

  /// Filename from the current platform's download URL.
  String get downloadFileName => Uri.parse(downloadUrl).pathSegments.last;

  /// Hugging Face `org/repo` path for app-managed model cache layout.
  String? get huggingFaceRepoPath {
    final uri = Uri.parse(downloadUrl);
    if (uri.host != 'huggingface.co' || uri.pathSegments.length < 2) {
      return null;
    }
    return '${uri.pathSegments[0]}/${uri.pathSegments[1]}';
  }

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

  /// Maximum KV cache size supported by this model on the current platform.
  ///
  /// Parsed from the download URL filename (e.g. `ekv1280` → 1280).
  /// Returns `null` if no explicit cache size is found in the URL, in which
  /// case the caller should use its own default.
  int? get maxKvCacheSize {
    final effectiveUrl = downloadUrl;
    final match = RegExp(r'ekv(\d+)').firstMatch(effectiveUrl);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Gemma models
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // Platform support:
  //   _mobileOnly       = {android, ios}
  //   _allNativePlatforms = {android, ios, macos, linux, windows}
  //
  // Desktop uses GGUF through lib_llama_cpp when available, and falls back to
  // LiteRT-LM for older model entries that still only publish that format.
  // ---------------------------------------------------------------------------

  static const _gemma4e2b = GemmaModelInfo(
    id: 'gemma-4-E2B-it',
    displayName: 'Gemma 4 E2B IT',
    description: 'Local GGUF text model, 2B effective params',
    sizeLabel: '4.6 GB',
    url:
        'https://huggingface.co/ggml-org/gemma-4-E2B-it-GGUF/resolve/main/gemma-4-E2B-it-Q8_0.gguf',
    modelType: gemma.ModelType.gemmaIt,
    needsAuth: false,
    supportsThinking: true,
  );

  static const _gemma4e4b = GemmaModelInfo(
    id: 'gemma-4-E4B-it',
    displayName: 'Gemma 4 E4B IT',
    description: 'Default local GGUF text model, Q4_K_M',
    sizeLabel: '5.0 GB',
    url:
        'https://huggingface.co/ggml-org/gemma-4-E4B-it-GGUF/resolve/main/gemma-4-E4B-it-Q4_K_M.gguf',
    modelType: gemma.ModelType.gemmaIt,
    needsAuth: false,
    supportsThinking: true,
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
    _gemma4e4b,
    _gemma4e2b,
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
  static const desktopModels = <GemmaModelInfo>[
    // Gemma 4 GGUF through lib_llama_cpp
    _gemma4e4b,
    _gemma4e2b,
    // Gemma 3 text-only
    _gemma3_1b,
    _gemma3_270m,
    // Qwen
    _qwen3_06b,
    _qwen25_15b,
    // DeepSeek
    _deepseekR1,
    // Phi
    _phi4Mini,
    // Excluded — .litertlm contains vision/audio sections that crash the server:
    //   _gemma3n2b, _gemma3n4b, _fastVLM
    // Excluded — no .litertlm variant:
    //   _functionGemma270m, _qwen25_05b, _smolLM
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

  /// The default local model.
  static const defaultModel = _gemma4e4b;

  /// Whether the current desktop machine has an arm64 CPU.
  /// LiteRT-LM native libraries are arm64-only; Intel (x86_64) Macs
  /// cannot run the gRPC inference server.
  static final bool _isDesktopArm64 = () {
    try {
      final result = Process.runSync('uname', ['-m']);
      return (result.stdout as String).trim() == 'arm64';
    } catch (_) {
      return false;
    }
  }();

  /// Models for the current platform.
  static List<GemmaModelInfo> get platformModels {
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      if (!_isDesktopArm64) return const [];
      return desktopModels;
    }
    return mobileModels;
  }

  /// The default free model that is compatible with the current platform.
  /// Used for auto-download when no models are installed.
  static GemmaModelInfo? get smallestFreeModel {
    if (!defaultModel.needsAuth && defaultModel.isCurrentPlatformCompatible) {
      return defaultModel;
    }
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

  /// Whether this model should avoid the desktop GPU LiteRT-LM backend.
  ///
  /// Phi-4 Mini currently crashes the LiteRT-LM Java process on macOS while
  /// initializing the WebGPU/Metal delegate. Use CPU for this model so startup
  /// and manual selection do not take down the app process.
  bool get requiresCpuBackendOnDesktop {
    if (!Platform.isMacOS && !Platform.isLinux && !Platform.isWindows) {
      return false;
    }
    return id == _phi4Mini.id;
  }
}

/// The backend to use for inference.
enum GemmaBackend {
  /// GPU acceleration (recommended for performance).
  gpu,

  /// CPU-only inference (fallback).
  cpu,
}

/// Configuration for chat inference.
class ModelConfig extends Equatable {
  const ModelConfig({
    this.inferenceMode = ChatInferenceMode.local,
    this.modelType = GemmaModelType.gemma2bIt,
    this.customModelPath,
    this.maxTokens = 2048,
    this.temperature = 0.8,
    this.topK = 40,
    this.backend = GemmaBackend.gpu,
    this.remoteProvider = RemoteLlmProvider.openAiCompatible,
    this.remoteAccountId,
    this.remoteBaseUrl = 'https://api.openai.com/v1',
    this.remoteModel = 'gpt-4.1-mini',
    this.remoteStreamingEnabled = true,
    this.remoteThinkingEffort = RemoteThinkingEffort.off,
  });

  /// Creates a default configuration.
  static const ModelConfig defaultConfig = ModelConfig();

  /// Sentinel account ID meaning "send a dummy bearer token".
  ///
  /// Service account IDs are positive auto-increment values, so 0 is reserved
  /// for local/no-auth OpenAI-compatible APIs such as Ollama and LM Studio.
  static const int dummyRemoteAccountId = 0;

  /// Where inference should run.
  final ChatInferenceMode inferenceMode;

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

  /// Remote LLM API family.
  final RemoteLlmProvider remoteProvider;

  /// Service account containing the remote API key.
  final int? remoteAccountId;

  /// Remote API base URL, for example `https://api.openai.com/v1`.
  final String remoteBaseUrl;

  /// Remote model identifier.
  final String remoteModel;

  /// Whether to request streaming responses from the remote API.
  final bool remoteStreamingEnabled;

  /// Provider-side thinking/reasoning effort for remote APIs that support it.
  final RemoteThinkingEffort remoteThinkingEffort;

  @override
  List<Object?> get props => [
        inferenceMode,
        modelType,
        customModelPath,
        maxTokens,
        temperature,
        topK,
        backend,
        remoteProvider,
        remoteAccountId,
        remoteBaseUrl,
        remoteModel,
        remoteStreamingEnabled,
        remoteThinkingEffort,
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
    if (inferenceMode == ChatInferenceMode.remote) return remoteModel;

    return switch (modelType) {
      GemmaModelType.gemma2bIt => 'Gemma 2B-IT',
      GemmaModelType.gemma7bIt => 'Gemma 7B-IT',
      GemmaModelType.custom => customModelPath ?? 'Custom Model',
    };
  }

  /// Human-readable inference mode label.
  String get inferenceModeDisplayName {
    return switch (inferenceMode) {
      ChatInferenceMode.local => 'Local',
      ChatInferenceMode.remote => 'Remote',
    };
  }

  /// Whether enough non-secret remote settings are present.
  bool get isRemoteConfigured {
    return (remoteAccountId != null || remoteUsesDummyToken) &&
        remoteBaseUrl.trim().isNotEmpty &&
        remoteModel.trim().isNotEmpty;
  }

  bool get remoteUsesDummyToken {
    final host = Uri.tryParse(remoteBaseUrl.trim())?.host.toLowerCase();
    return remoteAccountId == dummyRemoteAccountId ||
        (remoteAccountId == null &&
            (host == 'localhost' ||
                host == '127.0.0.1' ||
                host == '0.0.0.0' ||
                host == '::1'));
  }

  /// Preference key for the remote models that should appear in model pickers.
  String get remoteVisibleModelsKey {
    return 'remote_visible_models_${remoteProvider.name}_'
        '${remoteAccountId ?? 'none'}_${remoteBaseUrl.trim()}';
  }

  ModelConfig copyWith({
    ChatInferenceMode? inferenceMode,
    GemmaModelType? modelType,
    String? customModelPath,
    int? maxTokens,
    double? temperature,
    int? topK,
    GemmaBackend? backend,
    RemoteLlmProvider? remoteProvider,
    int? remoteAccountId,
    bool clearRemoteAccount = false,
    String? remoteBaseUrl,
    String? remoteModel,
    bool? remoteStreamingEnabled,
    RemoteThinkingEffort? remoteThinkingEffort,
  }) {
    return ModelConfig(
      inferenceMode: inferenceMode ?? this.inferenceMode,
      modelType: modelType ?? this.modelType,
      customModelPath: customModelPath ?? this.customModelPath,
      maxTokens: maxTokens ?? this.maxTokens,
      temperature: temperature ?? this.temperature,
      topK: topK ?? this.topK,
      backend: backend ?? this.backend,
      remoteProvider: remoteProvider ?? this.remoteProvider,
      remoteAccountId:
          clearRemoteAccount ? null : (remoteAccountId ?? this.remoteAccountId),
      remoteBaseUrl: remoteBaseUrl ?? this.remoteBaseUrl,
      remoteModel: remoteModel ?? this.remoteModel,
      remoteStreamingEnabled:
          remoteStreamingEnabled ?? this.remoteStreamingEnabled,
      remoteThinkingEffort: remoteThinkingEffort ?? this.remoteThinkingEffort,
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

    if (inferenceMode == ChatInferenceMode.remote) {
      final uri = Uri.tryParse(remoteBaseUrl.trim());
      if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
        errors.add('Remote base URL must be a valid URL');
      }
      if (uri != null &&
          uri.scheme != 'https' &&
          !(uri.scheme == 'http' && _isLocalhost(uri.host))) {
        errors.add('Remote base URL must use HTTPS');
      }
    }

    return errors;
  }

  /// Returns true if the configuration is valid.
  bool get isValid => validate().isEmpty;

  static bool _isLocalhost(String host) {
    return host == 'localhost' || host == '127.0.0.1' || host == '::1';
  }
}
