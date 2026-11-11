import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:zmodem/src/consts.dart' as consts;
import 'package:zmodem/src/util/string.dart';
import 'package:zmodem/src/zmodem_frame.dart';
import 'package:zmodem/zmodem.dart';

Uint8List _bytes(Iterable<ZModemPacket> packets) {
  final builder = BytesBuilder();
  for (final packet in packets) {
    builder.add(packet.encode());
  }
  return builder.takeBytes();
}

ZModemHeader _header(int type, int value, {bool isBinary = false}) =>
    ZModemHeader(
      type,
      value & 0xff,
      (value >> 8) & 0xff,
      (value >> 16) & 0xff,
      (value >> 24) & 0xff,
      isBinary: isBinary,
    );

/// A receiver that has accepted `a.bin` and is waiting for ZDATA.
ZModemCore _acceptingReceiver() {
  final core = ZModemCore()..initiateReceive();
  core.dataToSend();
  final events = core
      .receive(
        _bytes([
          ZModemHeader.file(),
          ZModemDataPacket.fileInfo(
            ZModemFileInfo(pathname: 'a.bin', length: 6),
          ),
        ]),
      )
      .toList();
  expect(events.single, isA<ZFileOfferedEvent>());
  core.acceptFile(0);
  core.dataToSend();
  return core;
}

/// A sender whose file has been accepted and is sending content.
ZModemCore _sendingSender() {
  final core = ZModemCore()..initiateSend();
  core.dataToSend();
  expect(
    core.receive(ZModemHeader.rinit().encode()).toList().single,
    isA<ZReadyToSendEvent>(),
  );
  core.offerFile(ZModemFileInfo(pathname: 'a.bin', length: 100000));
  core.dataToSend();
  expect(
    core.receive(ZModemHeader.rpos(0).encode()).toList().single,
    isA<ZFileAcceptedEvent>(),
  );
  core.dataToSend();
  return core;
}

