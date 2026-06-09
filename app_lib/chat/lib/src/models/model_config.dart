import 'dart:io' show Platform;

import 'package:equatable/equatable.dart';

import 'inference.dart';

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
enum ModelCategory { gemma, qwen, deepSeek, phi, other }

/// Runtime memory class for a local model preset.
enum GemmaModelMemoryRequirement {
  /// Normal model size for the app's local inference path.
  standard,

  /// Large model that should not be auto-loaded without an explicit support
  /// path because the OS can terminate the app before Dart can catch an error.
  large,
}

extension GemmaModelMemoryRequirementDisplay on GemmaModelMemoryRequirement {
  String get displayName {
    return switch (this) {
      GemmaModelMemoryRequirement.standard => 'Standard memory',
      GemmaModelMemoryRequirement.large => 'Large memory',
    };
  }
}

/// Information about an available on-device model.
class GemmaModelInfo {
  const GemmaModelInfo({
    required this.id,
    required this.displayName,
    required this.description,
    required this.sizeLabel,
    required this.quantizationLabel,
    required this.url,
    this.androidDescription,
    this.androidSizeLabel,
    this.androidUrl,
    this.iosDescription,
    this.iosSizeLabel,
    this.iosUrl,
    this.category = ModelCategory.gemma,
    this.needsAuth = false,
    this.supportsMultimodal = false,
    this.supportsAudio = false,
    this.supportsThinking = false,
    this.supportsFunctionCalls = false,
    this.memoryRequirement = GemmaModelMemoryRequirement.standard,
    this.minimumMemoryLabel,
  });

  /// Unique identifier, e.g. 'gemma3-1b-int4'.
  final String id;

  /// Human-readable name, e.g. 'Gemma 4 E4B IT'.
  final String displayName;

  /// Short description of the model.
  final String description;

  /// Approximate download size, e.g. '529 MB'.
  final String sizeLabel;

  /// Quantization label, e.g. 'Q4_K_M'.
  final String quantizationLabel;

  /// HuggingFace download URL.
  final String url;

  /// Android-specific model description.
  final String? androidDescription;

  /// Android-specific approximate download size.
  final String? androidSizeLabel;

  /// Android-specific download URL.
  final String? androidUrl;

  /// iOS-specific model description.
  final String? iosDescription;

  /// iOS-specific approximate download size.
  final String? iosSizeLabel;

  /// iOS-specific download URL.
  final String? iosUrl;

  /// Category for grouping in UI.
  final ModelCategory category;

  /// Whether HuggingFace auth token is required.
  final bool needsAuth;

  /// Whether this model supports multimodal (image) input.
  final bool supportsMultimodal;

  /// Whether this model supports audio input.
  final bool supportsAudio;

  /// Whether this model supports thinking/chain-of-thought reasoning.
  final bool supportsThinking;

  /// Whether this model supports function/tool calling.
  final bool supportsFunctionCalls;

  /// Runtime memory class for this model.
  final GemmaModelMemoryRequirement memoryRequirement;

  /// Human-readable minimum memory guidance for large local models.
  final String? minimumMemoryLabel;

  /// Whether vision/multimodal works on the current platform.
  bool get effectiveSupportsMultimodal {
    // Local multimodal execution is currently not supported on any platform.
    return false;
  }

  /// Whether audio input works on the current platform.
  bool get effectiveSupportsAudio {
    // Local audio execution is currently not supported on any platform.
    return false;
  }

  /// Whether function calling works on the current platform.
  bool get effectiveSupportsFunctionCalls {
    // Local function calling is currently not supported on any platform.
    return false;
  }

  /// Whether thinking mode works on the current platform.
  bool get effectiveSupportsThinking {
    if (Platform.isAndroid || Platform.isIOS) {
      return false; // Mobile platforms do not support thinking mode yet.
    }
    return supportsThinking;
  }

  /// Whether this model has an artifact compatible with an operating system.
  bool isCompatibleArtifactForOperatingSystem(String operatingSystem) {
    final lower = downloadUrlForOperatingSystem(operatingSystem).toLowerCase();
    return switch (operatingSystem.toLowerCase()) {
      'android' => lower.endsWith('.litertlm'),
      'ios' => lower.endsWith('.zip') || lower.contains('mlx'),
      _ => lower.endsWith('.gguf'),
    };
  }

  /// Whether this model has a format compatible with the current platform.
  bool get isGguf {
    return isCompatibleArtifactForOperatingSystem(Platform.operatingSystem);
  }

  /// Whether this preset is a 4-bit model compatible with an operating system.
  bool isFourBitArtifactForOperatingSystem(String operatingSystem) {
    return isCompatibleArtifactForOperatingSystem(operatingSystem) &&
        quantizationLabel.startsWith('Q4');
  }

