import 'dart:async';

import 'package:app_chat/app_chat.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'event.dart';
part 'state.dart';

/// BLoC for managing Gemma model lifecycle.
class GemmaModelBloc extends Bloc<GemmaModelEvent, GemmaModelState> {
  GemmaModelBloc({
    required GemmaRepository repository,
    required SharedPreferences preferences,
  })  : _repository = repository,
        _preferences = preferences,
        super(const GemmaModelState()) {
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
    on<_GemmaModelStatusChanged>(_onStatusChanged);
    on<_GemmaModelDownloadProgress>(_onDownloadProgress);

    _statusSubscription = _repository.statusStream.listen((status) {
      add(_GemmaModelStatusChanged(status));
    });

    _progressSubscription = _repository.progressStream.listen((progress) {
      add(_GemmaModelDownloadProgress(progress));
    });
  }

  static const _selectedModelKey = 'gemma_selected_model_id';

  final GemmaRepository _repository;
  final SharedPreferences _preferences;
  StreamSubscription<GemmaModelStatus>? _statusSubscription;
  StreamSubscription<DownloadProgress>? _progressSubscription;

  /// Whether to suppress queued status-stream events.
  ///
  /// Long-running handlers (init, select, install) call multiple repository
  /// methods that each fire status changes through [_statusSubscription].
  /// These arrive as queued [_GemmaModelStatusChanged] events AFTER the
  /// handler completes, and can overwrite the final state (e.g. replaying
  /// `installed` after the handler already set `ready`).
  bool _suppressStatusStream = false;

