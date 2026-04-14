import 'dart:async';
import 'dart:collection';

import 'package:app_chat/app_chat.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'event.dart';
part 'state.dart';

/// Maximum number of concurrent model downloads.
const int _maxConcurrentDownloads = 3;

/// BLoC for managing Gemma model lifecycle.
class GemmaModelBloc extends Bloc<GemmaModelEvent, GemmaModelState> {
  GemmaModelBloc({
    required GemmaRepository repository,
    required SharedPreferences preferences,
    required ToolExecutor toolExecutor,
  })  : _repository = repository,
        _preferences = preferences,
        _toolExecutor = toolExecutor,
        super(GemmaModelState(
          selectedModelId: preferences.getString('gemma_selected_model_id'),
        )) {
    on<GemmaModelInitialize>(_onInitialize);
    on<GemmaModelCheckInstallation>(_onCheckInstallation);
    on<GemmaModelInstall>(_onInstall);
    on<GemmaModelInstallFromAsset>(_onInstallFromAsset);
    on<GemmaModelListInstalled>(_onListInstalled);
    on<GemmaModelSetProxy>(_onSetProxy);
    on<GemmaModelLoad>(_onLoad);
    on<GemmaModelUnload>(_onUnload);
    on<GemmaModelDelete>(_onDelete);
    on<GemmaModelSelect>(_onSelect);
    on<GemmaModelDeleteById>(_onDeleteById);
    on<GemmaModelDismissFailure>(_onDismissFailure);
    on<_GemmaModelStatusChanged>(_onStatusChanged);
    on<_GemmaModelDownloadProgress>(_onDownloadProgress);
    on<_GemmaModelDownloadComplete>(_onDownloadComplete);

    _statusSubscription = _repository.statusStream.listen((status) {
      add(_GemmaModelStatusChanged(status));
    });

    _progressSubscription = _repository.progressStream.listen((progress) {
      add(_GemmaModelDownloadProgress(progress));
    });
  }

  static const _selectedModelKey = 'gemma_selected_model_id';
  static const _thinkingEnabledKey = 'chat_thinking_enabled';

  final GemmaRepository _repository;
  final SharedPreferences _preferences;
  final ToolExecutor _toolExecutor;
  StreamSubscription<GemmaModelStatus>? _statusSubscription;
  StreamSubscription<DownloadProgress>? _progressSubscription;

  /// Whether to suppress queued status-stream events.
  bool _suppressStatusStream = false;

  /// Queue of pending download requests when max concurrent is reached.
  final Queue<GemmaModelInstall> _downloadQueue = Queue();

  /// Tracks which model ID the repository is currently downloading for
  /// progress mapping. Only the actively-downloading model gets progress
  /// events from the single repository stream.
  String? _activeRepositoryDownloadModelId;

