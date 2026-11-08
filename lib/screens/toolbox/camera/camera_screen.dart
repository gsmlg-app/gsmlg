import 'dart:async';
import 'dart:ui' show DisplayFeatureType;

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_components/app_components.dart';
import 'package:app_locale/app_locale.dart';
import 'package:camera/camera.dart';
import 'package:camera_bloc/camera_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';

enum CameraFitMode {
  contain,
  cover,
}

/// Fold posture perception for foldable devices like Google Pixel Fold.
enum FoldPosture {
  folded,
  unfolded,
}

extension FoldPostureExtension on FoldPosture {
  bool get isFolded => this == FoldPosture.folded;
  bool get isUnfolded => this == FoldPosture.unfolded;
}

FoldPosture resolveFoldPosture(BuildContext context) {
  final mq = MediaQuery.of(context);
  final hasFoldFeature = mq.displayFeatures.any(
    (f) =>
        f.type == DisplayFeatureType.fold ||
        f.type == DisplayFeatureType.hinge,
  );
  if (hasFoldFeature) return FoldPosture.unfolded;
  // Cover screen on foldables (e.g. Pixel Fold cover is 411dp) has shortestSide < 600dp.
  // Inner unfolded screen (Pixel Fold inner is ~701dp) has shortestSide >= 600dp.
  return mq.size.shortestSide >= 600 ? FoldPosture.unfolded : FoldPosture.folded;
}

String getCameraDisplayName(CameraDescription camera, BuildContext context) {
  if (camera.lensDirection == CameraLensDirection.front) {
    final posture = resolveFoldPosture(context);
    return posture.isUnfolded ? 'Front (Inner)' : 'Front (Cover)';
  }
  return camera.title;
}

IconData getCameraDisplayIcon(CameraDescription camera, BuildContext context) {
  if (camera.lensDirection == CameraLensDirection.front) {
    final posture = resolveFoldPosture(context);
    return posture.isUnfolded ? Icons.devices_fold : Icons.phone_android;
  }
  return Icons.camera_rear;
}

String getCameraBadgeTitle(CameraDescription camera, BuildContext context) {
  if (camera.lensDirection == CameraLensDirection.front) {
    final posture = resolveFoldPosture(context);
    return posture.isUnfolded
        ? 'Front Camera (Inner · 展开内屏)'
        : 'Front Camera (Cover · 外屏)';
  }
  return '${camera.title} Camera';
}

/// Viewfinder widget that renders the camera preview stream with exact
/// pixel aspect ratio and rotation compensation for foldables, tablets,
/// and phones. Never distorts or squashes circular geometry.
class CameraViewfinder extends StatelessWidget {
  const CameraViewfinder({
    super.key,
    required this.controller,
    required this.quarterTurns,
    this.fitMode = CameraFitMode.contain,
  });

  final CameraController controller;
  final int quarterTurns;
  final CameraFitMode fitMode;

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final previewSize = controller.value.previewSize;
    if (previewSize == null) {
      return const SizedBox.shrink();
    }

    final isUnfoldedWide = resolveFoldPosture(context).isUnfolded;

    // On standard portrait screens (Folded cover screen or regular phones),
    // CameraX already maps the native stream to portrait orientation, so the
    // stream width is min(width, height) and stream height is max(width, height).
    // On unfolded wide screens (e.g. Pixel Fold inner landscape panel), CameraX
    // outputs a landscape buffer which is then rotated by 3 quarter turns (270°).
    final double streamWidth;
    final double streamHeight;

    if (isUnfoldedWide) {
      streamWidth = previewSize.width;
      streamHeight = previewSize.height;
    } else {
      final isPortrait =
          controller.value.deviceOrientation == DeviceOrientation.portraitUp ||
              controller.value.deviceOrientation ==
                  DeviceOrientation.portraitDown;
      if (isPortrait) {
        final w = previewSize.width;
        final h = previewSize.height;
        streamWidth = w < h ? w : h;
        streamHeight = w > h ? w : h;
      } else {
        streamWidth = previewSize.width;
        streamHeight = previewSize.height;
      }
    }

    final isSwapped = (quarterTurns % 2 == 1);
    final visualWidth = isSwapped ? streamHeight : streamWidth;
    final visualHeight = isSwapped ? streamWidth : streamHeight;
    final visualAspectRatio = visualWidth / visualHeight;

