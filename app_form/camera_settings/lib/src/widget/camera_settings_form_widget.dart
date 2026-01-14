import 'package:camera_macos/camera_macos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../bloc/camera_settings_form_bloc.dart';

/// Camera settings form widget for use in dialogs
class CameraSettingsFormWidget extends StatelessWidget {
  const CameraSettingsFormWidget({
    super.key,
    required this.formBloc,
    required this.videoDevices,
    required this.audioDevices,
  });

  final CameraSettingsFormBloc formBloc;
  final List<CameraMacOSDevice> videoDevices;
  final List<CameraMacOSDevice> audioDevices;

  String? _getDeviceName(String? deviceId, List<CameraMacOSDevice> devices) {
    if (deviceId == null) return null;
    final device = devices.where((d) => d.deviceId == deviceId).firstOrNull;
    if (device == null) return deviceId;
    return '${device.localizedName} (${device.manufacturer})';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: formBloc,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownFieldBlocBuilder<CameraMacOSMode>(
              selectFieldBloc: formBloc.cameraMode,
              decoration: const InputDecoration(
                labelText: 'Camera Mode',
                border: OutlineInputBorder(),
              ),
              itemBuilder: (context, value) =>
                  FieldItem(child: Text(value.name)),
            ),
            const SizedBox(height: 16),
            DropdownFieldBlocBuilder<String>(
              selectFieldBloc: formBloc.deviceId,
              decoration: const InputDecoration(
                labelText: 'Video Device',
                border: OutlineInputBorder(),
              ),
              itemBuilder: (context, value) => FieldItem(
                child: Text(_getDeviceName(value, videoDevices) ?? value),
              ),
            ),
            const SizedBox(height: 16),
            DropdownFieldBlocBuilder<String>(
              selectFieldBloc: formBloc.audioDeviceId,
              decoration: const InputDecoration(
                labelText: 'Audio Device',
                border: OutlineInputBorder(),
              ),
              itemBuilder: (context, value) => FieldItem(
                child: Text(_getDeviceName(value, audioDevices) ?? value),
              ),
            ),
            const SizedBox(height: 16),
            DropdownFieldBlocBuilder<CameraOrientation>(
              selectFieldBloc: formBloc.orientation,
              decoration: const InputDecoration(
                labelText: 'Orientation',
                border: OutlineInputBorder(),
              ),
              itemBuilder: (context, value) =>
                  FieldItem(child: Text(value.name)),
            ),
            const SizedBox(height: 16),
            DropdownFieldBlocBuilder<Torch>(
              selectFieldBloc: formBloc.torch,
              decoration: const InputDecoration(
                labelText: 'Torch',
                border: OutlineInputBorder(),
              ),
              itemBuilder: (context, value) =>
                  FieldItem(child: Text(value.name)),
            ),
            const SizedBox(height: 16),
            SwitchFieldBlocBuilder(
              booleanFieldBloc: formBloc.isVideoMirrored,
              body: const Text('Mirror-Flip Video'),
            ),
          ],
        ),
      ),
    );
  }
}
