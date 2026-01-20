import 'dart:async';

import 'package:app_chat/app_chat.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'event.dart';
part 'state.dart';

/// BLoC for managing Gemma model lifecycle.
class GemmaModelBloc extends Bloc<GemmaModelEvent, GemmaModelState> {
  GemmaModelBloc({
    required GemmaRepository repository,
  })  : _repository = repository,
        super(const GemmaModelState()) {
    on<GemmaModelInitialize>(_onInitialize);
    on<GemmaModelCheckInstallation>(_onCheckInstallation);
    on<GemmaModelInstall>(_onInstall);
    on<GemmaModelLoad>(_onLoad);
    on<GemmaModelUnload>(_onUnload);
    on<GemmaModelDelete>(_onDelete);
    on<_GemmaModelStatusChanged>(_onStatusChanged);
    on<_GemmaModelDownloadProgress>(_onDownloadProgress);

    _statusSubscription = _repository.statusStream.listen((status) {
      add(_GemmaModelStatusChanged(status));
    });

    _progressSubscription = _repository.progressStream.listen((progress) {
      add(_GemmaModelDownloadProgress(progress));
    });
  }

  final GemmaRepository _repository;
  StreamSubscription<GemmaModelStatus>? _statusSubscription;
  StreamSubscription<DownloadProgress>? _progressSubscription;

  Future<void> _onInitialize(
    GemmaModelInitialize event,
    Emitter<GemmaModelState> emit,
  ) async {
    emit(state.copyWith(status: GemmaModelStatus.checking));
    final isInstalled = await _repository.checkModelInstalled(event.modelType);
    if (isInstalled) {
      emit(state.copyWith(
        status: GemmaModelStatus.installed,
        modelType: event.modelType,
      ));
    } else {
      emit(state.copyWith(
        status: GemmaModelStatus.notInstalled,
        modelType: event.modelType,
      ));
    }
  }

  Future<void> _onCheckInstallation(
    GemmaModelCheckInstallation event,
    Emitter<GemmaModelState> emit,
  ) async {
    emit(state.copyWith(status: GemmaModelStatus.checking));
    await _repository.checkModelInstalled(event.modelType);
  }

  Future<void> _onInstall(
    GemmaModelInstall event,
    Emitter<GemmaModelState> emit,
  ) async {
    emit(state.copyWith(
      status: GemmaModelStatus.downloading,
      downloadProgress: 0,
    ));

    await _repository.installModel(
      modelType: event.modelType,
      url: event.url,
      token: event.token,
    );
  }

  Future<void> _onLoad(
    GemmaModelLoad event,
    Emitter<GemmaModelState> emit,
  ) async {
    emit(state.copyWith(status: GemmaModelStatus.loading));
    await _repository.loadModel(event.config);
  }

  Future<void> _onUnload(
    GemmaModelUnload event,
    Emitter<GemmaModelState> emit,
  ) async {
    await _repository.unloadModel();
    emit(state.copyWith(status: GemmaModelStatus.installed));
  }

  Future<void> _onDelete(
    GemmaModelDelete event,
    Emitter<GemmaModelState> emit,
  ) async {
    await _repository.deleteModel(event.modelType);
    emit(state.copyWith(status: GemmaModelStatus.notInstalled));
  }

  void _onStatusChanged(
    _GemmaModelStatusChanged event,
    Emitter<GemmaModelState> emit,
  ) {
    emit(state.copyWith(
      status: event.status,
      errorMessage: _repository.lastError,
    ));
  }

  void _onDownloadProgress(
    _GemmaModelDownloadProgress event,
    Emitter<GemmaModelState> emit,
  ) {
    emit(state.copyWith(
      downloadProgress: event.progress.percentage,
    ));
  }

  @override
  Future<void> close() async {
    await _statusSubscription?.cancel();
    await _progressSubscription?.cancel();
    return super.close();
  }
}
