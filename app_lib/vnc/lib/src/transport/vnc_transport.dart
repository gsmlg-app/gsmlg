import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_ssh/app_ssh.dart';

import '../models/vnc_exceptions.dart';
import '../models/vnc_models.dart';

/// Bidirectional byte transport backing an RFB/VNC connection.
abstract interface class VncTransport {
  /// Incoming byte chunks received from the remote VNC server.
  Stream<Uint8List> get stream;

  /// Enqueues [data] to be sent to the remote VNC server.
  ///
  /// Throws a [StateError] if [close] has already been called.
  void add(Uint8List data);

  /// Flushes any buffered outbound bytes to the underlying transport.
  Future<void> flush();

  /// Gracefully closes the transport, falling back to forceful teardown on
  /// error or timeout.
  ///
  /// Safe to call multiple times or concurrently; subsequent calls return the
  /// same future.
  Future<void> close();

  /// Completes when the transport has terminated, either because the remote
  /// peer closed the connection or because [close] finished.
  Future<void> get done;
}

/// Direct TCP transport for VNC connections.
class TcpVncTransport implements VncTransport {
  TcpVncTransport._(
    this._socket, {
    Duration closeTimeout = const Duration(seconds: 2),
  }) : _closeTimeout = closeTimeout {
    _stream = _socket.transform(
      StreamTransformer<Uint8List, Uint8List>.fromHandlers(
        handleData: (data, sink) => sink.add(data),
        handleError: (error, stackTrace, sink) {
          _completeDone();
          sink.addError(error, stackTrace);
        },
        handleDone: (sink) {
          _completeDone();
          sink.close();
        },
      ),
    );
    unawaited(
      _socket.done.catchError((Object _) {}).whenComplete(_completeDone),
    );
  }

  final Socket _socket;
  final Duration _closeTimeout;
  final Completer<void> _doneCompleter = Completer<void>();
  late final Stream<Uint8List> _stream;
  Future<void>? _closeFuture;

  static Future<TcpVncTransport> connect({
    required String host,
    required int port,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      try {
        socket.setOption(SocketOption.tcpNoDelay, true);
      } catch (_) {
        // Ignore unsupported socket option errors on platforms that reject it.
      }
      return TcpVncTransport._(socket);
    } on SocketException catch (e) {
      throw VncConnectionException('Failed to connect to $host:$port', e);
    } on TimeoutException catch (e) {
      throw VncConnectionException('Connection to $host:$port timed out', e);
    } on ArgumentError catch (e) {
      throw VncConnectionException('Invalid VNC endpoint $host:$port', e);
    }
  }

  void _completeDone() {
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete();
    }
  }

  @override
  Stream<Uint8List> get stream => _stream;

  @override
  void add(Uint8List data) {
    if (_closeFuture != null) {
      throw StateError('Transport is closed');
    }
    _socket.add(data);
  }

  @override
  Future<void> flush() => _socket.flush();

  @override
  Future<void> get done => _doneCompleter.future;

  @override
  Future<void> close() => _closeFuture ??= _closeInternal();

  Future<void> _closeInternal() async {
    try {
      final closeFuture = _socket.close();
      unawaited(closeFuture.catchError((Object _) {}));
      await closeFuture.timeout(_closeTimeout);
    } catch (_) {
      // Fall through to destroy() below.
    } finally {
      try {
        _socket.destroy();
      } catch (_) {
        // Suppress errors when destroying an already broken socket.
      }
      _completeDone();
    }
  }
}

/// VNC transport tunneled through an `app_ssh` local port-forwarding channel.
class SshTunnelVncTransport implements VncTransport {
  SshTunnelVncTransport.fromChannel({
    required SSHSocket channel,
    required FutureOr<void> Function() closeClient,
    Duration closeTimeout = const Duration(seconds: 2),
  }) : _channel = channel,
       _closeClient = closeClient,
       _closeTimeout = closeTimeout;

  final SSHSocket _channel;
  final FutureOr<void> Function() _closeClient;
  final Duration _closeTimeout;
  late final Stream<Uint8List> _stream = _channel.stream;
  Future<void>? _closeFuture;

