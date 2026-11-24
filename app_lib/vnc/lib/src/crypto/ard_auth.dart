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
    if (prime <= BigInt.one) {
      throw ArgumentError.value(primeBytes, 'primeBytes', 'Prime must be > 1');
    }

    final random = Random.secure();
    final BigInt clientPriv;
    if (clientPrivateKeyOverride != null) {
      if (clientPrivateKeyOverride <= BigInt.zero) {
        throw ArgumentError.value(
          clientPrivateKeyOverride,
          'clientPrivateKeyOverride',
          'Must be positive',
        );
      }
      clientPriv = clientPrivateKeyOverride;
    } else {
      clientPriv = _generatePrivateKey(random, keyLength, prime);
    }

    final serverPub = bytesToBigInt(serverPublicKeyBytes);
    final clientPub = BigInt.from(generator).modPow(clientPriv, prime);
    final clientPubBytes = bigIntToFixedBytes(clientPub, keyLength);

    final shared = serverPub.modPow(clientPriv, prime);
    final sharedBytes = bigIntToFixedBytes(shared, keyLength);
    final aesKey = Uint8List.fromList(md5.convert(sharedBytes).bytes);

    final plaintext = Uint8List(_credentialBlockLength);
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
  }

  static BigInt _generatePrivateKey(
    Random random,
    int keyLength,
    BigInt prime,
  ) {
    final rawBytes = Uint8List(keyLength);
    for (var i = 0; i < keyLength; i++) {
      rawBytes[i] = random.nextInt(256);
    }
    final raw = bytesToBigInt(rawBytes);
    if (prime <= BigInt.two) {
      return BigInt.one;
    }
    // Map into [1, prime - 2] so 1 <= priv < prime - 1.
    return BigInt.one + (raw % (prime - BigInt.two));
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
