import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_ssh/app_ssh.dart';
import 'package:app_vnc/app_vnc.dart';
import 'package:test/test.dart';

class _FakeForwardChannel implements SSHForwardChannel {
  _FakeForwardChannel({
    this.throwOnClose = false,
    this.closeDelay = Duration.zero,
    this.closeGate,
  });

  final bool throwOnClose;
  final Duration closeDelay;
  final Completer<void>? closeGate;

  final StreamController<Uint8List> _incoming = StreamController<Uint8List>();
  final StreamController<List<int>> _outgoing = StreamController<List<int>>();
  final Completer<void> _doneCompleter = Completer<void>();

  final List<Uint8List> writtenChunks = [];
  int closeCalls = 0;
  int destroyCalls = 0;

  void startCapturingWrites() {
    _outgoing.stream.listen((chunk) {
      writtenChunks.add(chunk is Uint8List ? chunk : Uint8List.fromList(chunk));
    });
  }

  void emitIncoming(List<int> bytes) {
    _incoming.add(Uint8List.fromList(bytes));
  }

  @override
  Stream<Uint8List> get stream => _incoming.stream;

  @override
  StreamSink<List<int>> get sink => _outgoing.sink;

  @override
  Future<void> get done => _doneCompleter.future;

  Future<void> _closeController(StreamController<Object?> controller) async {
    if (controller.isClosed) {
      return;
    }
    if (controller.hasListener) {
      await controller.close();
    } else {
      unawaited(controller.close());
    }
  }

  @override
  Future<void> close() async {
    closeCalls++;
    if (closeGate != null) {
      await closeGate!.future;
    }
    if (closeDelay > Duration.zero) {
      await Future<void>.delayed(closeDelay);
    }
    if (throwOnClose) {
      throw StateError('channel close failed');
    }
    await _closeController(_incoming);
    await _closeController(_outgoing);
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete();
    }
  }

  @override
  void destroy() {
    destroyCalls++;
    if (!_incoming.isClosed) {
      unawaited(_incoming.close());
    }
    if (!_outgoing.isClosed) {
      unawaited(_outgoing.close());
    }
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete();
    }
    if (closeGate != null && !closeGate!.isCompleted) {
      closeGate!.complete();
    }
  }
}

Future<int> _getUnusedLoopbackPort() async {
  final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  final port = server.port;
  await server.close();
  return port;
}

