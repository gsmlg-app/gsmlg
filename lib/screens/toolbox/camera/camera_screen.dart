import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_components/app_components.dart';
import 'package:app_locale/app_locale.dart';
import 'package:camera/camera.dart';
import 'package:camera_bloc/camera_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';

class CameraScreen extends StatefulWidget {
  static const name = 'Camera';
  static const path = 'camera';

  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late final CameraBloc _cameraBloc;

  @override
  void initState() {
    super.initState();
    _cameraBloc = context.read<CameraBloc>();
    _cameraBloc.add(const CameraInitCameras());
  }

  @override
  void dispose() {
    _cameraBloc.add(const CameraStop());
    super.dispose();
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
        child: BlocBuilder<CameraBloc, CameraState>(
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

              return CustomScrollView(
                slivers: [
                  DmNavigationHeader(
                    builder: (context, header) => SliverAppBar(
                      leading: header.leading,
                      leadingWidth: header.leadingWidth,
                      automaticallyImplyLeading:
                          header.automaticallyImplyLeading,
                      floating: true,
                      title: Text(title),
                    ),
                  ),
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

