import 'package:test/test.dart';
import 'package:app_ssh/src/ssh_algorithm.dart';
import 'package:app_ssh/src/algorithm/ssh_cipher_type.dart';
import 'package:app_ssh/src/algorithm/ssh_hostkey_type.dart';
import 'package:app_ssh/src/algorithm/ssh_kex_type.dart';
import 'package:app_ssh/src/algorithm/ssh_mac_type.dart';

class MockAlgorithm with SSHAlgorithm {
  @override
  final String name;

  MockAlgorithm(this.name);
}

void main() {
  group('SSHAlgorithm mixin', () {
    test('name getter returns algorithm name', () {
      final alg = MockAlgorithm('test-alg');
      expect(alg.name, 'test-alg');
    });

    test('toString includes runtimeType and name', () {
      final alg = MockAlgorithm('my-algorithm');
      expect(alg.toString(), contains('MockAlgorithm'));
      expect(alg.toString(), contains('my-algorithm'));
    });
  });

  group('SSHAlgorithmList extension', () {
    test('toNameList returns list of algorithm names', () {
      final algorithms = [
        MockAlgorithm('alg1'),
        MockAlgorithm('alg2'),
        MockAlgorithm('alg3'),
      ];
      expect(algorithms.toNameList(), ['alg1', 'alg2', 'alg3']);
    });

    test('toNameList returns empty list for empty input', () {
      final algorithms = <MockAlgorithm>[];
      expect(algorithms.toNameList(), isEmpty);
    });

    test('getByName returns matching algorithm', () {
      final algorithms = [
        MockAlgorithm('first'),
        MockAlgorithm('second'),
        MockAlgorithm('third'),
      ];
      final result = algorithms.getByName('second');
      expect(result, isNotNull);
      expect(result!.name, 'second');
    });

    test('getByName returns null for non-matching name', () {
      final algorithms = [
        MockAlgorithm('first'),
        MockAlgorithm('second'),
      ];
      expect(algorithms.getByName('nonexistent'), isNull);
    });

    test('getByName returns first match if duplicates exist', () {
      final algorithms = [
        MockAlgorithm('duplicate'),
        MockAlgorithm('duplicate'),
      ];
      final result = algorithms.getByName('duplicate');
      expect(result, same(algorithms[0]));
    });

    test('works with SSHKexType list', () {
      final kexList = [SSHKexType.x25519, SSHKexType.nistp256];
      final names = kexList.toNameList();
      expect(names, contains('curve25519-sha256@libssh.org'));
      expect(names, contains('ecdh-sha2-nistp256'));
    });

    test('works with SSHHostkeyType list', () {
      final hostkeys = [SSHHostkeyType.ed25519, SSHHostkeyType.rsaSha256];
      final names = hostkeys.toNameList();
      expect(names, contains('ssh-ed25519'));
      expect(names, contains('rsa-sha2-256'));
    });

    test('works with SSHCipherType list', () {
      final ciphers = [SSHCipherType.aes128ctr, SSHCipherType.aes256cbc];
      final names = ciphers.toNameList();
      expect(names, contains('aes128-ctr'));
      expect(names, contains('aes256-cbc'));
    });

    test('works with SSHMacType list', () {
      final macs = [SSHMacType.hmacSha1, SSHMacType.hmacSha256];
      final names = macs.toNameList();
      expect(names, contains('hmac-sha1'));
      expect(names, contains('hmac-sha2-256'));
    });
  });

  group('SSHAlgorithms', () {
    test('default constructor provides all algorithm types', () {
      const algorithms = SSHAlgorithms();
      expect(algorithms.kex, isNotEmpty);
      expect(algorithms.hostkey, isNotEmpty);
      expect(algorithms.cipher, isNotEmpty);
      expect(algorithms.mac, isNotEmpty);
    });

    test('default kex includes x25519', () {
      const algorithms = SSHAlgorithms();
      expect(algorithms.kex, contains(SSHKexType.x25519));
    });

    test('default kex includes NIST curves', () {
      const algorithms = SSHAlgorithms();
      expect(algorithms.kex, contains(SSHKexType.nistp256));
      expect(algorithms.kex, contains(SSHKexType.nistp384));
      expect(algorithms.kex, contains(SSHKexType.nistp521));
    });

    test('default kex includes DH algorithms', () {
      const algorithms = SSHAlgorithms();
      expect(algorithms.kex, contains(SSHKexType.dh14Sha256));
      expect(algorithms.kex, contains(SSHKexType.dh14Sha1));
      expect(algorithms.kex, contains(SSHKexType.dh1Sha1));
      expect(algorithms.kex, contains(SSHKexType.dhGexSha256));
      expect(algorithms.kex, contains(SSHKexType.dhGexSha1));
    });

    test('default hostkey includes common types', () {
      const algorithms = SSHAlgorithms();
      expect(algorithms.hostkey, contains(SSHHostkeyType.ed25519));
      expect(algorithms.hostkey, contains(SSHHostkeyType.rsaSha256));
      expect(algorithms.hostkey, contains(SSHHostkeyType.rsaSha512));
      expect(algorithms.hostkey, contains(SSHHostkeyType.rsaSha1));
    });

    test('default hostkey includes ECDSA types', () {
      const algorithms = SSHAlgorithms();
      expect(algorithms.hostkey, contains(SSHHostkeyType.ecdsa256));
      expect(algorithms.hostkey, contains(SSHHostkeyType.ecdsa384));
      expect(algorithms.hostkey, contains(SSHHostkeyType.ecdsa521));
    });

    test('default cipher includes AES variants', () {
      const algorithms = SSHAlgorithms();
      expect(algorithms.cipher, contains(SSHCipherType.aes128ctr));
      expect(algorithms.cipher, contains(SSHCipherType.aes128cbc));
      expect(algorithms.cipher, contains(SSHCipherType.aes256ctr));
      expect(algorithms.cipher, contains(SSHCipherType.aes256cbc));
    });

    test('default mac includes HMAC variants', () {
      const algorithms = SSHAlgorithms();
      expect(algorithms.mac, contains(SSHMacType.hmacSha1));
      expect(algorithms.mac, contains(SSHMacType.hmacSha256));
      expect(algorithms.mac, contains(SSHMacType.hmacSha512));
      expect(algorithms.mac, contains(SSHMacType.hmacMd5));
    });

    test('custom kex list is used', () {
      const algorithms = SSHAlgorithms(kex: [SSHKexType.x25519]);
      expect(algorithms.kex, hasLength(1));
      expect(algorithms.kex[0], SSHKexType.x25519);
    });

    test('custom hostkey list is used', () {
      const algorithms = SSHAlgorithms(hostkey: [SSHHostkeyType.ed25519]);
      expect(algorithms.hostkey, hasLength(1));
      expect(algorithms.hostkey[0], SSHHostkeyType.ed25519);
    });

    test('custom cipher list is used', () {
      const algorithms = SSHAlgorithms(cipher: [SSHCipherType.aes256ctr]);
      expect(algorithms.cipher, hasLength(1));
      expect(algorithms.cipher[0], SSHCipherType.aes256ctr);
    });

    test('custom mac list is used', () {
      const algorithms = SSHAlgorithms(mac: [SSHMacType.hmacSha256]);
      expect(algorithms.mac, hasLength(1));
      expect(algorithms.mac[0], SSHMacType.hmacSha256);
    });

    test('empty lists allowed', () {
      const algorithms = SSHAlgorithms(
        kex: [],
        hostkey: [],
        cipher: [],
        mac: [],
      );
      expect(algorithms.kex, isEmpty);
      expect(algorithms.hostkey, isEmpty);
      expect(algorithms.cipher, isEmpty);
      expect(algorithms.mac, isEmpty);
    });
  });
}
