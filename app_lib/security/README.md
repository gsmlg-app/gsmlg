# App Security

A Dart/Flutter package providing cryptographic utilities for secure data encryption and key generation.

## Features

- **AES Encryption**: AES-256 symmetric encryption with random IV generation
- **RSA Key Handling**: RSA key pair parsing and conversion utilities
- **Secure Random**: Cryptographically secure random string generation
- **Salt-based Encryption**: Key derivation with customizable salt values
- **Backward Compatibility**: Supports legacy encryption formats while using improved security

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  app_security:
    path: ../app_lib/security
```

## Usage

### AES Encryption

```dart
import 'package:app_security/app_security.dart';

// Create an AES helper with your app name
final aes = AesHelper('MyApp');

// Simple encryption/decryption
final encrypted = aes.encrypt64('secret message');
final decrypted = aes.decrypt64(encrypted);

// Encryption with custom salt
final saltEncrypted = aes.encrypt64WithSalt('secret', 'custom-salt');
final saltDecrypted = aes.decrypt64WithSalt(saltEncrypted, 'custom-salt');
```

### RSA Key Handling

```dart
import 'package:app_security/app_security.dart';

// Parse PEM-encoded RSA keys
final publicKey = RsaKeyHelper.parsePublicKeyFromPem(pemString);
final privateKey = RsaKeyHelper.parsePrivateKeyFromPem(pemString);

// Encrypt/decrypt with RSA
final rsaEncrypted = RsaKeyHelper.rsaEncrypt(publicKey, plainText);
final rsaDecrypted = RsaKeyHelper.rsaDecrypt(privateKey, rsaEncrypted);
```

### Secure Random Strings

```dart
import 'package:app_security/app_security.dart';

// Generate random string for passwords, tokens, etc.
final randomString = StringHelper.getRandomString(32);
final alphanumeric = StringHelper.getRandomAlphanumericString(16);
```

## Components

### AesHelper

AES-256 encryption helper with automatic IV management.

| Method | Description |
|--------|-------------|
| `encrypt(String)` | Encrypt text, returns `Encrypted` with IV prepended |
| `decrypt(Encrypted)` | Decrypt, auto-detects IV format |
| `encrypt64(String)` | Encrypt and return base64 string |
| `decrypt64(String)` | Decrypt base64-encoded ciphertext |
| `encrypt64WithSalt(String, String)` | Encrypt with custom salt |
| `decrypt64WithSalt(String, String)` | Decrypt with custom salt |

### RsaKeyHelper

RSA key management and cryptographic operations.

| Method | Description |
|--------|-------------|
| `parsePublicKeyFromPem(String)` | Parse PEM-encoded public key |
| `parsePrivateKeyFromPem(String)` | Parse PEM-encoded private key |
| `rsaEncrypt(RSAPublicKey, String)` | Encrypt with public key |
| `rsaDecrypt(RSAPrivateKey, String)` | Decrypt with private key |

### StringHelper

Secure random string generation.

| Method | Description |
|--------|-------------|
| `getRandomString(int)` | Generate random string of given length |
| `getRandomAlphanumericString(int)` | Generate alphanumeric random string |

## Security Notes

- **Random IV**: New encryptions use cryptographically secure random IVs (16 bytes)
- **Key Derivation**: Keys are derived from app name and salt using deterministic padding
- **Legacy Support**: Decryption automatically handles both new (random IV) and legacy (static IV) formats
- **No Static IVs in New Encryptions**: Same plaintext produces different ciphertext on each encryption

## Dependencies

Uses the vendored `encrypt` package for underlying cryptographic operations with AES and RSA algorithms.
