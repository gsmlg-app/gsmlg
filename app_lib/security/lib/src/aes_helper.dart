import 'dart:typed_data';

import '../encrypt/encrypt.dart';

/// AES encryption helper with random IV generation for improved security.
///
/// New encryptions use a random 16-byte IV prepended to the ciphertext.
/// Decryption supports both new format (with IV) and legacy format (static IV)
/// for backward compatibility with existing encrypted data.
class AesHelper {
  /// Legacy static IV for backward compatibility with old encrypted data.
  static final IV _legacyIv = IV.fromUtf8('Best in my World');

  /// AES block size / IV length in bytes.
  static const int _ivLength = 16;

  final String appName;
  AesHelper._(this.appName);

  factory AesHelper(String appName) {
    return AesHelper._(appName);
  }

  String salt = 'salt';

  Key get key {
    final ss = '$salt.GSMLG.$appName';
    String s;
    if (ss.length > 32) {
      s = ss.substring(0, 32);
    } else {
      s = ss.padRight(32, '.');
    }
    return Key.fromUtf8(s);
  }

  Encrypter get encrypter {
    return Encrypter(AES(key));
  }

  /// Generates a cryptographically secure random IV.
  IV _generateRandomIv() {
    final random = SecureRandom(_ivLength);
    return IV(random.bytes);
  }

  /// Encrypts text using a random IV.
  /// Returns an Encrypted object containing IV + ciphertext.
  Encrypted encrypt(String text) {
    final iv = _generateRandomIv();
    final encrypted = encrypter.encrypt(text, iv: iv);
    // Prepend IV to ciphertext
    final combined = Uint8List(_ivLength + encrypted.bytes.length);
    combined.setRange(0, _ivLength, iv.bytes);
    combined.setRange(_ivLength, combined.length, encrypted.bytes);
    return Encrypted(combined);
  }

  /// Decrypts text, automatically detecting format (new with IV or legacy).
  String decrypt(Encrypted text) {
    final bytes = text.bytes;
    // Try new format first (IV prepended)
    if (bytes.length > _ivLength) {
      try {
        final iv = IV(Uint8List.sublistView(bytes, 0, _ivLength));
        final ciphertext = Encrypted(Uint8List.sublistView(bytes, _ivLength));
        return encrypter.decrypt(ciphertext, iv: iv);
      } catch (_) {
        // Fall through to legacy format
      }
    }
    // Legacy format with static IV
    return encrypter.decrypt(text, iv: _legacyIv);
  }

  /// Encrypts text and returns base64-encoded result with random IV.
  String encrypt64(String text) {
    return encrypt(text).base64;
  }

  /// Decrypts base64-encoded text, supporting both new and legacy formats.
  String decrypt64(String text) {
    final encrypted = Encrypted.fromBase64(text);
    return decrypt(encrypted);
  }

  Key keyWithSalt(String salt) {
    String ss = '$salt.GSMLG.$appName';
    if (ss.length > 32) {
      ss = ss.substring(0, 32);
    } else {
      ss = ss.padRight(32, '.');
    }
    return Key.fromUtf8(ss);
  }

  /// Encrypts text with salt using random IV.
  /// The IV is prepended to the ciphertext before base64 encoding.
  String encrypt64WithSalt(String text, String salt) {
    final iv = _generateRandomIv();
    final encrypter = Encrypter(AES(keyWithSalt(salt)));
    final encrypted = encrypter.encrypt(text, iv: iv);
    // Prepend IV to ciphertext
    final combined = Uint8List(_ivLength + encrypted.bytes.length);
    combined.setRange(0, _ivLength, iv.bytes);
    combined.setRange(_ivLength, combined.length, encrypted.bytes);
    return Encrypted(combined).base64;
  }

  /// Decrypts text with salt, supporting both new format (with IV) and legacy format.
  String decrypt64WithSalt(String text, String salt) {
    try {
      final bytes = Encrypted.fromBase64(text).bytes;
      final encrypter = Encrypter(AES(keyWithSalt(salt)));

      // Try new format first (IV prepended)
      if (bytes.length > _ivLength) {
        try {
          final iv = IV(Uint8List.sublistView(bytes, 0, _ivLength));
          final ciphertext = Encrypted(Uint8List.sublistView(bytes, _ivLength));
          return encrypter.decrypt(ciphertext, iv: iv);
        } catch (_) {
          // Fall through to legacy format
        }
      }

      // Legacy format with static IV
      return encrypter.decrypt(Encrypted(bytes), iv: _legacyIv);
    } catch (e) {
      throw Exception('Invalid encrypt text or salt');
    }
  }
}