void main() {
  test('CRC mismatch in a data subpacket throws ZModemException', () {
    final core = _acceptingReceiver();
    final good = _bytes([
      ZModemHeader.data(0),
      ZModemDataPacket(consts.ZCRCG, Uint8List.fromList('abc'.codeUnits)),
    ]);
    final bad = Uint8List.fromList(good);
    final index = bad.lastIndexOf(0x62); // 'b'
    bad[index] = 0x7a;

    expect(() => core.receive(bad).toList(), throwsA(isA<ZModemException>()));
  });

  test('ZCRCQ subpacket makes the receiver enqueue ZACK with the offset', () {
    final core = _acceptingReceiver();
    final events = core
        .receive(
          _bytes([
            ZModemHeader.data(0),
            ZModemDataPacket(consts.ZCRCQ, Uint8List.fromList([1, 2, 3])),
          ]),
        )
        .toList();

    expect(events.single, isA<ZFileDataEvent>());
    expect(core.dataToSend(), _header(consts.ZACK, 3).encode());
  });

  test('ZCRCW subpacket is acknowledged too', () {
    final core = _acceptingReceiver();
    core
        .receive(
          _bytes([
            ZModemHeader.data(0),
            ZModemDataPacket(consts.ZCRCG, Uint8List.fromList([1, 2])),
            ZModemDataPacket(consts.ZCRCW, Uint8List.fromList([3, 4, 5, 6])),
          ]),
        )
        .toList();

    expect(core.dataToSend(), _header(consts.ZACK, 6).encode());
  });

  test('five CAN bytes yield ZSessionCancelledEvent', () {
    final core = _acceptingReceiver();
    final events = core
        .receive(
          Uint8List.fromList([consts.CAN, consts.CAN, consts.CAN]),
        )
        .toList();
    expect(events, isEmpty);

    expect(
      core.receive(Uint8List.fromList([consts.CAN, consts.CAN])).toList(),
      [isA<ZSessionCancelledEvent>()],
    );
    expect(core.isFinished, isTrue);
  });

  test('ZRPOS offsets use all four position bytes', () {
    final core = ZModemCore()..initiateSend();
    core.receive(ZModemHeader.rinit().encode()).toList();
    core.offerFile(ZModemFileInfo(pathname: 'a.bin', length: 100000));
    core.dataToSend();

    final events = core.receive(ZModemHeader.rpos(70000).encode()).toList();

    expect((events.single as ZFileAcceptedEvent).offset, 70000);
    expect(core.dataToSend(), ZModemHeader.data(70000).encode());
  });

  test('ZRPOS while sending yields ZFileRepositionEvent', () {
    final core = _sendingSender();
    core.sendFileData(Uint8List(1000));

    final events = core.receive(ZModemHeader.rpos(300).encode()).toList();

    expect((events.single as ZFileRepositionEvent).offset, 300);
    // Queued data past the old position is dropped; the caller resends
    // from the new position, announced with repositionTo.
    expect(core.dataToSend(), isEmpty);
    core.repositionTo(300);
    expect(core.dataToSend(), ZModemHeader.data(300).encode());
  });

  test('ZRPOS after ZEOF goes back to sending', () {
    final core = _sendingSender();
    core.sendFileData(Uint8List(100));
    core.finishSending(100);
    core.dataToSend();

    final events = core.receive(ZModemHeader.rpos(40).encode()).toList();

    expect((events.single as ZFileRepositionEvent).offset, 40);
    core.repositionTo(40);
    core.sendFileData(Uint8List(60));
    core.finishSending(100);
  });

  test('ZACK while sending yields ZFileAckEvent', () {
    final core = _sendingSender();

    final events = core.receive(_header(consts.ZACK, 4096).encode()).toList();

    expect((events.single as ZFileAckEvent).offset, 4096);
  });

  test('sendFileData with ack ends with a ZCRCQ subpacket', () {
    final core = _sendingSender();
    final receiver = _acceptingReceiver();

    core.sendFileData(Uint8List.fromList('hello'.codeUnits), ack: true);
    receiver
        .receive(
          Uint8List.fromList([
            ...ZModemHeader.data(0).encode(),
            ...core.dataToSend(),
          ]),
        )
        .toList();

    // The receiver acknowledges ZCRCQ subpackets.
    expect(receiver.dataToSend(), _header(consts.ZACK, 5).encode());
  });

  test('ZFILE header with garbage size field parses with length null', () {
    final core = ZModemCore()..initiateReceive();
    core.dataToSend();
    final info = BytesBuilder();
    writeCString(info, 'a.bin');
    writeCString(info, 'abc zz 100644');

    final events = core
        .receive(
          _bytes([
            ZModemHeader.file(),
            ZModemDataPacket(consts.ZCRCW, info.takeBytes()),
          ]),
        )
        .toList();

    final offer = events.single as ZFileOfferedEvent;
    expect(offer.fileInfo.pathname, 'a.bin');
    expect(offer.fileInfo.length, isNull);
    expect(offer.fileInfo.modificationTime, isNull);
  });

  test('hex header with a bad CRC throws ZModemException', () {
    final core = ZModemCore();
    final header = ZModemHeader.rqinit().encode();
    // Corrupt the last CRC hex digit (just before CR LF).
    final index = header.indexOf(consts.CR) - 1;
    header[index] = header[index] == 0x30 ? 0x31 : 0x30;

    expect(
      () => core.receive(Uint8List.fromList(header)).toList(),
      throwsA(isA<ZModemException>()),
    );
  });

  test('binary header with a bad CRC throws ZModemException', () {
    final core = _acceptingReceiver();
    final header = ZModemHeader.data(0).encode();
    header[header.length - 1] ^= 0x01;

    expect(
      () => core.receive(Uint8List.fromList(header)).toList(),
      throwsA(isA<ZModemException>()),
    );
  });

  test('a repeated ZRQINIT while waiting for a file re-sends ZRINIT', () {
    final core = ZModemCore();
    core.receive(ZModemHeader.rqinit().encode()).toList();
    expect(core.dataToSend(), ZModemHeader.rinit().encode());

    expect(core.receive(ZModemHeader.rqinit().encode()).toList(), isEmpty);
    expect(core.dataToSend(), ZModemHeader.rinit().encode());
  });

  test('data escapes every control character so terminals pass it intact', () {
    final data = Uint8List.fromList([
      for (var b = 0; b < 0x20; b++) b,
      0x7f,
      for (var b = 0x80; b < 0xa0; b++) b,
      0xff,
      0x41,
    ]);
    final encoded = ZModemDataPacket(consts.ZCRCW, data).encode();
    // Everything up to the frame end (ZDLE ZCRCW) must be printable or ZDLE.
    final body = encoded.sublist(0, encoded.lastIndexOf(consts.ZCRCW) - 1);
    for (final byte in body) {
      if (byte == consts.ZDLE) continue;
      expect((byte & 0x7f) >= 0x20 && byte != 0x7f && byte != 0xff, isTrue,
          reason: 'raw 0x${byte.toRadixString(16)} in encoded data');
    }

    final receiver = _acceptingReceiver();
    final events = receiver
        .receive(
          Uint8List.fromList([
            ...ZModemHeader.data(0).encode(),
            ...encoded,
          ]),
        )
        .toList();
    expect((events.single as ZFileDataEvent).data, data);
  });
}