  Future<void> _onInitialize(
    GemmaModelInitialize event,
    Emitter<GemmaModelState> emit,
  ) async {
    debugPrint(
        '[GemmaModelBloc] _onInitialize(modelType=${event.modelType}), current status=${state.status}');

    // Skip if already ready — avoid resetting state on re-navigation.
    if (state.status == GemmaModelStatus.ready) {
      debugPrint('[GemmaModelBloc] Already ready, skipping re-initialization');
      return;
    }

    _suppressStatusStream = true;
    emit(state.copyWith(status: GemmaModelStatus.checking));

    // Refresh installed models list
    debugPrint('[GemmaModelBloc] Fetching installed models list...');
    final installed = await _repository.listInstalledModels();
    debugPrint('[GemmaModelBloc] Installed models: $installed');

    // Restore persisted selection
    final savedId = _preferences.getString(_selectedModelKey);
    debugPrint('[GemmaModelBloc] Persisted selectedModelId: $savedId');

    emit(state.copyWith(
      installedModels: installed,
      selectedModelId: savedId,
    ));

    // If any model is already installed, try to activate and auto-load.
    if (installed.isNotEmpty) {
      debugPrint(
          '[GemmaModelBloc] ${installed.length} model(s) already installed');

      // Build candidate list: persisted selection first, then remaining.
      final candidates = <String>[];
      if (savedId != null && installed.contains(savedId)) {
        candidates.add(savedId);
      }
      for (final id in installed) {
        if (!candidates.contains(id)) candidates.add(id);
      }

      var loaded = false;
      for (final modelId in candidates) {
        debugPrint('[GemmaModelBloc] Trying model candidate: $modelId');

        if (modelId != state.selectedModelId) {
          await _preferences.setString(_selectedModelKey, modelId);
          emit(state.copyWith(selectedModelId: modelId));
        }

        final modelInfo = _findModelInfoByInstalledId(modelId);
        if (modelInfo == null) {
          debugPrint(
              '[GemmaModelBloc] No matching model info for: $modelId, skipping');
          continue;
        }
        if (!modelInfo.isCurrentPlatformCompatible) {
          debugPrint(
              '[GemmaModelBloc] ${modelInfo.displayName} is not compatible with this platform, skipping');
          continue;
        }
        debugPrint(
            '[GemmaModelBloc] Activating: ${modelInfo.displayName} (id: $modelId)');
        await _repository.activateModel(modelInfo);

        if (_repository.status == GemmaModelStatus.installed) {
          debugPrint('[GemmaModelBloc] Auto-loading model into memory...');
          emit(state.copyWith(
            status: GemmaModelStatus.loading,
            modelType: event.modelType,
          ));
          await _loadModelWithCapabilities(ModelConfig.defaultConfig, modelInfo,
              thinkingEnabled:
                  _preferences.getBool(_thinkingEnabledKey) ?? false);
          debugPrint(
              '[GemmaModelBloc] Auto-load done, repo status: ${_repository.status}');

          if (_repository.status == GemmaModelStatus.ready) {
            debugPrint('[GemmaModelBloc] Model $modelId loaded successfully');
            emit(state.copyWith(status: GemmaModelStatus.ready));
            loaded = true;
            break;
          }

          debugPrint(
              '[GemmaModelBloc] Model $modelId failed to load (status=${_repository.status})');
          continue;
        }
      }

      if (!loaded) {
        debugPrint('[GemmaModelBloc] All model candidates failed to load');
        final refreshed = await _repository.listInstalledModels();
        emit(state.copyWith(
          status: refreshed.isEmpty
              ? GemmaModelStatus.notInstalled
              : GemmaModelStatus.error,
          installedModels: refreshed,
          errorMessage: _repository.lastError ?? 'Failed to load model.',
        ));
      }
    } else {
      // No models installed — just report not installed.
      // Users must download models manually from the model management screen.
      debugPrint('[GemmaModelBloc] No models available, setting notInstalled');
      emit(state.copyWith(status: GemmaModelStatus.notInstalled));
    }
    _suppressStatusStream = false;
    debugPrint(
        '[GemmaModelBloc] _onInitialize done, final status: ${state.status}');
  }

  Future<void> _onCheckInstallation(
    GemmaModelCheckInstallation event,
    Emitter<GemmaModelState> emit,
  ) async {
    debugPrint(
        '[GemmaModelBloc] _onCheckInstallation(modelType=${event.modelType})');
    emit(state.copyWith(status: GemmaModelStatus.checking));
    await _repository.checkModelInstalled(event.modelType);
  }

  Future<void> _onInstall(
    GemmaModelInstall event,
    Emitter<GemmaModelState> emit,
  ) async {
    final modelId = event.modelId ?? event.url;
    debugPrint(
        '[GemmaModelBloc] _onInstall(modelId=$modelId, activeDownloads=${state.activeDownloads.length})');

    // Don't allow duplicate downloads
    if (state.isModelDownloading(modelId)) {
      debugPrint('[GemmaModelBloc] Model $modelId is already downloading');
      return;
    }

    // If at max concurrent, queue the request
    if (state.activeDownloads.length >= _maxConcurrentDownloads) {
      debugPrint('[GemmaModelBloc] Max concurrent reached, queuing $modelId');
      _downloadQueue.add(event);
      return;
    }

    // Add to active downloads, clear from failed list
    final updatedDownloads = [
      ...state.activeDownloads,
      ModelDownloadProgress(modelId: modelId),
    ];
    final updatedFailed =
        state.failedDownloads.where((f) => f.modelId != modelId).toList();
    emit(state.copyWith(
      status: GemmaModelStatus.downloading,
      activeDownloads: updatedDownloads,
      failedDownloads: updatedFailed,
    ));

    // Start the actual download
    _startDownload(event);
  }

