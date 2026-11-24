import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_ssh/app_ssh.dart';

import '../models/vnc_exceptions.dart';
import '../models/vnc_models.dart';

/// Bidirectional byte transport backing an RFB/VNC connection.
abstract interface class VncTransport {
  Stream<Uint8List> get stream;

  void add(Uint8List data);

  Future<void> flush();

  Future<void> close();

  Future<void> get done;
}

/// Direct TCP transport for VNC connections.
class TcpVncTransport implements VncTransport {
  TcpVncTransport._(this._socket);

  final Socket _socket;
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

  @override
  Stream<Uint8List> get stream => _socket;

  @override
  void add(Uint8List data) => _socket.add(data);

  @override
  Future<void> flush() => _socket.flush();

  @override
  Future<void> get done => _socket.done;

  @override
  Future<void> close() => _closeFuture ??= _closeInternal();

  Future<void> _closeInternal() async {
    try {
      await _socket.close();
    } catch (_) {
      try {
        _socket.destroy();
      } catch (_) {
        // Suppress errors when destroying an already broken socket.
      }
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

    try {
      List<SSHKeyPair>? identities;
      final privateKeyPem = tunnel.privateKeyPem;
      if (privateKeyPem != null && privateKeyPem.trim().isNotEmpty) {
        identities = SSHKeyPair.fromPem(
          privateKeyPem,
          tunnel.privateKeyPassphrase,
        );
      }

      socket = await SSHSocket.connect(
        tunnel.host,
        tunnel.port,
        timeout: timeout,
      );

      client = SSHClient(
        socket,
        username: tunnel.username,
        identities: identities,
        onPasswordRequest: tunnel.password != null
            ? () => tunnel.password
            : null,
      );

      await client.authenticated.timeout(timeout);

      channel = await client
          .forwardLocal(remoteHost, remotePort)
          .timeout(timeout);

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
        await socket.close();
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
  void add(Uint8List data) => _channel.sink.add(data);

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
      await _channel.close().timeout(_closeTimeout);
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