  /// Whether this preset is a 4-bit model compatible with the current platform.
  bool get isFourBitGguf {
    return isFourBitArtifactForOperatingSystem(Platform.operatingSystem);
  }

  /// Whether this model is known to need a large runtime memory budget.
  bool get requiresLargeMemory {
    return memoryRequirement == GemmaModelMemoryRequirement.large;
  }

  /// Whether the app should avoid starting local inference for this model.
  bool get shouldAvoidAutomaticLocalInference => requiresLargeMemory;

  /// Warning shown before the app attempts to run a large local model.
  String? get localInferenceBlockReason {
    if (!shouldAvoidAutomaticLocalInference) return null;
    final memory = minimumMemoryLabel ?? memoryRequirement.displayName;
    return '$displayName is marked as a large-memory model ($memory). '
        'To avoid the operating system terminating the app during native '
        'llama.cpp execution, select Gemma 4 E2B or another smaller model.';
  }

  /// Human-readable runtime memory note for settings UI.
  String get memoryRequirementLabel {
    final minimum = minimumMemoryLabel;
    const baseLabel = 'Uses system memory while loaded';
    if (minimum == null || minimum.isEmpty) {
      return baseLabel;
    }
    return '$baseLabel: $minimum';
  }

  /// Whether this model downloads from Hugging Face on an operating system.
  bool isHuggingFaceDownloadForOperatingSystem(String operatingSystem) {
    return Uri.parse(
          downloadUrlForOperatingSystem(operatingSystem),
        ).host.toLowerCase() ==
        'huggingface.co';
  }

  /// Whether this model downloads from Hugging Face.
  bool get isHuggingFaceDownload {
    return isHuggingFaceDownloadForOperatingSystem(Platform.operatingSystem);
  }

  /// Filename from an operating system's download URL.
  String downloadFileNameForOperatingSystem(String operatingSystem) {
    return Uri.parse(
      downloadUrlForOperatingSystem(operatingSystem),
    ).pathSegments.last;
  }

  /// Filename from the current platform's download URL.
  String get downloadFileName {
    return downloadFileNameForOperatingSystem(Platform.operatingSystem);
  }

  String? _huggingFaceRepoPathForUrl(String url) {
    final uri = Uri.parse(url);
    if (uri.host != 'huggingface.co' || uri.pathSegments.length < 2) {
      return null;
    }
    return '${uri.pathSegments[0]}/${uri.pathSegments[1]}';
  }

  /// Hugging Face `org/repo` path for app-managed model cache layout.
  String? huggingFaceRepoPathForOperatingSystem(String operatingSystem) {
    return _huggingFaceRepoPathForUrl(
      downloadUrlForOperatingSystem(operatingSystem),
    );
  }

  /// Hugging Face `org/repo` path for app-managed model cache layout.
  String? get huggingFaceRepoPath {
    return huggingFaceRepoPathForOperatingSystem(Platform.operatingSystem);
  }

  String _downloadSourceNameForUrl(String url) {
    final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
    if (host == 'huggingface.co') return 'Hugging Face';
    return host.isEmpty ? 'Preset URL' : host;
  }

  /// Human-readable source name for an operating system's preset download URL.
  String downloadSourceNameForOperatingSystem(String operatingSystem) {
    return _downloadSourceNameForUrl(
      downloadUrlForOperatingSystem(operatingSystem),
    );
  }

  /// Human-readable source name for the preset download URL.
  String get downloadSourceName {
    return downloadSourceNameForOperatingSystem(Platform.operatingSystem);
  }

  String _downloadSourceLabelForUrl(String url) {
    return _huggingFaceRepoPathForUrl(url) ??
        Uri.tryParse(url)?.host ??
        'Preset URL';
  }

  /// Human-readable source label for an operating system.
  String downloadSourceLabelForOperatingSystem(String operatingSystem) {
    return _downloadSourceLabelForUrl(
      downloadUrlForOperatingSystem(operatingSystem),
    );
  }

  /// Human-readable source label, usually the Hugging Face `org/repo` path.
  String get downloadSourceLabel {
    return downloadSourceLabelForOperatingSystem(Platform.operatingSystem);
  }

  /// The download URL for this model on a Dart operating system name.
  String downloadUrlForOperatingSystem(String operatingSystem) {
    final normalizedOperatingSystem = operatingSystem.toLowerCase();
    if (normalizedOperatingSystem == 'android' && androidUrl != null) {
      return androidUrl!;
    }
    if (normalizedOperatingSystem == 'ios' && iosUrl != null) {
      return iosUrl!;
    }
    return url;
  }