  void _startDownload(GemmaModelInstall event) {
    final modelId = event.modelId ?? event.url;
    _activeRepositoryDownloadModelId = modelId;

    final proxy = state.proxyUrl;
    debugPrint(
        '[GemmaModelBloc] Starting download for $modelId, proxy: $proxy');

    // Run download in a fire-and-forget fashion so multiple can be queued.
    // The repository streams progress/status that we handle via events.
    () async {
      String? errorMessage;
      try {
        if (proxy != null && proxy.isNotEmpty) {
          await _repository.installModelWithProxy(
            nativeModelType: event.nativeModelType,
            url: event.url,
            proxyUrl: proxy,
            token: event.token,
          );
        } else {
          await _repository.installModel(
            nativeModelType: event.nativeModelType,
            url: event.url,
            token: event.token,
          );
        }
      } catch (e) {
        errorMessage = e.toString();
        debugPrint(
            '[GemmaModelBloc] Download failed for $modelId: $errorMessage');
      } finally {
        add(_GemmaModelDownloadComplete(
          modelId: modelId,
          errorMessage: errorMessage ?? _repository.lastError,
        ));
      }
    }();
  }

  Future<void> _onDownloadComplete(
    _GemmaModelDownloadComplete event,
    Emitter<GemmaModelState> emit,
  ) async {
    final hasFailed = event.errorMessage != null;
    debugPrint(
        '[GemmaModelBloc] Download complete: ${event.modelId}, failed=$hasFailed');

    // Remove from active downloads
    final updatedDownloads =
        state.activeDownloads.where((d) => d.modelId != event.modelId).toList();

    // Track failed download (replace existing entry for same model)
    final updatedFailed = [
      ...state.failedDownloads.where((f) => f.modelId != event.modelId),
      if (hasFailed)
        FailedDownload(
          modelId: event.modelId,
          errorMessage: event.errorMessage!,
        ),
    ];

    // Refresh installed list
    final installed = await _repository.listInstalledModels();
    debugPrint('[GemmaModelBloc] Post-download installed models: $installed');

    emit(state.copyWith(
      installedModels: installed,
      activeDownloads: updatedDownloads,
      failedDownloads: updatedFailed,
      status: updatedDownloads.isEmpty &&
              state.status == GemmaModelStatus.downloading
          ? (installed.isNotEmpty
              ? GemmaModelStatus.installed
              : GemmaModelStatus.notInstalled)
          : null,
    ));

    // Process queued downloads
    if (_downloadQueue.isNotEmpty &&
        state.activeDownloads.length < _maxConcurrentDownloads) {
      final next = _downloadQueue.removeFirst();
      add(next);
    }
  }

  Future<void> _onInstallFromAsset(
    GemmaModelInstallFromAsset event,
    Emitter<GemmaModelState> emit,
  ) async {
    debugPrint(
        '[GemmaModelBloc] _onInstallFromAsset(modelId=${event.modelId}, assetPath=${event.assetPath})');

    final updatedDownloads = [
      ...state.activeDownloads,
      ModelDownloadProgress(modelId: event.modelId),
    ];
    emit(state.copyWith(
      status: GemmaModelStatus.downloading,
      activeDownloads: updatedDownloads,
    ));

    final modelInfo = GemmaModelInfo.findById(event.modelId);
    debugPrint(
        '[GemmaModelBloc] Resolved model info: ${modelInfo?.displayName ?? 'not found, using default'}');
    await _repository.installModelFromAsset(
      modelType: modelInfo?.modelType ?? GemmaModelInfo.defaultModel.modelType,
      assetPath: event.assetPath,
    );

    debugPrint(
        '[GemmaModelBloc] Asset install returned, refreshing installed list...');
    final installed = await _repository.listInstalledModels();
    debugPrint('[GemmaModelBloc] Post-asset-install models: $installed');

    final postDownloads =
        state.activeDownloads.where((d) => d.modelId != event.modelId).toList();
    emit(state.copyWith(
      installedModels: installed,
      activeDownloads: postDownloads,
    ));

    // Auto-select + activate + load the newly installed model.
    if (installed.isNotEmpty) {
      await _autoSelectAndLoad(installed, event.modelId, emit);
    }
  }

