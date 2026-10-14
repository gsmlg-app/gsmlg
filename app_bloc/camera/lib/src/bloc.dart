import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'event.dart';
part 'state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraBloc() : super(CameraInitial()) {
    // All camera events share one queue because native camera resources are
    // shared across controllers, including during disposal.
    on<CameraEvent>(
      _onEvent,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }

  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  Completer<void>? _stopCompleter;
  Future<void>? _closeFuture;
  bool _closing = false;

  Future<void> _onEvent(
    CameraEvent event,
    Emitter<CameraState> emitter,
  ) async {
    try {
      switch (event) {
        case CameraInitCameras():
          await _initCameras(event, emitter);
        case CameraSwitched():
          await _onCameraSwitched(event, emitter);
        case CameraStop():
          await _onCameraStop(event, emitter);
        case CameraStart():
          break;
      }
    } catch (e, stackTrace) {
      try {
        await _disposeController();
      } catch (disposeError, disposeStackTrace) {
        if (!emitter.isDone) {
          emitter(CameraError(disposeError, disposeStackTrace));
        }
        return;
      }
      if (!emitter.isDone) {
        emitter(CameraError(e, stackTrace));
      }
    } finally {
      if (event is CameraStop) {
        _stopCompleter?.complete();
        _stopCompleter = null;
      }
    }
  }

  Future<void> _initCameras(
    CameraInitCameras event,
    Emitter<CameraState> emitter,
  ) async {
    if (state is! CameraInitial && state is! CameraNoHardwareAvailable) {
      emitter(CameraLoaded(cameras: _cameras));
    }
    await _disposeController();
    try {
      _cameras = await availableCameras();
    } catch (e) {
      if (isNoCameraError(e)) {
        _cameras = [];
        if (!emitter.isDone) {
          emitter(CameraNoHardwareAvailable(message: e.toString()));
        }
        return;
      }
      rethrow;
    }
    if (!emitter.isDone) {
      if (_cameras.isEmpty) {
        emitter(const CameraNoHardwareAvailable());
      } else {
        emitter(CameraLoaded(cameras: _cameras));
      }
    }
  }

  Future<void> _onCameraSwitched(
    CameraSwitched event,
    Emitter<CameraState> emitter,
  ) async {
    emitter(CameraLoaded(cameras: _cameras));
    await _disposeController();
    if (_closing || emitter.isDone) return;

    final controller = CameraController(
      event.camera,
      ResolutionPreset.max,
      enableAudio: false,
    );
    _controller = controller;
    await controller.initialize();
    if (_closing || emitter.isDone) {
      await _disposeController();
    } else {
      emitter(
        CameraLoaded(
          cameras: _cameras,
          controller: controller,
        ),
      );
    }
  }

  Future<void> _onCameraStop(
    CameraStop event,
    Emitter<CameraState> emitter,
  ) async {
    if (state is CameraLoaded) {
      emitter(CameraLoaded(cameras: _cameras));
    }
    await _disposeController();
  }

  Future<void> _disposeController() async {
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
  }

  @override
  Future<void> close() {
    if (_closeFuture != null) return _closeFuture!;
    _closing = true;
    // Queue cleanup before closing emitters so an in-flight initialization
    // finishes and the preview is detached before its controller is disposed.
    final stopped = _stopCompleter = Completer<void>();
    add(const CameraStop());
    return _closeFuture = stopped.future.then((_) => super.close());
  }
}

/// Checks whether an exception indicates that no camera hardware exists
/// on the device or the camera is permanently unavailable.
bool isNoCameraError(Object e) {
  if (e is CameraException) {
    final code = e.code.toLowerCase();
    final desc = (e.description ?? '').toLowerCase();
    if (code.contains('nocamera') ||
        code.contains('noavailablecameras') ||
        code.contains('notfound') ||
        code.contains('unavailable') ||
        desc.contains('no camera') ||
        desc.contains('camera unavailable') ||
        desc.contains('available cameras: 0') ||
        desc.contains('expected camera missing')) {
      return true;
    }
  }
  if (e is PlatformException) {
    final code = e.code.toLowerCase();
    final message = (e.message ?? '').toLowerCase();
    final details = (e.details ?? '').toString().toLowerCase();
    if (code.contains('nocamera') ||
        code.contains('noavailablecameras') ||
        code.contains('unavailable') ||
        message.contains('cameraunavailableexception') ||
        message.contains('no camera') ||
        message.contains('available cameras: 0') ||
        message.contains('expected camera missing') ||
        details.contains('cameraunavailableexception') ||
        details.contains('no available camera') ||
        details.contains('available cameras: 0') ||
        details.contains('expected camera missing')) {
      return true;
    }
  }
  final str = e.toString().toLowerCase();
  return str.contains('cameraunavailableexception') ||
      str.contains('available cameras: 0') ||
      str.contains('no available camera') ||
      str.contains('expected camera missing') ||
      str.contains('no cameras available');
}