  /// The download URL for this model on the current platform.
  String get downloadUrl {
    return downloadUrlForOperatingSystem(Platform.operatingSystem);
  }

  /// Description for this model on an operating system.
  String descriptionForOperatingSystem(String operatingSystem) {
    return switch (operatingSystem.toLowerCase()) {
      'android' => androidDescription ?? description,
      'ios' => iosDescription ?? description,
      _ => description,
    };
  }

  /// Description for this model on the current platform.
  String get effectiveDescription {
    return descriptionForOperatingSystem(Platform.operatingSystem);
  }

  /// User-facing artifact format for this model on an operating system.
  String formatLabelForOperatingSystem(String operatingSystem) {
    return switch (operatingSystem.toLowerCase()) {
      'android' => 'LiteRT-LM',
      'ios' => 'MLX',
      _ => 'GGUF',
    };
  }

  /// User-facing artifact format for this model on the current platform.
  String get formatLabel {
    return formatLabelForOperatingSystem(Platform.operatingSystem);
  }

  /// Expected local file extensions for this model on an operating system.
  List<String> fileExtensionsForOperatingSystem(String operatingSystem) {
    return switch (operatingSystem.toLowerCase()) {
      'android' => const ['litertlm'],
      'ios' => const ['zip'],
      _ => const ['gguf'],
    };
  }

  /// The size label for this model on an operating system.
  String sizeLabelForOperatingSystem(String operatingSystem) {
    return switch (operatingSystem.toLowerCase()) {
      'android' => androidSizeLabel ?? sizeLabel,
      'ios' => iosSizeLabel ?? sizeLabel,
      _ => sizeLabel,
    };
  }

  /// The size label for this model.
  String get effectiveSizeLabel {
    return sizeLabelForOperatingSystem(Platform.operatingSystem);
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

  static const _gemma4e2b = GemmaModelInfo(
    id: 'gemma-4-E2B-it',
    displayName: 'Gemma 4 E2B IT',
    description: 'Default local GGUF text model, Q4_K_M',
    sizeLabel: '3.43 GB',
    quantizationLabel: 'Q4_K_M',
    url:
        'https://huggingface.co/dahus/gemma-4-e2b-it-Q4_K_M-GGUF/resolve/main/gemma-4-e2b-Q4_K_M.gguf',
    androidDescription: 'Default Android LiteRT-LM text model',
    androidSizeLabel: '2.4 GB',
    androidUrl:
        'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm',
    iosDescription: 'Default iOS MLX text model',
    iosUrl:
        'https://huggingface.co/mlx-community/gemma-4-E2B-it-4bit-mlx/resolve/main/gemma-4-E2B-it-4bit-mlx.zip',
    needsAuth: false,
    supportsMultimodal: true,
    supportsAudio: true,
    supportsThinking: true,
  );

  static const _gemma4e4b = GemmaModelInfo(
    id: 'gemma-4-E4B-it',
    displayName: 'Gemma 4 E4B IT',
    description: 'Local GGUF text model, Q4_K_M',
    sizeLabel: '5.34 GB',
    quantizationLabel: 'Q4_K_M',
    url:
        'https://huggingface.co/ggml-org/gemma-4-E4B-it-GGUF/resolve/main/gemma-4-E4B-it-Q4_K_M.gguf',
    androidDescription: 'Android LiteRT-LM text model',
    androidSizeLabel: '3.4 GB',
    androidUrl:
        'https://huggingface.co/litert-community/gemma-4-E4B-it-litert-lm/resolve/main/gemma-4-E4B-it.litertlm',
    iosDescription: 'iOS MLX text model',
    iosUrl:
        'https://huggingface.co/mlx-community/gemma-4-E4B-it-4bit-mlx/resolve/main/gemma-4-E4B-it-4bit-mlx.zip',
    needsAuth: false,
    supportsMultimodal: true,
    supportsAudio: true,
    supportsThinking: true,
  );

  // ---------------------------------------------------------------------------
  // Per-platform model lists
  //
  // The local catalog is platform-specific. Android downloads LiteRT-LM
  // artifacts, iOS downloads MLX artifacts, and desktop downloads GGUF
  // artifacts. Model files are downloaded and owned by the app.
  // ---------------------------------------------------------------------------

  /// Models available on mobile platforms (Android, iOS).
  static const mobileModels = <GemmaModelInfo>[_gemma4e2b, _gemma4e4b];

  /// Models available on desktop platforms (macOS, Linux, Windows).
  static const desktopModels = <GemmaModelInfo>[_gemma4e2b, _gemma4e4b];

  /// All known models across all platforms.
  static const availableModels = <GemmaModelInfo>[_gemma4e2b, _gemma4e4b];

  /// The default local model.
  static const defaultModel = _gemma4e2b;

  /// Models for the current platform.
  static List<GemmaModelInfo> get platformModels => availableModels;

  /// The default free model that is compatible with the current platform.
  /// Used for auto-download when no models are installed.
  static GemmaModelInfo? get smallestFreeModel {
    if (!defaultModel.needsAuth &&
        defaultModel.isCurrentPlatformCompatible &&
        !defaultModel.shouldAvoidAutomaticLocalInference) {
      return defaultModel;
    }
    final candidates = platformModels
        .where((m) => !m.needsAuth && !m.shouldAvoidAutomaticLocalInference)
        .toList();
    if (candidates.isEmpty) return null;
    return candidates.first;
  }

  /// Look up a model by its ID or installed filename.
  /// Searches [platformModels] first, then falls back to [availableModels]
  /// so installed-but-incompatible models can still be identified.
  static GemmaModelInfo? findById(String id) {
    return findByIdForOperatingSystem(id, Platform.operatingSystem);
  }

  /// Look up a model by its ID or installed filename on an operating system.
  static GemmaModelInfo? findByIdForOperatingSystem(
    String id,
    String operatingSystem,
  ) {
    // Search platform models first for the common case
    final result = _findInList(id, platformModels, operatingSystem);
    if (result != null) return result;
    // Fall back to all models (e.g. model installed from another platform)
    return _findInList(id, availableModels, operatingSystem);
  }

  static GemmaModelInfo? _findInList(
    String id,
    List<GemmaModelInfo> models,
    String operatingSystem,
  ) {
    for (final model in models) {
      if (model.id == id) return model;
      if (id.contains(model.id) || model.id.contains(id)) return model;
      final urlFilename =
          Uri.parse(
            model.downloadUrlForOperatingSystem(operatingSystem),
          ).pathSegments.lastOrNull ??
          '';
      if (urlFilename.isNotEmpty && id == urlFilename) return model;
    }
    return null;
  }

  /// Whether this model is in the current platform's model list.
  bool get isCurrentPlatformCompatible => platformModels.contains(this);

  /// Whether this model should avoid the GPU backend.
  bool get requiresCpuBackendOnDesktop => false;
}

/// The backend to use for inference.
enum GemmaBackend {
  /// CPU-only inference (fallback).
  cpu,

