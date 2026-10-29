import 'dart:typed_data';

import 'package:app_ssh/src/ssh_algorithm.dart';
import 'package:pointycastle/export.dart';

class SSHMacType with SSHAlgorithm {
  static const hmacMd5 = SSHMacType._(
    name: 'hmac-md5',
    keySize: 16,
    macFactory: _hmacMd5Factory,
  );

  static const hmacSha1 = SSHMacType._(
    name: 'hmac-sha1',
    keySize: 20,
    macFactory: _hmacSha1Factory,
  );

  static const hmacSha256 = SSHMacType._(
    name: 'hmac-sha2-256',
    keySize: 32,
    macFactory: _hmacSha256Factory,
  );

  static const hmacSha512 = SSHMacType._(
    name: 'hmac-sha2-512',
    keySize: 64,
    macFactory: _hmacSha512Factory,
  );

  static const hmacSha1Etm = SSHMacType._(
    name: 'hmac-sha1-etm@openssh.com',
    keySize: 20,
    macFactory: _hmacSha1Factory,
    isETM: true,
  );

  static const hmacSha256Etm = SSHMacType._(
    name: 'hmac-sha2-256-etm@openssh.com',
    keySize: 32,
    macFactory: _hmacSha256Factory,
    isETM: true,
  );

  static const hmacSha512Etm = SSHMacType._(
    name: 'hmac-sha2-512-etm@openssh.com',
    keySize: 64,
    macFactory: _hmacSha512Factory,
    isETM: true,
  );

  static const hmacMd5Etm = SSHMacType._(
    name: 'hmac-md5-etm@openssh.com',
    keySize: 16,
    macFactory: _hmacMd5Factory,
    isETM: true,
  );

  const SSHMacType._({
    required this.name,
    required this.keySize,
    required this.macFactory,
    this.isETM = false,
  });

  /// The name of the algorithm. For example, `"aes256-ctr`"`.
  @override
  final String name;

  /// The length of the key in bytes. This is the same as the length of the
  /// output of the MAC algorithm.
  final int keySize;

  /// Whether this is an Encrypt-Then-MAC variant.
  /// ETM computes MAC over the ciphertext instead of plaintext.
  final bool isETM;

  final Mac Function() macFactory;

  Mac createMac(Uint8List key) {
    if (key.length != keySize) {
      throw ArgumentError.value(key, 'key', 'Key must be $keySize bytes long');
    }

    final mac = macFactory();
    mac.init(KeyParameter(key));
    return mac;
  }
}

Mac _hmacMd5Factory() {
  return HMac(MD5Digest(), 64);
}

Mac _hmacSha1Factory() {
  return HMac(SHA1Digest(), 64);
}

Mac _hmacSha256Factory() {
  return HMac(SHA256Digest(), 64);
}

Mac _hmacSha512Factory() {
  return HMac(SHA512Digest(), 128);
}