    final childWidget = SizedBox(
      width: visualWidth,
      height: visualHeight,
      child: RotatedBox(
        quarterTurns: quarterTurns,
        child: SizedBox(
          width: streamWidth,
          height: streamHeight,
          child: controller.buildPreview(),
        ),
      ),
    );

    if (fitMode == CameraFitMode.cover) {
      return ClipRect(
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: childWidget,
          ),
        ),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: visualAspectRatio,
        child: FittedBox(
          fit: BoxFit.contain,
          child: childWidget,
        ),
      ),
    );
  }
}

bool _isSameCamera(CameraDescription? a, CameraDescription? b) {
  if (a == null || b == null) return false;
  return a.name == b.name && a.lensDirection == b.lensDirection;
}

class CameraScreen extends StatefulWidget {
  static const name = 'Camera';
  static const path = 'camera';

  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  late final CameraBloc _cameraBloc;
  bool _hasRequestedInitialCamera = false;
  int _manualRotationQuarterTurns = 0;
  CameraFitMode _fitMode = CameraFitMode.contain;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  FoldPosture? _lastPosture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameraBloc = context.read<CameraBloc>();
    _cameraBloc.add(const CameraInitCameras());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lastPosture ??= resolveFoldPosture(context);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!mounted) return;
    final newPosture = resolveFoldPosture(context);
    if (_lastPosture != null && _lastPosture != newPosture) {
      _lastPosture = newPosture;
      setState(() {});
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                newPosture.isUnfolded
                    ? Icons.devices_fold
                    : Icons.phone_android,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                newPosture.isUnfolded
                    ? '折叠已展开：自动切换至内屏前摄'
                    : '折叠已合上：自动切换至外屏前摄',
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopRecordingTimer();
    _cameraBloc.add(const CameraStop());
    super.dispose();
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingSeconds = 0;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _recordingSeconds++);
      }
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _recordingSeconds = 0;
  }

  int _computeBaseQuarterTurns(
    CameraController controller,
    BuildContext context,
  ) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return 0;
    }

    final orientation = controller.value.isRecordingVideo
        ? controller.value.recordingOrientation!
        : (controller.value.previewPauseOrientation ??
            controller.value.lockedCaptureOrientation ??
            controller.value.deviceOrientation);

    final turns = <DeviceOrientation, int>{
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeRight: 1,
      DeviceOrientation.portraitDown: 2,
      DeviceOrientation.landscapeLeft: 3,
    };
    int baseTurns = turns[orientation] ?? 0;

    // Pixel Fold inner screen and landscape tablets compensation:
    // Natural orientation panel is landscape (width > height) with ROTATION_90
    // hardware installation.
    // - Back camera sensor orientation is 90°, so it needs +3 turns (270°).
    // - Inner front camera sensor orientation is 0° (unlike outer front 270°),
    //   so it needs +1 turn (90°) instead of +3 turns (270°) to avoid being 180° upside-down.
    final isUnfoldedWide = resolveFoldPosture(context).isUnfolded;
    if (isUnfoldedWide &&
        (orientation == DeviceOrientation.portraitUp ||
            orientation == DeviceOrientation.portraitDown)) {
      if (controller.description.lensDirection == CameraLensDirection.front) {
        baseTurns = (baseTurns + 1) % 4;
      } else {
        baseTurns = (baseTurns + 3) % 4;
      }
    }

    return baseTurns;
  }

  int _getEffectiveQuarterTurns(
    CameraController controller,
    BuildContext context,
  ) {
    final base = _computeBaseQuarterTurns(controller, context);
    return (base + _manualRotationQuarterTurns) % 4;
  }

  Future<void> _takePhoto(CameraController controller) async {
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      final fileName = file.path.split('/').last;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo captured: $fileName'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to take photo: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _toggleVideoRecording(CameraController controller) async {
    try {
      if (controller.value.isRecordingVideo) {
        final file = await controller.stopVideoRecording();
        _stopRecordingTimer();
        if (!mounted) return;
        final fileName = file.path.split('/').last;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video saved: $fileName'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        await controller.startVideoRecording();
        _startRecordingTimer();
      }
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Video recording error: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _cycleFlashMode(CameraController controller) async {
    final current = controller.value.flashMode;
    FlashMode next;
    switch (current) {
      case FlashMode.off:
        next = FlashMode.auto;
      case FlashMode.auto:
        next = FlashMode.always;
      case FlashMode.always:
        next = FlashMode.torch;
      case FlashMode.torch:
        next = FlashMode.off;
    }
    try {
      await controller.setFlashMode(next);
      if (mounted) setState(() {});
    } catch (_) {
      // Flash mode not supported by camera
    }
  }

  IconData _getFlashIcon(FlashMode mode) {
    switch (mode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.torch:
        return Icons.highlight;
    }
  }

  void _switchNextCamera(
    List<CameraDescription> cameras,
    CameraController? controller,
  ) {
    if (cameras.length <= 1) return;
    final currentIndex =
        cameras.indexWhere((c) => _isSameCamera(c, controller?.description));
    final nextIndex =
        currentIndex >= 0 ? (currentIndex + 1) % cameras.length : 0;
    context.read<CameraBloc>().add(CameraSwitched(cameras[nextIndex]));
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = l10n.cameraTitle;

    return AppAdaptiveScaffold(
      navigationRestoreInHeader: context.select<CameraBloc, bool>(
        (bloc) =>
            bloc.state is CameraError ||
            bloc.state is CameraLoaded ||
            bloc.state is CameraNoHardwareAvailable,
      ),
      selectedIndex: Destinations.indexOf(
        const Key(ToolboxScreen.name),
        context,
      ),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: kDefaultGridGap),
        child: BlocConsumer<CameraBloc, CameraState>(
          listenWhen: (previous, current) =>
              current is CameraLoaded &&
              current.controller == null &&
              current.cameras.isNotEmpty,
          listener: (context, state) {
            if (state is CameraLoaded &&
                state.controller == null &&
                state.cameras.isNotEmpty &&
                !_hasRequestedInitialCamera) {
              _hasRequestedInitialCamera = true;
              final defaultCamera = state.cameras.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.back,
                orElse: () => state.cameras.first,
              );
              context.read<CameraBloc>().add(CameraSwitched(defaultCamera));
            }
          },
          builder: (context, state) {
            if (state is CameraInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CameraNoHardwareAvailable) {
              return _NoCameraView(title: title);
            }

            if (state is CameraError) {
              if (isNoCameraError(state.error)) {
                return _NoCameraView(title: title);
              }
              return _CameraErrorView(
                title: title,
                error: state.error,
              );
            }

            if (state is CameraLoaded) {
              final cameras = state.cameras;
              final controller = state.controller;

              if (cameras.isEmpty) {
                return _NoCameraView(title: title);
              }

              final effectiveTurns = controller != null
                  ? _getEffectiveQuarterTurns(controller, context)
                  : 0;

              return Column(
                children: [
                  DmNavigationHeader(
                    builder: (context, header) => AppBar(
                      leading: header.leading,
                      leadingWidth: header.leadingWidth,
                      automaticallyImplyLeading:
                          header.automaticallyImplyLeading,
                      title: Text(title),
                      actions: [
                        // Camera Selector in AppBar
                        if (cameras.length <= 3)
                          for (final camera in cameras)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                selected:
                                    _isSameCamera(controller?.description, camera),
                                avatar: Icon(
                                  getCameraDisplayIcon(camera, context),
                                  size: 16,
                                ),
                                label: Text(getCameraDisplayName(camera, context)),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                onSelected: (selected) {
                                  if (selected &&
                                      !_isSameCamera(controller?.description, camera)) {
                                    context.read<CameraBloc>().add(
                                          CameraSwitched(camera),
                                        );
                                  }
                                },
                              ),
                            )
                        else
                          PopupMenuButton<CameraDescription>(
                            tooltip: 'Select Camera',
                            initialValue: controller?.description,
                            icon: const Icon(Icons.cameraswitch_outlined),
                            onSelected: (camera) {
                              context.read<CameraBloc>().add(
                                    CameraSwitched(camera),
                                  );
                            },
                            itemBuilder: (context) => [
                              for (final camera in cameras)
                                PopupMenuItem(
                                  value: camera,
                                  child: Row(
                                    children: [
                                      Icon(
                                        getCameraDisplayIcon(camera, context),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(getCameraDisplayName(camera, context)),
                                      const Spacer(),
                                      Text(
                                        '${camera.sensorOrientation}°',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                        if (controller != null) ...[
                          // Flash Mode
                          IconButton(
                            icon: Icon(_getFlashIcon(controller.value.flashMode)),
                            tooltip: 'Flash: ${controller.value.flashMode.name}',
                            onPressed: () => _cycleFlashMode(controller),
                          ),
                          // Aspect Ratio Mode
                          IconButton(
                            icon: Icon(
                              _fitMode == CameraFitMode.contain
                                  ? Icons.fit_screen_outlined
                                  : Icons.crop_free_outlined,
                            ),
                            tooltip: _fitMode == CameraFitMode.contain
                                ? 'Fit (Letterbox)'
                                : 'Fill (Cover)',
                            onPressed: () {
                              setState(() {
                                _fitMode = _fitMode == CameraFitMode.contain
                                    ? CameraFitMode.cover
                                    : CameraFitMode.contain;
                              });
                            },
                          ),
                          // Rotation Menu
                          PopupMenuButton<int>(
                            tooltip:
                                'Rotate (${effectiveTurns * 90}°)',
                            icon: Badge(
                              isLabelVisible: _manualRotationQuarterTurns != 0,
                              label: Text('${_manualRotationQuarterTurns * 90}°'),
                              child: const Icon(
                                Icons.rotate_90_degrees_cw_outlined,
                              ),
                            ),
                            onSelected: (value) {
                              setState(() {
                                _manualRotationQuarterTurns = value;
                              });
                            },
                            itemBuilder: (context) {
                              final baseTurns = _computeBaseQuarterTurns(
                                controller,
                                context,
                              );
                              return [
                                PopupMenuItem(
                                  value: 0,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.auto_mode, size: 20),
                                      const SizedBox(width: 8),
                                      const Text('Auto'),
                                      if (_manualRotationQuarterTurns == 0) ...[
                                        const Spacer(),
                                        Icon(
                                          Icons.check,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          size: 20,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                for (int i = 1; i <= 3; i++)
                                  PopupMenuItem(
                                    value: i,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.rotate_right, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          '+${i * 90}° (${((baseTurns + i) % 4) * 90}°)',
                                        ),
                                        if (_manualRotationQuarterTurns == i) ...[
                                          const Spacer(),
                                          Icon(
                                            Icons.check,
                                            color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                            size: 20,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                              ];
                            },
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Viewfinder container (fills space between AppBar and BottomControls)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant
                              .withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (controller != null)
                            CameraViewfinder(
                              controller: controller,
                              quarterTurns: effectiveTurns,
                              fitMode: _fitMode,
                            )
                          else
                            const SizedBox.shrink(),

                          // Viewfinder corner brackets overlay
                          IgnorePointer(
                            child: CustomPaint(
                              painter: _ViewfinderReticlePainter(
                                color:
                                    Colors.white.withValues(alpha: 0.35),
                              ),
                            ),
                          ),

                          // Info badge (top-left)
                          if (controller != null)
                            Positioned(
                              top: 14,
                              left: 14,
                              child: _buildInfoBadge(
                                context,
                                controller,
                                effectiveTurns,
                              ),
                            ),

                          // Recording indicator (top-right)
                          if (controller?.value.isRecordingVideo ?? false)
                            Positioned(
                              top: 14,
                              right: 14,
                              child: _buildRecordingBadge(),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom camera control bar (always pinned at the bottom)
                  if (controller != null)
                    _buildBottomControls(context, controller, cameras),
                  const SizedBox(height: 12),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildInfoBadge(
    BuildContext context,
    CameraController controller,
    int effectiveTurns,
  ) {
    final previewSize = controller.value.previewSize;
    final sizeText = previewSize != null
        ? '${previewSize.width.toInt()}×${previewSize.height.toInt()}'
        : '';
    final hasManualRotation = _manualRotationQuarterTurns != 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getCameraDisplayIcon(controller.description, context),
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            getCameraBadgeTitle(controller.description, context),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (sizeText.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              '· $sizeText',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
          if (hasManualRotation) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${_manualRotationQuarterTurns * 90}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'REC ${_formatDuration(_recordingSeconds)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(
    BuildContext context,
    CameraController controller,
    List<CameraDescription> cameras,
  ) {
    final isRecording = controller.value.isRecordingVideo;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Quick Rotate Button
          IconButton.filledTonal(
            tooltip: 'Quick Rotate 90°',
            icon: const Icon(Icons.rotate_90_degrees_cw_outlined),
            onPressed: () {
              setState(() {
                _manualRotationQuarterTurns =
                    (_manualRotationQuarterTurns + 1) % 4;
              });
            },
          ),

          // Shutter / Record Button
          GestureDetector(
            onTap: () {
              if (isRecording) {
                _toggleVideoRecording(controller);
              } else {
                _takePhoto(controller);
              }
            },
            onLongPress: () {
              _toggleVideoRecording(controller);
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isRecording ? Colors.red : Colors.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isRecording
                        ? Colors.red.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isRecording ? Colors.red : Colors.white,
                  borderRadius: BorderRadius.circular(isRecording ? 10 : 32),
                ),
                child: Center(
                  child: Icon(
                    isRecording ? Icons.stop : Icons.camera_alt,
                    color: isRecording ? Colors.white : Colors.black87,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),

          // Camera Flip Button
          IconButton.filledTonal(
            tooltip: 'Switch Camera',
            icon: const Icon(Icons.cameraswitch_outlined),
            onPressed: cameras.length > 1
                ? () => _switchNextCamera(cameras, controller)
                : null,
          ),
        ],
      ),
    );
  }
}

class _ViewfinderReticlePainter extends CustomPainter {
  const _ViewfinderReticlePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const cornerSize = 24.0;
    const margin = 20.0;

    // Top-left
    canvas.drawLine(
      const Offset(margin, margin + cornerSize),
      const Offset(margin, margin),
      paint,
    );
    canvas.drawLine(
      const Offset(margin, margin),
      const Offset(margin + cornerSize, margin),
      paint,
    );

    // Top-right
    canvas.drawLine(
      Offset(size.width - margin - cornerSize, margin),
      Offset(size.width - margin, margin),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - margin, margin),
      Offset(size.width - margin, margin + cornerSize),
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(margin, size.height - margin - cornerSize),
      Offset(margin, size.height - margin),
      paint,
    );
    canvas.drawLine(
      Offset(margin, size.height - margin),
      Offset(margin + cornerSize, size.height - margin),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(size.width - margin - cornerSize, size.height - margin),
      Offset(size.width - margin, size.height - margin),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - margin, size.height - margin),
      Offset(size.width - margin, size.height - margin - cornerSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ViewfinderReticlePainter oldDelegate) =>
      color != oldDelegate.color;
}

class _NoCameraView extends StatelessWidget {
  const _NoCameraView({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomScrollView(
      slivers: [
        DmNavigationHeader(
          builder: (context, header) => SliverAppBar(
            leading: header.leading,
            leadingWidth: header.leadingWidth,
            automaticallyImplyLeading: header.automaticallyImplyLeading,
            floating: true,
            title: Text(title),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.no_photography_outlined,
                        size: 48,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.cameraNoHardwareTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.cameraNoHardwareDescription,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        FilledButton.tonalIcon(
                          icon: const Icon(Icons.arrow_back),
                          label: Text(l10n.cameraBackToToolbox),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.goNamed(ToolboxScreen.name);
                            }
                          },
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.retry),
                          onPressed: () {
                            context.read<CameraBloc>().add(
                              const CameraInitCameras(),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CameraErrorView extends StatelessWidget {
  const _CameraErrorView({
    required this.title,
    required this.error,
  });

  final String title;
  final Object error;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomScrollView(
      slivers: [
        DmNavigationHeader(
          builder: (context, header) => SliverAppBar(
            leading: header.leading,
            leadingWidth: header.leadingWidth,
            automaticallyImplyLeading: header.automaticallyImplyLeading,
            floating: true,
            title: Text(title),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 40,
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.cameraErrorTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(maxHeight: 140),
                      child: SingleChildScrollView(
                        child: Text(
                          error.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        FilledButton.tonalIcon(
                          icon: const Icon(Icons.arrow_back),
                          label: Text(l10n.cameraBackToToolbox),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.goNamed(ToolboxScreen.name);
                            }
                          },
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.retry),
                          onPressed: () {
                            context.read<CameraBloc>().add(
                              const CameraInitCameras(),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