void main() {
  group('TcpVncTransport', () {
    test(
      'connects to loopback ServerSocket, transfers bytes bidirectionally, and closes idempotently',
      () async {
        final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        final serverReceived = BytesBuilder(copy: false);
        final serverReceived4Bytes = Completer<Uint8List>();
        final serverClientClosed = Completer<void>();
        Socket? acceptedSocket;

        final serverSub = server.listen((clientSocket) {
          acceptedSocket = clientSocket;
          clientSocket.listen(
            (data) {
              serverReceived.add(data);
              if (serverReceived.length >= 4 &&
                  !serverReceived4Bytes.isCompleted) {
                serverReceived4Bytes.complete(serverReceived.toBytes());
                clientSocket.add(Uint8List.fromList([0xCA, 0xFE, 0xBA, 0xBE]));
              }
            },
            onDone: () {
              if (!serverClientClosed.isCompleted) {
                serverClientClosed.complete();
              }
              clientSocket.close();
            },
          );
        });

        try {
          final transport = await TcpVncTransport.connect(
            host: InternetAddress.loopbackIPv4.address,
            port: server.port,
          );

          final clientReceived = BytesBuilder(copy: false);
          final clientReceived4Bytes = Completer<Uint8List>();
          final clientSub = transport.stream.listen((chunk) {
            clientReceived.add(chunk);
            if (clientReceived.length >= 4 &&
                !clientReceived4Bytes.isCompleted) {
              clientReceived4Bytes.complete(clientReceived.toBytes());
            }
          });

          transport.add(Uint8List.fromList([0x01, 0x02, 0x03, 0x04]));
          await transport.flush();

          expect(
            await serverReceived4Bytes.future.timeout(
              const Duration(seconds: 5),
            ),
            Uint8List.fromList([0x01, 0x02, 0x03, 0x04]),
          );
          expect(
            await clientReceived4Bytes.future.timeout(
              const Duration(seconds: 5),
            ),
            Uint8List.fromList([0xCA, 0xFE, 0xBA, 0xBE]),
          );

          // Concurrent and repeated close calls must be idempotent.
          await Future.wait([transport.close(), transport.close()]);
          await transport.close();

          expect(
            () => transport.add(Uint8List.fromList([0x05])),
            throwsStateError,
          );

          await serverClientClosed.future.timeout(const Duration(seconds: 5));
          await transport.done.timeout(const Duration(seconds: 5));
          await clientSub.cancel();
        } finally {
          acceptedSocket?.destroy();
          await serverSub.cancel();
          await server.close();
        }
      },
    );

    test(
      'completes done when remote peer closes the socket before local close',
      () async {
        final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        final serverSub = server.listen((clientSocket) {
          clientSocket.add(Uint8List.fromList([0x52, 0x46, 0x42]));
          unawaited(clientSocket.close());
        });

        try {
          final transport = await TcpVncTransport.connect(
            host: InternetAddress.loopbackIPv4.address,
            port: server.port,
          );

          final received = BytesBuilder(copy: false);
          final streamDone = Completer<void>();
          final sub = transport.stream.listen(
            received.add,
            onDone: () {
              if (!streamDone.isCompleted) {
                streamDone.complete();
              }
            },
          );

          await streamDone.future.timeout(const Duration(seconds: 5));
          await transport.done.timeout(const Duration(seconds: 5));
          expect(received.toBytes(), Uint8List.fromList([0x52, 0x46, 0x42]));

          await transport.close();
          await sub.cancel();
        } finally {
          await serverSub.cancel();
          await server.close();
        }
      },
    );

    test(
      'close() destroys socket cleanly even if remote peer keeps connection open',
      () async {
        final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        Socket? acceptedSocket;
        final accepted = Completer<void>();
        final serverSub = server.listen((clientSocket) {
          acceptedSocket = clientSocket;
          // Intentionally keep peer socket open without closing it back.
          if (!accepted.isCompleted) {
            accepted.complete();
          }
        });

        try {
          final transport = await TcpVncTransport.connect(
            host: InternetAddress.loopbackIPv4.address,
            port: server.port,
          );
          await accepted.future.timeout(const Duration(seconds: 2));

          await transport.close().timeout(const Duration(seconds: 5));
          await transport.done.timeout(const Duration(seconds: 2));
          expect(
            () => transport.add(Uint8List.fromList([0x01])),
            throwsStateError,
          );
        } finally {
          acceptedSocket?.destroy();
          await serverSub.cancel();
          await server.close();
        }
      },
    );

    test('wraps connection refused as VncConnectionException', () async {
      final closedPort = await _getUnusedLoopbackPort();

      await expectLater(
        TcpVncTransport.connect(
          host: InternetAddress.loopbackIPv4.address,
          port: closedPort,
          timeout: const Duration(seconds: 2),
        ),
        throwsA(
          isA<VncConnectionException>().having(
            (e) => e.cause,
            'cause',
            isNotNull,
          ),
        ),
      );
    });

    test('wraps invalid port as VncConnectionException', () async {
      await expectLater(
        TcpVncTransport.connect(
          host: InternetAddress.loopbackIPv4.address,
          port: 70000,
        ),
        throwsA(
          isA<VncConnectionException>().having(
            (e) => e.cause,
            'cause',
            isA<ArgumentError>(),
          ),
        ),
      );
    });
  });

  group('SshTunnelVncTransport', () {
    test(
      'wraps connection failure on unreachable port as VncSshTunnelException',
      () async {
        final closedPort = await _getUnusedLoopbackPort();

        await expectLater(
          SshTunnelVncTransport.connect(
            tunnel: VncSshTunnelConfig(
              host: InternetAddress.loopbackIPv4.address,
              port: closedPort,
              username: 'tester',
              password: 'secret',
            ),
            remoteHost: '127.0.0.1',
            remotePort: 5900,
            timeout: const Duration(seconds: 2),
          ),
          throwsA(
            isA<VncSshTunnelException>().having(
              (e) => e.cause,
              'cause',
              isNotNull,
            ),
          ),
        );
      },
    );

    test('wraps invalid private key PEM as VncSshTunnelException', () async {
      final closedPort = await _getUnusedLoopbackPort();

      await expectLater(
        SshTunnelVncTransport.connect(
          tunnel: VncSshTunnelConfig(
            host: InternetAddress.loopbackIPv4.address,
            port: closedPort,
            username: 'tester',
            privateKeyPem: 'not-a-valid-pem-key',
            privateKeyPassphrase: '',
          ),
          remoteHost: '127.0.0.1',
          remotePort: 5900,
          timeout: const Duration(seconds: 2),
        ),
        throwsA(
          isA<VncSshTunnelException>().having(
            (e) => e.cause,
            'cause',
            isNotNull,
          ),
        ),
      );
    });

    test(
      'relays bytes, guards add() after close, and closes both channel and SSH client idempotently',
      () async {
        final channel = _FakeForwardChannel(
          closeDelay: const Duration(milliseconds: 10),
        )..startCapturingWrites();
        var clientCloseCalls = 0;

        final transport = SshTunnelVncTransport.fromChannel(
          channel: channel,
          closeClient: () async {
            clientCloseCalls++;
          },
        );

        final received = <Uint8List>[];
        final sub = transport.stream.listen(received.add);

        channel.emitIncoming([0x52, 0x46, 0x42]);
        transport.add(Uint8List.fromList([0x01, 0x02]));
        await transport.flush();
        await Future<void>.delayed(Duration.zero);

        expect(received, [
          Uint8List.fromList([0x52, 0x46, 0x42]),
        ]);
        expect(channel.writtenChunks, [
          Uint8List.fromList([0x01, 0x02]),
        ]);

        // Double concurrent close + subsequent close should invoke teardown once.
        await Future.wait([transport.close(), transport.close()]);
        await transport.close();
        await transport.done;
        await sub.cancel();

        expect(
          () => transport.add(Uint8List.fromList([0x03])),
          throwsStateError,
        );
        expect(channel.closeCalls, 1);
        expect(channel.destroyCalls, 0);
        expect(clientCloseCalls, 1);
      },
    );

    test(
      'falls back to channel.destroy() and still closes SSH client when channel.close() throws',
      () async {
        final channel = _FakeForwardChannel(throwOnClose: true);
        var clientCloseCalls = 0;

        final transport = SshTunnelVncTransport.fromChannel(
          channel: channel,
          closeClient: () {
            clientCloseCalls++;
          },
        );

        await transport.close();
        await transport.close();
        await transport.done;

        expect(channel.closeCalls, 1);
        expect(channel.destroyCalls, 1);
        expect(clientCloseCalls, 1);
      },
    );

    test(
      'falls back to channel.destroy() and closes SSH client when channel.close() times out',
      () async {
        final closeGate = Completer<void>();
        final channel = _FakeForwardChannel(
          closeGate: closeGate,
          throwOnClose: true,
        );
        var clientCloseCalls = 0;

        final transport = SshTunnelVncTransport.fromChannel(
          channel: channel,
          closeClient: () {
            clientCloseCalls++;
          },
          closeTimeout: const Duration(milliseconds: 20),
        );

        await transport.close();
        await transport.done;
        // Let any late rejection from the timed-out closeFuture settle cleanly.
        await Future<void>.delayed(Duration.zero);

        expect(channel.closeCalls, 1);
        expect(channel.destroyCalls, 1);
        expect(clientCloseCalls, 1);
      },
    );

    test(
      'cleans up and throws VncSshTunnelException when SSH handshake aborts',
      () async {
        final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        final accepted = Completer<void>();
        final serverSub = server.listen((socket) {
          if (!accepted.isCompleted) {
            accepted.complete();
          }
          socket.destroy();
        });

        try {
          await expectLater(
            SshTunnelVncTransport.connect(
              tunnel: VncSshTunnelConfig(
                host: InternetAddress.loopbackIPv4.address,
                port: server.port,
                username: 'tester',
                password: 'secret',
              ),
              remoteHost: '127.0.0.1',
              remotePort: 5900,
              timeout: const Duration(seconds: 2),
            ),
            throwsA(
              isA<VncSshTunnelException>().having(
                (e) => e.cause,
                'cause',
                isNotNull,
              ),
            ),
          );
          await accepted.future.timeout(const Duration(seconds: 2));
        } finally {
          await serverSub.cancel();
          await server.close();
        }
      },
    );

    test(
      'cleans up and throws VncSshTunnelException when SSH handshake times out against a silent server',
      () async {
        final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        final accepted = Completer<void>();
        final peerDisconnected = Completer<void>();
        Socket? acceptedSocket;

        final serverSub = server.listen((socket) {
          acceptedSocket = socket;
          if (!accepted.isCompleted) {
            accepted.complete();
          }
          // Never send an SSH banner; drain incoming client banner and wait for disconnect.
          socket.listen(
            (_) {},
            onDone: () {
              if (!peerDisconnected.isCompleted) {
                peerDisconnected.complete();
              }
            },
            onError: (_) {
              if (!peerDisconnected.isCompleted) {
                peerDisconnected.complete();
              }
            },
          );
        });

        try {
          await expectLater(
            SshTunnelVncTransport.connect(
              tunnel: VncSshTunnelConfig(
                host: InternetAddress.loopbackIPv4.address,
                port: server.port,
                username: 'tester',
                password: 'secret',
              ),
              remoteHost: '127.0.0.1',
              remotePort: 5900,
              timeout: const Duration(milliseconds: 150),
            ),
            throwsA(
              isA<VncSshTunnelException>().having(
                (e) => e.cause,
                'cause',
                isA<TimeoutException>(),
              ),
            ),
          );
          await accepted.future.timeout(const Duration(seconds: 2));
          await peerDisconnected.future.timeout(const Duration(seconds: 2));
        } finally {
          acceptedSocket?.destroy();
          await serverSub.cancel();
          await server.close();
        }
      },
    );
  });
}
