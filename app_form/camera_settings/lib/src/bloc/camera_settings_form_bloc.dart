import 'dart:async';

import 'package:camera_macos/camera_macos.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

/// FormBloc for Camera Settings
class CameraSettingsFormBloc extends FormBloc<String, String> {
  CameraSettingsFormBloc({
    List<CameraMacOSDevice> videoDevices = const [],
    List<CameraMacOSDevice> audioDevices = const [],
  }) : super(autoValidate: true) {
    // Update items for device selectors
    deviceId.updateItems(videoDevices.map((d) => d.deviceId).toList());
    audioDeviceId.updateItems(audioDevices.map((d) => d.deviceId).toList());

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
    deviceId.updateItems(devices.map((d) => d.deviceId).toList());
  }

  void updateAudioDevices(List<CameraMacOSDevice> devices) {
    audioDeviceId.updateItems(devices.map((d) => d.deviceId).toList());
  }

  @override
  FutureOr<void> onSubmitting() async {
    emitSuccess();
  }
}