  /// Metal acceleration on Apple platforms.
  metal,

  /// CUDA acceleration on supported NVIDIA platforms.
  cuda,

  /// Vulkan acceleration on supported platforms.
  vulkan,

  /// NPU acceleration on supported platforms.
  npu,
}

/// Backends supported by the current platform.
List<GemmaBackend> supportedGemmaBackendsForCurrentPlatform() {
  return supportedGemmaBackendsForOperatingSystem(Platform.operatingSystem);
}

/// Backends supported by a Dart [Platform.operatingSystem] value.
List<GemmaBackend> supportedGemmaBackendsForOperatingSystem(
  String operatingSystem,
) {
  return switch (operatingSystem.toLowerCase()) {
    'macos' || 'ios' => const [GemmaBackend.cpu, GemmaBackend.metal],
    'linux' || 'windows' => const [
      GemmaBackend.cpu,
      GemmaBackend.cuda,
      GemmaBackend.vulkan,
    ],
    'android' => const [
      GemmaBackend.cpu,
      GemmaBackend.vulkan,
      GemmaBackend.npu,
    ],
    _ => const [GemmaBackend.cpu],
  };
}

/// Default backend for the current platform.
GemmaBackend defaultGemmaBackendForCurrentPlatform() {
  return defaultGemmaBackendForOperatingSystem(Platform.operatingSystem);
}

/// Default backend for a Dart [Platform.operatingSystem] value.
GemmaBackend defaultGemmaBackendForOperatingSystem(String operatingSystem) {
  final supported = supportedGemmaBackendsForOperatingSystem(operatingSystem);
  if (supported.contains(GemmaBackend.metal)) return GemmaBackend.metal;
  if (operatingSystem.toLowerCase() == 'android') {
    if (supported.contains(GemmaBackend.vulkan)) return GemmaBackend.vulkan;
  }
  return GemmaBackend.cpu;
}

extension GemmaBackendDisplay on GemmaBackend {
  String get displayName {
    return switch (this) {
      GemmaBackend.cpu => 'CPU',
      GemmaBackend.metal => 'Metal',
      GemmaBackend.cuda => 'CUDA',
      GemmaBackend.vulkan => 'Vulkan',
      GemmaBackend.npu => 'NPU',
    };
  }

