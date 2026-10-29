import 'package:app_ssh/app_ssh.dart';
import 'package:test/test.dart';

void main() {
  group('SSHHostkeyType', () {
    group('static constants', () {
      test('rsaSha1 has correct name', () {
        expect(SSHHostkeyType.rsaSha1.name, equals('ssh-rsa'));
      });

      test('rsaSha256 has correct name', () {
        expect(SSHHostkeyType.rsaSha256.name, equals('rsa-sha2-256'));
      });

      test('rsaSha512 has correct name', () {
        expect(SSHHostkeyType.rsaSha512.name, equals('rsa-sha2-512'));
      });

      test('ecdsa256 has correct name', () {
        expect(SSHHostkeyType.ecdsa256.name, equals('ecdsa-sha2-nistp256'));
      });

      test('ecdsa384 has correct name', () {
        expect(SSHHostkeyType.ecdsa384.name, equals('ecdsa-sha2-nistp384'));
      });

      test('ecdsa521 has correct name', () {
        expect(SSHHostkeyType.ecdsa521.name, equals('ecdsa-sha2-nistp521'));
      });

      test('ed25519 has correct name', () {
        expect(SSHHostkeyType.ed25519.name, equals('ssh-ed25519'));
      });
    });

    group('toString()', () {
      test('rsaSha1 returns correct format', () {
        expect(SSHHostkeyType.rsaSha1.toString(),
            equals('SSHHostkeyType(ssh-rsa)'));
      });

      test('rsaSha256 returns correct format', () {
        expect(SSHHostkeyType.rsaSha256.toString(),
            equals('SSHHostkeyType(rsa-sha2-256)'));
      });

      test('rsaSha512 returns correct format', () {
        expect(SSHHostkeyType.rsaSha512.toString(),
            equals('SSHHostkeyType(rsa-sha2-512)'));
      });

      test('ecdsa256 returns correct format', () {
        expect(SSHHostkeyType.ecdsa256.toString(),
            equals('SSHHostkeyType(ecdsa-sha2-nistp256)'));
      });

      test('ecdsa384 returns correct format', () {
        expect(SSHHostkeyType.ecdsa384.toString(),
            equals('SSHHostkeyType(ecdsa-sha2-nistp384)'));
      });

      test('ecdsa521 returns correct format', () {
        expect(SSHHostkeyType.ecdsa521.toString(),
            equals('SSHHostkeyType(ecdsa-sha2-nistp521)'));
      });

      test('ed25519 returns correct format', () {
        expect(SSHHostkeyType.ed25519.toString(),
            equals('SSHHostkeyType(ssh-ed25519)'));
      });
    });

    group('name property', () {
      test('name property is accessible', () {
        expect(SSHHostkeyType.ed25519.name, equals('ssh-ed25519'));
      });

      test('all hostkey types have name property', () {
        expect(SSHHostkeyType.rsaSha1.name, isA<String>());
        expect(SSHHostkeyType.rsaSha256.name, isA<String>());
        expect(SSHHostkeyType.rsaSha512.name, isA<String>());
        expect(SSHHostkeyType.ecdsa256.name, isA<String>());
        expect(SSHHostkeyType.ecdsa384.name, isA<String>());
        expect(SSHHostkeyType.ecdsa521.name, isA<String>());
        expect(SSHHostkeyType.ed25519.name, isA<String>());
      });
    });

    group('uniqueness', () {
      test('all hostkey types have unique names', () {
        final names = [
          SSHHostkeyType.rsaSha1.name,
          SSHHostkeyType.rsaSha256.name,
          SSHHostkeyType.rsaSha512.name,
          SSHHostkeyType.ecdsa256.name,
          SSHHostkeyType.ecdsa384.name,
          SSHHostkeyType.ecdsa521.name,
          SSHHostkeyType.ed25519.name,
        ];
        expect(names.toSet().length, equals(names.length));
      });
    });
  });
}
