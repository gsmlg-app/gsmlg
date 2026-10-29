import 'dart:typed_data';

import 'package:app_security/encrypt/encrypt.dart';
import 'package:test/test.dart';

void main() {
  group('SecureRandom', () {
    test('generates bytes of specified length', () {
      final random = SecureRandom(16);
      expect(random.bytes.length, 16);
      expect(random.length, 16);
    });

    test('generates zero-length bytes', () {
      final random = SecureRandom(0);
      expect(random.bytes.length, 0);
      expect(random.length, 0);
    });

    test('generates different bytes each time', () {
      final random1 = SecureRandom(32);
      final random2 = SecureRandom(32);
      // Extremely unlikely to be equal
      expect(random1.bytes, isNot(equals(random2.bytes)));
    });

    test('base16 returns hex string', () {
      final random = SecureRandom(4);
      expect(random.base16.length, 8); // 4 bytes * 2 hex chars
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(random.base16), isTrue);
    });

    test('base64 returns base64 string', () {
      final random = SecureRandom(16);
      // Base64 encoding: 16 bytes -> 24 chars (with padding)
      expect(random.base64.length, greaterThanOrEqualTo(20));
    });

    test('bytes returns Uint8List', () {
      final random = SecureRandom(8);
      expect(random.bytes, isA<Uint8List>());
    });
  });

  group('Encrypted', () {
    test('creates from Uint8List', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      final encrypted = Encrypted(bytes);
      expect(encrypted.bytes, bytes);
    });

    test('creates from base16', () {
      final encrypted = Encrypted.fromBase16('01020304');
      expect(encrypted.bytes, Uint8List.fromList([1, 2, 3, 4]));
    });

    test('creates from base64', () {
      final encrypted = Encrypted.fromBase64('AQIDBA==');
      expect(encrypted.bytes, Uint8List.fromList([1, 2, 3, 4]));
    });

    test('creates from64 alias', () {
      final encrypted = Encrypted.from64('AQIDBA==');
      expect(encrypted.bytes, Uint8List.fromList([1, 2, 3, 4]));
    });

    test('creates from UTF-8', () {
      final encrypted = Encrypted.fromUtf8('test');
      expect(encrypted.bytes, Uint8List.fromList([116, 101, 115, 116]));
    });

    test('creates from length with secure random', () {
      final encrypted = Encrypted.fromLength(16);
      expect(encrypted.bytes.length, 16);
    });

    test('creates from secure random', () {
      final encrypted = Encrypted.fromSecureRandom(16);
      expect(encrypted.bytes.length, 16);
    });

    test('creates all zeros', () {
      final encrypted = Encrypted.allZerosOfLength(4);
      expect(encrypted.bytes, Uint8List.fromList([0, 0, 0, 0]));
    });

    test('base16 getter returns hex string', () {
      final encrypted = Encrypted(Uint8List.fromList([255, 0, 15]));
      expect(encrypted.base16, 'ff000f');
    });

    test('base64 getter returns base64 string', () {
      final encrypted = Encrypted(Uint8List.fromList([1, 2, 3, 4]));
      expect(encrypted.base64, 'AQIDBA==');
    });

    test('equality works correctly', () {
      final encrypted1 = Encrypted(Uint8List.fromList([1, 2, 3]));
      final encrypted2 = Encrypted(Uint8List.fromList([1, 2, 3]));
      final encrypted3 = Encrypted(Uint8List.fromList([1, 2, 4]));

      expect(encrypted1, equals(encrypted2));
      expect(encrypted1, isNot(equals(encrypted3)));
    });

    test('equality with non-Encrypted returns false', () {
      final encrypted = Encrypted(Uint8List.fromList([1, 2, 3]));
      // ignore: unrelated_type_equality_checks
      expect(encrypted == 'not encrypted', isFalse);
    });

    test('hashCode is consistent', () {
      final encrypted1 = Encrypted(Uint8List.fromList([1, 2, 3]));
      final encrypted2 = Encrypted(Uint8List.fromList([1, 2, 3]));

      expect(encrypted1.hashCode, encrypted2.hashCode);
    });
  });

  group('IV', () {
    test('creates from Uint8List', () {
      final bytes = Uint8List.fromList(
          [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]);
      final iv = IV(bytes);
      expect(iv.bytes, bytes);
    });

    test('creates from base16', () {
      final iv = IV.fromBase16('01020304050607080910111213141516');
      expect(iv.bytes.length, 16);
    });

    test('creates from base64', () {
      final iv = IV.fromBase64('AQIDBAUGBwgJEBESExQVFg==');
      expect(iv.bytes.length, 16);
    });

    test('creates from UTF-8', () {
      final iv = IV.fromUtf8('1234567890123456');
      expect(iv.bytes.length, 16);
    });

    test('creates from length', () {
      final iv = IV.fromLength(16);
      expect(iv.bytes.length, 16);
    });

    test('creates from secure random', () {
      final iv = IV.fromSecureRandom(16);
      expect(iv.bytes.length, 16);
    });

    test('creates all zeros', () {
      final iv = IV.allZerosOfLength(16);
      expect(iv.bytes, Uint8List(16));
    });

    test('inherits from Encrypted', () {
      final iv = IV.fromLength(16);
      expect(iv, isA<Encrypted>());
    });

    test('base16 and base64 work correctly', () {
      final iv = IV(Uint8List.fromList([1, 2, 3, 4]));
      expect(iv.base16, '01020304');
      expect(iv.base64, 'AQIDBA==');
    });
  });

  group('Key', () {
    test('creates from Uint8List', () {
      final bytes = Uint8List.fromList(List.generate(32, (i) => i));
      final key = Key(bytes);
      expect(key.bytes, bytes);
    });

    test('creates from base16', () {
      final key = Key.fromBase16(
          '0102030405060708091011121314151617181920212223242526272829303132');
      expect(key.bytes.length, 32);
    });

    test('creates from base64', () {
      final key =
          Key.fromBase64('AQIDBAUGBwgJEBESExQVFhcYGSAhIiMkJSYnKCkwMTI=');
      expect(key.bytes.length, 32);
    });

    test('creates from UTF-8', () {
      final key = Key.fromUtf8('12345678901234567890123456789012');
      expect(key.bytes.length, 32);
    });

    test('creates from length', () {
      final key = Key.fromLength(32);
      expect(key.bytes.length, 32);
    });

    test('creates from secure random', () {
      final key = Key.fromSecureRandom(32);
      expect(key.bytes.length, 32);
    });

    test('creates all zeros', () {
      final key = Key.allZerosOfLength(32);
      expect(key.bytes, Uint8List(32));
    });

    test('inherits from Encrypted', () {
      final key = Key.fromLength(32);
      expect(key, isA<Encrypted>());
    });

    test('length getter returns correct value', () {
      final key = Key.fromLength(32);
      expect(key.length, 32);
    });

    test('stretch creates derived key', () {
      final key = Key.fromUtf8('password');
      final stretched = key.stretch(32, iterationCount: 100);

      expect(stretched.length, 32);
      expect(stretched, isA<Key>());
    });

    test('stretch with custom salt', () {
      final key = Key.fromUtf8('password');
      final salt = Uint8List.fromList(List.generate(16, (i) => i));

      final stretched1 = key.stretch(32, iterationCount: 100, salt: salt);
      final stretched2 = key.stretch(32, iterationCount: 100, salt: salt);

      // Same salt should produce same result
      expect(stretched1.bytes, stretched2.bytes);
    });

    test('stretch produces different keys for different passwords', () {
      final key1 = Key.fromUtf8('password1');
      final key2 = Key.fromUtf8('password2');
      final salt = Uint8List.fromList(List.generate(16, (i) => i));

      final stretched1 = key1.stretch(32, iterationCount: 100, salt: salt);
      final stretched2 = key2.stretch(32, iterationCount: 100, salt: salt);

      expect(stretched1.bytes, isNot(equals(stretched2.bytes)));
    });
  });

  group('Encrypter with AES', () {
    late Key key;
    late IV iv;
    late Encrypter encrypter;

    setUp(() {
      key = Key.fromUtf8(
          '12345678901234567890123456789012'); // 32 bytes for AES-256
      iv = IV.fromUtf8('1234567890123456'); // 16 bytes for AES
      encrypter = Encrypter(AES(key));
    });

    test('encrypt returns Encrypted', () {
      final encrypted = encrypter.encrypt('Hello, World!', iv: iv);
      expect(encrypted, isA<Encrypted>());
    });

    test('decrypt returns original string', () {
      final original = 'Hello, World!';
      final encrypted = encrypter.encrypt(original, iv: iv);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      expect(decrypted, original);
    });

    test('encryptBytes works with List<int>', () {
      final input = [72, 101, 108, 108, 111]; // "Hello"
      final encrypted = encrypter.encryptBytes(input, iv: iv);
      expect(encrypted, isA<Encrypted>());
    });

    test('encryptBytes works with Uint8List', () {
      final input = Uint8List.fromList([72, 101, 108, 108, 111]); // "Hello"
      final encrypted = encrypter.encryptBytes(input, iv: iv);
      expect(encrypted, isA<Encrypted>());
    });

    test('decryptBytes returns bytes', () {
      final original = 'Test';
      final encrypted = encrypter.encrypt(original, iv: iv);
      final decrypted = encrypter.decryptBytes(encrypted, iv: iv);

      expect(decrypted, [84, 101, 115, 116]);
    });

    test('decrypt16 decrypts hex-encoded string', () {
      final original = 'Test';
      final encrypted = encrypter.encrypt(original, iv: iv);
      final decrypted = encrypter.decrypt16(encrypted.base16, iv: iv);

      expect(decrypted, original);
    });

    test('decrypt64 decrypts base64-encoded string', () {
      final original = 'Test message';
      final encrypted = encrypter.encrypt(original, iv: iv);
      final decrypted = encrypter.decrypt64(encrypted.base64, iv: iv);

      expect(decrypted, original);
    });

    test('encrypts and decrypts whitespace string', () {
      final original = ' ';
      final encrypted = encrypter.encrypt(original, iv: iv);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      expect(decrypted, original);
    });

    test('encrypts and decrypts unicode text', () {
      final original = '你好世界 🎉 Hello!';
      final encrypted = encrypter.encrypt(original, iv: iv);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      expect(decrypted, original);
    });

    test('encrypts and decrypts long text', () {
      final original = 'A' * 10000;
      final encrypted = encrypter.encrypt(original, iv: iv);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      expect(decrypted, original);
    });
  });

  group('Encrypter with different AES modes', () {
    late Key key;
    late IV iv;

    setUp(() {
      key = Key.fromUtf8('12345678901234567890123456789012');
      iv = IV.fromUtf8('1234567890123456');
    });

    test('CBC mode encryption/decryption', () {
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      final original = 'Test CBC mode';

      final encrypted = encrypter.encrypt(original, iv: iv);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      expect(decrypted, original);
    });

    test('CTR mode encryption/decryption', () {
      final encrypter = Encrypter(AES(key, mode: AESMode.ctr));
      final original = 'Test CTR mode';

      final encrypted = encrypter.encrypt(original, iv: iv);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      expect(decrypted, original);
    });

    test('SIC mode encryption/decryption', () {
      final encrypter = Encrypter(AES(key, mode: AESMode.sic));
      final original = 'Test SIC mode';

      final encrypted = encrypter.encrypt(original, iv: iv);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      expect(decrypted, original);
    });

    test('different modes produce different ciphertext', () {
      final cbcEncrypter = Encrypter(AES(key, mode: AESMode.cbc));
      final ctrEncrypter = Encrypter(AES(key, mode: AESMode.ctr));
      final original = 'Test different modes';

      final cbcEncrypted = cbcEncrypter.encrypt(original, iv: iv);
      final ctrEncrypted = ctrEncrypter.encrypt(original, iv: iv);

      expect(cbcEncrypted.bytes, isNot(equals(ctrEncrypted.bytes)));
    });
  });

  group('AES algorithm', () {
    test('creates AES with default mode (SIC)', () {
      final key = Key.fromLength(32);
      final aes = AES(key);
      expect(aes, isA<Algorithm>());
    });

    test('creates AES with specific mode', () {
      final key = Key.fromLength(32);
      final aes = AES(key, mode: AESMode.cbc);
      expect(aes, isA<Algorithm>());
    });

    test('supports 128-bit key (16 bytes)', () {
      final key = Key.fromLength(16);
      final iv = IV.fromLength(16);
      final aes = AES(key);
      final encrypter = Encrypter(aes);

      final encrypted = encrypter.encrypt('Test', iv: iv);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      expect(decrypted, 'Test');
    });

    test('supports 192-bit key (24 bytes)', () {
      final key = Key.fromLength(24);
      final iv = IV.fromLength(16);
      final aes = AES(key);
      final encrypter = Encrypter(aes);

      final encrypted = encrypter.encrypt('Test', iv: iv);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      expect(decrypted, 'Test');
    });

    test('supports 256-bit key (32 bytes)', () {
      final key = Key.fromLength(32);
      final iv = IV.fromLength(16);
      final aes = AES(key);
      final encrypter = Encrypter(aes);

      final encrypted = encrypter.encrypt('Test', iv: iv);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      expect(decrypted, 'Test');
    });
  });

  group('Salsa20 algorithm', () {
    test('encrypts and decrypts', () {
      final key = Key.fromLength(32);
      final iv = IV.fromLength(8);
      final salsa = Salsa20(key);
      final encrypter = Encrypter(salsa);

      final original = 'Test Salsa20';
      final encrypted = encrypter.encrypt(original, iv: iv);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      expect(decrypted, original);
    });

    test('produces different ciphertext than AES', () {
      final key = Key.fromUtf8('12345678901234567890123456789012');
      final iv = IV.fromUtf8('12345678');
      final aesIv = IV.fromUtf8('1234567890123456');

      final salsaEncrypter = Encrypter(Salsa20(key));
      final aesEncrypter = Encrypter(AES(key));
      final original = 'Test';

      final salsaEncrypted = salsaEncrypter.encrypt(original, iv: iv);
      final aesEncrypted = aesEncrypter.encrypt(original, iv: aesIv);

      expect(salsaEncrypted.bytes, isNot(equals(aesEncrypted.bytes)));
    });
  });
}
