import 'dart:typed_data';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_components/app_components.dart';
import 'package:app_logging/app_logging.dart';
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
  // The plugin owns one native session shared by all screen instances.
  static Future<void>? _cameraTask;

  CameraMacOSController? macOSController;
  Uint8List? lastImagePreviewData;
  Uint8List? lastRecordedVideoData;
  List<CameraMacOSDevice> videoDevices = [];
  List<CameraMacOSDevice> audioDevices = [];
  CameraImageData? streamedImage;

  bool _devicesLoaded = false;
  int _cameraRequest = 0;
  Widget? _cameraView;
  Future<CameraMacOSArguments?>? _cameraInitialization;

  late CameraSettingsFormBloc _formBloc;

  @override
  void initState() {
    super.initState();
    _formBloc = CameraSettingsFormBloc();
    _loadDevices();
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
    if (!mounted || !_devicesLoaded) return;
    final request = ++_cameraRequest;
    _queueCameraTask(() => _restartCamera(request));
  }

  void _queueCameraTask(Future<void> Function() operation) {
    final previous = _cameraTask ?? Future<void>.value();
    late final Future<void> task;
    task = previous
        .then((_) => operation())
        .catchError(_reportCameraError)
        .whenComplete(() {
          // Keep only pending work, without retaining an idle screen or its zone.
          if (identical(_cameraTask, task)) _cameraTask = null;
        });
    _cameraTask = task;
  }

  Future<void> _restartCamera(int request) async {
    if (!mounted || request != _cameraRequest) return;
    setState(() => _cameraView = null);
    await _destroyCamera();
    if (!mounted || request != _cameraRequest) return;

    final key = GlobalKey<CameraMacOSViewState>();
    _cameraInitialization = null;
    setState(() => _cameraView = _createCameraView(key));
    await WidgetsBinding.instance.endOfFrame;
    final initialization =
        _cameraInitialization ?? key.currentState?.initializeCameraFuture;
    if (initialization != null) await initialization;
  }

  Future<void> _destroyCamera() async {
    final controller = macOSController;
    if (controller != null) {
      await controller.destroy();
      macOSController = null;
    }
  }

  void _reportCameraError(Object error, StackTrace stackTrace) {
    AppLogger().e('Camera lifecycle failed', error, stackTrace);
  }

  @override
  void dispose() {
    _cameraRequest++;
    _queueCameraTask(_destroyCamera);
    _formBloc.close();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    final videos = await CameraMacOS.instance.listDevices(
      deviceType: CameraMacOSDeviceType.video,
    );
    if (!mounted) return;
    final audios = await CameraMacOS.instance.listDevices(
      deviceType: CameraMacOSDeviceType.audio,
    );
    if (!mounted) return;

    _formBloc.updateVideoDevices(videos);
    _formBloc.updateAudioDevices(audios);
    _setupFormListeners();
    _devicesLoaded = true;

    setState(() {
      videoDevices = videos;
      audioDevices = audios;
    });

    _rebuildCamera();
  }

  @override
  Widget build(BuildContext context) {
    const String title = 'Camera';

    return BlocProvider.value(
      value: _formBloc,
      child: AppAdaptiveScaffold(
        navigationRestoreInHeader: true,
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
              DmNavigationHeader(
                builder: (context, header) => SliverAppBar(
                  leading: header.leading,
                  leadingWidth: header.leadingWidth,
                  automaticallyImplyLeading: header.automaticallyImplyLeading,
                  floating: true,
                  title: const Text(title),
                  actions: _buildActions(context),
                ),
              ),
              SliverFillRemaining(child: _buildCameraView()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return _cameraView ?? const Center(child: CircularProgressIndicator());
  }

  Widget _createCameraView(GlobalKey<CameraMacOSViewState> key) {
    return CameraMacOSView(
      key: key,
      fit: BoxFit.contain,
      deviceId: _formBloc.deviceId.value,
      audioDeviceId: _formBloc.audioDeviceId.value,
      cameraMode: _formBloc.cameraMode.value ?? CameraMacOSMode.video,
      toggleTorch: _formBloc.torch.value ?? Torch.off,
      isVideoMirrored: _formBloc.isVideoMirrored.value,
      orientation:
          _formBloc.orientation.value ?? CameraOrientation.orientation0deg,
      onCameraLoading: (error) {
        // Retain the native initialization future if the view is unmounted.
        _cameraInitialization ??= key.currentState?.initializeCameraFuture;
        return error == null
            ? const Center(child: CircularProgressIndicator())
            : const ColoredBox(color: Colors.black);
      },
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
