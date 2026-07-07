import 'dart:async';

import 'package:camera_macos/camera_macos.dart';
import 'package:duskmoon_form/duskmoon_form.dart';

/// FormBloc for Camera Settings
class CameraSettingsFormBloc extends FormBloc<String, String> {
  CameraSettingsFormBloc({
    List<CameraMacOSDevice> videoDevices = const [],
    List<CameraMacOSDevice> audioDevices = const [],
  }) : super(autoValidate: true) {
    _updateDeviceItems(deviceId, videoDevices);
    _updateDeviceItems(audioDeviceId, audioDevices);

    addFieldBlocs(fieldBlocs: [
      cameraMode,
      deviceId,
      audioDeviceId,
      orientation,
      torch,
      isVideoMirrored,
    ]);
  }

  final cameraMode = SelectFieldBloc<CameraMacOSMode, dynamic>(
    name: 'cameraMode',
    initialValue: CameraMacOSMode.video,
    items: CameraMacOSMode.values,
  );

  final deviceId = SelectFieldBloc<String, dynamic>(
    name: 'deviceId',
    items: [],
  );

  final audioDeviceId = SelectFieldBloc<String, dynamic>(
    name: 'audioDeviceId',
    items: [],
  );

  final orientation = SelectFieldBloc<CameraOrientation, dynamic>(
    name: 'orientation',
    initialValue: CameraOrientation.orientation0deg,
    items: CameraOrientation.values,
  );

  final torch = SelectFieldBloc<Torch, dynamic>(
    name: 'torch',
    initialValue: Torch.off,
    items: Torch.values,
  );

  final isVideoMirrored = BooleanFieldBloc(
    name: 'isVideoMirrored',
    initialValue: false,
  );

  void updateVideoDevices(List<CameraMacOSDevice> devices) {
    _updateDeviceItems(deviceId, devices);
  }

  void updateAudioDevices(List<CameraMacOSDevice> devices) {
    _updateDeviceItems(audioDeviceId, devices);
  }

  void _updateDeviceItems(
    SelectFieldBloc<String, dynamic> fieldBloc,
    List<CameraMacOSDevice> devices,
  ) {
    final deviceIds = devices.map((device) => device.deviceId).toList();
    fieldBloc.updateItems(deviceIds);

    if (deviceIds.isNotEmpty &&
        (fieldBloc.value == null || !deviceIds.contains(fieldBloc.value))) {
      fieldBloc.updateValue(deviceIds.first);
    }
  }

  @override
  FutureOr<void> onSubmitting() async {
    emitSuccess();
  }
}
