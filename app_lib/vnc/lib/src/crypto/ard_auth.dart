import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';

/// Client payload for Apple Remote Desktop (RFB security type 30) Diffie-Hellman
/// authentication.
@immutable
class ArdAuthResponse {
  const ArdAuthResponse({
    required this.encryptedCredentials,
    required this.clientPublicKey,
  });

  /// 128-byte AES-128-ECB encrypted username (64 bytes) and password (64 bytes).
  final Uint8List encryptedCredentials;

  /// Fixed-length big-endian Diffie-Hellman client public key.
  final Uint8List clientPublicKey;
}

/// Cryptographic primitives for macOS Apple Remote Desktop (RFB security type 30)
/// authentication.
abstract final class ArdAuthCrypto {
  static const int _credentialBlockLength = 128;
  static const int _fieldLength = 64;
  static const int _maxFieldPayloadBytes = 63;

  /// Converts an unsigned big-endian byte sequence to a [BigInt].
  static BigInt bytesToBigInt(Uint8List bytes) {
    var result = BigInt.zero;
    for (final byte in bytes) {
      result = (result << 8) | BigInt.from(byte & 0xFF);
    }
    return result;
  }

  /// Encodes a non-negative [BigInt] as a fixed-[length] unsigned big-endian
  /// byte array, left-padded with zeros.
  static Uint8List bigIntToFixedBytes(BigInt value, int length) {
    if (length < 0) {
      throw ArgumentError.value(length, 'length', 'Must be non-negative');
    }
    if (value.isNegative) {
      throw ArgumentError.value(value, 'value', 'Must be non-negative');
    }

    final out = Uint8List(length);
    var remaining = value;
    final mask = BigInt.from(0xFF);
    for (var i = length - 1; i >= 0; i--) {
      out[i] = (remaining & mask).toInt();
      remaining >>= 8;
    }
    if (remaining != BigInt.zero) {
      throw ArgumentError.value(
        value,
        'value',
        'Exceeds fixed byte length $length',
      );
    }
    return out;
  }

  /// Builds the Apple Remote Desktop (Type 30) client response.
  ///
  /// Performs Diffie-Hellman key agreement using [generator], [primeBytes], and
  /// [serverPublicKeyBytes], derives a 16-byte AES-128 key via MD5 of the
  /// fixed-width shared secret, and encrypts the 128-byte credential payload
  /// (64-byte null-terminated username + 64-byte null-terminated password with
  /// random padding) in AES-128-ECB mode.
  static ArdAuthResponse buildResponse({
    required int generator,
    required int keyLength,
    required Uint8List primeBytes,
    required Uint8List serverPublicKeyBytes,
    required String username,
    required String password,
    BigInt? clientPrivateKeyOverride,
  }) {
    if (keyLength <= 0) {
      throw ArgumentError.value(keyLength, 'keyLength', 'Must be positive');
    }
    if (primeBytes.length != keyLength) {
      throw ArgumentError.value(
        primeBytes.length,
        'primeBytes',
        'Must match keyLength ($keyLength)',
      );
    }
    if (serverPublicKeyBytes.length != keyLength) {
      throw ArgumentError.value(
        serverPublicKeyBytes.length,
        'serverPublicKeyBytes',
        'Must match keyLength ($keyLength)',
      );
    }

    final prime = bytesToBigInt(primeBytes);
    if (prime <= BigInt.from(3)) {
      throw ArgumentError.value(primeBytes, 'primeBytes', 'Prime must be > 3');
    }

    final generatorBig = BigInt.from(generator);
    if (generator < 2 || generatorBig >= prime) {
      throw ArgumentError.value(
        generator,
        'generator',
        'Generator must satisfy 2 <= generator < prime',
      );
    }

    final maxKey = prime - BigInt.two;
    final serverPub = bytesToBigInt(serverPublicKeyBytes);
    if (serverPub < BigInt.two || serverPub > maxKey) {
      throw ArgumentError.value(
        serverPublicKeyBytes,
        'serverPublicKeyBytes',
        'Server public key must satisfy 2 <= serverPub <= prime - 2',
      );
    }

    final random = Random.secure();
    final BigInt clientPriv;
    if (clientPrivateKeyOverride != null) {
      if (clientPrivateKeyOverride < BigInt.two ||
          clientPrivateKeyOverride > maxKey) {
        throw ArgumentError.value(
          clientPrivateKeyOverride,
          'clientPrivateKeyOverride',
          'Must satisfy 2 <= clientPrivateKey <= prime - 2',
        );
      }
      clientPriv = clientPrivateKeyOverride;
    } else {
      clientPriv = _generatePrivateKey(random, prime);
    }

    final clientPub = generatorBig.modPow(clientPriv, prime);
    final clientPubBytes = bigIntToFixedBytes(clientPub, keyLength);

    Uint8List? sharedBytes;
    Uint8List? aesKey;
    Uint8List? plaintext;
    try {
      final shared = serverPub.modPow(clientPriv, prime);
      sharedBytes = bigIntToFixedBytes(shared, keyLength);
      aesKey = Uint8List.fromList(md5.convert(sharedBytes).bytes);

      plaintext = Uint8List(_credentialBlockLength);
      _writeCredentialField(plaintext, 0, username, random);
      _writeCredentialField(plaintext, _fieldLength, password, random);

      final aes = AESEngine()..init(true, KeyParameter(aesKey));
      final encrypted = Uint8List(_credentialBlockLength);
      for (var offset = 0; offset < _credentialBlockLength; offset += 16) {
        aes.processBlock(plaintext, offset, encrypted, offset);
      }

      return ArdAuthResponse(
        encryptedCredentials: encrypted,
        clientPublicKey: clientPubBytes,
      );
    } finally {
      sharedBytes?.fillRange(0, sharedBytes.length, 0);
      aesKey?.fillRange(0, aesKey.length, 0);
      plaintext?.fillRange(0, plaintext.length, 0);
    }
  }

