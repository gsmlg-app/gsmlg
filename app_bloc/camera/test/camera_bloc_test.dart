import 'dart:async';

import 'package:camera/camera.dart';
import 'package:camera_bloc/camera_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
      const noHardware = CameraNoHardwareAvailable();
      final error = CameraError(Exception('test'), StackTrace.current);

      expect(initial, isA<CameraState>());
      expect(loaded, isA<CameraState>());
      expect(noHardware, isA<CameraState>());
      expect(error, isA<CameraState>());
    });

    test('isNoCameraError identifies camera-less hardware exceptions', () {
      expect(
        isNoCameraError(
          CameraException(
              'noAvailableCameras', 'No cameras available for the device'),
        ),
        isTrue,
      );
      expect(
        isNoCameraError(
          PlatformException(
            code: 'ExecutionException',
            message:
                'CameraUnavailableException: Expected camera missing from device',
            details: 'Available cameras: 0',
          ),
        ),
        isTrue,
      );
      expect(
        isNoCameraError(
          Exception(
              'java.lang.IllegalArgumentException: No available camera can be found. Cams:0'),
        ),
        isTrue,
      );
      expect(
        isNoCameraError(
            CameraException('permissionDenied', 'Camera permission denied')),
        isFalse,
      );
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

  group('CameraBloc controller lifecycle', () {
    late _CameraBackend backend;
    late CameraBloc bloc;

    setUp(() {
      backend = _CameraBackend();
      bloc = CameraBloc();
    });

    tearDown(() async {
      backend.releaseGates();
      await bloc.close();
      backend.uninstall();
    });

    Future<void> loadCameras() async {
      bloc.add(const CameraInitCameras());
      await _until(() => bloc.state is CameraLoaded);
    }

    Future<void> select(CameraDescription camera) async {
      bloc.add(CameraSwitched(camera));
      await _until(
        () =>
            bloc.state is CameraLoaded &&
            (bloc.state as CameraLoaded).controller?.description == camera,
      );
    }

    test('initial discovery only publishes the resolved camera list', () async {
      final loadedStates = <CameraLoaded>[];
      final subscription = bloc.stream.listen((state) {
        if (state is CameraLoaded) loadedStates.add(state);
      });
      addTearDown(subscription.cancel);

      bloc.add(const CameraInitCameras());
      await _until(
        () =>
            bloc.state is CameraLoaded &&
            (bloc.state as CameraLoaded).cameras.isNotEmpty,
      );

      expect(loadedStates, hasLength(1));
      expect(loadedStates.single.cameras, [_back, _front]);
    });

    test('initial discovery with 0 cameras emits CameraNoHardwareAvailable',
        () async {
      backend.emptyCameras = true;
      bloc.add(const CameraInitCameras());
      await _until(() => bloc.state is CameraNoHardwareAvailable);
      expect(bloc.state, isA<CameraNoHardwareAvailable>());
    });

    test(
        'initial discovery throwing CameraUnavailableException emits CameraNoHardwareAvailable',
        () async {
      backend.throwUnavailable = true;
      bloc.add(const CameraInitCameras());
      await _until(() => bloc.state is CameraNoHardwareAvailable);
      expect(bloc.state, isA<CameraNoHardwareAvailable>());
    });

    test('detaches and releases old camera before opening replacement',
        () async {
      await loadCameras();
      await select(_back);
      final previous = (bloc.state as CameraLoaded).controller!;
      backend.disposeGate = Completer<void>();

      bloc.add(const CameraSwitched(_front));
      await _until(() => backend.calls.contains('dispose:1'));

      expect((bloc.state as CameraLoaded).controller, isNull);
      expect(backend.calls, isNot(contains('create:front')));
      backend.releaseGates();
      await _until(
        () => (bloc.state as CameraLoaded).controller?.description == _front,
      );
      previous.debugCheckIsDisposed();
      expect(
        backend.calls,
        containsAllInOrder(['disposed:1', 'create:front', 'initialize:2']),
      );
    });

    test('serializes rapid switches without overlapping initialization',
        () async {
      await loadCameras();
      await select(_back);
      backend.initializeGate = Completer<void>();
      bloc.add(const CameraSwitched(_front));
      await _until(() => backend.calls.contains('initialize:2'));

      bloc.add(const CameraSwitched(_back));
      await _drainEvents();
      expect(backend.calls.where((call) => call.startsWith('create:')),
          hasLength(2));

      backend.releaseGates();
      await _until(
        () =>
            bloc.state is CameraLoaded &&
            (bloc.state as CameraLoaded).controller?.cameraId == 3,
      );
      expect(
        backend.calls,
        containsAllInOrder(['initialized:2', 'disposed:2', 'create:back']),
      );
    });

    test('stop queued during initialization releases the resulting camera',
        () async {
      await loadCameras();
      backend.initializeGate = Completer<void>();
      bloc.add(const CameraSwitched(_back));
      await _until(() => backend.calls.contains('initialize:1'));

      bloc.add(const CameraStop());
      await _drainEvents();
      backend.releaseGates();
      await _until(() => backend.calls.contains('disposed:1'));
      expect((bloc.state as CameraLoaded).controller, isNull);
      expect((bloc.state as CameraLoaded).cameras, [_back, _front]);
    });

    test('failed initialization releases controller and allows retry',
        () async {
      await loadCameras();
      // Failed MethodChannel initialization leaves an event listener pending.
      // Use distinct IDs so later tests cannot notify that failed session.
      backend.nextId = 100;
      backend.failInitialization = true;
      bloc.add(const CameraSwitched(_back));
      await _until(() => bloc.state is CameraError);
      expect((bloc.state as CameraError).error, isA<CameraException>());
      expect(backend.calls, contains('disposed:101'));

      backend.failInitialization = false;
      await select(_front);
      expect((bloc.state as CameraLoaded).cameras, [_back, _front]);
      expect(
          (bloc.state as CameraLoaded).controller!.value.isInitialized, isTrue);
    });

    test('close releases the active controller', () async {
      await loadCameras();
      await select(_back);
      final controller = (bloc.state as CameraLoaded).controller!;

      await bloc.close();

      expect(backend.calls, contains('disposed:1'));
      expect((bloc.state as CameraLoaded).controller, isNull);
      controller.debugCheckIsDisposed();
    });

    test('close during initialization waits for controller cleanup', () async {
      await loadCameras();
      backend.initializeGate = Completer<void>();
      bloc.add(const CameraSwitched(_back));
      await _until(() => backend.calls.contains('initialize:1'));

      var closed = false;
      final closing = bloc.close().then((_) => closed = true);
      await _drainEvents();
      expect(closed, isFalse);

      backend.releaseGates();
      await closing;
      expect(backend.calls, contains('disposed:1'));
      expect((bloc.state as CameraLoaded).controller, isNull);
    });
  });
}

const _back = CameraDescription(
  name: 'back',
  lensDirection: CameraLensDirection.back,
  sensorOrientation: 90,
);
const _front = CameraDescription(
  name: 'front',
  lensDirection: CameraLensDirection.front,
  sensorOrientation: 90,
);

Future<void> _drainEvents() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

Future<void> _until(bool Function() condition) async {
  for (var i = 0; i < 100; i++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  fail('Camera lifecycle did not reach the expected state');
}

class _CameraBackend {
  _CameraBackend() {
    messenger.setMockMethodCallHandler(channel, _handleCall);
  }

  static const channel = MethodChannel('plugins.flutter.io/camera');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <String>[];
  Completer<void>? disposeGate;
  Completer<void>? initializeGate;
  bool failInitialization = false;
  bool emptyCameras = false;
  bool throwUnavailable = false;
  int nextId = 0;

  Future<Object?> _handleCall(MethodCall call) async {
    final arguments = call.arguments as Map<Object?, Object?>?;
    switch (call.method) {
      case 'availableCameras':
        if (throwUnavailable) {
          throw PlatformException(
            code: 'ExecutionException',
            message:
                'CameraUnavailableException: Expected camera missing from device',
            details: 'Available cameras: 0',
          );
        }
        if (emptyCameras) {
          return <Map<String, Object?>>[];
        }
        return [
          for (final camera in [_back, _front])
            {
              'name': camera.name,
              'lensFacing': camera.lensDirection.name,
              'sensorOrientation': camera.sensorOrientation,
            },
        ];
      case 'create':
        calls.add('create:${arguments!['cameraName']}');
        return {'cameraId': ++nextId};
      case 'initialize':
        final id = arguments!['cameraId'] as int;
        calls.add('initialize:$id');
        await initializeGate?.future;
        if (failInitialization) {
          throw PlatformException(code: 'cameraInitializationFailed');
        }
        await messenger.handlePlatformMessage(
          'flutter.io/cameraPlugin/camera$id',
          channel.codec.encodeMethodCall(
            const MethodCall('initialized', {
              'previewWidth': 640.0,
              'previewHeight': 480.0,
              'exposureMode': 'auto',
              'exposurePointSupported': true,
              'focusMode': 'auto',
              'focusPointSupported': true,
            }),
          ),
          null,
        );
        calls.add('initialized:$id');
        return null;
      case 'dispose':
        final id = arguments!['cameraId'] as int;
        calls.add('dispose:$id');
        await disposeGate?.future;
        calls.add('disposed:$id');
        return null;
      default:
        throw UnsupportedError(call.method);
    }
  }

  void releaseGates() {
    if (disposeGate case final gate? when !gate.isCompleted) {
      gate.complete();
    }
    if (initializeGate case final gate? when !gate.isCompleted) {
      gate.complete();
    }
  }

  void uninstall() {
    messenger.setMockMethodCallHandler(channel, null);
  }
}
