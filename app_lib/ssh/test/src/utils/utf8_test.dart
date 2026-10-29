import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:app_ssh/src/utils/utf8.dart';

void main() {
  group('utf8Encode', () {
    test('encodes empty string', () {
      final result = utf8Encode('');
      expect(result.length, 0);
    });

    test('encodes ASCII characters', () {
      final result = utf8Encode('hello');
      expect(result, Uint8List.fromList([0x68, 0x65, 0x6c, 0x6c, 0x6f]));
    });

    test('encodes space', () {
      final result = utf8Encode(' ');
      expect(result, Uint8List.fromList([0x20]));
    });

    test('encodes newline', () {
      final result = utf8Encode('\n');
      expect(result, Uint8List.fromList([0x0A]));
    });

    test('encodes tab', () {
      final result = utf8Encode('\t');
      expect(result, Uint8List.fromList([0x09]));
    });

    test('encodes two-byte UTF-8 characters', () {
      // é is U+00E9, encoded as 0xC3 0xA9
      final result = utf8Encode('é');
      expect(result, Uint8List.fromList([0xC3, 0xA9]));
    });

    test('encodes three-byte UTF-8 characters', () {
      // 中 is U+4E2D, encoded as 0xE4 0xB8 0xAD
      final result = utf8Encode('中');
      expect(result, Uint8List.fromList([0xE4, 0xB8, 0xAD]));
    });

    test('encodes four-byte UTF-8 characters (emoji)', () {
      // 😀 is U+1F600, encoded as 0xF0 0x9F 0x98 0x80
      final result = utf8Encode('😀');
      expect(result, Uint8List.fromList([0xF0, 0x9F, 0x98, 0x80]));
    });

    test('encodes mixed ASCII and Unicode', () {
      final result = utf8Encode('hi中');
      expect(result, Uint8List.fromList([0x68, 0x69, 0xE4, 0xB8, 0xAD]));
    });

    test('returns Uint8List type', () {
      final result = utf8Encode('test');
      expect(result, isA<Uint8List>());
    });
  });

  group('utf8Decode', () {
    test('decodes empty bytes', () {
      final result = utf8Decode(Uint8List(0));
      expect(result, '');
    });

    test('decodes ASCII characters', () {
      final result = utf8Decode(
        Uint8List.fromList([0x68, 0x65, 0x6c, 0x6c, 0x6f]),
      );
      expect(result, 'hello');
    });

    test('decodes space', () {
      final result = utf8Decode(Uint8List.fromList([0x20]));
      expect(result, ' ');
    });

    test('decodes newline', () {
      final result = utf8Decode(Uint8List.fromList([0x0A]));
      expect(result, '\n');
    });

    test('decodes two-byte UTF-8 characters', () {
      final result = utf8Decode(Uint8List.fromList([0xC3, 0xA9]));
      expect(result, 'é');
    });

    test('decodes three-byte UTF-8 characters', () {
      final result = utf8Decode(Uint8List.fromList([0xE4, 0xB8, 0xAD]));
      expect(result, '中');
    });

    test('decodes four-byte UTF-8 characters (emoji)', () {
      final result = utf8Decode(
        Uint8List.fromList([0xF0, 0x9F, 0x98, 0x80]),
      );
      expect(result, '😀');
    });

    test('decodes mixed ASCII and Unicode', () {
      final result = utf8Decode(
        Uint8List.fromList([0x68, 0x69, 0xE4, 0xB8, 0xAD]),
      );
      expect(result, 'hi中');
    });

    test('returns String type', () {
      final result = utf8Decode(Uint8List.fromList([0x74, 0x65, 0x73, 0x74]));
      expect(result, isA<String>());
    });
  });

  group('roundtrip tests', () {
    test('encode then decode ASCII', () {
      const original = 'hello world';
      final encoded = utf8Encode(original);
      final decoded = utf8Decode(encoded);
      expect(decoded, original);
    });

    test('encode then decode Unicode', () {
      const original = '你好世界';
      final encoded = utf8Encode(original);
      final decoded = utf8Decode(encoded);
      expect(decoded, original);
    });

    test('encode then decode mixed content', () {
      const original = 'Hello 世界! 🌍';
      final encoded = utf8Encode(original);
      final decoded = utf8Decode(encoded);
      expect(decoded, original);
    });

    test('encode then decode special characters', () {
      const original = 'Tab:\tNewline:\nCarriage:\r';
      final encoded = utf8Encode(original);
      final decoded = utf8Decode(encoded);
      expect(decoded, original);
    });

    test('encode then decode all ASCII printable', () {
      final buffer = StringBuffer();
      for (var i = 32; i < 127; i++) {
        buffer.writeCharCode(i);
      }
      final original = buffer.toString();
      final encoded = utf8Encode(original);
      final decoded = utf8Decode(encoded);
      expect(decoded, original);
    });

    test('encode then decode common Unicode ranges', () {
      // Latin Extended
      const latin = 'àáâãäåæçèéêë';
      expect(utf8Decode(utf8Encode(latin)), latin);

      // Greek
      const greek = 'αβγδεζηθ';
      expect(utf8Decode(utf8Encode(greek)), greek);

      // Cyrillic
      const cyrillic = 'абвгдеёж';
      expect(utf8Decode(utf8Encode(cyrillic)), cyrillic);
    });
  });

  group('real-world scenarios', () {
    test('encodes SSH banner', () {
      const banner = 'SSH-2.0-OpenSSH_8.9p1\r\n';
      final encoded = utf8Encode(banner);
      expect(encoded.length, 23); // 21 chars + \r + \n
      expect(encoded.last, 0x0A); // newline
      expect(encoded[encoded.length - 2], 0x0D); // carriage return
    });

    test('decodes terminal output', () {
      // Simulated terminal output with escape codes
      final bytes = Uint8List.fromList([
        0x1B, 0x5B, 0x33, 0x32, 0x6D, // ESC[32m (green)
        0x4F, 0x4B, // "OK"
        0x1B, 0x5B, 0x30, 0x6D, // ESC[0m (reset)
      ]);
      final decoded = utf8Decode(bytes);
      expect(decoded, '\x1B[32mOK\x1B[0m');
    });

    test('handles path with Unicode filename', () {
      const path = '/home/用户/文档/file.txt';
      final encoded = utf8Encode(path);
      final decoded = utf8Decode(encoded);
      expect(decoded, path);
    });
  });
}