  /// Generates a uniform random private key in `[2, prime - 2]` using
  /// unbiased rejection sampling over `prime.bitLength` bits.
  static BigInt _generatePrivateKey(Random random, BigInt prime) {
    final min = BigInt.two;
    final max = prime - BigInt.two;
    final bitLength = prime.bitLength;
    final byteCount = (bitLength + 7) ~/ 8;
    final excessBits = byteCount * 8 - bitLength;
    final topMask = 0xFF >>> excessBits;

    final rawBytes = Uint8List(byteCount);
    try {
      while (true) {
        for (var i = 0; i < byteCount; i++) {
          rawBytes[i] = random.nextInt(256);
        }
        rawBytes[0] &= topMask;
        final candidate = bytesToBigInt(rawBytes);
        if (candidate >= min && candidate <= max) {
          return candidate;
        }
      }
    } finally {
      rawBytes.fillRange(0, rawBytes.length, 0);
    }
  }

  static void _writeCredentialField(
    Uint8List buffer,
    int fieldOffset,
    String value,
    Random random,
  ) {
    final payload = _encodeUtf8Truncated(value, _maxFieldPayloadBytes);
    buffer.setRange(fieldOffset, fieldOffset + payload.length, payload);
    buffer[fieldOffset + payload.length] = 0;
    for (var i = payload.length + 1; i < _fieldLength; i++) {
      buffer[fieldOffset + i] = random.nextInt(256);
    }
  }

  /// Encodes [value] as UTF-8, truncating at a scalar value boundary so the
  /// resulting byte length never exceeds [maxBytes].
  static Uint8List _encodeUtf8Truncated(String value, int maxBytes) {
    final full = utf8.encode(value);
    if (full.length <= maxBytes) {
      return Uint8List.fromList(full);
    }

    final builder = BytesBuilder(copy: false);
    var total = 0;
    for (final rune in value.runes) {
      final encoded = utf8.encode(String.fromCharCode(rune));
      if (total + encoded.length > maxBytes) {
        break;
      }
      builder.add(encoded);
      total += encoded.length;
    }
    return builder.takeBytes();
  }
}
