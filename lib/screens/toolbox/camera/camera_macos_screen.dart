import 'dart:typed_data';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_components/app_components.dart';
import 'package:camera_macos/camera_macos.dart';
import 'package:camera_settings_form/camera_settings_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/toolbox/camera/camera_settings_dialog.dart';
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
  Uint8List? lastImagePreviewData;
  Uint8List? lastRecordedVideoData;
  List<CameraMacOSDevice> videoDevices = [];
  List<CameraMacOSDevice> audioDevices = [];
  CameraImageData? streamedImage;

  // Camera key - incremented to force rebuild
  int _cameraKey = 0;

  late CameraSettingsFormBloc _formBloc;

  @override
  void initState() {
    super.initState();
    _formBloc = CameraSettingsFormBloc();
    _loadDevices();
    _setupFormListeners();
  }

  void _setupFormListeners() {
    // All settings changes trigger camera restart
    _formBloc.cameraMode.onValueChanges(
      onData: (previous, current) async* {
        _rebuildCamera();
      },
    );

    _formBloc.deviceId.onValueChanges(
      onData: (previous, current) async* {
        _rebuildCamera();
      },
    );

    _formBloc.audioDeviceId.onValueChanges(
      onData: (previous, current) async* {
        _rebuildCamera();
      },
    );

    _formBloc.orientation.onValueChanges(
      onData: (previous, current) async* {
        _rebuildCamera();
      },
    );

    _formBloc.torch.onValueChanges(
      onData: (previous, current) async* {
        _rebuildCamera();
      },
    );

    _formBloc.isVideoMirrored.onValueChanges(
      onData: (previous, current) async* {
        _rebuildCamera();
      },
    );
  }

  void _rebuildCamera() {
    // Destroy old controller before rebuild
    macOSController?.destroy();
    macOSController = null;
    setState(() {
      _cameraKey++;
    });
  }

  @override
  void dispose() {
    macOSController?.destroy();
    _formBloc.close();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    final videos = await CameraMacOS.instance.listDevices(
      deviceType: CameraMacOSDeviceType.video,
    );
    final audios = await CameraMacOS.instance.listDevices(
      deviceType: CameraMacOSDeviceType.audio,
    );

    setState(() {
      videoDevices = videos;
      audioDevices = audios;
    });

    _formBloc.updateVideoDevices(videos);
    _formBloc.updateAudioDevices(audios);
  }

  @override
  Widget build(BuildContext context) {
    const String title = 'Camera';

    return BlocProvider.value(
      value: _formBloc,
      child: AppAdaptiveScaffold(
        selectedIndex: Destinations.indexOf(
          const Key(ToolboxScreen.name),
          context,
        ),
        destinations: Destinations.navs(context),
        onSelectedIndexChange: (idx) =>
            Destinations.changeHandler(idx, context),
        body: (_) => SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: kDefaultGridGap),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                title: const Text(title),
                actions: _buildActions(context),
              ),
              SliverFillRemaining(child: _buildCameraView()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return CameraMacOSView(
      key: ValueKey(_cameraKey),
      fit: BoxFit.contain,
      deviceId: _formBloc.deviceId.value,
      audioDeviceId: _formBloc.audioDeviceId.value,
      cameraMode: _formBloc.cameraMode.value ?? CameraMacOSMode.video,
      toggleTorch: _formBloc.torch.value ?? Torch.off,
      isVideoMirrored: _formBloc.isVideoMirrored.value,
      orientation:
          _formBloc.orientation.value ?? CameraOrientation.orientation0deg,
      onCameraInizialized: (CameraMacOSController controller) {
        macOSController = controller;
      },
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      AppAdaptiveActionList(
        size: AppAdaptiveActionSize.medium,
        actions: [
          AppAdaptiveAction(
            icon: Icons.settings,
            title: 'Setting',
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
    ];
  }

  void _showSettingsDialog(BuildContext context) {
    // WORKAROUND(upstream): duskmoon-dev/flutter-duskmoon-ui#16
    showDialog<void>(
      context: context,
      builder: (dialogContext) => CameraSettingsDialog(
        formBloc: _formBloc,
        videoDevices: videoDevices,
        audioDevices: audioDevices,
        onClose: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }
}
