import 'dart:async';

import 'package:app_vnc/app_vnc.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'event.dart';
part 'state.dart';

/// BLoC managing a single VNC remote desktop session lifecycle.
///
/// High-frequency framebuffer updates are exposed on [frames] (and cached in
/// [latestFrame]) instead of emitting a new [VncSessionState] on every frame.
class VncSessionBloc extends Bloc<VncSessionEvent, VncSessionState> {
  VncSessionBloc({
    VncSessionClient Function()? clientFactory,
    this.autoSelectPrimaryDisplay = false,
    this.onDiagnostic,
  }) : _clientFactory = clientFactory ?? VncIsolateClient.new,
       super(const VncSessionState()) {
    on<VncSessionConnect>(_onConnect);
    on<VncSessionSubmitCredentials>(_onSubmitCredentials);
    on<VncSessionCancelAuth>(_onCancelAuth);
    on<VncSessionReconnect>(_onReconnect);
    on<VncSessionDisconnect>(_onDisconnect);
    on<VncSessionSendPointer>(_onSendPointer);
    on<VncSessionSendKey>(_onSendKey);
    on<VncSessionSendClipboard>(_onSendClipboard);
    on<VncSessionToggleViewOnly>(_onToggleViewOnly);
    on<VncSessionRequestRefresh>(_onRequestRefresh);
    on<VncSessionSelectDisplay>(_onSelectDisplay);
    on<_VncClientEventReceived>(_onClientEventReceived);
  }

  final VncSessionClient Function() _clientFactory;

  /// When `true` and a macOS `RFB 003.889` server opens on a combined
  /// multi-display view (`currentDisplayId == null` with multiple displays),
  /// automatically switches once to the primary display to avoid rendering a
  /// giant combined multi-Retina framebuffer by default.
  final bool autoSelectPrimaryDisplay;

  /// Optional sink for non-sensitive protocol/session diagnostics.
  final void Function(String message)? onDiagnostic;

  final StreamController<VncFrameData> _framesController =
      StreamController<VncFrameData>.broadcast();

  VncSessionClient? _client;
  StreamSubscription<VncClientEvent>? _subscription;
  int _sessionGeneration = 0;
  VncFrameData? _latestFrame;
  bool _didAutoSelectPrimary = false;
  bool _isClosing = false;

  /// Broadcast stream of decoded RGBA desktop frames for canvas rendering.
  Stream<VncFrameData> get frames => _framesController.stream;

  /// Most recent frame received for the active session, if any.
  VncFrameData? get latestFrame => _latestFrame;

  /// Low-latency helper for sending pointer events directly to the active
  /// client when connected and not in view-only mode.
  void sendPointer(int x, int y, int buttonMask) {
    if (_isClosing ||
        isClosed ||
        state.status != VncSessionStatus.connected ||
        state.viewOnly) {
      return;
    }
    _client?.sendPointerEvent(x, y, buttonMask);
  }

  /// Low-latency helper for sending keyboard events directly to the active
  /// client when connected and not in view-only mode.
  void sendKey(int keysym, {required bool down}) {
    if (_isClosing ||
        isClosed ||
        state.status != VncSessionStatus.connected ||
        state.viewOnly) {
      return;
    }
    _client?.sendKeyEvent(keysym, down: down);
  }

  Future<void> _onConnect(
    VncSessionConnect event,
    Emitter<VncSessionState> emit,
  ) async {
    await _startConnection(event.config, emit);
  }

  Future<void> _onReconnect(
    VncSessionReconnect event,
    Emitter<VncSessionState> emit,
  ) async {
    final existingConfig = state.config;
    if (existingConfig == null) {
      return;
    }
    final nextConfig = _copyConfig(
      existingConfig,
      credentials: event.overrideCredentials ?? existingConfig.credentials,
      viewOnly: state.viewOnly,
    );
    await _startConnection(nextConfig, emit, useCurrentViewOnly: true);
  }

