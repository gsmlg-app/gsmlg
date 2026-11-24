import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../models/vnc_exceptions.dart';
import '../models/vnc_models.dart';
import '../protocol/byte_reader.dart';
import '../protocol/framebuffer.dart';
import '../protocol/rfb_handshake.dart';
import '../protocol/rfb_session.dart';
import '../transport/vnc_transport.dart';

/// Events emitted by a [VncSessionClient] during a VNC session lifecycle.
@immutable
sealed class VncClientEvent {
  const VncClientEvent();
}

final class VncConnectingEvent extends VncClientEvent {
  const VncConnectingEvent();
}

final class VncAuthRequiredEvent extends VncClientEvent {
  const VncAuthRequiredEvent({
    required this.securityType,
    required this.requiresUsername,
  });

  final int securityType;
  final bool requiresUsername;
}

final class VncConnectedEvent extends VncClientEvent {
  const VncConnectedEvent(this.desktopInfo);

  final VncDesktopInfo desktopInfo;
}

final class VncFrameEvent extends VncClientEvent {
  const VncFrameEvent(this.frame);

  final VncFrameData frame;
}

final class VncResizedEvent extends VncClientEvent {
  const VncResizedEvent({
    required this.width,
    required this.height,
    this.screens = const [],
    this.hasCurrentDisplayId = false,
    this.currentDisplayId,
  });

  final int width;
  final int height;
  final List<VncScreenInfo> screens;
  final bool hasCurrentDisplayId;
  final int? currentDisplayId;
}

final class VncCursorEvent extends VncClientEvent {
  const VncCursorEvent(this.cursor);

  final VncCursorData cursor;
}

final class VncClipboardEvent extends VncClientEvent {
  const VncClipboardEvent(this.text);

  final String text;
}

final class VncDisconnectedEvent extends VncClientEvent {
  const VncDisconnectedEvent({this.reason});

  final String? reason;
}

final class VncErrorEvent extends VncClientEvent {
  const VncErrorEvent(this.error);

  final VncException error;
}

/// Client interface for controlling an active RFB/VNC session.
abstract interface class VncSessionClient {
  Stream<VncClientEvent> get events;

  Future<void> connect(VncConnectionConfig config);

  void submitCredentials(VncCredentials credentials);

  void cancelCredentials();

  void sendPointerEvent(int x, int y, int buttonMask);

  void sendKeyEvent(int keysym, {required bool down});

  void sendClipboardText(String text);

  void setViewOnly(bool viewOnly);

  void setActiveRegion(VncScreenInfo? region);

  void selectDisplay(int? displayId);

  void requestFullRefresh();

  Future<void> disconnect();
}

/// Runs VNC transport (direct TCP or `app_ssh` tunnel), RFB handshake, and the
/// post-handshake [RfbSession] message loop in a dedicated background
/// [Isolate], transferring throttled RGBA frames via [TransferableTypedData].
class VncIsolateClient implements VncSessionClient {
  VncIsolateClient({
    Duration minFrameInterval = const Duration(milliseconds: 25),
  }) : _minFrameInterval = minFrameInterval;

  final Duration _minFrameInterval;
  final StreamController<VncClientEvent> _eventsController =
      StreamController<VncClientEvent>.broadcast();

  Isolate? _isolate;
  ReceivePort? _receivePort;
  ReceivePort? _exitPort;
  ReceivePort? _errorPort;
  SendPort? _workerCommandPort;
  Completer<void>? _exitCompleter;
  Completer<void>? _readyCompleter;

  bool _connectStarted = false;
  bool _terminalEventEmitted = false;
  Future<void>? _disconnectFuture;

  @override
  Stream<VncClientEvent> get events => _eventsController.stream;

