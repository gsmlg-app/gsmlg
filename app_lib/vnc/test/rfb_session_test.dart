import 'dart:async';
import 'dart:typed_data';

import 'package:app_vnc/app_vnc.dart';
import 'package:test/test.dart';

class _InMemoryVncPipe implements VncTransport {
  final StreamController<Uint8List> _serverToClient =
      StreamController<Uint8List>();
  final StreamController<Uint8List> _clientToServer =
      StreamController<Uint8List>();
  final Completer<void> _doneCompleter = Completer<void>();

  late final BufferedByteReader serverReader = BufferedByteReader(
    _clientToServer.stream,
  );
  late final BufferedByteReader clientReader = BufferedByteReader(
    _serverToClient.stream,
  );

  bool _closed = false;

  void serverSend(List<int> bytes) {
    if (!_serverToClient.isClosed) {
      _serverToClient.add(Uint8List.fromList(bytes));
    }
  }

  void serverSendUint16(int value) {
    final bd = ByteData(2)..setUint16(0, value, Endian.big);
    serverSend(bd.buffer.asUint8List());
  }

  void serverSendUint32(int value) {
    final bd = ByteData(4)..setUint32(0, value, Endian.big);
    serverSend(bd.buffer.asUint8List());
  }

  void serverSendInt32(int value) {
    final bd = ByteData(4)..setInt32(0, value, Endian.big);
    serverSend(bd.buffer.asUint8List());
  }

  void serverSendRectHeader({
    required int x,
    required int y,
    required int width,
    required int height,
    required int encoding,
  }) {
    final bd = ByteData(12)
      ..setUint16(0, x, Endian.big)
      ..setUint16(2, y, Endian.big)
      ..setUint16(4, width, Endian.big)
      ..setUint16(6, height, Endian.big)
      ..setInt32(8, encoding, Endian.big);
    serverSend(bd.buffer.asUint8List());
  }

  Future<void> dispose() async {
    await clientReader.dispose();
    await serverReader.dispose();
    await close();
  }

  @override
  Stream<Uint8List> get stream => _serverToClient.stream;

  @override
  void add(Uint8List data) {
    if (_closed) {
      throw StateError('Transport is closed');
    }
    _clientToServer.add(Uint8List.fromList(data));
  }

  @override
  Future<void> flush() async {}

  @override
  Future<void> get done => _doneCompleter.future;

  @override
  Future<void> close() async {
    if (_closed) {
      return;
    }
    _closed = true;
    if (!_serverToClient.isClosed) {
      await _serverToClient.close();
    }
    if (!_clientToServer.isClosed) {
      await _clientToServer.close();
    }
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete();
    }
  }
}

