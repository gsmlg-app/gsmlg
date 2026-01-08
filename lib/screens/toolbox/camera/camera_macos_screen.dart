import 'dart:typed_data';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_components/app_components.dart';
import 'package:camera_macos/camera_macos.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';

class CameraMacosScreen extends StatefulWidget {
  static const name = 'Camera Macos';
  static const path = 'camera_macos';

  const CameraMacosScreen({super.key});

  @override
  State<CameraMacosScreen> createState() => _CameraMacosScreenState();
}

class _CameraMacosScreenState extends State<CameraMacosScreen> {
  CameraMacOSController? macOSController;
  CameraMacOSMode cameraMode = CameraMacOSMode.video;
  late TextEditingController durationController;
  late double durationValue;
  Uint8List? lastImagePreviewData;
  Uint8List? lastRecordedVideoData;
  GlobalKey cameraKey = GlobalKey();
  List<CameraMacOSDevice> videoDevices = [];
  String? selectedVideoDevice;
  PictureResolution selectedPictureResolution = PictureResolution.max;
  AudioQuality selectedAudioQuality = AudioQuality.min;
  PictureFormat selectedPictureFormat = PictureFormat.tiff;
  CameraOrientation selectedOrientation = CameraOrientation.orientation0deg;
  VideoFormat selectedVideoFormat = VideoFormat.mp4;
  AudioFormat selectedAudioFormat = AudioFormat.kAudioFormatAppleLossless;

  List<CameraMacOSDevice> audioDevices = [];
  String? selectedAudioDevice;

  Torch selectedTorch = Torch.off;

  bool usePlatformView = false;
  bool streamImage = false;
  bool isVideoMirrored = false;

  CameraImageData? streamedImage;

  double zoom = 1.0;

  List<DropdownMenuItem<String>> add = [];

  String? deviceId;
  String? audioDeviceId;

  @override
  void initState() {
    super.initState();
    loadDevices();
  }

  @override
  void dispose() {
    macOSController?.destroy();
    super.dispose();
  }

  void loadDevices() async {
    setState(() async {
      videoDevices = await CameraMacOS.instance
          .listDevices(deviceType: CameraMacOSDeviceType.video);
      audioDevices = await CameraMacOS.instance
          .listDevices(deviceType: CameraMacOSDeviceType.audio);
    });
  }

  @override
  Widget build(BuildContext context) {
    const String title = 'Camera';

    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(ToolboxScreen.name),
        context,
      ),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: kDefaultGridGap),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: const Text(title),
              actions: getActions(context),
            ),
            SliverFillRemaining(
              child: CameraMacOSView(
                fit: BoxFit.contain,
                deviceId: deviceId,
                audioDeviceId: audioDeviceId,
                cameraMode: cameraMode,
                toggleTorch: selectedTorch,
                isVideoMirrored: isVideoMirrored,
                onCameraInizialized: (CameraMacOSController controller) {
                  setState(() {
                    macOSController = controller;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> getActions(
    BuildContext context, {
    bool isSmall = false,
    bool isLarge = false,
  }) {
    final size = isSmall
        ? AppAdaptiveActionSize.small
        : isLarge
            ? AppAdaptiveActionSize.large
            : AppAdaptiveActionSize.medium;

    return [
      AppAdaptiveActionList(
        size: size,
        actions: [
          AppAdaptiveAction(
            icon: Icons.settings,
            title: 'Setting',
            onPressed: () {
              showAdaptiveDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: SizedBox(
                      width: 600,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Setting'),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 24,
                              children: [
                                const Text('Camera Mode'),
                                DropdownButton<CameraMacOSMode>(
                                  value: cameraMode,
                                  items: CameraMacOSMode.values
                                      .map((CameraMacOSMode value) {
                                    return DropdownMenuItem<CameraMacOSMode>(
                                      value: value,
                                      child: Text(value.name),
                                    );
                                  }).toList(),
                                  onChanged: (CameraMacOSMode? value) {
                                    setState(() {
                                      cameraMode = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 24,
                              children: [
                                const Text('Device'),
                                DropdownButton<String>(
                                  value: deviceId,
                                  items: videoDevices
                                      .map((CameraMacOSDevice value) {
                                    return DropdownMenuItem<String>(
                                      value: value.deviceId,
                                      child: Text(
                                        '${value.localizedName} (${value.manufacturer})',
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      deviceId = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 24,
                              children: [
                                const Text('Audio Device'),
                                DropdownButton<String>(
                                  value: audioDeviceId,
                                  items: audioDevices
                                      .map((CameraMacOSDevice value) {
                                    return DropdownMenuItem<String>(
                                      value: value.deviceId,
                                      child: Text(
                                        '${value.localizedName} (${value.manufacturer})',
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      audioDeviceId = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 24,
                              children: [
                                const Text('Orientation'),
                                DropdownButton<CameraOrientation>(
                                  value: selectedOrientation,
                                  items: CameraOrientation.values
                                      .map((CameraOrientation value) {
                                    return DropdownMenuItem<CameraOrientation>(
                                      value: value,
                                      child: Text(value.name),
                                    );
                                  }).toList(),
                                  onChanged: (CameraOrientation? value) {
                                    setState(() {
                                      selectedOrientation = value!;
                                    });
                                    macOSController?.setOrientation(value!);
                                  },
                                ),
                              ],
                            ),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 24,
                              children: [
                                const Text('Torch'),
                                DropdownButton<Torch>(
                                  value: selectedTorch,
                                  items: Torch.values.map((Torch value) {
                                    return DropdownMenuItem<Torch>(
                                      value: value,
                                      child: Text(value.name),
                                    );
                                  }).toList(),
                                  onChanged: (Torch? value) {
                                    setState(() {
                                      selectedTorch = value!;
                                    });
                                    macOSController?.toggleTorch(value!);
                                  },
                                ),
                              ],
                            ),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 24,
                              children: [
                                const Text('Mirror-Flip Video'),
                                Switch(
                                  value: isVideoMirrored,
                                  onChanged: (value) {
                                    setState(() {
                                      isVideoMirrored = value;
                                    });
                                    macOSController?.setVideoMirrored(value);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    ];
  }
}