  @override
  Future<void> connect(VncConnectionConfig config) async {
    if (_disconnectFuture != null) {
      throw StateError('VncIsolateClient has been disconnected');
    }
    if (_connectStarted) {
      throw StateError('VncIsolateClient is already connected or connecting');
    }
    _connectStarted = true;
    _emit(const VncConnectingEvent());

    final receivePort = ReceivePort();
    final exitPort = ReceivePort();
    final errorPort = ReceivePort();
    final exitCompleter = Completer<void>();
    final readyCompleter = Completer<void>();

    _receivePort = receivePort;
    _exitPort = exitPort;
    _errorPort = errorPort;
    _exitCompleter = exitCompleter;
    _readyCompleter = readyCompleter;

    receivePort.listen(_handleWorkerMessage);
    exitPort.listen((_) {
      if (!exitCompleter.isCompleted) {
        exitCompleter.complete();
      }
      if (!readyCompleter.isCompleted) {
        readyCompleter.complete();
      }
      exitPort.close();
      errorPort.close();
      // Defer closing receivePort by one event-loop turn so any final message
      // (such as `error` or `disconnected`) sent just before isolate exit is
      // processed before the port closes.
      Timer.run(() {
        receivePort.close();
        if (!_terminalEventEmitted && _disconnectFuture == null) {
          _terminalEventEmitted = true;
          _emit(const VncDisconnectedEvent());
        }
      });
    });
    errorPort.listen((Object? rawError) {
      final String message;
      if (rawError is List && rawError.isNotEmpty) {
        message = rawError.first.toString();
      } else {
        message = rawError?.toString() ?? 'Unknown VNC isolate error';
      }
      if (!_terminalEventEmitted && _disconnectFuture == null) {
        _terminalEventEmitted = true;
        _emit(VncErrorEvent(VncConnectionException(message)));
      }
      if (!readyCompleter.isCompleted) {
        readyCompleter.complete();
      }
    });

    final startMessage = _encodeStartMessage(
      replyPort: receivePort.sendPort,
      config: config,
      minFrameIntervalMs: _minFrameInterval.inMilliseconds,
    );

    try {
      final isolate = await Isolate.spawn<Map<String, Object?>>(
        _vncWorkerEntryPoint,
        startMessage,
        onExit: exitPort.sendPort,
        onError: errorPort.sendPort,
        debugName: 'vnc_session_worker',
      );

      // If disconnect() was called while Isolate.spawn was awaiting, kill the
      // newly spawned isolate directly without storing it.
      if (_disconnectFuture != null) {
        isolate.kill(priority: Isolate.immediate);
        if (!exitCompleter.isCompleted) {
          exitCompleter.complete();
        }
        if (!readyCompleter.isCompleted) {
          readyCompleter.complete();
        }
        return;
      }

      _isolate = isolate;
      await readyCompleter.future;
    } catch (e) {
      receivePort.close();
      exitPort.close();
      errorPort.close();
      if (!exitCompleter.isCompleted) {
        exitCompleter.complete();
      }
      if (!readyCompleter.isCompleted) {
        readyCompleter.complete();
      }
      if (!_terminalEventEmitted && _disconnectFuture == null) {
        _terminalEventEmitted = true;
        _emit(
          VncErrorEvent(
            VncConnectionException('Failed to start VNC worker isolate', e),
          ),
        );
      }
    }
  }