  bool get usesGpuLayers => this != GemmaBackend.cpu;

  bool get isSupportedOnCurrentPlatform {
    return isSupportedOnOperatingSystem(Platform.operatingSystem);
  }

  bool isSupportedOnOperatingSystem(String operatingSystem) {
    return supportedGemmaBackendsForOperatingSystem(
      operatingSystem,
    ).contains(this);
  }
}

/// Configuration for chat inference.
class ModelConfig extends Equatable {
  const ModelConfig({
    this.inferenceMode = ChatInferenceMode.local,
    this.modelType = GemmaModelType.gemma2bIt,
    this.customModelPath,
    this.localModelId,
    this.maxTokens = 2048,
    this.temperature = 0.8,
    this.topK = 40,
    this.backend = GemmaBackend.cpu,
    this.remoteProvider = RemoteLlmProvider.openAiCompatible,
    RemoteLlmApiType? remoteApiType,
    this.remoteAccountId,
    this.remoteBaseUrl = 'https://api.openai.com/v1',
    this.remoteModel = 'gpt-4.1-mini',
    this.remoteStreamingEnabled = true,
    this.remoteThinkingEffort = RemoteThinkingEffort.off,
  }) : remoteApiType =
           remoteApiType ??
           (remoteProvider == RemoteLlmProvider.openAi
               ? RemoteLlmApiType.openAiResponses
               : remoteProvider == RemoteLlmProvider.anthropic
               ? RemoteLlmApiType.anthropicMessages
               : RemoteLlmApiType.openAiChatCompletions);

  /// Creates a default configuration.
  static const ModelConfig defaultConfig = ModelConfig();

  /// Creates a default configuration with the current platform's backend.
  static ModelConfig get platformDefaultConfig {
    return defaultConfig.withSupportedBackendForCurrentPlatform();
  }

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

  /// The local model ID.
  final String? localModelId;

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

  /// Remote LLM wire protocol.
  final RemoteLlmApiType remoteApiType;

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
    localModelId,
    maxTokens,
    temperature,
    topK,
    backend,
    remoteProvider,
    remoteApiType,
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

    if (localModelId != null) {
      final info = GemmaModelInfo.findById(localModelId!);
      if (info != null) return info.displayName;
      return localModelId!;
    }

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
    return 'remote_visible_models_${remoteProvider.name}_${remoteApiType.name}_'
        '${remoteAccountId ?? 'none'}_${remoteBaseUrl.trim()}';
  }

  ModelConfig copyWith({
    ChatInferenceMode? inferenceMode,
    GemmaModelType? modelType,
    String? customModelPath,
    String? localModelId,
    bool clearLocalModel = false,
    int? maxTokens,
    double? temperature,
    int? topK,
    GemmaBackend? backend,
    RemoteLlmProvider? remoteProvider,
    RemoteLlmApiType? remoteApiType,
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
      localModelId: clearLocalModel ? null : (localModelId ?? this.localModelId),
      maxTokens: maxTokens ?? this.maxTokens,
      temperature: temperature ?? this.temperature,
      topK: topK ?? this.topK,
      backend: backend ?? this.backend,
      remoteProvider: remoteProvider ?? this.remoteProvider,
      remoteApiType: remoteApiType ?? this.remoteApiType,
      remoteAccountId: clearRemoteAccount
          ? null
          : (remoteAccountId ?? this.remoteAccountId),
      remoteBaseUrl: remoteBaseUrl ?? this.remoteBaseUrl,
      remoteModel: remoteModel ?? this.remoteModel,
      remoteStreamingEnabled:
          remoteStreamingEnabled ?? this.remoteStreamingEnabled,
      remoteThinkingEffort: remoteThinkingEffort ?? this.remoteThinkingEffort,
    );
  }

  /// Returns this config with an unsupported backend replaced by the platform
  /// default for [operatingSystem].
  ModelConfig withSupportedBackendForOperatingSystem(String operatingSystem) {
    if (backend.isSupportedOnOperatingSystem(operatingSystem)) return this;
    return copyWith(
      backend: defaultGemmaBackendForOperatingSystem(operatingSystem),
    );
  }

  /// Returns this config with an unsupported backend replaced by the current
  /// platform default.
  ModelConfig withSupportedBackendForCurrentPlatform() {
    return withSupportedBackendForOperatingSystem(Platform.operatingSystem);
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

    if (!backend.isSupportedOnCurrentPlatform) {
      errors.add(
        '${backend.displayName} backend is not supported on '
        '${Platform.operatingSystem}',
      );
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