  Future<void> _startConnection(
    VncConnectionConfig config,
    Emitter<VncSessionState> emit, {
    bool useCurrentViewOnly = false,
  }) async {
    if (_isClosing || isClosed) {
      return;
    }
    final generation = ++_sessionGeneration;
    _latestFrame = null;
    _didAutoSelectPrimary = false;
    await _teardownClient();

    if (_isClosing || isClosed || generation != _sessionGeneration) {
      return;
    }

    final effectiveConfig = useCurrentViewOnly
        ? _copyConfig(config, viewOnly: state.viewOnly)
        : config;

    emit(
      state.copyWith(
        status: VncSessionStatus.connecting,
        config: effectiveConfig,
        clearDesktopInfo: true,
        width: 0,
        height: 0,
        screens: const [],
        clearActiveRegion: true,
        serverSideDisplaySwitch: false,
        clearActiveDisplayId: true,
        isSwitchingDisplay: false,
        viewOnly: effectiveConfig.viewOnly,
        clearAuth: true,
        clearCursor: true,
        clearError: true,
        clearDisconnectReason: true,
      ),
    );

    try {
      final client = _clientFactory();
      _client = client;
      _subscription = client.events.listen(
        (clientEvent) {
          if (_isClosing || isClosed || generation != _sessionGeneration) {
            return;
          }
          if (clientEvent is VncFrameEvent) {
            _latestFrame = clientEvent.frame;
            if (!_framesController.isClosed) {
              _framesController.add(clientEvent.frame);
            }
            return;
          }
          add(_VncClientEventReceived(generation, clientEvent));
        },
        onError: (Object error, StackTrace _) {
          if (_isClosing || isClosed || generation != _sessionGeneration) {
            return;
          }
          final vncError = error is VncException
              ? error
              : VncConnectionException(error.toString(), error);
          add(_VncClientEventReceived(generation, VncErrorEvent(vncError)));
        },
      );

      await client.connect(effectiveConfig);
    } catch (error) {
      if (_isClosing || isClosed || generation != _sessionGeneration) {
        return;
      }
      final vncError = error is VncException
          ? error
          : VncConnectionException(error.toString(), error);
      await _teardownClient();
      if (_isClosing || isClosed || generation != _sessionGeneration) {
        return;
      }
      emit(
        state.copyWith(
          status: VncSessionStatus.error,
          clearAuth: true,
          error: vncError,
        ),
      );
    }
  }

  void _onSubmitCredentials(
    VncSessionSubmitCredentials event,
    Emitter<VncSessionState> emit,
  ) {
    if (state.status != VncSessionStatus.authRequired) {
      return;
    }
    final client = _client;
    if (client == null) {
      return;
    }
    final updatedConfig = state.config == null
        ? null
        : _copyConfig(state.config!, credentials: event.credentials);
    emit(
      state.copyWith(
        status: VncSessionStatus.connecting,
        config: updatedConfig,
        clearAuth: true,
        clearError: true,
      ),
    );
    client.submitCredentials(event.credentials);
  }

  void _onCancelAuth(
    VncSessionCancelAuth event,
    Emitter<VncSessionState> emit,
  ) {
    if (state.status != VncSessionStatus.authRequired) {
      return;
    }
    _client?.cancelCredentials();
  }

  Future<void> _onDisconnect(
    VncSessionDisconnect event,
    Emitter<VncSessionState> emit,
  ) async {
    if (_isClosing || isClosed) {
      return;
    }
    final generation = ++_sessionGeneration;
    _latestFrame = null;
    _didAutoSelectPrimary = false;
    await _teardownClient();
    if (_isClosing || isClosed || generation != _sessionGeneration) {
      return;
    }
    emit(
      state.copyWith(
        status: VncSessionStatus.disconnected,
        screens: const [],
        clearActiveRegion: true,
        serverSideDisplaySwitch: false,
        clearActiveDisplayId: true,
        isSwitchingDisplay: false,
        clearAuth: true,
        clearError: true,
        clearDisconnectReason: true,
      ),
    );
  }

  void _onSendPointer(
    VncSessionSendPointer event,
    Emitter<VncSessionState> emit,
  ) {
    sendPointer(event.x, event.y, event.buttonMask);
  }

  void _onSendKey(VncSessionSendKey event, Emitter<VncSessionState> emit) {
    sendKey(event.keysym, down: event.down);
  }

  void _onSendClipboard(
    VncSessionSendClipboard event,
    Emitter<VncSessionState> emit,
  ) {
    if (state.status != VncSessionStatus.connected) {
      return;
    }
    _client?.sendClipboardText(event.text);
  }

