import 'package:camera_macos/camera_macos.dart';
import 'package:camera_settings_form/camera_settings_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/toolbox/camera/camera_settings_dialog.dart';

void main() {
  testWidgets('uses the active dark theme for the dialog surface', (
    tester,
  ) async {
    final formBloc = CameraSettingsFormBloc();
    addTearDown(() async => formBloc.close());

    final videoDevices = [
      CameraMacOSDevice(deviceId: 'camera1', localizedName: 'Built-in Camera'),
    ];
    final audioDevices = [
      CameraMacOSDevice(deviceId: 'mic1', localizedName: 'Studio Mic'),
    ];
    formBloc.updateVideoDevices(videoDevices);
    formBloc.updateAudioDevices(audioDevices);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: Brightness.dark,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: colorScheme),
        home: CameraSettingsDialog(
          formBloc: formBloc,
          videoDevices: videoDevices,
          audioDevices: audioDevices,
          onClose: () {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 10));

    final dialog = tester.widget<Dialog>(find.byType(Dialog));
    final title = tester.widget<Text>(find.text('Camera Settings'));
    final closeButton = tester.widget<TextButton>(
      find.ancestor(of: find.text('Close'), matching: find.byType(TextButton)),
    );

    expect(dialog.backgroundColor, colorScheme.surfaceContainerHighest);
    expect(title.style?.color, colorScheme.onSurface);
    expect(
      closeButton.style?.foregroundColor?.resolve({}),
      colorScheme.primary,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