  static Future<SshTunnelVncTransport> connect({
    required VncSshTunnelConfig tunnel,
    required String remoteHost,
    required int remotePort,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    SSHSocket? socket;
    SSHClient? client;
    SSHForwardChannel? channel;
    final stopwatch = Stopwatch()..start();

    Duration remainingTimeout() {
      final remaining = timeout - stopwatch.elapsed;
      if (remaining <= Duration.zero) {
        throw TimeoutException(
          'SSH tunnel setup timed out after $timeout',
          timeout,
        );
      }
      return remaining;
    }

    try {
      List<SSHKeyPair>? identities;
      final privateKeyPem = tunnel.privateKeyPem;
      if (privateKeyPem != null && privateKeyPem.trim().isNotEmpty) {
        final passphrase = tunnel.privateKeyPassphrase;
        final normalizedPassphrase = (passphrase == null || passphrase.isEmpty)
            ? null
            : passphrase;
        identities = SSHKeyPair.fromPem(privateKeyPem, normalizedPassphrase);
      }

      socket = await SSHSocket.connect(
        tunnel.host,
        tunnel.port,
        timeout: remainingTimeout(),
      );

      client = SSHClient(
        socket,
        username: tunnel.username,
        identities: identities,
        onPasswordRequest: tunnel.password != null
            ? () => tunnel.password
            : null,
      );

      final authFuture = client.authenticated;
      unawaited(authFuture.then<void>((_) {}, onError: (Object _) {}));
      await authFuture.timeout(remainingTimeout());

      final forwardFuture = client.forwardLocal(remoteHost, remotePort);
      unawaited(forwardFuture.then<void>((_) {}, onError: (Object _) {}));
      channel = await forwardFuture.timeout(remainingTimeout());

      final establishedClient = client;
      return SshTunnelVncTransport.fromChannel(
        channel: channel,
        closeClient: establishedClient.close,
      );
    } on VncSshTunnelException {
      await _cleanupFailedConnect(
        channel: channel,
        client: client,
        socket: socket,
      );
      rethrow;
    } catch (e) {
      await _cleanupFailedConnect(
        channel: channel,
        client: client,
        socket: socket,
      );
      throw VncSshTunnelException(
        'Failed to establish SSH tunnel via ${tunnel.host}:${tunnel.port} '
        'to $remoteHost:$remotePort',
        e,
      );
    }
  }

  static Future<void> _cleanupFailedConnect({
    SSHForwardChannel? channel,
    SSHClient? client,
    SSHSocket? socket,
  }) async {
    if (channel != null) {
      try {
        channel.destroy();
      } catch (_) {}
    }
    if (client != null) {
      unawaited(client.done.catchError((Object _) {}));
      try {
        client.close();
      } catch (_) {}
    } else if (socket != null) {
      try {
        final closeFuture = socket.close();
        unawaited(closeFuture.catchError((Object _) {}));
        await closeFuture.timeout(const Duration(seconds: 2));
      } catch (_) {
        try {
          socket.destroy();
        } catch (_) {}
      }
    }
  }

  @override
  Stream<Uint8List> get stream => _stream;

  @override
  void add(Uint8List data) {
    if (_closeFuture != null) {
      throw StateError('Transport is closed');
    }
    _channel.sink.add(data);
  }

  @override
  Future<void> flush() async {
    final sink = _channel.sink;
    if (sink is IOSink) {
      await sink.flush();
    }
  }

  @override
  Future<void> get done => _channel.done;

  @override
  Future<void> close() => _closeFuture ??= _closeInternal();

  Future<void> _closeInternal() async {
    try {
      final closeFuture = _channel.close();
      unawaited(closeFuture.catchError((Object _) {}));
      await closeFuture.timeout(_closeTimeout);
    } catch (_) {
      try {
        _channel.destroy();
      } catch (_) {
        // Ensure SSH client teardown still runs.
      }
    } finally {
      try {
        await _closeClient();
      } catch (_) {
        // Suppress teardown errors on close.
      }
    }
  }
}