  void _handleWorkerMessage(Object? message) {
    if (message is! Map<Object?, Object?>) {
      return;
    }
    final type = message['type'] as String?;
    final disconnecting = _disconnectFuture != null;

    if (type == 'ready') {
      final port = message['commandPort'];
      final ready = _readyCompleter;
      if (ready != null && !ready.isCompleted) {
        ready.complete();
      }
      if (disconnecting) {
        if (port is SendPort) {
          port.send(const <String, Object?>{'type': 'disconnect'});
        }
        return;
      }
      if (port is SendPort) {
        _workerCommandPort = port;
      }
      return;
    }

    if (type == 'disconnected') {
      if (!_terminalEventEmitted) {
        _terminalEventEmitted = true;
        _emit(VncDisconnectedEvent(reason: message['reason'] as String?));
      }
      return;
    }

    // Ignore any late session/frame/error events once disconnect() has started.
    if (disconnecting) {
      return;
    }

    switch (type) {
      case 'authRequired':
        _emit(
          VncAuthRequiredEvent(
            securityType: message['securityType'] as int,
            requiresUsername: message['requiresUsername'] as bool,
          ),
        );
      case 'connected':
        _emit(
          VncConnectedEvent(
            VncDesktopInfo(
              name: message['name'] as String,
              width: message['width'] as int,
              height: message['height'] as int,
              protocolVersion: message['protocolVersion'] as String,
              securityType: message['securityType'] as int,
              isApple889: message['isApple889'] as bool? ?? false,
            ),
          ),
        );
      case 'frame':
        final transferable = message['pixels'] as TransferableTypedData;
        final rgbaPixels = transferable.materialize().asUint8List();
        _emit(
          VncFrameEvent(
            VncFrameData(
              frameId: message['frameId'] as int,
              width: message['width'] as int,
              height: message['height'] as int,
              rgbaPixels: rgbaPixels,
            ),
          ),
        );
      case 'resized':
        final rawScreens = message['screens'] as List<Object?>?;
        final screens = rawScreens == null
            ? const <VncScreenInfo>[]
            : List<VncScreenInfo>.unmodifiable([
                for (final item in rawScreens)
                  if (item is Map<Object?, Object?>)
                    VncScreenInfo(
                      id: item['id'] as int,
                      x: item['x'] as int,
                      y: item['y'] as int,
                      width: item['width'] as int,
                      height: item['height'] as int,
                      flags: item['flags'] as int? ?? 0,
                    ),
              ]);
        _emit(
          VncResizedEvent(
            width: message['width'] as int,
            height: message['height'] as int,
            screens: screens,
            hasCurrentDisplayId:
                message['hasCurrentDisplayId'] as bool? ?? false,
            currentDisplayId: message['currentDisplayId'] as int?,
          ),
        );
      case 'cursor':
        final transferable = message['pixels'] as TransferableTypedData;
        final rgbaPixels = transferable.materialize().asUint8List();
        _emit(
          VncCursorEvent(
            VncCursorData(
              width: message['width'] as int,
              height: message['height'] as int,
              hotspotX: message['hotspotX'] as int,
              hotspotY: message['hotspotY'] as int,
              rgbaPixels: rgbaPixels,
            ),
          ),
        );
      case 'clipboard':
        _emit(VncClipboardEvent(message['text'] as String));
      case 'error':
        if (!_terminalEventEmitted) {
          _terminalEventEmitted = true;
          _emit(VncErrorEvent(_deserializeVncException(message)));
        }
    }
  }

  void _emit(VncClientEvent event) {
    if (!_eventsController.isClosed) {
      _eventsController.add(event);
    }
  }

  @override
  void submitCredentials(VncCredentials credentials) {
    _workerCommandPort?.send(<String, Object?>{
      'type': 'credentials',
      'username': credentials.username,
      'password': credentials.password,
    });
  }

  @override
  void cancelCredentials() {
    _workerCommandPort?.send(const <String, Object?>{
      'type': 'cancelCredentials',
    });
  }

  @override
  void sendPointerEvent(int x, int y, int buttonMask) {
    _workerCommandPort?.send(<String, Object?>{
      'type': 'pointer',
      'x': x,
      'y': y,
      'buttonMask': buttonMask,
    });
  }

  @override
  void sendKeyEvent(int keysym, {required bool down}) {
    _workerCommandPort?.send(<String, Object?>{
      'type': 'key',
      'keysym': keysym,
      'down': down,
    });
  }

  @override
  void sendClipboardText(String text) {
    _workerCommandPort?.send(<String, Object?>{
      'type': 'clipboard',
      'text': text,
    });
  }

  @override
  void setViewOnly(bool viewOnly) {
    _workerCommandPort?.send(<String, Object?>{
      'type': 'setViewOnly',
      'viewOnly': viewOnly,
    });
  }