  void _onToggleViewOnly(
    VncSessionToggleViewOnly event,
    Emitter<VncSessionState> emit,
  ) {
    final nextViewOnly = !state.viewOnly;
    final updatedConfig = state.config == null
        ? null
        : _copyConfig(state.config!, viewOnly: nextViewOnly);
    emit(state.copyWith(viewOnly: nextViewOnly, config: updatedConfig));
    _client?.setViewOnly(nextViewOnly);
  }

  void _onRequestRefresh(
    VncSessionRequestRefresh event,
    Emitter<VncSessionState> emit,
  ) {
    if (state.status != VncSessionStatus.connected) {
      return;
    }
    _client?.requestFullRefresh();
  }

  void _onSelectDisplay(
    VncSessionSelectDisplay event,
    Emitter<VncSessionState> emit,
  ) {
    final region = event.region;
    if (state.serverSideDisplaySwitch) {
      _didAutoSelectPrimary = true;
      _client?.selectDisplay(region?.id);
      emit(state.copyWith(clearActiveRegion: true, isSwitchingDisplay: true));
      return;
    }
    if (region == null) {
      emit(state.copyWith(clearActiveRegion: true));
      _client?.setActiveRegion(null);
      return;
    }
    if (region.width <= 0 || region.height <= 0) {
      return;
    }
    final VncScreenInfo clamped;
    if (state.width > 0 && state.height > 0) {
      final x0 = region.x.clamp(0, state.width);
      final y0 = region.y.clamp(0, state.height);
      final x1 = (region.x + region.width).clamp(0, state.width);
      final y1 = (region.y + region.height).clamp(0, state.height);
      final clampedW = x1 - x0;
      final clampedH = y1 - y0;
      if (clampedW <= 0 || clampedH <= 0) {
        return;
      }
      clamped = VncScreenInfo(
        id: region.id,
        x: x0,
        y: y0,
        width: clampedW,
        height: clampedH,
        flags: region.flags,
      );
    } else {
      clamped = region;
    }
    emit(state.copyWith(activeRegion: clamped));
    _client?.setActiveRegion(clamped);
  }

