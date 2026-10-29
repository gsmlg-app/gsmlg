import 'dart:typed_data';

import 'package:app_ssh/app_ssh.dart';
import 'package:pointycastle/export.dart';
import 'package:test/test.dart';

void main() {
  group('SSHMacType', () {
    group('static constants', () {
      test('hmacMd5 has correct name and keySize', () {
        expect(SSHMacType.hmacMd5.name, equals('hmac-md5'));
        expect(SSHMacType.hmacMd5.keySize, equals(16));
      });

      test('hmacSha1 has correct name and keySize', () {
        expect(SSHMacType.hmacSha1.name, equals('hmac-sha1'));
        expect(SSHMacType.hmacSha1.keySize, equals(20));
      });

      test('hmacSha256 has correct name and keySize', () {
        expect(SSHMacType.hmacSha256.name, equals('hmac-sha2-256'));
        expect(SSHMacType.hmacSha256.keySize, equals(32));
      });

      test('hmacSha512 has correct name and keySize', () {
        expect(SSHMacType.hmacSha512.name, equals('hmac-sha2-512'));
        expect(SSHMacType.hmacSha512.keySize, equals(64));
      });
    });

    group('name property', () {
      test('all mac types have name property', () {
        expect(SSHMacType.hmacMd5.name, isA<String>());
        expect(SSHMacType.hmacSha1.name, isA<String>());
        expect(SSHMacType.hmacSha256.name, isA<String>());
        expect(SSHMacType.hmacSha512.name, isA<String>());
      });

      test('name property is accessible', () {
        expect(SSHMacType.hmacSha256.name, equals('hmac-sha2-256'));
      });
    });

    group('toString()', () {
      test('hmacMd5 returns correct format', () {
        expect(SSHMacType.hmacMd5.toString(), equals('SSHMacType(hmac-md5)'));
      });

      test('hmacSha1 returns correct format', () {
        expect(SSHMacType.hmacSha1.toString(), equals('SSHMacType(hmac-sha1)'));
      });

      test('hmacSha256 returns correct format', () {
        expect(SSHMacType.hmacSha256.toString(),
            equals('SSHMacType(hmac-sha2-256)'));
      });

      test('hmacSha512 returns correct format', () {
        expect(SSHMacType.hmacSha512.toString(),
            equals('SSHMacType(hmac-sha2-512)'));
      });
    });

    group('createMac()', () {
      test('hmacMd5 returns correct Mac instance', () {
        final key = Uint8List(16);
        final mac = SSHMacType.hmacMd5.createMac(key);
        expect(mac, isA<HMac>());
      });

      test('hmacSha1 returns correct Mac instance', () {
        final key = Uint8List(20);
        final mac = SSHMacType.hmacSha1.createMac(key);
        expect(mac, isA<HMac>());
      });

      test('hmacSha256 returns correct Mac instance', () {
        final key = Uint8List(32);
        final mac = SSHMacType.hmacSha256.createMac(key);
        expect(mac, isA<HMac>());
      });

      test('hmacSha512 returns correct Mac instance', () {
        final key = Uint8List(64);
        final mac = SSHMacType.hmacSha512.createMac(key);
        expect(mac, isA<HMac>());
      });

      test('throws ArgumentError for key that is too short', () {
        final shortKey = Uint8List(15); // One byte too short for hmacMd5
        expect(
          () => SSHMacType.hmacMd5.createMac(shortKey),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError for key that is too long', () {
        final longKey = Uint8List(17); // One byte too long for hmacMd5
        expect(
          () => SSHMacType.hmacMd5.createMac(longKey),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError for wrong keySize with hmacSha1', () {
        final wrongKey = Uint8List(16); // Should be 20
        expect(
          () => SSHMacType.hmacSha1.createMac(wrongKey),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError for wrong keySize with hmacSha256', () {
        final wrongKey = Uint8List(20); // Should be 32
        expect(
          () => SSHMacType.hmacSha256.createMac(wrongKey),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError for wrong keySize with hmacSha512', () {
        final wrongKey = Uint8List(32); // Should be 64
        expect(
          () => SSHMacType.hmacSha512.createMac(wrongKey),
          throwsArgumentError,
        );
      });
    });

    group('uniqueness', () {
      test('all mac types have unique names', () {
        final names = [
          SSHMacType.hmacMd5.name,
          SSHMacType.hmacSha1.name,
          SSHMacType.hmacSha256.name,
          SSHMacType.hmacSha512.name,
        ];
        expect(names.toSet().length, equals(names.length));
      });

      test('all mac types have unique keySizes', () {
        final keySizes = [
          SSHMacType.hmacMd5.keySize,
          SSHMacType.hmacSha1.keySize,
          SSHMacType.hmacSha256.keySize,
          SSHMacType.hmacSha512.keySize,
        ];
        expect(keySizes.toSet().length, equals(keySizes.length));
      });
    });

    group('MAC computation', () {
      test('hmacMd5 can compute MAC on data', () {
        final key = Uint8List(16);
        final mac = SSHMacType.hmacMd5.createMac(key);
        final data = Uint8List.fromList([1, 2, 3, 4, 5]);
        final result = mac.process(data);
        expect(result.length, equals(16)); // MD5 produces 16 bytes
      });

      test('hmacSha1 can compute MAC on data', () {
        final key = Uint8List(20);
        final mac = SSHMacType.hmacSha1.createMac(key);
        final data = Uint8List.fromList([1, 2, 3, 4, 5]);
        final result = mac.process(data);
        expect(result.length, equals(20)); // SHA1 produces 20 bytes
      });

      test('hmacSha256 can compute MAC on data', () {
        final key = Uint8List(32);
        final mac = SSHMacType.hmacSha256.createMac(key);
        final data = Uint8List.fromList([1, 2, 3, 4, 5]);
        final result = mac.process(data);
        expect(result.length, equals(32)); // SHA256 produces 32 bytes
      });

      test('hmacSha512 can compute MAC on data', () {
        final key = Uint8List(64);
        final mac = SSHMacType.hmacSha512.createMac(key);
        final data = Uint8List.fromList([1, 2, 3, 4, 5]);
        final result = mac.process(data);
        expect(result.length, equals(64)); // SHA512 produces 64 bytes
      });

      test('same key and data produce same MAC', () {
        final key = Uint8List.fromList(List.generate(32, (i) => i));
        final mac1 = SSHMacType.hmacSha256.createMac(key);
        final mac2 = SSHMacType.hmacSha256.createMac(key);
        final data = Uint8List.fromList([1, 2, 3, 4, 5]);
        final result1 = mac1.process(data);
        final result2 = mac2.process(data);
        expect(result1, equals(result2));
      });

      test('different keys produce different MACs', () {
        final key1 = Uint8List.fromList(List.generate(32, (i) => i));
        final key2 = Uint8List.fromList(List.generate(32, (i) => i + 1));
        final mac1 = SSHMacType.hmacSha256.createMac(key1);
        final mac2 = SSHMacType.hmacSha256.createMac(key2);
        final data = Uint8List.fromList([1, 2, 3, 4, 5]);
        final result1 = mac1.process(data);
        final result2 = mac2.process(data);
        expect(result1, isNot(equals(result2)));
      });
    });
  });
}
