import 'dart:async';

import 'package:app_locale/app_locale.dart';
import 'package:camera_macos/camera_macos.dart';
import 'package:camera_settings_form/camera_settings_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/toolbox/camera/camera_macos_screen.dart';

void main() {
  late _DelayedCameraPlatform platform;

  Future<void> mount(WidgetTester tester) async {
    final previousPlatform = CameraMacOSPlatform.instance;
    platform = _DelayedCameraPlatform();
    CameraMacOSPlatform.instance = platform;
    addTearDown(() => CameraMacOSPlatform.instance = previousPlatform);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      for (var attempt = 0; attempt < 5; attempt++) {
        platform.completePendingOperations();
        await _pumpLifecycle(tester);
      }
    });
    await tester.pumpWidget(_cameraApp());
    await _pumpLifecycle(tester);
  }

  Future<void> discoverDevices(WidgetTester tester) async {
    platform.videoDevices.complete(platform.cameras);
    await _pumpLifecycle(tester);
    platform.audioDevices.complete(platform.microphones);
    await _pumpLifecycle(tester);
  }

  CameraSettingsFormBloc form(WidgetTester tester) => tester
      .element(find.byType(CameraMacOSView))
      .read<CameraSettingsFormBloc>();

  testWidgets('initializes once after video and audio selections settle', (
    tester,
  ) async {
    await mount(tester);
    expect(platform.initializations, isEmpty);

    await discoverDevices(tester);

    expect(platform.initializations, hasLength(1));
    expect(platform.initializations.single.deviceId, 'front');
    expect(platform.initializations.single.audioDeviceId, 'mic');
    expect(platform.maxConcurrentOperations, 1);
  });

  testWidgets(
    'waits for old camera destruction before starting the replacement',
    (tester) async {
      await mount(tester);
      await discoverDevices(tester);
      platform.initializations.last.complete();
      await _pumpLifecycle(tester);
      final initializedCount = platform.initializations.length;

      form(tester).deviceId.updateValue('back');
      await _pumpLifecycle(tester);

      expect(platform.destructions, hasLength(1));
      expect(platform.initializations, hasLength(initializedCount));
      platform.destructions.single.complete(true);
      await _pumpLifecycle(tester);
      expect(platform.initializations, hasLength(initializedCount + 1));
      expect(platform.initializations.last.deviceId, 'back');
      expect(platform.maxConcurrentOperations, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'coalesces rapid settings changes while initialization is pending',
    (tester) async {
      await mount(tester);
      await discoverDevices(tester);
      final settings = form(tester);

      settings.deviceId.updateValue('back');
      settings.orientation.updateValue(CameraOrientation.orientation90deg);
      await _pumpLifecycle(tester);

      expect(platform.initializations, hasLength(1));
      platform.initializations.single.complete();
      await _pumpLifecycle(tester);
      expect(platform.destructions, hasLength(1));
      expect(platform.initializations, hasLength(1));
      platform.destructions.single.complete(true);
      await _pumpLifecycle(tester);
      expect(platform.initializations, hasLength(2));
      expect(platform.initializations.last.deviceId, 'back');
      expect(
        platform.initializations.last.orientation,
        CameraOrientation.orientation90deg,
      );
      expect(platform.maxConcurrentOperations, 1);
    },
  );

  testWidgets(
    'destroys a camera that finishes initializing after screen exit',
    (tester) async {
      await mount(tester);
      await discoverDevices(tester);
      await tester.pumpWidget(const SizedBox.shrink());
      platform.initializations.last.complete();
      await _pumpLifecycle(tester);

      expect(platform.destructions, hasLength(1));
      expect(tester.takeException(), isNull);
      platform.destructions.single.complete(true);
      await tester.pump();
      expect(platform.activeOperations, 0);
    },
  );

  for (final failsWithError in [false, true]) {
    testWidgets(
      'retries after ${failsWithError ? 'failed' : 'null'} initialization',
      (tester) async {
        await mount(tester);
        await discoverDevices(tester);
        final initialization = platform.initializations.single;
        if (failsWithError) {
          initialization.completion.completeError(
            StateError('Camera unavailable'),
          );
        } else {
          initialization.completion.complete(null);
        }
        await _pumpLifecycle(tester);

        form(tester).deviceId.updateValue('back');
        await _pumpLifecycle(tester);

        expect(platform.initializations, hasLength(2));
        expect(platform.initializations.last.deviceId, 'back');
        expect(platform.maxConcurrentOperations, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('reopening waits for the previous screen to release its camera', (
    tester,
  ) async {
    await mount(tester);
    await discoverDevices(tester);
    expect(platform.initializations, hasLength(1));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(_cameraApp());
    await _pumpLifecycle(tester);

    expect(platform.initializations, hasLength(1));
    platform.initializations.single.complete();
    await _pumpLifecycle(tester);
    expect(platform.destructions, hasLength(1));
    expect(platform.initializations, hasLength(1));
    platform.destructions.single.complete(true);
    await _pumpLifecycle(tester);
    expect(platform.initializations, hasLength(2));
    expect(platform.maxConcurrentOperations, 1);
    expect(tester.takeException(), isNull);
  });
}

Widget _cameraApp() => MaterialApp(
  localizationsDelegates: AppLocale.localizationsDelegates,
  supportedLocales: AppLocale.supportedLocales,
  home: const CameraMacosScreen(),
);

class _Initialization {
  _Initialization(this.deviceId, this.audioDeviceId, this.orientation);

  final String? deviceId;
  final String? audioDeviceId;
  final CameraOrientation orientation;
  final completion = Completer<CameraMacOSArguments?>();

  void complete() {
    if (!completion.isCompleted) {
      completion.complete(
        CameraMacOSArguments(textureId: 1, size: const Size(640, 480)),
      );
    }
  }
}

class _DelayedCameraPlatform extends CameraMacOSPlatform {
  final videoDevices = Completer<List<CameraMacOSDevice>>();
  final audioDevices = Completer<List<CameraMacOSDevice>>();
  final cameras = [
    CameraMacOSDevice(
      deviceId: 'front',
      deviceType: CameraMacOSDeviceType.video,
    ),
    CameraMacOSDevice(
      deviceId: 'back',
      deviceType: CameraMacOSDeviceType.video,
    ),
  ];
  final microphones = [
    CameraMacOSDevice(deviceId: 'mic', deviceType: CameraMacOSDeviceType.audio),
  ];
  final initializations = <_Initialization>[];
  final destructions = <Completer<bool?>>[];
  int activeOperations = 0;
  int maxConcurrentOperations = 0;

  void _started() {
    activeOperations++;
    if (activeOperations > maxConcurrentOperations) {
      maxConcurrentOperations = activeOperations;
    }
  }

  @override
  Future<List<CameraMacOSDevice>> listDevices({
    CameraMacOSDeviceType? deviceType,
  }) => deviceType == CameraMacOSDeviceType.video
      ? videoDevices.future
      : audioDevices.future;

  @override
  Future<CameraMacOSArguments?> initialize({
    String? deviceId,
    String? audioDeviceId,
    bool enableAudio = true,
    PictureFormat pictureFormat = PictureFormat.tiff,
    VideoFormat videoFormat = VideoFormat.mp4,
    PictureResolution resolution = PictureResolution.max,
    AudioFormat audioFormat = AudioFormat.kAudioFormatAppleLossless,
    AudioQuality audioQuality = AudioQuality.max,
    Torch toggleTorch = Torch.off,
    CameraOrientation orientation = CameraOrientation.orientation0deg,
    bool isVideoMirrored = true,
    required CameraMacOSMode cameraMacOSMode,
  }) {
    _started();
    final initialization = _Initialization(
      deviceId,
      audioDeviceId,
      orientation,
    );
    initializations.add(initialization);
    return initialization.completion.future.whenComplete(
      () => activeOperations--,
    );
  }

  @override
  Future<bool?> destroy() {
    _started();
    final completion = Completer<bool?>();
    destructions.add(completion);
    return completion.future.whenComplete(() => activeOperations--);
  }

  void completePendingOperations() {
    for (final initialization in initializations) {
      initialization.complete();
    }
    for (final destruction in destructions) {
      if (!destruction.isCompleted) destruction.complete(true);
    }
  }
}

Future<void> _pumpLifecycle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 10));
  await tester.pump(const Duration(milliseconds: 10));
}