  void _onClientEventReceived(
    _VncClientEventReceived event,
    Emitter<VncSessionState> emit,
  ) {
    if (event.generation != _sessionGeneration) {
      return;
    }
    switch (event.clientEvent) {
      case VncConnectingEvent():
        if (state.status != VncSessionStatus.connected &&
            state.status != VncSessionStatus.authRequired) {
          emit(
            state.copyWith(
              status: VncSessionStatus.connecting,
              clearError: true,
              clearDisconnectReason: true,
            ),
          );
        }
      case VncAuthRequiredEvent(:final securityType, :final requiresUsername):
        emit(
          state.copyWith(
            status: VncSessionStatus.authRequired,
            authSecurityType: securityType,
            authRequiresUsername: requiresUsername,
            clearError: true,
          ),
        );
      case VncConnectedEvent(:final desktopInfo):
        emit(
          state.copyWith(
            status: VncSessionStatus.connected,
            desktopInfo: desktopInfo,
            width: desktopInfo.width,
            height: desktopInfo.height,
            serverSideDisplaySwitch: desktopInfo.isApple889,
            clearAuth: true,
            clearError: true,
            clearDisconnectReason: true,
          ),
        );
      case VncFrameEvent(:final frame):
        _latestFrame = frame;
        if (!_framesController.isClosed) {
          _framesController.add(frame);
        }
      case VncResizedEvent(
        :final width,
        :final height,
        :final screens,
        :final hasScreens,
        :final hasCurrentDisplayId,
        :final currentDisplayId,
      ):
        if (_latestFrame != null &&
            (_latestFrame!.width != width || _latestFrame!.height != height)) {
          _latestFrame = null;
        }
        final effectiveScreens = hasScreens ? screens : state.screens;
        if (state.serverSideDisplaySwitch) {
          final shouldAutoSelectPrimary =
              autoSelectPrimaryDisplay &&
              !_didAutoSelectPrimary &&
              hasScreens &&
              effectiveScreens.length > 1 &&
              hasCurrentDisplayId &&
              currentDisplayId == null;
          if (shouldAutoSelectPrimary) {
            _didAutoSelectPrimary = true;
            final primary = effectiveScreens.firstWhere(
              (s) => (s.flags & 0x01) != 0,
              orElse: () => effectiveScreens.first,
            );
            onDiagnostic?.call(
              'Auto-selecting primary macOS display #${primary.id} '
              '(${primary.width}x${primary.height})',
            );
            _client?.selectDisplay(primary.id);
          }
          emit(
            state.copyWith(
              width: width,
              height: height,
              screens: effectiveScreens,
              clearActiveRegion: true,
              activeDisplayId: hasCurrentDisplayId
                  ? currentDisplayId
                  : state.activeDisplayId,
              clearActiveDisplayId:
                  hasCurrentDisplayId && currentDisplayId == null,
              isSwitchingDisplay: shouldAutoSelectPrimary
                  ? true
                  : (hasCurrentDisplayId ? false : state.isSwitchingDisplay),
            ),
          );
        } else {
          VncScreenInfo? nextActiveRegion = state.activeRegion;
          var clearActiveRegion = false;
          if (nextActiveRegion != null) {
            VncScreenInfo? matched;
            if (hasScreens && effectiveScreens.isNotEmpty) {
              for (final screen in effectiveScreens) {
                if (screen.id == nextActiveRegion.id) {
                  matched = screen;
                  break;
                }
              }
            }
            if (matched != null) {
              nextActiveRegion = matched;
            } else if (nextActiveRegion.x < 0 ||
                nextActiveRegion.y < 0 ||
                nextActiveRegion.x + nextActiveRegion.width > width ||
                nextActiveRegion.y + nextActiveRegion.height > height) {
              clearActiveRegion = true;
              nextActiveRegion = null;
            }
          }
          emit(
            state.copyWith(
              width: width,
              height: height,
              screens: effectiveScreens,
              activeRegion: nextActiveRegion,
              clearActiveRegion: clearActiveRegion,
              activeDisplayId: hasCurrentDisplayId
                  ? currentDisplayId
                  : state.activeDisplayId,
              clearActiveDisplayId:
                  hasCurrentDisplayId && currentDisplayId == null,
            ),
          );
        }
      case VncDiagnosticEvent(:final message):
        onDiagnostic?.call(message);
      case VncCursorEvent(:final cursor):
        emit(state.copyWith(cursor: cursor));
      case VncClipboardEvent(:final text):
        emit(
          state.copyWith(
            lastRemoteClipboard: text,
            clipboardSeq: state.clipboardSeq + 1,
          ),
        );
      case VncDisconnectedEvent(:final reason):
        onDiagnostic?.call('Disconnected${reason != null ? ": $reason" : ""}');
        emit(
          state.copyWith(
            status: VncSessionStatus.disconnected,
            isSwitchingDisplay: false,
            clearAuth: true,
            disconnectReason: reason,
            clearDisconnectReason: reason == null,
          ),
        );
      case VncErrorEvent(:final error):
        onDiagnostic?.call('Error: ${error.message}');
        emit(
          state.copyWith(
            status: VncSessionStatus.error,
            isSwitchingDisplay: false,
            clearAuth: true,
            error: error,
          ),
        );
    }
  }

  VncConnectionConfig _copyConfig(
    VncConnectionConfig base, {
    VncCredentials? credentials,
    bool? viewOnly,
  }) {
    return VncConnectionConfig(
      host: base.host,
      port: base.port,
      authPreference: base.authPreference,
      credentials: credentials ?? base.credentials,
      sshTunnel: base.sshTunnel,
      viewOnly: viewOnly ?? base.viewOnly,
      sharedDesktop: base.sharedDesktop,
      connectTimeout: base.connectTimeout,
      enableAppleExtensions: base.enableAppleExtensions,
    );
  }

  Future<void> _teardownClient() async {
    final sub = _subscription;
    final client = _client;
    _subscription = null;
    _client = null;
    try {
      if (sub != null) {
        try {
          await sub.cancel();
        } catch (_) {
          // Ignore cancellation errors from the underlying event stream.
        }
      }
    } finally {
      if (client != null) {
        try {
          await client.disconnect();
        } catch (_) {
          // Ignore disconnect errors during teardown.
        }
      }
    }
  }

  @override
  Future<void> close() async {
    _isClosing = true;
    _sessionGeneration++;
    _latestFrame = null;
    try {
      await _teardownClient();
    } finally {
      if (!_framesController.isClosed) {
        await _framesController.close();
      }
      await super.close();
    }
  }
}