  @override
  void setActiveRegion(VncScreenInfo? region) {
    _workerCommandPort?.send(<String, Object?>{
      'type': 'setActiveRegion',
      'region': region == null
          ? null
          : <String, int>{
              'id': region.id,
              'x': region.x,
              'y': region.y,
              'width': region.width,
              'height': region.height,
              'flags': region.flags,
            },
    });
  }

  @override
  void selectDisplay(int? displayId) {
    _workerCommandPort?.send(<String, Object?>{
      'type': 'selectDisplay',
      'displayId': displayId,
    });
  }

  @override
  void requestFullRefresh() {
    _workerCommandPort?.send(const <String, Object?>{'type': 'refresh'});
  }

  @override
  Future<void> disconnect() => _disconnectFuture ??= _disconnectInternal();

  Future<void> _disconnectInternal() async {
    try {
      _workerCommandPort?.send(const <String, Object?>{'type': 'disconnect'});
      _workerCommandPort = null;

      final exitCompleter = _exitCompleter;
      final isolate = _isolate;
      if (exitCompleter != null && !exitCompleter.isCompleted) {
        try {
          await exitCompleter.future.timeout(const Duration(seconds: 1));
        } on TimeoutException {
          isolate?.kill(priority: Isolate.immediate);
        }
      }
    } finally {
      _receivePort?.close();
      _exitPort?.close();
      _errorPort?.close();
      _receivePort = null;
      _exitPort = null;
      _errorPort = null;
      _isolate = null;

      if (_connectStarted && !_terminalEventEmitted) {
        _terminalEventEmitted = true;
        _emit(const VncDisconnectedEvent());
      }
      if (!_eventsController.isClosed) {
        await _eventsController.close();
      }
    }
  }
}

Map<String, Object?> _encodeStartMessage({
  required SendPort replyPort,
  required VncConnectionConfig config,
  required int minFrameIntervalMs,
}) {
  final ssh = config.sshTunnel;
  return <String, Object?>{
    'replyPort': replyPort,
    'host': config.host,
    'port': config.port,
    'authPreference': config.authPreference.code,
    'username': config.credentials.username,
    'password': config.credentials.password,
    'viewOnly': config.viewOnly,
    'sharedDesktop': config.sharedDesktop,
    'connectTimeoutMs': config.connectTimeout.inMilliseconds,
    'enableAppleExtensions': config.enableAppleExtensions,
    'minFrameIntervalMs': minFrameIntervalMs,
    if (ssh != null)
      'sshTunnel': <String, Object?>{
        'host': ssh.host,
        'port': ssh.port,
        'username': ssh.username,
        'password': ssh.password,
        'privateKeyPem': ssh.privateKeyPem,
        'privateKeyPassphrase': ssh.privateKeyPassphrase,
      },
  };
}

VncConnectionConfig _decodeConfig(Map<String, Object?> message) {
  final sshMap = message['sshTunnel'] as Map<Object?, Object?>?;
  final sshTunnel = sshMap == null
      ? null
      : VncSshTunnelConfig(
          host: sshMap['host'] as String,
          port: sshMap['port'] as int,
          username: sshMap['username'] as String,
          password: sshMap['password'] as String?,
          privateKeyPem: sshMap['privateKeyPem'] as String?,
          privateKeyPassphrase: sshMap['privateKeyPassphrase'] as String?,
        );
  return VncConnectionConfig(
    host: message['host'] as String,
    port: message['port'] as int,
    authPreference: VncAuthPreference.fromCode(
      message['authPreference'] as int,
    ),
    credentials: VncCredentials(
      username: message['username'] as String?,
      password: message['password'] as String?,
    ),
    sshTunnel: sshTunnel,
    viewOnly: message['viewOnly'] as bool,
    sharedDesktop: message['sharedDesktop'] as bool,
    connectTimeout: Duration(milliseconds: message['connectTimeoutMs'] as int),
    enableAppleExtensions: message['enableAppleExtensions'] as bool? ?? true,
  );
}

