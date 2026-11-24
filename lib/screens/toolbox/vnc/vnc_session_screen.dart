import 'dart:async';

import 'package:app_locale/app_locale.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/toolbox/vnc/vnc_launch_config.dart';
import 'package:gsmlg/screens/toolbox/vnc/vnc_screen.dart';
import 'package:gsmlg/screens/toolbox/vnc/widgets/vnc_auth_dialog.dart';
import 'package:vnc_session_bloc/vnc_session_bloc.dart';
import 'package:vnc_viewer_widgets/vnc_viewer_widgets.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Live VNC remote desktop session viewer screen.
class VncSessionScreen extends StatefulWidget {
  static const name = 'VncSession';
  static const path = 'session';

  const VncSessionScreen({super.key, this.launchConfig, this.blocOverride});

  final Object? launchConfig;
  final VncSessionBloc? blocOverride;

  @override
  State<VncSessionScreen> createState() => _VncSessionScreenState();
}

class _VncSessionScreenState extends State<VncSessionScreen> {
  VncSessionBloc? _ownedBloc;
  bool _showToolbar = true;
  bool _showShortcutBar = false;
  bool _isFullscreen = false;
  bool _authDialogOpen = false;
  VncScaleMode _scaleMode = VncScaleMode.fit;
  VncTouchMode _touchMode = VncTouchMode.direct;

  VncLaunchConfig? get _launch => widget.launchConfig is VncLaunchConfig
      ? widget.launchConfig as VncLaunchConfig
      : null;

  VncSessionBloc? get _bloc => widget.blocOverride ?? _ownedBloc;

  @override
  void initState() {
    super.initState();
    final launch = _launch;
    if (launch != null) {
      if (widget.blocOverride == null) {
        _ownedBloc = VncSessionBloc();
      }
      _bloc!.add(VncSessionConnect(launch.config));
    }
  }

  @override
  void dispose() {
    if (_isFullscreen) {
      _setWakelock(false);
      unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    }
    unawaited(_ownedBloc?.close());
    super.dispose();
  }

  void _setWakelock(bool enabled) {
    final future = enabled ? WakelockPlus.enable() : WakelockPlus.disable();
    unawaited(future.catchError((Object _) {}));
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    _setWakelock(_isFullscreen);
    unawaited(
      SystemChrome.setEnabledSystemUIMode(
        _isFullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
      ),
    );
  }

