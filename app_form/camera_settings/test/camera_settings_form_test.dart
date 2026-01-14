import 'package:camera_macos/camera_macos.dart';
import 'package:camera_settings_form/camera_settings_form.dart';
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
  });
}
