import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

part 'event.dart';
part 'state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraBloc() : super(CameraInitial()) {
    on<CameraInitCameras>(_initCameras);
    on<CameraSwitched>(_onCameraSwitched);
    on<CameraStop>(_onCameraStop);
  }

  Future<void> _initCameras(
    CameraInitCameras event,
    Emitter<CameraState> emitter,
  ) async {
    try {
      final cameras = await availableCameras();
      emitter(CameraLoaded(cameras: cameras));
    } catch (e, stackTrace) {
      emitter(CameraError(e, stackTrace));
    }
  }

  Future<void> _onCameraSwitched(
    CameraSwitched event,
    Emitter<CameraState> emitter,
  ) async {
    final controller = CameraController(
      event.camera,
      ResolutionPreset.max,
      enableAudio: false,
    );
    await controller.initialize();
    if (state is CameraLoaded) {
      (state as CameraLoaded).controller?.dispose();
      emitter(
        CameraLoaded(
          cameras: (state as CameraLoaded).cameras,
          controller: controller,
        ),
      );
    } else {
      add(CameraInitCameras());
    }
  }

  void _onCameraStop(CameraStop event, Emitter<CameraState> emitter) {
    if (state is CameraLoaded) {
      (state as CameraLoaded).controller?.dispose();
    }
  }
}