  /// Auto-selects, activates, and loads a model after installation.
  Future<void> _autoSelectAndLoad(
    List<String> installed,
    String? preferredModelId,
    Emitter<GemmaModelState> emit,
  ) async {
    _suppressStatusStream = true;

    final candidates = <String>[];
    if (preferredModelId != null && installed.contains(preferredModelId)) {
      candidates.add(preferredModelId);
    }
    final currentSel = state.selectedModelId;
    if (currentSel != null &&
        installed.contains(currentSel) &&
        !candidates.contains(currentSel)) {
      candidates.add(currentSel);
    }
    for (final id in installed) {
      if (!candidates.contains(id)) candidates.add(id);
    }

    for (final modelId in candidates) {
      debugPrint('[GemmaModelBloc] _autoSelectAndLoad: trying $modelId');
      await _preferences.setString(_selectedModelKey, modelId);
      emit(state.copyWith(selectedModelId: modelId));

      final modelInfo = _findModelInfoByInstalledId(modelId);
      if (modelInfo == null) {
        debugPrint(
            '[GemmaModelBloc] No matching model info for: $modelId, skipping');
        continue;
      }
      if (!modelInfo.isCurrentPlatformCompatible) {
        debugPrint(
            '[GemmaModelBloc] ${modelInfo.displayName} is not compatible with this platform, skipping');
        continue;
      }
      debugPrint(
          '[GemmaModelBloc] Activating model: ${modelInfo.displayName}');
      await _repository.activateModel(modelInfo);

      if (_repository.status == GemmaModelStatus.installed) {
        debugPrint('[GemmaModelBloc] Auto-loading model into memory...');
        emit(state.copyWith(status: GemmaModelStatus.loading));
        await _loadModelWithCapabilities(ModelConfig.defaultConfig, modelInfo,
            thinkingEnabled:
                _preferences.getBool(_thinkingEnabledKey) ?? false);
        debugPrint(
            '[GemmaModelBloc] Auto-load done, repo status: ${_repository.status}');

        if (_repository.status == GemmaModelStatus.ready) {
          debugPrint('[GemmaModelBloc] Model $modelId loaded successfully');
          emit(state.copyWith(status: GemmaModelStatus.ready));
          _suppressStatusStream = false;
          return;
        }

        debugPrint(
            '[GemmaModelBloc] Model $modelId failed to load (status=${_repository.status})');
        continue;
      }

      debugPrint(
          '[GemmaModelBloc] Model $modelId activation status: ${_repository.status}, trying next...');
    }

    debugPrint('[GemmaModelBloc] All model candidates failed to load');
    final refreshed = await _repository.listInstalledModels();
    emit(state.copyWith(
      status: refreshed.isEmpty
          ? GemmaModelStatus.notInstalled
          : GemmaModelStatus.error,
      installedModels: refreshed,
      errorMessage: _repository.lastError ?? 'Failed to load model.',
    ));
    _suppressStatusStream = false;
  }

  Future<void> _onListInstalled(
    GemmaModelListInstalled event,
    Emitter<GemmaModelState> emit,
  ) async {
    debugPrint('[GemmaModelBloc] _onListInstalled');
    final installed = await _repository.listInstalledModels();
    debugPrint('[GemmaModelBloc] Listed installed models: $installed');
    emit(state.copyWith(installedModels: installed));
  }

  void _onSetProxy(
    GemmaModelSetProxy event,
    Emitter<GemmaModelState> emit,
  ) {
    debugPrint('[GemmaModelBloc] _onSetProxy(proxyUrl=${event.proxyUrl})');
    if (event.proxyUrl == null || event.proxyUrl!.isEmpty) {
      emit(state.copyWith(clearProxy: true));
    } else {
      emit(state.copyWith(proxyUrl: event.proxyUrl));
    }
  }

