import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:app_ssh/src/utils/chunk_buffer.dart';

void main() {
  group('ChunkBuffer', () {
    late ChunkBuffer buffer;

    setUp(() {
      buffer = ChunkBuffer();
    });

    group('constructor', () {
      test('starts empty', () {
        expect(buffer.isEmpty, isTrue);
        expect(buffer.isNotEmpty, isFalse);
        expect(buffer.length, 0);
      });
    });

    group('add', () {
      test('adds data to empty buffer', () {
        buffer.add(Uint8List.fromList([1, 2, 3]));
        expect(buffer.length, 3);
        expect(buffer.data, Uint8List.fromList([1, 2, 3]));
      });

      test('appends data to existing buffer', () {
        buffer.add(Uint8List.fromList([1, 2]));
        buffer.add(Uint8List.fromList([3, 4]));
        expect(buffer.length, 4);
        expect(buffer.data, Uint8List.fromList([1, 2, 3, 4]));
      });

      test('handles multiple appends', () {
        buffer.add(Uint8List.fromList([1]));
        buffer.add(Uint8List.fromList([2]));
        buffer.add(Uint8List.fromList([3]));
        buffer.add(Uint8List.fromList([4]));
        expect(buffer.data, Uint8List.fromList([1, 2, 3, 4]));
      });

      test('handles empty data add', () {
        buffer.add(Uint8List.fromList([1, 2]));
        buffer.add(Uint8List(0));
        expect(buffer.length, 2);
      });

      test('handles add to empty buffer with empty data', () {
        buffer.add(Uint8List(0));
        expect(buffer.isEmpty, isTrue);
      });
    });

    group('consume', () {
      test('consumes all data when no length specified', () {
        buffer.add(Uint8List.fromList([1, 2, 3, 4, 5]));
        final consumed = buffer.consume();
        expect(consumed, Uint8List.fromList([1, 2, 3, 4, 5]));
        expect(buffer.isEmpty, isTrue);
      });

      test('consumes specified length', () {
        buffer.add(Uint8List.fromList([1, 2, 3, 4, 5]));
        final consumed = buffer.consume(3);
        expect(consumed, Uint8List.fromList([1, 2, 3]));
        expect(buffer.data, Uint8List.fromList([4, 5]));
      });

      test('consumes partial data leaves remainder', () {
        buffer.add(Uint8List.fromList([10, 20, 30, 40, 50]));
        buffer.consume(2);
        expect(buffer.length, 3);
        expect(buffer.data, Uint8List.fromList([30, 40, 50]));
      });

      test('consumes exactly all data', () {
        buffer.add(Uint8List.fromList([1, 2, 3]));
        final consumed = buffer.consume(3);
        expect(consumed, Uint8List.fromList([1, 2, 3]));
        expect(buffer.isEmpty, isTrue);
      });

      test('returns empty when buffer is empty', () {
        final consumed = buffer.consume();
        expect(consumed.length, 0);
      });

      test('multiple partial consumes', () {
        buffer.add(Uint8List.fromList([1, 2, 3, 4, 5, 6]));

        expect(buffer.consume(2), Uint8List.fromList([1, 2]));
        expect(buffer.consume(2), Uint8List.fromList([3, 4]));
        expect(buffer.consume(2), Uint8List.fromList([5, 6]));
        expect(buffer.isEmpty, isTrue);
      });
    });

    group('clear', () {
      test('clears non-empty buffer', () {
        buffer.add(Uint8List.fromList([1, 2, 3]));
        buffer.clear();
        expect(buffer.isEmpty, isTrue);
        expect(buffer.length, 0);
      });

      test('clears empty buffer without error', () {
        buffer.clear();
        expect(buffer.isEmpty, isTrue);
      });
    });

    group('view', () {
      test('returns sublist view', () {
        buffer.add(Uint8List.fromList([1, 2, 3, 4, 5]));
        final view = buffer.view(1, 3);
        expect(view, Uint8List.fromList([2, 3, 4]));
      });

      test('view at start', () {
        buffer.add(Uint8List.fromList([10, 20, 30, 40]));
        expect(buffer.view(0, 2), Uint8List.fromList([10, 20]));
      });

      test('view at end', () {
        buffer.add(Uint8List.fromList([10, 20, 30, 40]));
        expect(buffer.view(2, 2), Uint8List.fromList([30, 40]));
      });

      test('view does not modify buffer', () {
        buffer.add(Uint8List.fromList([1, 2, 3, 4, 5]));
        buffer.view(0, 3);
        expect(buffer.length, 5);
        expect(buffer.data, Uint8List.fromList([1, 2, 3, 4, 5]));
      });
    });

    group('data', () {
      test('returns current buffer contents', () {
        buffer.add(Uint8List.fromList([1, 2, 3]));
        expect(buffer.data, Uint8List.fromList([1, 2, 3]));
      });

      test('returns empty list when empty', () {
        expect(buffer.data.length, 0);
      });
    });

    group('length', () {
      test('returns 0 for empty buffer', () {
        expect(buffer.length, 0);
      });

      test('returns correct length after add', () {
        buffer.add(Uint8List.fromList([1, 2, 3, 4]));
        expect(buffer.length, 4);
      });

      test('updates after consume', () {
        buffer.add(Uint8List.fromList([1, 2, 3, 4, 5]));
        buffer.consume(2);
        expect(buffer.length, 3);
      });
    });

    group('isEmpty/isNotEmpty', () {
      test('isEmpty true when empty', () {
        expect(buffer.isEmpty, isTrue);
      });

      test('isEmpty false when has data', () {
        buffer.add(Uint8List.fromList([1]));
        expect(buffer.isEmpty, isFalse);
      });

      test('isNotEmpty true when has data', () {
        buffer.add(Uint8List.fromList([1]));
        expect(buffer.isNotEmpty, isTrue);
      });

      test('isNotEmpty false when empty', () {
        expect(buffer.isNotEmpty, isFalse);
      });

      test('changes after consume all', () {
        buffer.add(Uint8List.fromList([1, 2]));
        expect(buffer.isEmpty, isFalse);
        buffer.consume();
        expect(buffer.isEmpty, isTrue);
      });
    });

    group('byteData', () {
      test('returns ByteData view of buffer', () {
        buffer.add(Uint8List.fromList([0x01, 0x02, 0x03, 0x04]));
        final byteData = buffer.byteData;
        expect(byteData.getUint8(0), 0x01);
        expect(byteData.getUint8(1), 0x02);
        expect(byteData.getUint8(2), 0x03);
        expect(byteData.getUint8(3), 0x04);
      });

      test('allows reading as different types', () {
        buffer.add(Uint8List.fromList([0x00, 0x00, 0x01, 0x00]));
        final byteData = buffer.byteData;
        // Big endian: 0x00000100 = 256
        expect(byteData.getUint32(0, Endian.big), 256);
      });
    });

    group('toString', () {
      test('returns formatted string', () {
        buffer.add(Uint8List.fromList([1, 2, 3]));
        expect(buffer.toString(), 'SSHChunkBuffer(length: 3)');
      });

      test('shows zero length when empty', () {
        expect(buffer.toString(), 'SSHChunkBuffer(length: 0)');
      });
    });

    group('real-world scenarios', () {
      test('socket-like data accumulation', () {
        // Simulate receiving partial data packets
        buffer
            .add(Uint8List.fromList([0x00, 0x00, 0x00, 0x05])); // Length header
        buffer.add(Uint8List.fromList([0x68, 0x65])); // "he"
        buffer.add(Uint8List.fromList([0x6c, 0x6c, 0x6f])); // "llo"

        // Read length header
        final length = buffer.byteData.getUint32(0, Endian.big);
        expect(length, 5);

        // Consume header
        buffer.consume(4);

        // Consume payload
        final payload = buffer.consume(length);
        expect(String.fromCharCodes(payload), 'hello');
      });

      test('packet framing scenario', () {
        // Add a complete packet
        buffer.add(Uint8List.fromList([0x05, 0x01, 0x02, 0x03, 0x04, 0x05]));

        // Read packet length (first byte)
        final packetLength = buffer.data[0];
        expect(packetLength, 5);

        // Consume length byte
        buffer.consume(1);

        // Consume packet data
        final packet = buffer.consume(packetLength);
        expect(packet, Uint8List.fromList([1, 2, 3, 4, 5]));
      });
    });
  });
}
