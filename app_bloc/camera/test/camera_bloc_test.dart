import 'package:camera_bloc/camera_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CameraBloc', () {
    test('initial state is CameraInitial', () {
      final bloc = CameraBloc();
      expect(bloc.state, isA<CameraInitial>());
      bloc.close();
    });

    test('CameraEvent classes are properly defined', () {
      const initEvent = CameraInitCameras();
      const startEvent = CameraStart();
      const stopEvent = CameraStop();

      expect(initEvent, isA<CameraEvent>());
      expect(startEvent, isA<CameraEvent>());
      expect(stopEvent, isA<CameraEvent>());
    });

    test('CameraState classes are properly defined', () {
      const initial = CameraInitial();
      const loaded = CameraLoaded(cameras: []);
      final error = CameraError(Exception('test'), StackTrace.current);

      expect(initial, isA<CameraState>());
      expect(loaded, isA<CameraState>());
      expect(error, isA<CameraState>());
    });

    test('CameraPreviewState extension methods work correctly', () {
      expect(CameraPreviewState.paused.isPaused, isTrue);
      expect(CameraPreviewState.paused.isRunning, isFalse);
      expect(CameraPreviewState.running.isPaused, isFalse);
      expect(CameraPreviewState.running.isRunning, isTrue);

      expect(CameraPreviewState.paused.title, 'Paused');
      expect(CameraPreviewState.running.title, 'Running');
    });
  });
}