  Future<void> _onLoad(
    GemmaModelLoad event,
    Emitter<GemmaModelState> emit,
  ) async {
    debugPrint('[GemmaModelBloc] _onLoad(config=${event.config})');
    emit(state.copyWith(status: GemmaModelStatus.loading));
    final modelInfo = state.selectedModelId != null
        ? _findModelInfoByInstalledId(state.selectedModelId!)
        : null;
    await _loadModelWithCapabilities(event.config, modelInfo,
        thinkingEnabled: _preferences.getBool(_thinkingEnabledKey) ?? false);
    debugPrint(
        '[GemmaModelBloc] _onLoad done, repo status: ${_repository.status}');

    if (_repository.status == GemmaModelStatus.notInstalled) {
      debugPrint(
          '[GemmaModelBloc] Model file missing, refreshing installed list');
      final installed = await _repository.listInstalledModels();
      emit(state.copyWith(
        status: GemmaModelStatus.notInstalled,
        installedModels: installed,
      ));
    }
  }

  Future<void> _onUnload(
    GemmaModelUnload event,
    Emitter<GemmaModelState> emit,
  ) async {
    debugPrint('[GemmaModelBloc] _onUnload');
    await _repository.unloadModel();
    emit(state.copyWith(status: GemmaModelStatus.installed));
  }

  Future<void> _onDelete(
    GemmaModelDelete event,
    Emitter<GemmaModelState> emit,
  ) async {
    debugPrint('[GemmaModelBloc] _onDelete(modelType=${event.modelType})');
    await _repository.deleteModel(event.modelType);
    final installed = await _repository.listInstalledModels();
    debugPrint('[GemmaModelBloc] Post-delete installed models: $installed');
    emit(state.copyWith(
      status: GemmaModelStatus.notInstalled,
      installedModels: installed,
    ));
  }

  Future<void> _onSelect(
    GemmaModelSelect event,
    Emitter<GemmaModelState> emit,
  ) async {
    debugPrint('[GemmaModelBloc] _onSelect(modelId=${event.modelId})');
    _suppressStatusStream = true;

    await _preferences.setString(_selectedModelKey, event.modelId);
    // Emit loading immediately so the UI shows the model switch transition.
    emit(state.copyWith(
      selectedModelId: event.modelId,
      status: GemmaModelStatus.loading,
    ));

    await _repository.unloadModel();

    final modelInfo = _findModelInfoByInstalledId(event.modelId);
    if (modelInfo != null &&
        !modelInfo.isCurrentPlatformCompatible) {
      debugPrint(
          '[GemmaModelBloc] ${modelInfo.displayName} is not compatible with this platform');
      emit(state.copyWith(
        status: GemmaModelStatus.error,
        errorMessage:
            '${modelInfo.displayName} is not compatible with this platform.',
      ));
      _suppressStatusStream = false;
      return;
    }
    if (modelInfo != null) {
      debugPrint(
          '[GemmaModelBloc] Activating selected model: ${modelInfo.displayName}');
      await _repository.activateModel(modelInfo);
    }

    if (_repository.status == GemmaModelStatus.installed) {
      debugPrint('[GemmaModelBloc] Auto-loading selected model...');
      emit(state.copyWith(status: GemmaModelStatus.loading));
      await _loadModelWithCapabilities(ModelConfig.defaultConfig, modelInfo,
          thinkingEnabled: _preferences.getBool(_thinkingEnabledKey) ?? false);
      debugPrint(
          '[GemmaModelBloc] Auto-load done, repo status: ${_repository.status}');

      if (_repository.status == GemmaModelStatus.ready) {
        emit(state.copyWith(status: GemmaModelStatus.ready));
      } else {
        debugPrint(
            '[GemmaModelBloc] Selected model failed to load: ${_repository.lastError}');
        emit(state.copyWith(
          status: GemmaModelStatus.error,
          errorMessage: _repository.lastError ?? 'Model failed to load.',
        ));
      }
    }
    _suppressStatusStream = false;
  }

