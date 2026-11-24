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
  VncSessionBloc({VncSessionClient Function()? clientFactory})
    : _clientFactory = clientFactory ?? VncIsolateClient.new,
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
    on<_VncClientEventReceived>(_onClientEventReceived);
  }

  final VncSessionClient Function() _clientFactory;
  final StreamController<VncFrameData> _framesController =
      StreamController<VncFrameData>.broadcast();

  VncSessionClient? _client;
  StreamSubscription<VncClientEvent>? _subscription;
  int _sessionGeneration = 0;
  VncFrameData? _latestFrame;

  /// Broadcast stream of decoded RGBA desktop frames for canvas rendering.
  Stream<VncFrameData> get frames => _framesController.stream;

  /// Most recent frame received for the active session, if any.
  VncFrameData? get latestFrame => _latestFrame;

  /// Low-latency helper for sending pointer events directly to the active
  /// client when connected and not in view-only mode.
  void sendPointer(int x, int y, int buttonMask) {
    if (isClosed ||
        state.status != VncSessionStatus.connected ||
        state.viewOnly) {
      return;
    }
    _client?.sendPointerEvent(x, y, buttonMask);
  }

  /// Low-latency helper for sending keyboard events directly to the active
  /// client when connected and not in view-only mode.
  void sendKey(int keysym, {required bool down}) {
    if (isClosed ||
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
    await _startConnection(nextConfig, emit);
  }

  Future<void> _startConnection(
    VncConnectionConfig config,
    Emitter<VncSessionState> emit,
  ) async {
    final generation = ++_sessionGeneration;
    _latestFrame = null;
    await _teardownClient();

    if (isClosed || generation != _sessionGeneration) {
      return;
    }

    emit(
      state.copyWith(
        status: VncSessionStatus.connecting,
        config: config,
        clearDesktopInfo: true,
        width: 0,
        height: 0,
        viewOnly: config.viewOnly,
        clearAuth: true,
        clearCursor: true,
        clearError: true,
        clearDisconnectReason: true,
      ),
    );

    final client = _clientFactory();
    _client = client;
    _subscription = client.events.listen(
      (clientEvent) {
        if (isClosed || generation != _sessionGeneration) {
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
        if (isClosed || generation != _sessionGeneration) {
          return;
        }
        final vncError = error is VncException
            ? error
            : VncConnectionException(error.toString(), error);
        add(_VncClientEventReceived(generation, VncErrorEvent(vncError)));
      },
    );

    try {
      await client.connect(config);
    } catch (error) {
      if (isClosed || generation != _sessionGeneration) {
        return;
      }
      final vncError = error is VncException
          ? error
          : VncConnectionException(error.toString(), error);
      await _teardownClient();
      if (isClosed || generation != _sessionGeneration) {
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
    final generation = ++_sessionGeneration;
    _latestFrame = null;
    await _teardownClient();
    if (isClosed || generation != _sessionGeneration) {
      return;
    }
    emit(
      state.copyWith(
        status: VncSessionStatus.disconnected,
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
    emit(state.copyWith(viewOnly: !state.viewOnly));
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
      case VncResizedEvent(:final width, :final height):
        emit(state.copyWith(width: width, height: height));
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
        emit(
          state.copyWith(
            status: VncSessionStatus.disconnected,
            clearAuth: true,
            disconnectReason: reason,
            clearDisconnectReason: reason == null,
          ),
        );
      case VncErrorEvent(:final error):
        emit(
          state.copyWith(
            status: VncSessionStatus.error,
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
