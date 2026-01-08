part of 'bloc.dart';

@immutable
sealed class CameraEvent {
  const CameraEvent();
}

final class CameraInitCameras extends CameraEvent {
  const CameraInitCameras();
}

final class CameraStart extends CameraEvent {
  const CameraStart();
}

final class CameraStop extends CameraEvent {
  const CameraStop();
}

final class CameraSwitched extends CameraEvent {
  final CameraDescription camera;

  const CameraSwitched(this.camera);
}