  Future<void> _onInitialize(
    GemmaModelInitialize event,
    Emitter<GemmaModelState> emit,
  ) async {
    debugPrint('[GemmaModelBloc] _onInitialize(modelType=${event.modelType}), current status=${state.status}');

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
    // Loops through candidates so a single stale model doesn't block others.
    if (installed.isNotEmpty) {
      debugPrint('[GemmaModelBloc] ${installed.length} model(s) already installed');

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
        if (modelInfo != null) {
          debugPrint('[GemmaModelBloc] Activating: ${modelInfo.displayName} (id: $modelId)');
          await _repository.activateModel(modelInfo);
        } else {
          debugPrint('[GemmaModelBloc] No matching model info for: $modelId, skipping');
          continue;
        }

        if (_repository.status == GemmaModelStatus.installed) {
          debugPrint('[GemmaModelBloc] Auto-loading model into memory...');
          emit(state.copyWith(
            status: GemmaModelStatus.loading,
            modelType: event.modelType,
          ));
          await _repository.loadModel(ModelConfig.defaultConfig);
          debugPrint('[GemmaModelBloc] Auto-load done, repo status: ${_repository.status}');

          if (_repository.status == GemmaModelStatus.ready) {
            debugPrint('[GemmaModelBloc] Model $modelId loaded successfully');
            emit(state.copyWith(status: GemmaModelStatus.ready));
            loaded = true;
            break;
          }

          // Load failed — keep model installed, report error, try next candidate.
          debugPrint('[GemmaModelBloc] Model $modelId failed to load (status=${_repository.status})');
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
      // No models installed — try bundled asset first, then auto-download
      // the smallest free model.
      final bundled = GemmaModelInfo.defaultModel;
      if (bundled.assetPath != null) {
        debugPrint('[GemmaModelBloc] Trying bundled asset: ${bundled.assetPath}');
        emit(state.copyWith(
          status: GemmaModelStatus.downloading,
          modelType: event.modelType,
          downloadProgress: 0,
        ));
        await _repository.installModelFromAsset(
          modelType: bundled.modelType,
          assetPath: bundled.assetPath!,
        );
        debugPrint('[GemmaModelBloc] Asset install returned, refreshing installed list...');
        final updatedInstalled = await _repository.listInstalledModels();
        debugPrint('[GemmaModelBloc] Updated installed models: $updatedInstalled');
        emit(state.copyWith(installedModels: updatedInstalled));
        if (updatedInstalled.isNotEmpty) {
          await _autoSelectAndLoad(updatedInstalled, null, emit);
          _suppressStatusStream = false;
          debugPrint('[GemmaModelBloc] _onInitialize done (bundled), final status: ${state.status}');
          return;
        }
      }

      // No bundled asset or it failed — auto-download the smallest free model
      // so the user has something to chat with immediately.
      final fallback = GemmaModelInfo.smallestFreeModel;
      if (fallback != null) {
        debugPrint('[GemmaModelBloc] Auto-downloading smallest free model: ${fallback.displayName}');
        emit(state.copyWith(
          status: GemmaModelStatus.downloading,
          downloadProgress: 0,
          downloadingModelId: fallback.id,
        ));

        final proxy = state.proxyUrl;
        if (proxy != null && proxy.isNotEmpty) {
          await _repository.installModelWithProxy(
            nativeModelType: fallback.modelType,
            url: fallback.url,
            proxyUrl: proxy,
          );
        } else {
          await _repository.installModel(
            nativeModelType: fallback.modelType,
            url: fallback.url,
          );
        }

        final updatedInstalled = await _repository.listInstalledModels();
        debugPrint('[GemmaModelBloc] Post-auto-download installed: $updatedInstalled');
        emit(state.copyWith(
          installedModels: updatedInstalled,
          clearDownloadingModel: true,
        ));

        if (updatedInstalled.isNotEmpty) {
          await _autoSelectAndLoad(updatedInstalled, fallback.id, emit);
          _suppressStatusStream = false;
          debugPrint('[GemmaModelBloc] _onInitialize done (auto-download), final status: ${state.status}');
          return;
        }
      }

      debugPrint('[GemmaModelBloc] No models available, setting notInstalled');
      emit(state.copyWith(status: GemmaModelStatus.notInstalled));
    }
    _suppressStatusStream = false;
    debugPrint('[GemmaModelBloc] _onInitialize done, final status: ${state.status}');
  }

  Future<void> _onCheckInstallation(
    GemmaModelCheckInstallation event,
    Emitter<GemmaModelState> emit,
  ) async {
    debugPrint('[GemmaModelBloc] _onCheckInstallation(modelType=${event.modelType})');
    emit(state.copyWith(status: GemmaModelStatus.checking));
    await _repository.checkModelInstalled(event.modelType);
  }

  Future<void> _onInstall(
    GemmaModelInstall event,
    Emitter<GemmaModelState> emit,
  ) async {
    debugPrint('[GemmaModelBloc] _onInstall(nativeModelType=${event.nativeModelType}, url=${event.url}, modelId=${event.modelId}, hasToken=${event.token != null})');
    emit(state.copyWith(
      status: GemmaModelStatus.downloading,
      downloadProgress: 0,
      downloadingModelId: event.modelId,
    ));

    final proxy = state.proxyUrl;
    debugPrint('[GemmaModelBloc] Current proxy: $proxy');
    if (proxy != null && proxy.isNotEmpty) {
      debugPrint('[GemmaModelBloc] Using proxy download path');
      await _repository.installModelWithProxy(
        nativeModelType: event.nativeModelType,
        url: event.url,
        proxyUrl: proxy,
        token: event.token,
      );
    } else {
      debugPrint('[GemmaModelBloc] Using direct download path');
      await _repository.installModel(
        nativeModelType: event.nativeModelType,
        url: event.url,
        token: event.token,
      );
    }

    debugPrint('[GemmaModelBloc] Install call returned, refreshing installed list...');
    final installed = await _repository.listInstalledModels();
    debugPrint('[GemmaModelBloc] Post-install installed models: $installed');
    emit(state.copyWith(installedModels: installed, clearDownloadingModel: true));

    // Auto-select + activate + load the newly installed model.
    if (installed.isNotEmpty) {
      await _autoSelectAndLoad(installed, event.modelId, emit);
    }
  }

  Future<void> _onInstallFromAsset(
    GemmaModelInstallFromAsset event,
    Emitter<GemmaModelState> emit,
  ) async {
    debugPrint('[GemmaModelBloc] _onInstallFromAsset(modelId=${event.modelId}, assetPath=${event.assetPath})');
    emit(state.copyWith(
      status: GemmaModelStatus.downloading,
      downloadProgress: 0,
      downloadingModelId: event.modelId,
    ));

    final modelInfo = GemmaModelInfo.findById(event.modelId);
    debugPrint('[GemmaModelBloc] Resolved model info: ${modelInfo?.displayName ?? 'not found, using default'}');
    await _repository.installModelFromAsset(
      modelType: modelInfo?.modelType ?? GemmaModelInfo.defaultModel.modelType,
      assetPath: event.assetPath,
    );

    debugPrint('[GemmaModelBloc] Asset install returned, refreshing installed list...');
    final installed = await _repository.listInstalledModels();
    debugPrint('[GemmaModelBloc] Post-asset-install models: $installed');
    emit(state.copyWith(installedModels: installed, clearDownloadingModel: true));

    // Auto-select + activate + load the newly installed model.
    if (installed.isNotEmpty) {
      await _autoSelectAndLoad(installed, event.modelId, emit);
    }
  }

  /// Auto-selects, activates, and loads a model after installation.
  ///
  /// If no model is currently selected, selects [preferredModelId] (the model
  /// that was just installed) or falls back to the first installed model.
  /// Then activates and loads it so the chat is immediately usable.
  ///
  /// When a model fails to load (e.g. stale registry entry with missing file),
  /// iterates through remaining installed models and tries each one.
  Future<void> _autoSelectAndLoad(
    List<String> installed,
    String? preferredModelId,
    Emitter<GemmaModelState> emit,
  ) async {
    _suppressStatusStream = true;

    // Build ordered candidate list: preferred first, then current selection,
    // then remaining installed models.
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

      // Activate
      final modelInfo = _findModelInfoByInstalledId(modelId);
      if (modelInfo != null) {
        debugPrint('[GemmaModelBloc] Activating model: ${modelInfo.displayName}');
        await _repository.activateModel(modelInfo);
      }

      // Auto-load
      if (_repository.status == GemmaModelStatus.installed) {
        debugPrint('[GemmaModelBloc] Auto-loading model into memory...');
        emit(state.copyWith(status: GemmaModelStatus.loading));
        await _repository.loadModel(ModelConfig.defaultConfig);
        debugPrint('[GemmaModelBloc] Auto-load done, repo status: ${_repository.status}');

        if (_repository.status == GemmaModelStatus.ready) {
          // Success — emit ready so UI updates immediately.
          debugPrint('[GemmaModelBloc] Model $modelId loaded successfully');
          emit(state.copyWith(status: GemmaModelStatus.ready));
          _suppressStatusStream = false;
          return;
        }

        // Load failed — keep model installed, report error, try next candidate.
        debugPrint('[GemmaModelBloc] Model $modelId failed to load (status=${_repository.status})');
        continue;
      }

      // If activation didn't reach `installed` status, try next candidate.
      debugPrint('[GemmaModelBloc] Model $modelId activation status: ${_repository.status}, trying next...');
    }

    // All candidates failed — keep models installed, report error.
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
    await _repository.loadModel(event.config);
    debugPrint('[GemmaModelBloc] _onLoad done, repo status: ${_repository.status}');

    // If the model file was missing on disk, refresh the installed list
    // so the UI reflects reality.
    if (_repository.status == GemmaModelStatus.notInstalled) {
      debugPrint('[GemmaModelBloc] Model file missing, refreshing installed list');
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

    // Persist selection
    await _preferences.setString(_selectedModelKey, event.modelId);
    emit(state.copyWith(selectedModelId: event.modelId));

    // Unload current model
    await _repository.unloadModel();

    // Activate the selected model
    final modelInfo = _findModelInfoByInstalledId(event.modelId);
    if (modelInfo != null) {
      debugPrint('[GemmaModelBloc] Activating selected model: ${modelInfo.displayName}');
      await _repository.activateModel(modelInfo);
    }

    // Auto-load
    if (_repository.status == GemmaModelStatus.installed) {
      debugPrint('[GemmaModelBloc] Auto-loading selected model...');
      emit(state.copyWith(status: GemmaModelStatus.loading));
      await _repository.loadModel(ModelConfig.defaultConfig);
      debugPrint('[GemmaModelBloc] Auto-load done, repo status: ${_repository.status}');

      if (_repository.status == GemmaModelStatus.ready) {
        emit(state.copyWith(status: GemmaModelStatus.ready));
      } else {
        // Load failed — keep model installed but report error.
        debugPrint('[GemmaModelBloc] Selected model failed to load: ${_repository.lastError}');
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

    // Clear selection if the deleted model was selected
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

  void _onStatusChanged(
    _GemmaModelStatusChanged event,
    Emitter<GemmaModelState> emit,
  ) {
    if (_suppressStatusStream) {
      debugPrint('[GemmaModelBloc] _onStatusChanged(${event.status}) SUPPRESSED');
      return;
    }
    debugPrint('[GemmaModelBloc] _onStatusChanged(${event.status}), lastError=${_repository.lastError}');
    emit(state.copyWith(
      status: event.status,
      errorMessage: _repository.lastError,
    ));
  }

  void _onDownloadProgress(
    _GemmaModelDownloadProgress event,
    Emitter<GemmaModelState> emit,
  ) {
    // Only log at 10% intervals to avoid flooding
    final pct = event.progress.percentage.toInt();
    if (pct % 10 == 0) {
      debugPrint('[GemmaModelBloc] Download progress: ${event.progress}');
    }
    emit(state.copyWith(
      downloadProgress: event.progress.percentage,
    ));
  }

  /// Finds a [GemmaModelInfo] that matches an installed model ID.
  ///
  /// Installed IDs from flutter_gemma may include a file extension (e.g.
  /// `deepseek_q8_ekv1280.task`) while our catalog IDs may not, so we use
  /// fuzzy matching.
  GemmaModelInfo? _findModelInfoByInstalledId(String installedId) {
    for (final model in GemmaModelInfo.availableModels) {
      if (installedId == model.id ||
          installedId.contains(model.id) ||
          model.id.contains(installedId)) {
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
