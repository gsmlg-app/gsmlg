import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_components/app_components.dart';
import 'package:camera/camera.dart';
import 'package:camera_bloc/camera_bloc.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CameraScreen extends StatefulWidget {
  static const name = 'Camera';
  static const path = 'camera';

  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CameraBloc>().add(const CameraInitCameras());
  }

  @override
  void dispose() {
    context.read<CameraBloc>().add(const CameraStop());
    super.dispose();
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
        child: BlocBuilder<CameraBloc, CameraState>(
          builder: (context, state) {
            if (state is CameraInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CameraError) {
              return CustomScrollView(
                slivers: [
                  const SliverAppBar(floating: true, title: Text(title)),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.618,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Error:'),
                            Text('Error: ${state.error}'),
                            Text('Stack: ${state.stackTrace}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (state is CameraLoaded) {
              final cameras = state.cameras;
              final controller = state.controller;

              return CustomScrollView(
                slivers: [
                  const SliverAppBar(floating: true, title: Text(title)),
                  SliverList.list(
                    children: [
                      const SizedBox(height: kDefaultGridGap),
                      for (final camera in cameras)
                        ListTile(
                          leading: controller?.description == camera
                              ? const Icon(Icons.radio_button_checked)
                              : const Icon(Icons.radio_button_unchecked),
                          title: Text(camera.title),
                          subtitle: Text(
                            '${camera.lensDirection.name} / '
                            '${camera.sensorOrientation}',
                          ),
                          onTap: () => context.read<CameraBloc>().add(
                            CameraSwitched(camera),
                          ),
                        ),
                      if (controller != null)
                        InkWell(
                          onTap: () async {
                            if (controller.value.isRecordingVideo) {
                              controller.stopVideoRecording();
                            } else {
                              controller.startVideoRecording();
                            }
                          },
                          child: CameraPreview(controller),
                        ),
                    ],
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
