import 'dart:typed_data';

import 'package:app_ssh/app_ssh.dart';

import 'package:test/test.dart';

void main() {
  const validPem = r'''-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACBZnnnYZjFQ7Zt0gMyJ2YYmDINTucLFWY81/Wuv2aOIpAAAAKBQ6gOSUOoD
kgAAAAtzc2gtZWQyNTUxOQAAACBZnnnYZjFQ7Zt0gMyJ2YYmDINTucLFWY81/Wuv2aOIpA
AAAEAP8fq0hjlR3jhL7pg+26PSaMiC1V/RrinVbo/4eBMRNFmeedhmMVDtm3SAzInZhiYM
g1O5wsVZjzX9a6/Zo4ikAAAAGWpmb3V0dHNAVVNBSkZPVVRUU00ubG9jYWwBAgME
-----END OPENSSH PRIVATE KEY-----''';

  const pemWithHeaders = r'''-----BEGIN OPENSSH PRIVATE KEY-----
Header1: Value1
Header2: Value2
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACBZnnnYZjFQ7Zt0gMyJ2YYmDINTucLFWY81/Wuv2aOIpAAAAKBQ6gOSUOoD
kgAAAAtzc2gtZWQyNTUxOQAAACBZnnnYZjFQ7Zt0gMyJ2YYmDINTucLFWY81/Wuv2aOIpA
AAAEAP8fq0hjlR3jhL7pg+26PSaMiC1V/RrinVbo/4eBMRNFmeedhmMVDtm3SAzInZhiYM
g1O5wsVZjzX9a6/Zo4ikAAAAGWpmb3V0dHNAVVNBSkZPVVRUU00ubG9jYWwBAgME
-----END OPENSSH PRIVATE KEY-----''';

  group('SSHPem.decode', () {
    test('works', () {
      final pem = SSHPem.decode(validPem);
      expect(pem.type, 'OPENSSH PRIVATE KEY');
    });

    test('extracts type correctly', () {
      final pem = SSHPem.decode(validPem);
      expect(pem.type, equals('OPENSSH PRIVATE KEY'));
    });

    test('can parse header', () {
      final pem = SSHPem.decode(pemWithHeaders);
      expect(pem.headers, {
        'Header1': 'Value1',
        'Header2': 'Value2',
      });
    });

    test('has empty headers when no headers present', () {
      final pem = SSHPem.decode(validPem);
      expect(pem.headers, isEmpty);
    });

    test('decodes content as Uint8List', () {
      final pem = SSHPem.decode(validPem);
      expect(pem.content, isA<Uint8List>());
      expect(pem.content.isNotEmpty, isTrue);
    });

    test('throws on invalid PEM (empty)', () {
      expect(() => SSHPem.decode(''), throwsA(isA<FormatException>()));
    });

    test('throws on missing BEGIN header', () {
      expect(
        () => SSHPem.decode('''no header
-----END OPENSSH PRIVATE KEY-----'''),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws on missing END footer', () {
      expect(
        () => SSHPem.decode('''-----BEGIN OPENSSH PRIVATE KEY-----
SGVsbG8gV29ybGQ=
no footer'''),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws on header not ending with dashes', () {
      expect(
        () => SSHPem.decode('''-----BEGIN OPENSSH PRIVATE KEY
SGVsbG8gV29ybGQ=
-----END OPENSSH PRIVATE KEY-----'''),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws on footer not ending with dashes', () {
      expect(
        () => SSHPem.decode('''-----BEGIN OPENSSH PRIVATE KEY-----
SGVsbG8gV29ybGQ=
-----END OPENSSH PRIVATE KEY'''),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws on type mismatch between header and footer', () {
      expect(
        () => SSHPem.decode('''-----BEGIN PRIVATE KEY-----
SGVsbG8gV29ybGQ=
-----END PUBLIC KEY-----'''),
        throwsA(isA<FormatException>()),
      );
    });

    test('parses RSA PRIVATE KEY type', () {
      final pem = SSHPem.decode('''-----BEGIN RSA PRIVATE KEY-----
SGVsbG8gV29ybGQ=
-----END RSA PRIVATE KEY-----''');
      expect(pem.type, 'RSA PRIVATE KEY');
    });

    test('parses PUBLIC KEY type', () {
      final pem = SSHPem.decode('''-----BEGIN PUBLIC KEY-----
SGVsbG8gV29ybGQ=
-----END PUBLIC KEY-----''');
      expect(pem.type, 'PUBLIC KEY');
    });

    test('parses CERTIFICATE type', () {
      final pem = SSHPem.decode('''-----BEGIN CERTIFICATE-----
SGVsbG8gV29ybGQ=
-----END CERTIFICATE-----''');
      expect(pem.type, 'CERTIFICATE');
    });

    test('skips empty lines', () {
      final pem = SSHPem.decode('''-----BEGIN TEST-----

SGVsbG8g

V29ybGQ=

-----END TEST-----''');
      expect(pem.content, isNotEmpty);
    });

    test('throws if header line after body', () {
      expect(
        () => SSHPem.decode('''-----BEGIN TEST-----
SGVsbG8gV29ybGQ=
Header: Value
-----END TEST-----'''),
        throwsA(isA<FormatException>()),
      );
    });

    test('handles single header line', () {
      final pem = SSHPem.decode('''-----BEGIN TEST-----
Proc-Type: 4,ENCRYPTED
SGVsbG8gV29ybGQ=
-----END TEST-----''');
      expect(pem.headers['Proc-Type'], '4,ENCRYPTED');
    });
  });

  group('SSHPem.encode', () {
    test('creates valid PEM format', () {
      final pem = SSHPem(
        'TEST KEY',
        {},
        Uint8List.fromList([72, 101, 108, 108, 111]), // "Hello"
      );
      final encoded = pem.encode();
      expect(encoded, contains('-----BEGIN TEST KEY-----'));
      expect(encoded, contains('-----END TEST KEY-----'));
    });

    test('roundtrip decode and encode', () {
      final original = SSHPem.decode(validPem);
      final encoded = original.encode();
      final decoded = SSHPem.decode(encoded);

      expect(decoded.type, original.type);
      expect(decoded.content, original.content);
    });

    test('uses default line length of 64', () {
      final content = Uint8List.fromList(List.generate(100, (i) => i));
      final pem = SSHPem('TEST', {}, content);
      final encoded = pem.encode();

      final lines = encoded.split('\n');
      // Check that body lines are <= 64 characters
      for (final line in lines.sublist(1, lines.length - 2)) {
        if (line.trim().isNotEmpty) {
          expect(line.length, lessThanOrEqualTo(64));
        }
      }
    });

    test('respects custom line length', () {
      final content = Uint8List.fromList(List.generate(100, (i) => i));
      final pem = SSHPem('TEST', {}, content);
      final encoded = pem.encode(32);

      final lines = encoded.split('\n');
      // Check that body lines are <= 32 characters
      for (final line in lines.sublist(1, lines.length - 2)) {
        if (line.trim().isNotEmpty) {
          expect(line.length, lessThanOrEqualTo(32));
        }
      }
    });

    test('handles empty content', () {
      final pem = SSHPem('EMPTY', {}, Uint8List(0));
      final encoded = pem.encode();
      expect(encoded, contains('-----BEGIN EMPTY-----'));
      expect(encoded, contains('-----END EMPTY-----'));
    });
  });

  group('SSHPem constructor', () {
    test('stores type', () {
      final pem = SSHPem('MY TYPE', {}, Uint8List(0));
      expect(pem.type, 'MY TYPE');
    });

    test('stores headers', () {
      final headers = {'Key': 'Value'};
      final pem = SSHPem('TYPE', headers, Uint8List(0));
      expect(pem.headers, headers);
    });

    test('stores content', () {
      final content = Uint8List.fromList([1, 2, 3, 4, 5]);
      final pem = SSHPem('TYPE', {}, content);
      expect(pem.content, content);
    });
  });

  group('SSHPem.toString', () {
    test('returns formatted string', () {
      final pem = SSHPem(
        'PRIVATE KEY',
        {},
        Uint8List.fromList([1, 2, 3, 4, 5]),
      );
      expect(pem.toString(), contains('PRIVATE KEY'));
      expect(pem.toString(), contains('length: 5'));
    });

    test('includes type in string', () {
      final pem = SSHPem('MY TYPE', {}, Uint8List(10));
      expect(pem.toString(), contains('MY TYPE'));
    });

    test('includes content length in string', () {
      final pem = SSHPem('TYPE', {}, Uint8List(42));
      expect(pem.toString(), contains('42'));
    });
  });
}