  Future<void> _onDeleteById(
    GemmaModelDeleteById event,
    Emitter<GemmaModelState> emit,
  ) async {
    debugPrint('[GemmaModelBloc] _onDeleteById(modelId=${event.modelId})');
    await _repository.deleteModelById(event.modelId);

    final installed = await _repository.listInstalledModels();
    debugPrint('[GemmaModelBloc] Post-deleteById installed models: $installed');

    final wasSelected = state.selectedModelId == event.modelId;
    if (wasSelected) {
      await _preferences.remove(_selectedModelKey);
    }

    emit(state.copyWith(
      status: installed.isEmpty
          ? GemmaModelStatus.notInstalled
          : GemmaModelStatus.installed,
      installedModels: installed,
      clearSelectedModel: wasSelected,
    ));
  }

  void _onDismissFailure(
    GemmaModelDismissFailure event,
    Emitter<GemmaModelState> emit,
  ) {
    final updatedFailed =
        state.failedDownloads.where((f) => f.modelId != event.modelId).toList();
    emit(state.copyWith(failedDownloads: updatedFailed));
  }

  void _onStatusChanged(
    _GemmaModelStatusChanged event,
    Emitter<GemmaModelState> emit,
  ) {
    if (_suppressStatusStream) {
      debugPrint(
          '[GemmaModelBloc] _onStatusChanged(${event.status}) SUPPRESSED');
      return;
    }
    debugPrint(
        '[GemmaModelBloc] _onStatusChanged(${event.status}), lastError=${_repository.lastError}');
    emit(state.copyWith(
      status: event.status,
      errorMessage: _repository.lastError,
    ));
  }

  void _onDownloadProgress(
    _GemmaModelDownloadProgress event,
    Emitter<GemmaModelState> emit,
  ) {
    final modelId = _activeRepositoryDownloadModelId;
    if (modelId == null) return;

    final pct = event.progress.percentage.toInt();
    if (pct % 10 == 0) {
      debugPrint(
          '[GemmaModelBloc] Download progress ($modelId): ${event.progress}');
    }

    // Update progress for the specific model in activeDownloads
    final updatedDownloads = state.activeDownloads.map((d) {
      if (d.modelId == modelId) {
        return ModelDownloadProgress(
          modelId: modelId,
          progress: event.progress.percentage,
        );
      }
      return d;
    }).toList();

    emit(state.copyWith(activeDownloads: updatedDownloads));
  }

  /// Loads a model with its capability flags and tool definitions.
  Future<void> _loadModelWithCapabilities(
    ModelConfig config,
    GemmaModelInfo? modelInfo, {
    bool thinkingEnabled = false,
  }) async {
    // Platform compatibility is enforced by supportedPlatforms on each model.
    // Models incompatible with the current platform are filtered out before
    // reaching this point (_onInitialize, _autoSelectAndLoad, _onSelect).
    if (modelInfo != null && !modelInfo.isCurrentPlatformCompatible) {
      _repository.setError(
        '${modelInfo.displayName} is not compatible with this platform.',
      );
      return;
    }

    final enableThinking =
        thinkingEnabled && (modelInfo?.supportsThinking ?? false);

    await _repository.loadModel(
      config,
      supportImage: modelInfo?.supportsMultimodal ?? false,
      supportAudio: modelInfo?.supportsAudio ?? false,
      isThinking: enableThinking,
      supportsFunctionCalls: modelInfo?.supportsFunctionCalls ?? false,
      tools: (modelInfo?.supportsFunctionCalls ?? false)
          ? _toolExecutor.toolDefinitions
          : const [],
      nativeModelType: modelInfo?.modelType,
    );
  }

  GemmaModelInfo? _findModelInfoByInstalledId(String installedId) {
    for (final model in GemmaModelInfo.availableModels) {
      if (installedId == model.id ||
          installedId.contains(model.id) ||
          model.id.contains(installedId)) {
        return model;
      }
      // On desktop, the installed filename comes from desktopUrl which may
      // differ from the catalog id. Match against the download URL filename.
      final downloadUrl = model.downloadUrl;
      final urlFilename = Uri.parse(downloadUrl).pathSegments.lastOrNull ?? '';
      if (urlFilename.isNotEmpty && installedId == urlFilename) {
        return model;
      }
    }
    return null;
  }

  @override
  Future<void> close() async {
    await _statusSubscription?.cancel();
    await _progressSubscription?.cancel();
    return super.close();
  }
}