void main() {
  group('RfbSession client-to-server wire writers', () {
    late _InMemoryVncPipe pipe;
    late VncFramebuffer framebuffer;
    late RfbSession session;

    setUp(() {
      pipe = _InMemoryVncPipe();
      framebuffer = VncFramebuffer(640, 480);
      session = RfbSession(
        transport: pipe,
        reader: pipe.clientReader,
        framebuffer: framebuffer,
      );
    });

    tearDown(() async {
      await pipe.dispose();
    });

    test(
      'requestFramebufferUpdate encodes default full framebuffer dimensions',
      () async {
        session.requestFramebufferUpdate(incremental: false);

        final bytes = await pipe.serverReader.readBytes(10);
        expect(
          bytes,
          equals([
            3, 0, // type=3, incremental=0
            0, 0, // x=0
            0, 0, // y=0
            0x02, 0x80, // width=640
            0x01, 0xE0, // height=480
          ]),
        );
      },
    );

    test(
      'requestFramebufferUpdate encodes explicit sub-rectangle and incremental flag',
      () async {
        session.requestFramebufferUpdate(
          incremental: true,
          x: 10,
          y: 20,
          width: 300,
          height: 200,
        );

        final bytes = await pipe.serverReader.readBytes(10);
        expect(
          bytes,
          equals([
            3, 1, // type=3, incremental=1
            0, 10, // x=10
            0, 20, // y=20
            0x01, 0x2C, // width=300
            0x00, 0xC8, // height=200
          ]),
        );
      },
    );

    test('sendKeyEvent encodes key down and key up messages', () async {
      session.sendKeyEvent(0xFF0D, down: true);
      session.sendKeyEvent(0x0041, down: false);

      final downBytes = await pipe.serverReader.readBytes(8);
      final upBytes = await pipe.serverReader.readBytes(8);

      expect(downBytes, equals([4, 1, 0, 0, 0x00, 0x00, 0xFF, 0x0D]));
      expect(upBytes, equals([4, 0, 0, 0, 0x00, 0x00, 0x00, 0x41]));
    });

    test(
      'sendPointerEvent encodes coordinates, clamps to framebuffer bounds, and masks buttons',
      () async {
        session.sendPointerEvent(100, 250, 0x01);
        session.sendPointerEvent(-50, -1, 0x105);
        session.sendPointerEvent(9999, 9999, 0x04);

        final normal = await pipe.serverReader.readBytes(6);
        final lowClamped = await pipe.serverReader.readBytes(6);
        final highClamped = await pipe.serverReader.readBytes(6);

        expect(normal, equals([5, 0x01, 0x00, 100, 0x00, 250]));
        expect(lowClamped, equals([5, 0x05, 0x00, 0x00, 0x00, 0x00]));
        // 639 = 0x027F, 479 = 0x01DF
        expect(highClamped, equals([5, 0x04, 0x02, 0x7F, 0x01, 0xDF]));
      },
    );

    test(
      'sendClientCutText preserves Latin-1 bytes and replaces non-Latin-1 with "?"',
      () async {
        session.sendClientCutText('caf\u00e9 \u4e2d\u6587!');

        final header = await pipe.serverReader.readBytes(8);
        expect(header.sublist(0, 4), equals([6, 0, 0, 0]));
        final length = ByteData.sublistView(header, 4, 8).getUint32(0);
        expect(length, 8);

        final body = await pipe.serverReader.readBytes(length);
        // c, a, f, 0xE9, ' ', '?', '?', '!'
        expect(body, equals([0x63, 0x61, 0x66, 0xE9, 0x20, 0x3F, 0x3F, 0x21]));
      },
    );

    test('sendClientCutText bounds payload to 1 MiB', () async {
      final huge = 'A' * (RfbSession.maxCutTextLength + 128);
      session.sendClientCutText(huge);

      final header = await pipe.serverReader.readBytes(8);
      expect(header.sublist(0, 4), equals([6, 0, 0, 0]));
      final length = ByteData.sublistView(header, 4, 8).getUint32(0);
      expect(length, RfbSession.maxCutTextLength);
    });
  });

  group('RfbSession server-to-client message loop', () {
    late _InMemoryVncPipe pipe;
    late VncFramebuffer framebuffer;
    late RfbSession session;

    setUp(() {
      pipe = _InMemoryVncPipe();
      framebuffer = VncFramebuffer(2, 2);
      session = RfbSession(
        transport: pipe,
        reader: pipe.clientReader,
        framebuffer: framebuffer,
      );
    });

    tearDown(() async {
      await pipe.dispose();
    });

    test(
      'handles Raw, DesktopSize, Cursor, LastRect, SetColourMapEntries, Bell, and ServerCutText',
      () async {
        var stop = false;
        final eventOrder = <String>[];
        final resizedTo = <(int, int)>[];
        final cursors = <VncCursorData>[];
        final cutTexts = <String>[];
        var bellCount = 0;
        var frameCount = 0;

        final loopFuture = session.runMessageLoop(
          onDesktopResized:
              (
                w,
                h,
                screens, {
                hasScreens = false,
                hasCurrentDisplayId = false,
                currentDisplayId,
              }) {
                expect(hasScreens, isFalse);
                eventOrder.add('resize:${w}x$h');
                resizedTo.add((w, h));
              },
          onCursorUpdated: (cursor) {
            eventOrder.add('cursor:${cursor.width}x${cursor.height}');
            cursors.add(cursor);
          },
          onFrameUpdated: () {
            frameCount++;
            eventOrder.add('frame:$frameCount');
          },
          onServerCutText: (text) {
            eventOrder.add('cut:$text');
            cutTexts.add(text);
            stop = true;
          },
          onBell: () {
            bellCount++;
            eventOrder.add('bell');
          },
          shouldStop: () => stop,
        );

        // 1. Initial non-incremental FramebufferUpdateRequest (2x2).
        final req1 = await pipe.serverReader.readBytes(10);
        expect(req1, equals([3, 0, 0, 0, 0, 0, 0, 2, 0, 2]));

        // Send FramebufferUpdate with 1 Raw rect (1x1 at (1, 0)).
        pipe.serverSend([0, 0]); // type=0, padding=0
        pipe.serverSendUint16(1); // numRects=1
        pipe.serverSendRectHeader(
          x: 1,
          y: 0,
          width: 1,
          height: 1,
          encoding: RfbEncoding.raw,
        );
        pipe.serverSend([10, 20, 30, 0]); // wire RGBA (alpha ignored -> 0xFF)

        // 2. Client requests incremental update (no resize happened).
        final req2 = await pipe.serverReader.readBytes(10);
        expect(req2, equals([3, 1, 0, 0, 0, 0, 0, 2, 0, 2]));
        expect(framebuffer.pixels.sublist(4, 8), equals([10, 20, 30, 0xFF]));

        // Send FramebufferUpdate with numRects=0xFFFF terminated by LastRect:
        // DesktopSize (4x3) + Cursor (1x1, hotspot 0,0) + Raw (1x1 at 0,0) + LastRect
        pipe.serverSend([0, 0]);
        pipe.serverSendUint16(0xFFFF);
        pipe.serverSendRectHeader(
          x: 0,
          y: 0,
          width: 4,
          height: 3,
          encoding: RfbEncoding.desktopSize,
        );
        pipe.serverSendRectHeader(
          x: 0,
          y: 0,
          width: 1,
          height: 1,
          encoding: RfbEncoding.cursor,
        );
        pipe.serverSend([0xAA, 0xBB, 0xCC, 0x00]); // 1x1 cursor pixel
        pipe.serverSend([0x80]); // mask bit set -> opaque
        pipe.serverSendRectHeader(
          x: 0,
          y: 0,
          width: 1,
          height: 1,
          encoding: RfbEncoding.raw,
        );
        pipe.serverSend([0x11, 0x22, 0x33, 0x00]);
        pipe.serverSendRectHeader(
          x: 0,
          y: 0,
          width: 0,
          height: 0,
          encoding: RfbEncoding.lastRect,
        );

        // 3. Because DesktopSize occurred, next request MUST be non-incremental
        // with the new 4x3 dimensions!
        final req3 = await pipe.serverReader.readBytes(10);
        expect(req3, equals([3, 0, 0, 0, 0, 0, 0, 4, 0, 3]));
        expect(framebuffer.width, 4);
        expect(framebuffer.height, 3);
        expect(
          framebuffer.pixels.sublist(0, 4),
          equals([0x11, 0x22, 0x33, 0xFF]),
        );

        // Send SetColourMapEntries (2 colours = 12 bytes to skip).
        pipe.serverSend([1, 0]); // type=1, padding=0
        pipe.serverSendUint16(0); // firstColour
        pipe.serverSendUint16(2); // numColours
        pipe.serverSend(List<int>.filled(12, 0x55));

        // Send Bell.
        pipe.serverSend([2]);

        // Send ServerCutText ("hi\u00e9" in Latin-1).
        pipe.serverSend([3, 0, 0, 0]);
        pipe.serverSendUint32(3);
        pipe.serverSend([0x68, 0x69, 0xE9]);

        await loopFuture;

        expect(resizedTo, equals([(4, 3)]));
        expect(cursors, hasLength(1));
        expect(cursors.first.rgbaPixels, equals([0xAA, 0xBB, 0xCC, 0xFF]));
        expect(bellCount, 1);
        expect(cutTexts, equals(['hi\u00e9']));
        expect(
          eventOrder,
          equals([
            'frame:1',
            'resize:4x3',
            'cursor:1x1',
            'frame:2',
            'bell',
            'cut:hi\u00e9',
          ]),
        );
      },
    );

    test(
      'throws VncProtocolException on oversized ServerCutText payload',
      () async {
        final loopFuture = session.runMessageLoop();

        // Drain initial FramebufferUpdateRequest.
        await pipe.serverReader.readBytes(10);

        pipe.serverSend([3, 0, 0, 0]);
        pipe.serverSendUint32(RfbSession.maxCutTextLength + 1);

        await expectLater(loopFuture, throwsA(isA<VncProtocolException>()));
      },
    );

    test(
      'throws VncProtocolException on unknown server message type',
      () async {
        final loopFuture = session.runMessageLoop();

        // Drain initial FramebufferUpdateRequest.
        await pipe.serverReader.readBytes(10);

        pipe.serverSend([99]);

        await expectLater(
          loopFuture,
          throwsA(
            isA<VncProtocolException>().having(
              (e) => e.message,
              'message',
              contains('Unknown RFB server message type: 99'),
            ),
          ),
        );
      },
    );

    test(
      'setActiveRegion scopes immediate and subsequent framebuffer update requests and restores full framebuffer on null',
      () async {
        final largeFb = VncFramebuffer(3840, 1440);
        final largeSession = RfbSession(
          transport: pipe,
          reader: pipe.clientReader,
          framebuffer: largeFb,
        );
        var stop = false;
        final reportedScreens = <List<VncScreenInfo>>[];

        final loopFuture = largeSession.runMessageLoop(
          onDesktopResized:
              (
                w,
                h,
                screens, {
                hasScreens = false,
                hasCurrentDisplayId = false,
                currentDisplayId,
              }) {
                reportedScreens.add(screens);
              },
          onBell: () {
            stop = true;
          },
          shouldStop: () => stop,
        );

        // 1. Initial full non-incremental request (0, 0, 3840, 1440).
        // 3840 = 0x0F00, 1440 = 0x05A0
        final req1 = await pipe.serverReader.readBytes(10);
        expect(req1, equals([3, 0, 0, 0, 0, 0, 0x0F, 0x00, 0x05, 0xA0]));

        // Select second monitor region (1920, 0, 1920, 1080).
        // 1920 = 0x0780, 1080 = 0x0438
        const monitor2 = VncScreenInfo(
          id: 2,
          x: 1920,
          y: 0,
          width: 1920,
          height: 1080,
          flags: 1,
        );
        largeSession.setActiveRegion(monitor2);
        expect(largeSession.activeRegion, equals(monitor2));

        // 2. Immediately sends non-incremental request scoped to monitor2.
        final req2 = await pipe.serverReader.readBytes(10);
        expect(req2, equals([3, 0, 0x07, 0x80, 0, 0, 0x07, 0x80, 0x04, 0x38]));

        // Server replies with an empty FramebufferUpdate; loop requests incremental ONLY for monitor2.
        pipe.serverSend([0, 0]);
        pipe.serverSendUint16(0);

        final req3 = await pipe.serverReader.readBytes(10);
        expect(req3, equals([3, 1, 0x07, 0x80, 0, 0, 0x07, 0x80, 0x04, 0x38]));

        // Server sends ExtendedDesktopSize updating monitor 2 to (1280, 0, 1280, 720) in a 2560x720 desktop.
        // 2560 = 0x0A00, 720 = 0x02D0, 1280 = 0x0500
        pipe.serverSend([0, 0]);
        pipe.serverSendUint16(1);
        pipe.serverSendRectHeader(
          x: 0,
          y: 0,
          width: 2560,
          height: 720,
          encoding: RfbEncoding.extendedDesktopSize,
        );
        pipe.serverSend([2, 0, 0, 0]); // 2 screens + 3 bytes padding
        final screen1Bytes = ByteData(16)
          ..setUint32(0, 1, Endian.big)
          ..setUint16(4, 0, Endian.big)
          ..setUint16(6, 0, Endian.big)
          ..setUint16(8, 1280, Endian.big)
          ..setUint16(10, 720, Endian.big)
          ..setUint32(12, 0, Endian.big);
        final screen2Bytes = ByteData(16)
          ..setUint32(0, 2, Endian.big)
          ..setUint16(4, 1280, Endian.big)
          ..setUint16(6, 0, Endian.big)
          ..setUint16(8, 1280, Endian.big)
          ..setUint16(10, 720, Endian.big)
          ..setUint32(12, 1, Endian.big);
        pipe.serverSend(screen1Bytes.buffer.asUint8List());
        pipe.serverSend(screen2Bytes.buffer.asUint8List());

        // 4. Post-resize non-incremental request uses updated monitor 2 geometry!
        final req4 = await pipe.serverReader.readBytes(10);
        expect(req4, equals([3, 0, 0x05, 0x00, 0, 0, 0x05, 0x00, 0x02, 0xD0]));
        expect(
          largeSession.activeRegion,
          equals(
            const VncScreenInfo(
              id: 2,
              x: 1280,
              y: 0,
              width: 1280,
              height: 720,
              flags: 1,
            ),
          ),
        );
        expect(reportedScreens, hasLength(1));
        expect(reportedScreens.single, hasLength(2));

        // Setting null restores full framebuffer non-incremental request (0, 0, 2560, 720).
        largeSession.setActiveRegion(null);
        expect(largeSession.activeRegion, isNull);
        final req5 = await pipe.serverReader.readBytes(10);
        expect(req5, equals([3, 0, 0, 0, 0, 0, 0x0A, 0x00, 0x02, 0xD0]));

        // Subsequent loop iteration sends incremental request for full framebuffer.
        pipe.serverSend([0, 0]);
        pipe.serverSendUint16(0);
        final req6 = await pipe.serverReader.readBytes(10);
        expect(req6, equals([3, 1, 0, 0, 0, 0, 0x0A, 0x00, 0x02, 0xD0]));

        pipe.serverSend([2]); // Bell to exit loop
        await loopFuture;
      },
    );
  });
}
