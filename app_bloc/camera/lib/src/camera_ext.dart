import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

extension CameraDescriptionExtension on CameraDescription {
  String get title {
    switch (lensDirection) {
      case CameraLensDirection.back:
        return 'Back';
      case CameraLensDirection.front:
        return 'Front';
      case CameraLensDirection.external:
        return 'External';
    }
  }
}

enum CameraPreviewState {
  paused,
  running,
}

extension CameraPreviewStateExtension on CameraPreviewState {
  bool get isPaused => this == CameraPreviewState.paused;
  bool get isRunning => this == CameraPreviewState.running;

  String get title {
    switch (this) {
      case CameraPreviewState.paused:
        return 'Paused';
      case CameraPreviewState.running:
        return 'Running';
    }
  }

  Widget get icon {
    switch (this) {
      case CameraPreviewState.paused:
        return const Icon(Icons.pause);
      case CameraPreviewState.running:
        return const Icon(Icons.videocam);
    }
  }
}