Map<String, Object?> _serializeVncException(Object error) {
  if (error is VncException) {
    return switch (error) {
      VncConnectionException(:final message, :final cause) => <String, Object?>{
        'type': 'error',
        'kind': 'connection',
        'message': message,
        'cause': cause?.toString(),
      },
      VncSshTunnelException(:final message, :final cause) => <String, Object?>{
        'type': 'error',
        'kind': 'sshTunnel',
        'message': message,
        'cause': cause?.toString(),
      },
      VncAuthenticationException(:final message, :final cause) =>
        <String, Object?>{
          'type': 'error',
          'kind': 'authentication',
          'message': message,
          'cause': cause?.toString(),
        },
      VncUnsupportedSecurityTypeException(
        :final message,
        :final offeredTypes,
      ) =>
        <String, Object?>{
          'type': 'error',
          'kind': 'unsupportedSecurityType',
          'message': message,
          'offeredTypes': List<int>.from(offeredTypes),
        },
      VncProtocolException(:final message, :final cause) => <String, Object?>{
        'type': 'error',
        'kind': 'protocol',
        'message': message,
        'cause': cause?.toString(),
      },
    };
  }
  return <String, Object?>{
    'type': 'error',
    'kind': 'connection',
    'message': error.toString(),
    'cause': null,
  };
}

VncException _deserializeVncException(Map<Object?, Object?> message) {
  final kind = message['kind'] as String? ?? 'connection';
  final text = message['message'] as String? ?? 'Unknown VNC error';
  final cause = message['cause'] as String?;
  return switch (kind) {
    'connection' => VncConnectionException(text, cause),
    'sshTunnel' => VncSshTunnelException(text, cause),
    'authentication' => VncAuthenticationException(text, cause),
    'unsupportedSecurityType' => VncUnsupportedSecurityTypeException(
      (message['offeredTypes'] as List<Object?>? ?? const <Object?>[])
          .cast<int>()
          .toList(growable: false),
      message: text,
    ),
    'protocol' => VncProtocolException(text, cause),
    _ => VncConnectionException(text, cause),
  };
}

