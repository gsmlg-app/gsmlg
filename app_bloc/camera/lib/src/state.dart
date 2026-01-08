part of 'bloc.dart';

@immutable
sealed class CameraState {
  const CameraState();
}

final class CameraInitial extends CameraState {
  const CameraInitial();
}

final class CameraLoaded extends CameraState {
  final List<CameraDescription> cameras;
  final CameraController? controller;

  const CameraLoaded({
    required this.cameras,
    this.controller,
  });
}

final class CameraError extends CameraState {
  final Object error;
  final StackTrace stackTrace;

  const CameraError(this.error, this.stackTrace);
}
