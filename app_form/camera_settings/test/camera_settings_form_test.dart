import 'package:camera_macos/camera_macos.dart';
import 'package:camera_settings_form/camera_settings_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CameraSettingsFormBloc', () {
    late CameraSettingsFormBloc formBloc;

    setUp(() {
      formBloc = CameraSettingsFormBloc();
    });

    tearDown(() {
      formBloc.close();
    });

    test('initial values are set correctly', () {
      expect(formBloc.cameraMode.value, CameraMacOSMode.video);
      expect(formBloc.orientation.value, CameraOrientation.orientation0deg);
      expect(formBloc.torch.value, Torch.off);
      expect(formBloc.isVideoMirrored.value, false);
      expect(formBloc.deviceId.value, isNull);
      expect(formBloc.audioDeviceId.value, isNull);
    });

    test('can update camera mode', () {
      formBloc.cameraMode.updateValue(CameraMacOSMode.photo);
      expect(formBloc.cameraMode.value, CameraMacOSMode.photo);
    });

    test('can update orientation', () {
      formBloc.orientation.updateValue(CameraOrientation.orientation90deg);
      expect(formBloc.orientation.value, CameraOrientation.orientation90deg);
    });

    test('can update torch', () {
      formBloc.torch.updateValue(Torch.on);
      expect(formBloc.torch.value, Torch.on);
    });

    test('can toggle video mirroring', () {
      formBloc.isVideoMirrored.updateValue(true);
      expect(formBloc.isVideoMirrored.value, true);
    });

    test('can update video devices', () {
      expect(formBloc.deviceId.state.items, isEmpty);

      formBloc.updateVideoDevices([
        CameraMacOSDevice(deviceId: 'device1', localizedName: 'Camera 1'),
        CameraMacOSDevice(deviceId: 'device2', localizedName: 'Camera 2'),
      ]);

      expect(formBloc.deviceId.state.items, hasLength(2));
      expect(formBloc.deviceId.state.items, contains('device1'));
      expect(formBloc.deviceId.state.items, contains('device2'));
    });

    test('can update audio devices', () {
      expect(formBloc.audioDeviceId.state.items, isEmpty);

      formBloc.updateAudioDevices([
        CameraMacOSDevice(deviceId: 'audio1', localizedName: 'Mic 1'),
      ]);

      expect(formBloc.audioDeviceId.state.items, hasLength(1));
      expect(formBloc.audioDeviceId.state.items, contains('audio1'));
    });

    test('selects first available video device by default', () {
      formBloc.updateVideoDevices([
        CameraMacOSDevice(deviceId: 'device1', localizedName: 'Camera 1'),
        CameraMacOSDevice(deviceId: 'device2', localizedName: 'Camera 2'),
      ]);

      expect(formBloc.deviceId.value, 'device1');
    });

    test('selects first available audio device by default', () {
      formBloc.updateAudioDevices([
        CameraMacOSDevice(deviceId: 'audio1', localizedName: 'Mic 1'),
      ]);

      expect(formBloc.audioDeviceId.value, 'audio1');
    });
  });

  group('CameraSettingsFormWidget', () {
    late CameraSettingsFormBloc formBloc;

    setUp(() {
      formBloc = CameraSettingsFormBloc();
      formBloc.updateVideoDevices([
        CameraMacOSDevice(
          deviceId: 'camera1',
          localizedName: 'Built-in Camera',
          manufacturer: 'Apple',
        ),
      ]);
      formBloc.updateAudioDevices([
        CameraMacOSDevice(
          deviceId: 'mic1',
          localizedName: 'Studio Mic',
          manufacturer: 'Apple',
        ),
      ]);
    });

    tearDown(() {
      formBloc.close();
    });

    testWidgets('shows labels and selected values on macOS', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.macOS),
          home: Scaffold(
            body: CameraSettingsFormWidget(
              formBloc: formBloc,
              videoDevices: [
                CameraMacOSDevice(
                  deviceId: 'camera1',
                  localizedName: 'Built-in Camera',
                  manufacturer: 'Apple',
                ),
              ],
              audioDevices: [
                CameraMacOSDevice(
                  deviceId: 'mic1',
                  localizedName: 'Studio Mic',
                  manufacturer: 'Apple',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Camera Mode'), findsOneWidget);
      expect(find.text('Video Device'), findsOneWidget);
      expect(find.text('Audio Device'), findsOneWidget);
      expect(find.text('Orientation'), findsOneWidget);
      expect(find.text('Torch'), findsOneWidget);
      expect(find.text('video'), findsOneWidget);
      expect(find.text('Built-in Camera (Apple)'), findsOneWidget);
      expect(find.text('Studio Mic (Apple)'), findsOneWidget);
      expect(find.text('orientation0deg'), findsOneWidget);
      expect(find.text('off'), findsOneWidget);
    });

    testWidgets('does not require a Material ancestor in dialog content', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.macOS),
          home: CameraSettingsFormWidget(
            formBloc: formBloc,
            videoDevices: [
              CameraMacOSDevice(
                deviceId: 'camera1',
                localizedName: 'Built-in Camera',
                manufacturer: 'Apple',
              ),
            ],
            audioDevices: [
              CameraMacOSDevice(
                deviceId: 'mic1',
                localizedName: 'Studio Mic',
                manufacturer: 'Apple',
              ),
            ],
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps labels visually separate from dropdown controls', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.macOS),
          home: Scaffold(
            body: CameraSettingsFormWidget(
              formBloc: formBloc,
              videoDevices: [
                CameraMacOSDevice(
                  deviceId: 'camera1',
                  localizedName: 'Built-in Camera',
                  manufacturer: 'Apple',
                ),
              ],
              audioDevices: [
                CameraMacOSDevice(
                  deviceId: 'mic1',
                  localizedName: 'Studio Mic',
                  manufacturer: 'Apple',
                ),
              ],
            ),
          ),
        ),
      );

      final labelRect = tester.getRect(find.text('Camera Mode'));
      final dropdownRect = tester.getRect(
        find.byType(DropdownButton<CameraMacOSMode>),
      );

      expect(labelRect.bottom + 6, lessThanOrEqualTo(dropdownRect.top));
    });

    testWidgets('uses readable theme colors for form text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.macOS),
          home: Scaffold(
            body: CameraSettingsFormWidget(
              formBloc: formBloc,
              videoDevices: [
                CameraMacOSDevice(
                  deviceId: 'camera1',
                  localizedName: 'Built-in Camera',
                  manufacturer: 'Apple',
                ),
              ],
              audioDevices: [
                CameraMacOSDevice(
                  deviceId: 'mic1',
                  localizedName: 'Studio Mic',
                  manufacturer: 'Apple',
                ),
              ],
            ),
          ),
        ),
      );

      final theme = Theme.of(
        tester.element(find.byType(CameraSettingsFormWidget)),
      );
      final selectedValue = tester.widget<Text>(find.text('video'));
      final switchLabel = tester.widget<Text>(find.text('Mirror-Flip Video'));

      expect(selectedValue.style?.color, theme.colorScheme.onSurface);
      expect(switchLabel.style?.color, theme.colorScheme.onSurfaceVariant);
    });
  });
}