Future<void> _vncWorkerEntryPoint(Map<String, Object?> startMessage) async {
  final replyPort = startMessage['replyPort'] as SendPort;
  final config = _decodeConfig(startMessage);
  final minFrameIntervalMs = (startMessage['minFrameIntervalMs'] as int? ?? 25)
      .clamp(0, 10000);

  final commandPort = ReceivePort();
  replyPort.send(<String, Object?>{
    'type': 'ready',
    'commandPort': commandPort.sendPort,
  });

  var stopping = false;
  var viewOnly = config.viewOnly;
  var errorSent = false;
  var hasPendingRegion = false;
  VncScreenInfo? pendingRegion;
  var hasPendingDisplaySelection = false;
  int? pendingDisplayId;
  Completer<VncCredentials?>? pendingCredentials;
  VncTransport? transport;
  BufferedByteReader? reader;
  RfbSession? session;
  Timer? trailingTimer;

  void safeSessionCall(void Function(RfbSession active) action) {
    if (stopping) {
      return;
    }
    final active = session;
    if (active == null) {
      return;
    }
    try {
      action(active);
    } on StateError {
      // Transport closed concurrently during teardown.
    }
  }

  commandPort.listen((Object? rawCommand) {
    if (rawCommand is! Map<Object?, Object?>) {
      return;
    }
    switch (rawCommand['type'] as String?) {
      case 'credentials':
        final completer = pendingCredentials;
        if (completer != null && !completer.isCompleted) {
          pendingCredentials = null;
          completer.complete(
            VncCredentials(
              username: rawCommand['username'] as String?,
              password: rawCommand['password'] as String?,
            ),
          );
        }
      case 'cancelCredentials':
        final completer = pendingCredentials;
        if (completer != null && !completer.isCompleted) {
          pendingCredentials = null;
          completer.complete(null);
        }
      case 'pointer':
        if (!viewOnly) {
          safeSessionCall(
            (s) => s.sendPointerEvent(
              rawCommand['x'] as int,
              rawCommand['y'] as int,
              rawCommand['buttonMask'] as int,
            ),
          );
        }
      case 'key':
        if (!viewOnly) {
          safeSessionCall(
            (s) => s.sendKeyEvent(
              rawCommand['keysym'] as int,
              down: rawCommand['down'] as bool,
            ),
          );
        }
      case 'clipboard':
        safeSessionCall(
          (s) => s.sendClientCutText(rawCommand['text'] as String),
        );
      case 'setViewOnly':
        viewOnly = rawCommand['viewOnly'] as bool;
      case 'setActiveRegion':
        final rawRegion = rawCommand['region'];
        final VncScreenInfo? region;
        if (rawRegion is Map<Object?, Object?>) {
          region = VncScreenInfo(
            id: rawRegion['id'] as int,
            x: rawRegion['x'] as int,
            y: rawRegion['y'] as int,
            width: rawRegion['width'] as int,
            height: rawRegion['height'] as int,
            flags: rawRegion['flags'] as int? ?? 0,
          );
        } else {
          region = null;
        }
        if (session != null) {
          safeSessionCall((s) => s.setActiveRegion(region));
        } else {
          hasPendingRegion = true;
          pendingRegion = region;
        }
      case 'selectDisplay':
        final displayId = rawCommand['displayId'] as int?;
        if (session != null) {
          safeSessionCall((s) => s.selectAppleDisplay(displayId));
        } else {
          hasPendingDisplaySelection = true;
          pendingDisplayId = displayId;
        }
      case 'refresh':
        safeSessionCall((s) => s.requestFramebufferUpdate(incremental: false));
      case 'disconnect':
        stopping = true;
        trailingTimer?.cancel();
        trailingTimer = null;
        final completer = pendingCredentials;
        if (completer != null && !completer.isCompleted) {
          pendingCredentials = null;
          completer.complete(null);
        }
        final activeReader = reader;
        if (activeReader != null) {
          unawaited(activeReader.dispose().catchError((Object _) {}));
        }
        final activeTransport = transport;
        if (activeTransport != null) {
          unawaited(activeTransport.close().catchError((Object _) {}));
        }
    }
  });

  try {
    final sshTunnel = config.sshTunnel;
    if (sshTunnel != null) {
      transport = await SshTunnelVncTransport.connect(
        tunnel: sshTunnel,
        remoteHost: config.host,
        remotePort: config.port,
        timeout: config.connectTimeout,
      );
    } else {
      transport = await TcpVncTransport.connect(
        host: config.host,
        port: config.port,
        timeout: config.connectTimeout,
      );
    }

    if (stopping) {
      return;
    }

    reader = BufferedByteReader(transport.stream);

    final handshake = await RfbHandshake.performSession(
      transport: transport,
      reader: reader,
      config: config,
      onCredentialsRequired:
          ({required int securityType, required bool requiresUsername}) async {
            if (stopping) {
              return null;
            }
            final completer = Completer<VncCredentials?>();
            pendingCredentials = completer;
            replyPort.send(<String, Object?>{
              'type': 'authRequired',
              'securityType': securityType,
              'requiresUsername': requiresUsername,
            });
            return completer.future;
          },
    );

    transport = handshake.transport;
    reader = handshake.reader;
    final desktopInfo = handshake.desktopInfo;

    if (stopping) {
      return;
    }

    replyPort.send(<String, Object?>{
      'type': 'connected',
      'name': desktopInfo.name,
      'width': desktopInfo.width,
      'height': desktopInfo.height,
      'protocolVersion': desktopInfo.protocolVersion,
      'securityType': desktopInfo.securityType,
      'isApple889': desktopInfo.isApple889,
    });

    final framebuffer = VncFramebuffer(desktopInfo.width, desktopInfo.height);
    session = RfbSession(
      transport: transport,
      reader: reader,
      framebuffer: framebuffer,
      isApple889: desktopInfo.isApple889,
    );
    if (hasPendingRegion) {
      hasPendingRegion = false;
      safeSessionCall((s) => s.setActiveRegion(pendingRegion));
    }
    if (hasPendingDisplaySelection) {
      hasPendingDisplaySelection = false;
      safeSessionCall((s) => s.selectAppleDisplay(pendingDisplayId));
    }

    var frameId = 0;
    var dirty = false;
    final stopwatch = Stopwatch()..start();
    var lastSentElapsedMs = -minFrameIntervalMs;

    void sendFrameNow() {
      if (stopping) {
        return;
      }
      dirty = false;
      trailingTimer?.cancel();
      trailingTimer = null;
      lastSentElapsedMs = stopwatch.elapsedMilliseconds;
      frameId++;
      final snapshot = framebuffer.snapshot();
      replyPort.send(<String, Object?>{
        'type': 'frame',
        'frameId': frameId,
        'width': framebuffer.width,
        'height': framebuffer.height,
        'pixels': TransferableTypedData.fromList(<Uint8List>[snapshot]),
      });
    }

    void scheduleFrameFlush() {
      if (stopping) {
        return;
      }
      final elapsedSinceLast =
          stopwatch.elapsedMilliseconds - lastSentElapsedMs;
      if (elapsedSinceLast >= minFrameIntervalMs) {
        sendFrameNow();
      } else {
        dirty = true;
        trailingTimer ??= Timer(
          Duration(milliseconds: minFrameIntervalMs - elapsedSinceLast),
          () {
            trailingTimer = null;
            if (dirty && !stopping) {
              sendFrameNow();
            }
          },
        );
      }
    }

    await session.runMessageLoop(
      onFrameUpdated: scheduleFrameFlush,
      onDesktopResized:
          (
            width,
            height,
            screens, {
            hasCurrentDisplayId = false,
            currentDisplayId,
          }) {
            if (stopping) {
              return;
            }
            dirty = false;
            trailingTimer?.cancel();
            trailingTimer = null;
            lastSentElapsedMs = -minFrameIntervalMs;
            replyPort.send(<String, Object?>{
              'type': 'resized',
              'width': width,
              'height': height,
              'screens': [
                for (final screen in screens)
                  <String, int>{
                    'id': screen.id,
                    'x': screen.x,
                    'y': screen.y,
                    'width': screen.width,
                    'height': screen.height,
                    'flags': screen.flags,
                  },
              ],
              'hasCurrentDisplayId': hasCurrentDisplayId,
              'currentDisplayId': currentDisplayId,
            });
          },
      onCursorUpdated: (cursor) {
        if (stopping) {
          return;
        }
        replyPort.send(<String, Object?>{
          'type': 'cursor',
          'width': cursor.width,
          'height': cursor.height,
          'hotspotX': cursor.hotspotX,
          'hotspotY': cursor.hotspotY,
          'pixels': TransferableTypedData.fromList(<Uint8List>[
            cursor.rgbaPixels,
          ]),
        });
      },
      onServerCutText: (text) {
        if (stopping) {
          return;
        }
        replyPort.send(<String, Object?>{'type': 'clipboard', 'text': text});
      },
      shouldStop: () => stopping,
    );
  } catch (e) {
    if (!stopping) {
      errorSent = true;
      replyPort.send(_serializeVncException(e));
    }
  } finally {
    stopping = true;
    trailingTimer?.cancel();
    trailingTimer = null;

    final completer = pendingCredentials;
    if (completer != null && !completer.isCompleted) {
      pendingCredentials = null;
      completer.complete(null);
    }

    if (reader != null) {
      try {
        await reader.dispose();
      } catch (_) {}
    }
    if (transport != null) {
      try {
        await transport.close();
      } catch (_) {}
    }

    if (!errorSent) {
      replyPort.send(const <String, Object?>{
        'type': 'disconnected',
        'reason': null,
      });
    }

    commandPort.close();
  }
}