  void _disconnectAndExit() {
    _bloc?.add(const VncSessionDisconnect());
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      if (router.canPop()) {
        router.pop();
      } else {
        router.goNamed(VncScreen.name);
      }
      return;
    }
    Navigator.of(context).maybePop();
  }

  Future<void> _sendClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (!mounted || text == null || text.isEmpty) {
      return;
    }
    _bloc?.add(VncSessionSendClipboard(text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.vncClipboardSent)));
  }

  Future<void> _promptAuthDialog(VncSessionState state) async {
    if (_authDialogOpen || !mounted) {
      return;
    }
    _authDialogOpen = true;
    try {
      final credentials = await VncAuthDialog.show(
        context,
        requiresUsername: state.authRequiresUsername,
        initialUsername: state.config?.credentials.username,
      );
      if (!mounted) {
        return;
      }
      if (credentials != null) {
        _bloc?.add(VncSessionSubmitCredentials(credentials));
      } else {
        _bloc?.add(const VncSessionCancelAuth());
      }
    } finally {
      _authDialogOpen = false;
    }
  }

  Future<void> _promptRetryCredentials(
    VncSessionState state,
    VncAuthenticationException error,
  ) async {
    if (_authDialogOpen || !mounted) {
      return;
    }
    final authPref = state.config?.authPreference ?? VncAuthPreference.auto;
    final showUsername =
        authPref == VncAuthPreference.appleArd ||
        authPref == VncAuthPreference.auto ||
        (state.config?.credentials.username?.isNotEmpty ?? false);
    _authDialogOpen = true;
    try {
      final credentials = await VncAuthDialog.show(
        context,
        requiresUsername: showUsername,
        usernameOptional: authPref == VncAuthPreference.auto,
        initialUsername: state.config?.credentials.username,
        subtitle: error.message,
      );
      if (!mounted || credentials == null) {
        return;
      }
      _bloc?.add(VncSessionReconnect(overrideCredentials: credentials));
    } finally {
      _authDialogOpen = false;
    }
  }

  Color _statusDotColor(
    VncSessionStatus status,
    ColorScheme colorScheme,
    DmColorExtension? dmColors,
  ) => switch (status) {
    VncSessionStatus.connected => dmColors?.success ?? colorScheme.primary,
    VncSessionStatus.connecting ||
    VncSessionStatus.authRequired => dmColors?.warning ?? colorScheme.tertiary,
    VncSessionStatus.error => colorScheme.error,
    VncSessionStatus.idle ||
    VncSessionStatus.disconnected => colorScheme.outline,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dmColors = theme.extension<DmColorExtension>();
    final launch = _launch;
    final bloc = _bloc;

    if (launch == null || bloc == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.vncTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.vncDisconnected, style: theme.textTheme.titleMedium),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _disconnectAndExit,
                  icon: const Icon(Icons.arrow_back),
                  label: Text(l10n.vncTitle),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BlocProvider<VncSessionBloc>.value(
      value: bloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<VncSessionBloc, VncSessionState>(
            listenWhen: (prev, curr) =>
                curr.status == VncSessionStatus.authRequired &&
                prev.status != VncSessionStatus.authRequired,
            listener: (context, state) {
              unawaited(_promptAuthDialog(state));
            },
          ),
          BlocListener<VncSessionBloc, VncSessionState>(
            listenWhen: (prev, curr) =>
                curr.clipboardSeq != prev.clipboardSeq &&
                curr.lastRemoteClipboard != null,
            listener: (context, state) {
              final text = state.lastRemoteClipboard;
              if (text == null) return;
              unawaited(Clipboard.setData(ClipboardData(text: text)));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.vncClipboardCopied),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: colorScheme.surfaceContainerLowest,
          body: SafeArea(
            top: !_isFullscreen,
            bottom: !_isFullscreen,
            child: BlocBuilder<VncSessionBloc, VncSessionState>(
              builder: (context, state) {
                return Stack(
                  children: [
                    Column(
                      children: [
                        if (_showToolbar)
                          _SessionToolbar(
                            title: (state.desktopInfo?.name.isNotEmpty ?? false)
                                ? state.desktopInfo!.name
                                : launch.title,
                            resolution:
                                state.status == VncSessionStatus.connected &&
                                    state.width > 0 &&
                                    state.height > 0
                                ? '${state.width}×${state.height}'
                                : null,
                            statusColor: _statusDotColor(
                              state.status,
                              colorScheme,
                              dmColors,
                            ),
                            scaleMode: _scaleMode,
                            touchMode: _touchMode,
                            viewOnly: state.viewOnly,
                            showShortcutBar: _showShortcutBar,
                            isFullscreen: _isFullscreen,
                            isConnected:
                                state.status == VncSessionStatus.connected,
                            onDisconnect: _disconnectAndExit,
                            onToggleScaleMode: () => setState(() {
                              _scaleMode = _scaleMode == VncScaleMode.fit
                                  ? VncScaleMode.actualSize
                                  : VncScaleMode.fit;
                            }),
                            onToggleTouchMode: () => setState(() {
                              _touchMode = _touchMode == VncTouchMode.direct
                                  ? VncTouchMode.trackpad
                                  : VncTouchMode.direct;
                            }),
                            onToggleViewOnly: () =>
                                bloc.add(const VncSessionToggleViewOnly()),
                            onSendClipboard: _sendClipboard,
                            onToggleShortcutBar: () => setState(() {
                              _showShortcutBar = !_showShortcutBar;
                            }),
                            onToggleFullscreen: _toggleFullscreen,
                            onCollapseToolbar: () =>
                                setState(() => _showToolbar = false),
                          ),
                        Expanded(child: _buildBody(context, bloc, state)),
                        if (_showShortcutBar &&
                            state.status == VncSessionStatus.connected)
                          VncShortcutBar(
                            enabled: !state.viewOnly,
                            onKeyEvent: (keysym, down) =>
                                bloc.sendKey(keysym, down: down),
                          ),
                      ],
                    ),
                    if (!_showToolbar)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: colorScheme.surfaceContainerHigh.withValues(
                            alpha: 0.9,
                          ),
                          shape: const StadiumBorder(),
                          child: IconButton(
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: colorScheme.onSurface,
                            ),
                            tooltip: l10n.vncTitle,
                            onPressed: () =>
                                setState(() => _showToolbar = true),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    VncSessionBloc bloc,
    VncSessionState state,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    switch (state.status) {
      case VncSessionStatus.idle:
      case VncSessionStatus.connecting:
      case VncSessionStatus.authRequired:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                l10n.vncConnecting,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              if (state.config != null) ...[
                const SizedBox(height: 6),
                Text(
                  '${state.config!.host}:${state.config!.port}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
        );
      case VncSessionStatus.connected:
        return VncViewerCanvas(
          frames: bloc.frames,
          initialFrame: bloc.latestFrame,
          framebufferWidth: state.width,
          framebufferHeight: state.height,
          cursor: state.cursor,
          scaleMode: _scaleMode,
          touchMode: _touchMode,
          viewOnly: state.viewOnly,
          onPointerEvent: bloc.sendPointer,
          onKeyEvent: (keysym, down) => bloc.sendKey(keysym, down: down),
        );
      case VncSessionStatus.disconnected:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.link_off, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        l10n.vncDisconnected,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (state.disconnectReason != null &&
                          state.disconnectReason!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          state.disconnectReason!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => bloc.add(const VncSessionReconnect()),
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.vncReconnect),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      case VncSessionStatus.error:
        final error = state.error;
        final isUnsupportedSecurity =
            error is VncUnsupportedSecurityTypeException;
        final isAuthError = error is VncAuthenticationException;
        final colorScheme = Theme.of(context).colorScheme;

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 40,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.error,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error?.message ?? l10n.vncDisconnected,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (isUnsupportedSecurity) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Offered security types: '
                          '${error.offeredTypes.join(', ')}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontFamily: 'monospace',
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.vncMacosSharingHint,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          if (isAuthError)
                            FilledButton.icon(
                              onPressed: () =>
                                  _promptRetryCredentials(state, error),
                              icon: const Icon(Icons.key),
                              label: Text(l10n.retry),
                            )
                          else
                            FilledButton.icon(
                              onPressed: () =>
                                  bloc.add(const VncSessionReconnect()),
                              icon: const Icon(Icons.refresh),
                              label: Text(l10n.vncReconnect),
                            ),
                          OutlinedButton(
                            onPressed: _disconnectAndExit,
                            child: Text(l10n.vncDisconnect),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }
}

class _SessionToolbar extends StatelessWidget {
  const _SessionToolbar({
    required this.title,
    required this.resolution,
    required this.statusColor,
    required this.scaleMode,
    required this.touchMode,
    required this.viewOnly,
    required this.showShortcutBar,
    required this.isFullscreen,
    required this.isConnected,
    required this.onDisconnect,
    required this.onToggleScaleMode,
    required this.onToggleTouchMode,
    required this.onToggleViewOnly,
    required this.onSendClipboard,
    required this.onToggleShortcutBar,
    required this.onToggleFullscreen,
    required this.onCollapseToolbar,
  });

  final String title;
  final String? resolution;
  final Color statusColor;
  final VncScaleMode scaleMode;
  final VncTouchMode touchMode;
  final bool viewOnly;
  final bool showShortcutBar;
  final bool isFullscreen;
  final bool isConnected;
  final VoidCallback onDisconnect;
  final VoidCallback onToggleScaleMode;
  final VoidCallback onToggleTouchMode;
  final VoidCallback onToggleViewOnly;
  final VoidCallback onSendClipboard;
  final VoidCallback onToggleShortcutBar;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onCollapseToolbar;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dmColors = theme.extension<DmColorExtension>();
    final activeHighlight = colorScheme.primary;
    final warningHighlight = dmColors?.warning ?? colorScheme.tertiary;

    return Material(
      color: colorScheme.surfaceContainerHigh,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
              tooltip: l10n.vncDisconnect,
              onPressed: onDisconnect,
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (resolution != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      resolution!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                scaleMode == VncScaleMode.fit
                    ? Icons.fit_screen
                    : Icons.zoom_out_map,
                color: colorScheme.onSurface,
                size: 20,
              ),
              tooltip: scaleMode == VncScaleMode.fit
                  ? l10n.vncActualSize
                  : l10n.vncFitScreen,
              onPressed: onToggleScaleMode,
            ),
            IconButton(
              icon: Icon(
                touchMode == VncTouchMode.trackpad
                    ? Icons.mouse_outlined
                    : Icons.touch_app_outlined,
                color: touchMode == VncTouchMode.trackpad
                    ? activeHighlight
                    : colorScheme.onSurface,
                size: 20,
              ),
              tooltip: touchMode == VncTouchMode.trackpad
                  ? l10n.vncDirectTouchMode
                  : l10n.vncTrackpadMode,
              onPressed: onToggleTouchMode,
            ),
            IconButton(
              icon: Icon(
                viewOnly ? Icons.visibility : Icons.visibility_outlined,
                color: viewOnly ? warningHighlight : colorScheme.onSurface,
                size: 20,
              ),
              tooltip: l10n.vncViewOnlyLabel,
              onPressed: onToggleViewOnly,
            ),
            IconButton(
              icon: Icon(
                Icons.content_paste_go,
                color: isConnected
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.38),
                size: 20,
              ),
              tooltip: l10n.vncSyncClipboard,
              onPressed: isConnected ? onSendClipboard : null,
            ),
            IconButton(
              icon: Icon(
                showShortcutBar
                    ? Icons.keyboard_hide_outlined
                    : Icons.keyboard_outlined,
                color: !isConnected
                    ? colorScheme.onSurface.withValues(alpha: 0.38)
                    : (showShortcutBar
                          ? activeHighlight
                          : colorScheme.onSurface),
                size: 20,
              ),
              tooltip: 'Shortcuts',
              onPressed: isConnected ? onToggleShortcutBar : null,
            ),
            IconButton(
              icon: Icon(
                isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                color: isFullscreen ? activeHighlight : colorScheme.onSurface,
                size: 20,
              ),
              tooltip: l10n.vncFullscreen,
              onPressed: onToggleFullscreen,
            ),
            IconButton(
              icon: Icon(
                Icons.keyboard_arrow_up,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
              tooltip: 'Hide toolbar',
              onPressed: onCollapseToolbar,
            ),
          ],
        ),
      ),
    );
  }
}
