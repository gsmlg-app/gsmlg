import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_vnc/app_vnc.dart';
import 'package:crypto/crypto.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:test/test.dart';

Uint8List _hexToBytes(String hex) {
  final clean = hex.replaceAll(RegExp(r'\s+'), '');
  final out = Uint8List(clean.length ~/ 2);
  for (var i = 0; i < out.length; i++) {
    out[i] = int.parse(clean.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return out;
}

Uint8List _aesEcbDecrypt(Uint8List ciphertext, Uint8List key) {
  final engine = AESEngine()..init(false, KeyParameter(key));
  final out = Uint8List(ciphertext.length);
  for (var offset = 0; offset < ciphertext.length; offset += 16) {
    engine.processBlock(ciphertext, offset, out, offset);
  }
  return out;
}

String _readNullTerminatedUtf8(Uint8List block, int start, int length) {
  var end = start;
  final limit = start + length;
  while (end < limit && block[end] != 0) {
    end++;
  }
  return utf8.decode(block.sublist(start, end));
}

final Uint8List _oakleyPrime128 = _hexToBytes(
  'FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD1'
  '29024E088A67CC74020BBEA63B139B22514A08798E3404DD'
  'EF9519B3CD3A431B302B0A6DF25F14374FE1356D6D51C245'
  'E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7ED'
  'EE386BFB5A899FA5AE9F24117C4B1FE649286651ECE65381'
  'FFFFFFFFFFFFFFFF',
);

Uint8List _buildServerInit({
  required int width,
  required int height,
  required String name,
}) {
  final nameBytes = utf8.encode(name);
  final header = ByteData(4)
    ..setUint16(0, width, Endian.big)
    ..setUint16(2, height, Endian.big);
  final nameLen = ByteData(4)..setUint32(0, nameBytes.length, Endian.big);
  final builder = BytesBuilder(copy: false)
    ..add(header.buffer.asUint8List())
    ..add(VncPixelFormat.rgba8888.toBytes())
    ..add(nameLen.buffer.asUint8List())
    ..add(nameBytes);
  return builder.takeBytes();
}

Future<void> _consumeInitialSetMessages(BufferedByteReader reader) async {
  // SetPixelFormat (20 bytes)
  await reader.readBytes(20);
  // SetEncodings header (4 bytes) + count * 4 bytes
  final header = await reader.readBytes(4);
  final count = (header[2] << 8) | header[3];
  await reader.readBytes(count * 4);
}

class _FakeMDnsClient extends MDnsClient {
  _FakeMDnsClient({
    this.startError,
    this.ptrRecords = const [],
    this.srvByName = const {},
    this.ipv4ByTarget = const {},
    this.ipv6ByTarget = const {},
    this.neverComplete = false,
    this.keepLookupStreamsOpenUntilTimeout = false,
  });

  final Object? startError;
  final List<PtrResourceRecord> ptrRecords;
  final Map<String, List<SrvResourceRecord>> srvByName;
  final Map<String, List<IPAddressResourceRecord>> ipv4ByTarget;
  final Map<String, List<IPAddressResourceRecord>> ipv6ByTarget;
  final bool neverComplete;
  final bool keepLookupStreamsOpenUntilTimeout;

  bool started = false;
  bool stopped = false;

  @override
  Future<void> start({
    InternetAddress? listenAddress,
    NetworkInterfacesFactory? interfacesFactory,
    int mDnsPort = 5353,
    InternetAddress? mDnsAddress,
    Function? onError,
  }) async {
    if (startError != null) {
      throw startError!;
    }
    started = true;
  }

  @override
  void stop() {
    stopped = true;
  }

  Stream<T> _streamForRecords<T extends ResourceRecord>(
    List<T> records,
    Duration timeout,
  ) {
    if (!keepLookupStreamsOpenUntilTimeout) {
      return Stream<T>.fromIterable(records);
    }
    late final StreamController<T> controller;
    Timer? closeTimer;
    controller = StreamController<T>(
      onListen: () {
        for (final record in records) {
          if (!controller.isClosed) {
            controller.add(record);
          }
        }
        closeTimer = Timer(timeout, () {
          if (!controller.isClosed) {
            controller.close();
          }
        });
      },
      onCancel: () {
        closeTimer?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Stream<T> lookup<T extends ResourceRecord>(
    ResourceRecordQuery query, {
    Duration timeout = const Duration(seconds: 5),
  }) {
    if (neverComplete) {
      return StreamController<T>().stream;
    }

    final key = query.fullyQualifiedName.endsWith('.')
        ? query.fullyQualifiedName.substring(
            0,
            query.fullyQualifiedName.length - 1,
          )
        : query.fullyQualifiedName;

    if (query.resourceRecordType == ResourceRecordType.serverPointer) {
      return _streamForRecords<T>(ptrRecords.cast<T>(), timeout);
    }
    if (query.resourceRecordType == ResourceRecordType.service) {
      return _streamForRecords<T>(
        (srvByName[key] ?? const []).cast<T>(),
        timeout,
      );
    }
    if (query.resourceRecordType == ResourceRecordType.addressIPv4) {
      return _streamForRecords<T>(
        (ipv4ByTarget[key] ?? const []).cast<T>(),
        timeout,
      );
    }
    if (query.resourceRecordType == ResourceRecordType.addressIPv6) {
      return _streamForRecords<T>(
        (ipv6ByTarget[key] ?? const []).cast<T>(),
        timeout,
      );
    }
    return Stream<T>.empty();
  }
}

void main() {
  group('VncIsolateClient', () {
    test(
      'connects over loopback RFB 003.889 Type 1, delivers 4x4 Raw frame, forwards input, and disconnects cleanly',
      () async {
        final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(server.close);

        // Build deterministic 4x4 Raw pixel data (wire alpha=0, client forces 0xFF).
        final wirePixels = Uint8List(4 * 4 * 4);
        final expectedRgba = Uint8List(4 * 4 * 4);
        for (var i = 0; i < 16; i++) {
          final r = (i * 15) & 0xFF;
          final g = (255 - i * 10) & 0xFF;
          final b = (i * 7 + 3) & 0xFF;
          wirePixels[i * 4] = r;
          wirePixels[i * 4 + 1] = g;
          wirePixels[i * 4 + 2] = b;
          wirePixels[i * 4 + 3] = 0;

          expectedRgba[i * 4] = r;
          expectedRgba[i * 4 + 1] = g;
          expectedRgba[i * 4 + 2] = b;
          expectedRgba[i * 4 + 3] = 0xFF;
        }

        final receivedPointer = Completer<Uint8List>();
        final receivedKey = Completer<Uint8List>();
        final receivedCutText = Completer<Uint8List>();
        final serverDone = Completer<void>();

        late StreamSubscription<Socket> serverSub;
        serverSub = server.listen((socket) async {
          final reader = BufferedByteReader(socket);
          try {
            socket.add(ascii.encode('RFB 003.889\n'));
            await socket.flush();
            final clientBanner = ascii.decode(await reader.readBytes(12));
            expect(clientBanner, 'RFB 003.008\n');

            // Offer Type 1 (None).
            socket.add([1, RfbSecurityType.none]);
            await socket.flush();
            expect(await reader.readUint8(), RfbSecurityType.none);

            // SecurityResult OK (4 zero bytes).
            socket.add([0, 0, 0, 0]);
            await socket.flush();

            // ClientInit.
            expect(await reader.readUint8(), 1);

            // ServerInit 4x4.
            socket.add(
              _buildServerInit(width: 4, height: 4, name: 'Mock Mac Mini'),
            );
            await socket.flush();

            await _consumeInitialSetMessages(reader);

            // Read initial FramebufferUpdateRequest (10 bytes).
            final initReq = await reader.readBytes(10);
            expect(initReq, equals([3, 0, 0, 0, 0, 0, 0, 4, 0, 4]));

            // Send 4x4 Raw FramebufferUpdate.
            final updateHeader = ByteData(16)
              ..setUint8(0, 0) // FramebufferUpdate
              ..setUint8(1, 0) // padding
              ..setUint16(2, 1, Endian.big) // 1 rect
              ..setUint16(4, 0, Endian.big) // x
              ..setUint16(6, 0, Endian.big) // y
              ..setUint16(8, 4, Endian.big) // w
              ..setUint16(10, 4, Endian.big) // h
              ..setInt32(12, RfbEncoding.raw, Endian.big);
            socket.add(updateHeader.buffer.asUint8List());
            socket.add(wirePixels);
            await socket.flush();

            // Read client messages until pointer, key, and cut text arrive.
            while (!receivedPointer.isCompleted ||
                !receivedKey.isCompleted ||
                !receivedCutText.isCompleted) {
              final msgType = await reader.readUint8();
              switch (msgType) {
                case 3:
                  // FramebufferUpdateRequest: 9 remaining bytes.
                  await reader.readBytes(9);
                case 4:
                  final rest = await reader.readBytes(7);
                  if (!receivedKey.isCompleted) {
                    receivedKey.complete(Uint8List.fromList([4, ...rest]));
                  }
                case 5:
                  final rest = await reader.readBytes(5);
                  if (!receivedPointer.isCompleted) {
                    receivedPointer.complete(Uint8List.fromList([5, ...rest]));
                  }
                case 6:
                  final padAndLen = await reader.readBytes(7);
                  final len = ByteData.sublistView(
                    padAndLen,
                    3,
                    7,
                  ).getUint32(0, Endian.big);
                  final textBytes = await reader.readBytes(len);
                  if (!receivedCutText.isCompleted) {
                    receivedCutText.complete(
                      Uint8List.fromList([6, ...padAndLen, ...textBytes]),
                    );
                  }
                default:
                  fail('Unexpected client message type: $msgType');
              }
            }
          } catch (_) {
            // Expected once client disconnects.
          } finally {
            await reader.dispose();
            await socket.close();
            if (!serverDone.isCompleted) {
              serverDone.complete();
            }
          }
        });
        addTearDown(() => serverSub.cancel());

        final client = VncIsolateClient();
        addTearDown(client.disconnect);

        final seenEvents = <VncClientEvent>[];
        final connectedCompleter = Completer<VncConnectedEvent>();
        final frameCompleter = Completer<VncFrameEvent>();
        final disconnectedCompleter = Completer<VncDisconnectedEvent>();

        final sub = client.events.listen((event) {
          seenEvents.add(event);
          if (event is VncConnectedEvent && !connectedCompleter.isCompleted) {
            connectedCompleter.complete(event);
          } else if (event is VncFrameEvent && !frameCompleter.isCompleted) {
            frameCompleter.complete(event);
          } else if (event is VncDisconnectedEvent &&
              !disconnectedCompleter.isCompleted) {
            disconnectedCompleter.complete(event);
          }
        });
        addTearDown(sub.cancel);

        await client.connect(
          VncConnectionConfig(
            host: InternetAddress.loopbackIPv4.address,
            port: server.port,
          ),
        );

        final connected = await connectedCompleter.future.timeout(
          const Duration(seconds: 5),
        );
        expect(
          connected.desktopInfo,
          const VncDesktopInfo(
            name: 'Mock Mac Mini',
            width: 4,
            height: 4,
            protocolVersion: 'RFB 003.889',
            securityType: RfbSecurityType.none,
          ),
        );

        final frameEvent = await frameCompleter.future.timeout(
          const Duration(seconds: 5),
        );
        expect(frameEvent.frame.width, 4);
        expect(frameEvent.frame.height, 4);
        expect(frameEvent.frame.rgbaPixels, equals(expectedRgba));

        // Verify Connecting -> Connected -> Frame ordering.
        expect(seenEvents[0], isA<VncConnectingEvent>());
        expect(seenEvents[1], isA<VncConnectedEvent>());
        expect(seenEvents[2], isA<VncFrameEvent>());

        // Send pointer, key, and clipboard text.
        client.sendPointerEvent(2, 3, 0x01);
        client.sendKeyEvent(0x0061, down: true);
        client.sendClipboardText('hello');

        expect(
          await receivedPointer.future.timeout(const Duration(seconds: 5)),
          equals([5, 1, 0, 2, 0, 3]),
        );
        expect(
          await receivedKey.future.timeout(const Duration(seconds: 5)),
          equals([4, 1, 0, 0, 0, 0, 0, 0x61]),
        );
        expect(
          await receivedCutText.future.timeout(const Duration(seconds: 5)),
          equals([6, 0, 0, 0, 0, 0, 0, 5, 0x68, 0x65, 0x6C, 0x6C, 0x6F]),
        );

        await client.disconnect().timeout(const Duration(seconds: 5));
        // Second call must be idempotent.
        await client.disconnect().timeout(const Duration(seconds: 5));
        await disconnectedCompleter.future.timeout(const Duration(seconds: 5));
        await serverDone.future.timeout(const Duration(seconds: 5));
      },
    );

    test(
      'emits VncAuthRequiredEvent for Type 30 ARD and completes handshake after submitCredentials',
      () async {
        final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(server.close);

        const generator = 2;
        final keyLength = _oakleyPrime128.length;
        final prime = ArdAuthCrypto.bytesToBigInt(_oakleyPrime128);
        final serverPriv = BigInt.parse(
          'ABCDEF0123456789ABCDEF0123456789',
          radix: 16,
        );
        final serverPubBytes = ArdAuthCrypto.bigIntToFixedBytes(
          BigInt.from(generator).modPow(serverPriv, prime),
          keyLength,
        );

        final verifiedCreds = Completer<(String, String)>();

        late StreamSubscription<Socket> serverSub;
        serverSub = server.listen((socket) async {
          final reader = BufferedByteReader(socket);
          try {
            socket.add(ascii.encode('RFB 003.889\n'));
            await socket.flush();
            await reader.readBytes(12);

            // Offer Type 30 (Apple ARD).
            socket.add([1, RfbSecurityType.appleArd]);
            await socket.flush();
            expect(await reader.readUint8(), RfbSecurityType.appleArd);

            // Send ARD DH challenge.
            final hdr = ByteData(4)
              ..setUint16(0, generator, Endian.big)
              ..setUint16(2, keyLength, Endian.big);
            socket.add(hdr.buffer.asUint8List());
            socket.add(_oakleyPrime128);
            socket.add(serverPubBytes);
            await socket.flush();

            // Read encrypted credentials (128B) + client public key (128B).
            final encryptedCreds = await reader.readBytes(128);
            final clientPubBytes = await reader.readBytes(keyLength);
            final sharedBytes = ArdAuthCrypto.bigIntToFixedBytes(
              ArdAuthCrypto.bytesToBigInt(
                clientPubBytes,
              ).modPow(serverPriv, prime),
              keyLength,
            );
            final aesKey = Uint8List.fromList(md5.convert(sharedBytes).bytes);
            final plaintext = _aesEcbDecrypt(encryptedCreds, aesKey);
            final user = _readNullTerminatedUtf8(plaintext, 0, 64);
            final pass = _readNullTerminatedUtf8(plaintext, 64, 64);
            if (!verifiedCreds.isCompleted) {
              verifiedCreds.complete((user, pass));
            }

            // SecurityResult OK.
            socket.add([0, 0, 0, 0]);
            await socket.flush();

            // ClientInit.
            await reader.readUint8();

            // ServerInit.
            socket.add(
              _buildServerInit(width: 8, height: 8, name: 'Mac Studio ARD'),
            );
            await socket.flush();

            await _consumeInitialSetMessages(reader);
            // Wait until client disconnects.
            await reader.readBytes(10);
          } catch (_) {
            // Expected on disconnect.
          } finally {
            await reader.dispose();
            await socket.close();
          }
        });
        addTearDown(() => serverSub.cancel());

        final client = VncIsolateClient();
        addTearDown(client.disconnect);

        final authRequiredCompleter = Completer<VncAuthRequiredEvent>();
        final connectedCompleter = Completer<VncConnectedEvent>();

        final sub = client.events.listen((event) {
          if (event is VncAuthRequiredEvent &&
              !authRequiredCompleter.isCompleted) {
            authRequiredCompleter.complete(event);
          } else if (event is VncConnectedEvent &&
              !connectedCompleter.isCompleted) {
            connectedCompleter.complete(event);
          }
        });
        addTearDown(sub.cancel);

        await client.connect(
          VncConnectionConfig(
            host: InternetAddress.loopbackIPv4.address,
            port: server.port,
          ),
        );

        final authEvent = await authRequiredCompleter.future.timeout(
          const Duration(seconds: 5),
        );
        expect(authEvent.securityType, RfbSecurityType.appleArd);
        expect(authEvent.requiresUsername, isTrue);

        client.submitCredentials(
          const VncCredentials(username: 'alice', password: 'mac-secret'),
        );

        final connected = await connectedCompleter.future.timeout(
          const Duration(seconds: 5),
        );
        expect(connected.desktopInfo.name, 'Mac Studio ARD');
        expect(connected.desktopInfo.securityType, RfbSecurityType.appleArd);

        final (user, pass) = await verifiedCreds.future.timeout(
          const Duration(seconds: 5),
        );
        expect(user, 'alice');
        expect(pass, 'mac-secret');

        await client.disconnect().timeout(const Duration(seconds: 5));
      },
    );

    test(
      'faithfully reconstructs VncUnsupportedSecurityTypeException across isolate boundary',
      () async {
        final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(server.close);

        late StreamSubscription<Socket> serverSub;
        serverSub = server.listen((socket) async {
          final reader = BufferedByteReader(socket);
          try {
            socket.add(ascii.encode('RFB 003.889\n'));
            await socket.flush();
            await reader.readBytes(12);
            // Only unsupported Apple security types.
            socket.add([2, 35, 36]);
            await socket.flush();
          } catch (_) {
            // Expected on close.
          } finally {
            await reader.dispose();
            await socket.close();
          }
        });
        addTearDown(() => serverSub.cancel());

        final client = VncIsolateClient();
        addTearDown(client.disconnect);

        final errorCompleter = Completer<VncErrorEvent>();
        final sub = client.events.listen((event) {
          if (event is VncErrorEvent && !errorCompleter.isCompleted) {
            errorCompleter.complete(event);
          }
        });
        addTearDown(sub.cancel);

        await client.connect(
          VncConnectionConfig(
            host: InternetAddress.loopbackIPv4.address,
            port: server.port,
          ),
        );

        final errorEvent = await errorCompleter.future.timeout(
          const Duration(seconds: 5),
        );
        expect(errorEvent.error, isA<VncUnsupportedSecurityTypeException>());
        final unsupported =
            errorEvent.error as VncUnsupportedSecurityTypeException;
        expect(unsupported.offeredTypes, equals([35, 36]));

        await client.disconnect().timeout(const Duration(seconds: 5));
      },
    );

    test(
      'throttles rapid frame updates with trailing flush so latest frame is never lost',
      () async {
        final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(server.close);

        Uint8List rawUpdate(int r, int g, int b) {
          final header = ByteData(16)
            ..setUint8(0, 0)
            ..setUint8(1, 0)
            ..setUint16(2, 1, Endian.big)
            ..setUint16(4, 0, Endian.big)
            ..setUint16(6, 0, Endian.big)
            ..setUint16(8, 2, Endian.big)
            ..setUint16(10, 2, Endian.big)
            ..setInt32(12, RfbEncoding.raw, Endian.big);
          final builder = BytesBuilder(copy: false)
            ..add(header.buffer.asUint8List());
          for (var i = 0; i < 4; i++) {
            builder.add([r, g, b, 0]);
          }
          return builder.takeBytes();
        }

        late StreamSubscription<Socket> serverSub;
        serverSub = server.listen((socket) async {
          final reader = BufferedByteReader(socket);
          try {
            socket.add(ascii.encode('RFB 003.889\n'));
            await socket.flush();
            await reader.readBytes(12);
            socket.add([1, RfbSecurityType.none]);
            await socket.flush();
            await reader.readUint8();
            socket.add([0, 0, 0, 0]);
            await socket.flush();
            await reader.readUint8();
            socket.add(_buildServerInit(width: 2, height: 2, name: 'Throttle'));
            await socket.flush();
            await _consumeInitialSetMessages(reader);

            // Initial request -> immediately send 3 back-to-back updates.
            await reader.readBytes(10);
            socket.add(rawUpdate(10, 0, 0));
            socket.add(rawUpdate(20, 0, 0));
            socket.add(rawUpdate(30, 40, 50));
            await socket.flush();

            // Wait for disconnect.
            await reader.readBytes(100);
          } catch (_) {
            // Expected on disconnect.
          } finally {
            await reader.dispose();
            await socket.close();
          }
        });
        addTearDown(() => serverSub.cancel());

        final client = VncIsolateClient(
          minFrameInterval: const Duration(milliseconds: 60),
        );
        addTearDown(client.disconnect);

        final frames = <VncFrameData>[];
        final finalFrameSeen = Completer<void>();
        final sub = client.events.listen((event) {
          if (event is VncFrameEvent) {
            frames.add(event.frame);
            if (event.frame.rgbaPixels[0] == 30 &&
                event.frame.rgbaPixels[1] == 40 &&
                event.frame.rgbaPixels[2] == 50 &&
                !finalFrameSeen.isCompleted) {
              finalFrameSeen.complete();
            }
          }
        });
        addTearDown(sub.cancel);

        await client.connect(
          VncConnectionConfig(
            host: InternetAddress.loopbackIPv4.address,
            port: server.port,
          ),
        );

        await finalFrameSeen.future.timeout(const Duration(seconds: 5));
        expect(
          frames.last.rgbaPixels.sublist(0, 4),
          equals([30, 40, 50, 0xFF]),
        );

        await client.disconnect().timeout(const Duration(seconds: 5));
      },
    );

    test('throws StateError when connect is called twice', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(server.close);

      final client = VncIsolateClient();
      addTearDown(client.disconnect);

      final config = VncConnectionConfig(
        host: InternetAddress.loopbackIPv4.address,
        port: server.port,
      );
      await client.connect(config);

      await expectLater(client.connect(config), throwsA(isA<StateError>()));
      await client.disconnect().timeout(const Duration(seconds: 5));
    });

    test(
      'disconnect during auth/handshake shuts down cleanly without emitting a late VncErrorEvent',
      () async {
        final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(server.close);

        late StreamSubscription<Socket> serverSub;
        serverSub = server.listen((socket) async {
          final reader = BufferedByteReader(socket);
          try {
            socket.add(ascii.encode('RFB 003.008\n'));
            await socket.flush();
            await reader.readBytes(12);
            socket.add([1, RfbSecurityType.vncAuth]);
            await socket.flush();
            await reader.readUint8();
            socket.add(Uint8List(16)); // 16-byte DES challenge
            await socket.flush();
            // Wait until client disconnects while waiting for credentials.
            await reader.readBytes(16);
          } catch (_) {
            // Expected on disconnect.
          } finally {
            await reader.dispose();
            await socket.close();
          }
        });
        addTearDown(() => serverSub.cancel());

        final client = VncIsolateClient();
        addTearDown(client.disconnect);

        final events = <VncClientEvent>[];
        final authRequired = Completer<VncAuthRequiredEvent>();
        final disconnected = Completer<VncDisconnectedEvent>();

        final sub = client.events.listen((event) {
          events.add(event);
          if (event is VncAuthRequiredEvent && !authRequired.isCompleted) {
            authRequired.complete(event);
          } else if (event is VncDisconnectedEvent &&
              !disconnected.isCompleted) {
            disconnected.complete(event);
          }
        });
        addTearDown(sub.cancel);

        await client.connect(
          VncConnectionConfig(
            host: InternetAddress.loopbackIPv4.address,
            port: server.port,
          ),
        );

        final authEvent = await authRequired.future.timeout(
          const Duration(seconds: 5),
        );
        expect(authEvent.securityType, RfbSecurityType.vncAuth);
        expect(authEvent.requiresUsername, isFalse);

        await client.disconnect().timeout(const Duration(seconds: 5));
        await disconnected.future.timeout(const Duration(seconds: 5));

        expect(events.whereType<VncErrorEvent>(), isEmpty);
        expect(events.whereType<VncDisconnectedEvent>(), hasLength(1));
      },
    );

    test(
      'cancelCredentials emits VncErrorEvent with VncAuthenticationException',
      () async {
        final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(server.close);

        late StreamSubscription<Socket> serverSub;
        serverSub = server.listen((socket) async {
          final reader = BufferedByteReader(socket);
          try {
            socket.add(ascii.encode('RFB 003.008\n'));
            await socket.flush();
            await reader.readBytes(12);
            socket.add([1, RfbSecurityType.vncAuth]);
            await socket.flush();
            await reader.readUint8();
            socket.add(Uint8List(16));
            await socket.flush();
            await reader.readBytes(16);
          } catch (_) {
            // Expected when client aborts auth.
          } finally {
            await reader.dispose();
            await socket.close();
          }
        });
        addTearDown(() => serverSub.cancel());

        final client = VncIsolateClient();
        addTearDown(client.disconnect);

        final authRequired = Completer<void>();
        final errorEvent = Completer<VncErrorEvent>();
        final sub = client.events.listen((event) {
          if (event is VncAuthRequiredEvent && !authRequired.isCompleted) {
            authRequired.complete();
          } else if (event is VncErrorEvent && !errorEvent.isCompleted) {
            errorEvent.complete(event);
          }
        });
        addTearDown(sub.cancel);

        await client.connect(
          VncConnectionConfig(
            host: InternetAddress.loopbackIPv4.address,
            port: server.port,
          ),
        );

        await authRequired.future.timeout(const Duration(seconds: 5));
        client.cancelCredentials();

        final error = await errorEvent.future.timeout(
          const Duration(seconds: 5),
        );
        expect(error.error, isA<VncAuthenticationException>());
        await client.disconnect().timeout(const Duration(seconds: 5));
      },
    );

    test(
      'forwards VncResizedEvent, VncCursorEvent, VncClipboardEvent, and requestFullRefresh over isolate bridge',
      () async {
        final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(server.close);

        final fullRefreshReceived = Completer<Uint8List>();

        late StreamSubscription<Socket> serverSub;
        serverSub = server.listen((socket) async {
          final reader = BufferedByteReader(socket);
          try {
            socket.add(ascii.encode('RFB 003.889\n'));
            await socket.flush();
            await reader.readBytes(12);
            socket.add([1, RfbSecurityType.none]);
            await socket.flush();
            await reader.readUint8();
            socket.add([0, 0, 0, 0]);
            await socket.flush();
            await reader.readUint8();
            socket.add(_buildServerInit(width: 2, height: 2, name: 'Events'));
            await socket.flush();
            await _consumeInitialSetMessages(reader);

            // Initial non-incremental update request (2x2).
            await reader.readBytes(10);

            // Send FramebufferUpdate containing DesktopSize (6x5) + Cursor (1x1, hotspot 1,0).
            final update = BytesBuilder(copy: false);
            final header = ByteData(4)
              ..setUint8(0, 0)
              ..setUint8(1, 0)
              ..setUint16(2, 2, Endian.big);
            update.add(header.buffer.asUint8List());

            final resizeRect = ByteData(12)
              ..setUint16(0, 0, Endian.big)
              ..setUint16(2, 0, Endian.big)
              ..setUint16(4, 6, Endian.big)
              ..setUint16(6, 5, Endian.big)
              ..setInt32(8, RfbEncoding.desktopSize, Endian.big);
            update.add(resizeRect.buffer.asUint8List());

            final cursorRect = ByteData(12)
              ..setUint16(0, 1, Endian.big) // hotspotX=1
              ..setUint16(2, 0, Endian.big) // hotspotY=0
              ..setUint16(4, 1, Endian.big)
              ..setUint16(6, 1, Endian.big)
              ..setInt32(8, RfbEncoding.cursor, Endian.big);
            update.add(cursorRect.buffer.asUint8List());
            update.add([0x12, 0x34, 0x56, 0x00]); // pixel
            update.add([0x80]); // opaque mask bit

            // Follow with ServerCutText ("clip").
            final cut = ByteData(8)
              ..setUint8(0, 3)
              ..setUint32(4, 4, Endian.big);
            update.add(cut.buffer.asUint8List());
            update.add(latin1.encode('clip'));

            socket.add(update.takeBytes());
            await socket.flush();

            // Next request from session loop is post-resize non-incremental (6x5).
            final postResizeReq = await reader.readBytes(10);
            expect(postResizeReq, equals([3, 0, 0, 0, 0, 0, 0, 6, 0, 5]));

            // Now wait for explicit requestFullRefresh() from client.
            final manualRefresh = await reader.readBytes(10);
            if (!fullRefreshReceived.isCompleted) {
              fullRefreshReceived.complete(manualRefresh);
            }
          } catch (_) {
            // Expected on disconnect.
          } finally {
            await reader.dispose();
            await socket.close();
          }
        });
        addTearDown(() => serverSub.cancel());

        final client = VncIsolateClient();
        addTearDown(client.disconnect);

        final resizedCompleter = Completer<VncResizedEvent>();
        final cursorCompleter = Completer<VncCursorEvent>();
        final clipboardCompleter = Completer<VncClipboardEvent>();

        final sub = client.events.listen((event) {
          if (event is VncResizedEvent && !resizedCompleter.isCompleted) {
            resizedCompleter.complete(event);
          } else if (event is VncCursorEvent && !cursorCompleter.isCompleted) {
            cursorCompleter.complete(event);
          } else if (event is VncClipboardEvent &&
              !clipboardCompleter.isCompleted) {
            clipboardCompleter.complete(event);
          }
        });
        addTearDown(sub.cancel);

        await client.connect(
          VncConnectionConfig(
            host: InternetAddress.loopbackIPv4.address,
            port: server.port,
          ),
        );

        final resized = await resizedCompleter.future.timeout(
          const Duration(seconds: 5),
        );
        expect(resized.width, 6);
        expect(resized.height, 5);

        final cursorEvent = await cursorCompleter.future.timeout(
          const Duration(seconds: 5),
        );
        expect(cursorEvent.cursor.width, 1);
        expect(cursorEvent.cursor.height, 1);
        expect(cursorEvent.cursor.hotspotX, 1);
        expect(cursorEvent.cursor.hotspotY, 0);
        expect(cursorEvent.cursor.rgbaPixels, equals([0x12, 0x34, 0x56, 0xFF]));

        final clipboard = await clipboardCompleter.future.timeout(
          const Duration(seconds: 5),
        );
        expect(clipboard.text, 'clip');

        client.requestFullRefresh();
        expect(
          await fullRefreshReceived.future.timeout(const Duration(seconds: 5)),
          equals([3, 0, 0, 0, 0, 0, 0, 6, 0, 5]),
        );

        await client.disconnect().timeout(const Duration(seconds: 5));
      },
    );

    test(
      'setViewOnly live-gates pointer and key events while allowing clipboard',
      () async {
        final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(server.close);

        final receivedPointers = <Uint8List>[];
        final receivedKeys = <Uint8List>[];
        final firstClipboard = Completer<String>();
        final interactivePointer = Completer<Uint8List>();
        final interactiveKey = Completer<Uint8List>();
        final secondClipboard = Completer<String>();

        late StreamSubscription<Socket> serverSub;
        serverSub = server.listen((socket) async {
          final reader = BufferedByteReader(socket);
          try {
            socket.add(ascii.encode('RFB 003.889\n'));
            await socket.flush();
            await reader.readBytes(12);
            socket.add([1, RfbSecurityType.none]);
            await socket.flush();
            await reader.readUint8();
            socket.add([0, 0, 0, 0]);
            await socket.flush();
            await reader.readUint8();
            socket.add(_buildServerInit(width: 4, height: 4, name: 'ViewOnly'));
            await socket.flush();
            await _consumeInitialSetMessages(reader);

            while (!secondClipboard.isCompleted) {
              final msgType = await reader.readUint8();
              switch (msgType) {
                case 3:
                  await reader.readBytes(9);
                case 4:
                  final rest = await reader.readBytes(7);
                  final bytes = Uint8List.fromList([4, ...rest]);
                  receivedKeys.add(bytes);
                  if (!interactiveKey.isCompleted) {
                    interactiveKey.complete(bytes);
                  }
                case 5:
                  final rest = await reader.readBytes(5);
                  final bytes = Uint8List.fromList([5, ...rest]);
                  receivedPointers.add(bytes);
                  if (!interactivePointer.isCompleted) {
                    interactivePointer.complete(bytes);
                  }
                case 6:
                  final padAndLen = await reader.readBytes(7);
                  final len = ByteData.sublistView(
                    padAndLen,
                    3,
                    7,
                  ).getUint32(0, Endian.big);
                  final text = latin1.decode(await reader.readBytes(len));
                  if (!firstClipboard.isCompleted) {
                    firstClipboard.complete(text);
                  } else if (!secondClipboard.isCompleted) {
                    secondClipboard.complete(text);
                  }
                default:
                  fail('Unexpected client message type: $msgType');
              }
            }
          } catch (_) {
            // Expected on disconnect.
          } finally {
            await reader.dispose();
            await socket.close();
          }
        });
        addTearDown(() => serverSub.cancel());

        final client = VncIsolateClient();
        addTearDown(client.disconnect);

        final connected = Completer<void>();
        final sub = client.events.listen((event) {
          if (event is VncConnectedEvent && !connected.isCompleted) {
            connected.complete();
          }
        });
        addTearDown(sub.cancel);

        // Start in view-only mode.
        await client.connect(
          VncConnectionConfig(
            host: InternetAddress.loopbackIPv4.address,
            port: server.port,
            viewOnly: true,
          ),
        );
        await connected.future.timeout(const Duration(seconds: 5));

        // Pointer & key must be dropped; clipboard must pass through.
        client.sendPointerEvent(1, 1, 1);
        client.sendKeyEvent(0x0061, down: true);
        client.sendClipboardText('clip-1');

        expect(
          await firstClipboard.future.timeout(const Duration(seconds: 5)),
          'clip-1',
        );
        expect(receivedPointers, isEmpty);
        expect(receivedKeys, isEmpty);

        // Live-disable view-only: pointer & key should now be forwarded.
        client.setViewOnly(false);
        client.sendPointerEvent(2, 3, 1);
        client.sendKeyEvent(0x0062, down: true);

        expect(
          await interactivePointer.future.timeout(const Duration(seconds: 5)),
          equals([5, 1, 0, 2, 0, 3]),
        );
        expect(
          await interactiveKey.future.timeout(const Duration(seconds: 5)),
          equals([4, 1, 0, 0, 0, 0, 0, 0x62]),
        );

        // Live-re-enable view-only: subsequent pointer & key dropped, clipboard still allowed.
        client.setViewOnly(true);
        client.sendPointerEvent(3, 3, 1);
        client.sendKeyEvent(0x0063, down: true);
        client.sendClipboardText('clip-2');

        expect(
          await secondClipboard.future.timeout(const Duration(seconds: 5)),
          'clip-2',
        );
        expect(receivedPointers, hasLength(1));
        expect(receivedKeys, hasLength(1));

        await client.disconnect().timeout(const Duration(seconds: 5));
      },
    );

    test(
      'forwards ExtendedDesktopSize screens in VncResizedEvent and scopes updates via setActiveRegion',
      () async {
        final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(server.close);

        final scopedReqCompleter = Completer<Uint8List>();
        final fullReqCompleter = Completer<Uint8List>();

        late StreamSubscription<Socket> serverSub;
        serverSub = server.listen((socket) async {
          final reader = BufferedByteReader(socket);
          try {
            socket.add(ascii.encode('RFB 003.889\n'));
            await socket.flush();
            await reader.readBytes(12);
            socket.add([1, RfbSecurityType.none]);
            await socket.flush();
            await reader.readUint8();
            socket.add([0, 0, 0, 0]);
            await socket.flush();
            await reader.readUint8();
            socket.add(_buildServerInit(width: 4, height: 4, name: 'Multi'));
            await socket.flush();
            await _consumeInitialSetMessages(reader);

            // Initial non-incremental update request (4x4).
            await reader.readBytes(10);

            // Send ExtendedDesktopSize (4480x1440) with 2 screens.
            final update = BytesBuilder(copy: false);
            final header = ByteData(4)
              ..setUint8(0, 0)
              ..setUint8(1, 0)
              ..setUint16(2, 1, Endian.big);
            update.add(header.buffer.asUint8List());

            final edsRect = ByteData(12)
              ..setUint16(0, 0, Endian.big)
              ..setUint16(2, 0, Endian.big)
              ..setUint16(4, 4480, Endian.big)
              ..setUint16(6, 1440, Endian.big)
              ..setInt32(8, RfbEncoding.extendedDesktopSize, Endian.big);
            update.add(edsRect.buffer.asUint8List());
            update.add([2, 0, 0, 0]); // numScreens=2 + padding

            final s1 = ByteData(16)
              ..setUint32(0, 1, Endian.big)
              ..setUint16(4, 0, Endian.big)
              ..setUint16(6, 0, Endian.big)
              ..setUint16(8, 1920, Endian.big)
              ..setUint16(10, 1080, Endian.big)
              ..setUint32(12, 0, Endian.big);
            final s2 = ByteData(16)
              ..setUint32(0, 2, Endian.big)
              ..setUint16(4, 1920, Endian.big)
              ..setUint16(6, 0, Endian.big)
              ..setUint16(8, 2560, Endian.big)
              ..setUint16(10, 1440, Endian.big)
              ..setUint32(12, 1, Endian.big);
            update.add(s1.buffer.asUint8List());
            update.add(s2.buffer.asUint8List());

            socket.add(update.takeBytes());
            await socket.flush();

            // Post-resize non-incremental request for full 4480x1440.
            final postResizeReq = await reader.readBytes(10);
            expect(
              postResizeReq,
              equals([3, 0, 0, 0, 0, 0, 0x11, 0x80, 0x05, 0xA0]),
            );

            // Next request should be scoped to monitor 2 (1920, 0, 2560, 1440).
            final scopedReq = await reader.readBytes(10);
            if (!scopedReqCompleter.isCompleted) {
              scopedReqCompleter.complete(scopedReq);
            }

            // Next request after setActiveRegion(null) restores full 4480x1440.
            final fullReq = await reader.readBytes(10);
            if (!fullReqCompleter.isCompleted) {
              fullReqCompleter.complete(fullReq);
            }
          } catch (_) {
            // Expected on disconnect.
          } finally {
            await reader.dispose();
            await socket.close();
          }
        });
        addTearDown(() => serverSub.cancel());

        final client = VncIsolateClient();
        addTearDown(client.disconnect);

        final resizedCompleter = Completer<VncResizedEvent>();
        final sub = client.events.listen((event) {
          if (event is VncResizedEvent && !resizedCompleter.isCompleted) {
            resizedCompleter.complete(event);
          }
        });
        addTearDown(sub.cancel);

        await client.connect(
          VncConnectionConfig(
            host: InternetAddress.loopbackIPv4.address,
            port: server.port,
          ),
        );

        final resized = await resizedCompleter.future.timeout(
          const Duration(seconds: 5),
        );
        expect(resized.width, 4480);
        expect(resized.height, 1440);
        expect(
          resized.screens,
          equals(const [
            VncScreenInfo(
              id: 1,
              x: 0,
              y: 0,
              width: 1920,
              height: 1080,
              flags: 0,
            ),
            VncScreenInfo(
              id: 2,
              x: 1920,
              y: 0,
              width: 2560,
              height: 1440,
              flags: 1,
            ),
          ]),
        );

        // Select second screen over isolate boundary.
        client.setActiveRegion(resized.screens[1]);
        // 1920 = 0x0780, 2560 = 0x0A00, 1440 = 0x05A0
        expect(
          await scopedReqCompleter.future.timeout(const Duration(seconds: 5)),
          equals([3, 0, 0x07, 0x80, 0, 0, 0x0A, 0x00, 0x05, 0xA0]),
        );

        // Clear active region to restore full desktop updates.
        client.setActiveRegion(null);
        // 4480 = 0x1180, 1440 = 0x05A0
        expect(
          await fullReqCompleter.future.timeout(const Duration(seconds: 5)),
          equals([3, 0, 0, 0, 0, 0, 0x11, 0x80, 0x05, 0xA0]),
        );

        await client.disconnect().timeout(const Duration(seconds: 5));
      },
    );
  });

  group('VncMdnsDiscovery', () {
    test(
      'discovers, resolves IPv4/IPv6, strips suffix/dots, deduplicates by id, and stops client',
      () async {
        final fakeClient = _FakeMDnsClient(
          ptrRecords: [
            const PtrResourceRecord(
              VncMdnsDiscovery.serviceName,
              0,
              domainName: 'Mac Studio._rfb._tcp.local.',
            ),
            // Duplicate pointer resolving to same host:port -> must deduplicate.
            const PtrResourceRecord(
              VncMdnsDiscovery.serviceName,
              0,
              domainName: 'Mac Studio._rfb._tcp.local',
            ),
          ],
          srvByName: {
            'Mac Studio._rfb._tcp.local': const [
              SrvResourceRecord(
                'Mac Studio._rfb._tcp.local',
                0,
                target: 'mac-studio.local.',
                port: 5900,
                priority: 0,
                weight: 0,
              ),
            ],
          },
          ipv4ByTarget: {
            'mac-studio.local': [
              IPAddressResourceRecord(
                'mac-studio.local',
                0,
                address: InternetAddress('192.168.1.42'),
              ),
            ],
          },
          ipv6ByTarget: {
            'mac-studio.local': [
              IPAddressResourceRecord(
                'mac-studio.local',
                0,
                address: InternetAddress('fe80::1'),
              ),
            ],
          },
        );

        final discovery = VncMdnsDiscovery(clientFactory: () => fakeClient);
        final hosts = await discovery
            .discover(timeout: const Duration(seconds: 2))
            .toList();

        expect(fakeClient.started, isTrue);
        expect(fakeClient.stopped, isTrue);
        expect(hosts, hasLength(1));
        expect(
          hosts.first,
          const VncDiscoveredHost(
            name: 'Mac Studio',
            host: 'mac-studio.local',
            port: 5900,
            addresses: ['192.168.1.42', 'fe80::1'],
          ),
        );
      },
    );

    test(
      'completes cleanly within timeout and calls stop even when lookups hang',
      () async {
        final fakeClient = _FakeMDnsClient(neverComplete: true);
        final discovery = VncMdnsDiscovery(clientFactory: () => fakeClient);

        final hosts = await discovery
            .discover(timeout: const Duration(milliseconds: 120))
            .toList()
            .timeout(const Duration(seconds: 2));

        expect(hosts, isEmpty);
        expect(fakeClient.started, isTrue);
        expect(fakeClient.stopped, isTrue);
      },
    );

    test('swallows platform socket errors without throwing', () async {
      final fakeClient = _FakeMDnsClient(
        startError: const SocketException('No multicast interface'),
      );
      final discovery = VncMdnsDiscovery(clientFactory: () => fakeClient);

      final hosts = await discovery
          .discover(timeout: const Duration(milliseconds: 100))
          .toList();

      expect(hosts, isEmpty);
      expect(fakeClient.stopped, isTrue);
    });

    test(
      'starts lazily only when the returned stream is listened to',
      () async {
        final fakeClient = _FakeMDnsClient();
        final discovery = VncMdnsDiscovery(clientFactory: () => fakeClient);

        final stream = discovery.discover(
          timeout: const Duration(milliseconds: 200),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(fakeClient.started, isFalse);

        await stream.toList();
        expect(fakeClient.started, isTrue);
        expect(fakeClient.stopped, isTrue);
      },
    );

    test(
      'emits IPv4-only Mac promptly when lookup streams stay open until timeout and supports take(1) cancellation',
      () async {
        final fakeClient = _FakeMDnsClient(
          keepLookupStreamsOpenUntilTimeout: true,
          ptrRecords: [
            const PtrResourceRecord(
              VncMdnsDiscovery.serviceName,
              0,
              domainName: 'MacBook Pro._rfb._tcp.local.',
            ),
          ],
          srvByName: {
            'MacBook Pro._rfb._tcp.local': const [
              SrvResourceRecord(
                'MacBook Pro._rfb._tcp.local',
                0,
                target: 'macbook-pro.local.',
                port: 5900,
                priority: 0,
                weight: 0,
              ),
            ],
          },
          ipv4ByTarget: {
            'macbook-pro.local': [
              IPAddressResourceRecord(
                'macbook-pro.local',
                0,
                address: InternetAddress('192.168.1.99'),
              ),
            ],
          },
          // No IPv6 AAAA records: AAAA stream emits nothing and stays open.
          ipv6ByTarget: const {},
        );

        final discovery = VncMdnsDiscovery(clientFactory: () => fakeClient);
        final sw = Stopwatch()..start();

        // Overall timeout is 5s, but take(1) should emit and stop well under 1.5s.
        final hosts = await discovery
            .discover(timeout: const Duration(seconds: 5))
            .take(1)
            .toList()
            .timeout(const Duration(seconds: 2));

        sw.stop();
        expect(hosts, hasLength(1));
        expect(
          hosts.first,
          const VncDiscoveredHost(
            name: 'MacBook Pro',
            host: 'macbook-pro.local',
            port: 5900,
            addresses: ['192.168.1.99'],
          ),
        );
        expect(sw.elapsedMilliseconds, lessThan(1500));

        // Allow onCancel teardown microtask to complete.
        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(fakeClient.stopped, isTrue);
      },
    );

    test(
      'preserves already-resolved host when overall timeout fires during open lookup streams',
      () async {
        final fakeClient = _FakeMDnsClient(
          keepLookupStreamsOpenUntilTimeout: true,
          ptrRecords: [
            const PtrResourceRecord(
              VncMdnsDiscovery.serviceName,
              0,
              domainName: 'iMac._rfb._tcp.local.',
            ),
          ],
          srvByName: {
            'iMac._rfb._tcp.local': const [
              SrvResourceRecord(
                'iMac._rfb._tcp.local',
                0,
                target: 'imac.local.',
                port: 5900,
                priority: 0,
                weight: 0,
              ),
            ],
          },
          ipv4ByTarget: {
            'imac.local': [
              IPAddressResourceRecord(
                'imac.local',
                0,
                address: InternetAddress('10.0.0.55'),
              ),
            ],
          },
          ipv6ByTarget: const {},
        );

        // Settle delay is 400ms while overall timeout is 200ms, so the overall
        // timeout deterministically fires while lookup streams are still open.
        final discovery = VncMdnsDiscovery(
          clientFactory: () => fakeClient,
          postFirstRecordSettle: const Duration(milliseconds: 400),
        );
        final hosts = await discovery
            .discover(timeout: const Duration(milliseconds: 200))
            .toList()
            .timeout(const Duration(seconds: 2));

        expect(hosts, hasLength(1));
        expect(hosts.first.name, 'iMac');
        expect(hosts.first.host, 'imac.local');
        expect(hosts.first.port, 5900);
        expect(fakeClient.stopped, isTrue);
      },
    );
  });
}
