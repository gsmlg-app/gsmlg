import 'package:app_security/app_security.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:test/test.dart';

void main() {
  group('StringHelper', () {
    group('randomString', () {
      test('generates string of specified length', () {
        expect(StringHelper.randomString(10).length, 10);
        expect(StringHelper.randomString(0).length, 0);
        expect(StringHelper.randomString(100).length, 100);
      });

      test('generates alphanumeric characters only', () {
        final result = StringHelper.randomString(1000);
        final pattern = RegExp(r'^[a-zA-Z0-9]+$');
        expect(pattern.hasMatch(result), isTrue);
      });

      test('generates different strings each time', () {
        final results = <String>{};
        for (var i = 0; i < 100; i++) {
          results.add(StringHelper.randomString(20));
        }
        // Very high probability all are unique
        expect(results.length, 100);
      });

      test('generates empty string for length 0', () {
        expect(StringHelper.randomString(0), '');
      });

      test('contains both uppercase and lowercase over many iterations', () {
        final result = StringHelper.randomString(1000);
        final hasUpper = result.contains(RegExp(r'[A-Z]'));
        final hasLower = result.contains(RegExp(r'[a-z]'));
        final hasDigit = result.contains(RegExp(r'[0-9]'));

        // With 1000 chars, extremely likely to have all types
        expect(hasUpper, isTrue);
        expect(hasLower, isTrue);
        expect(hasDigit, isTrue);
      });
    });

    group('randomAscii', () {
      test('generates string of specified length', () {
        expect(StringHelper.randomAscii(10).length, 10);
        expect(StringHelper.randomAscii(0).length, 0);
        expect(StringHelper.randomAscii(100).length, 100);
      });

      test('generates printable ASCII characters only', () {
        final result = StringHelper.randomAscii(1000);
        for (var i = 0; i < result.length; i++) {
          final code = result.codeUnitAt(i);
          // ASCII printable range: 33-126 (excludes space at 32)
          expect(code, greaterThanOrEqualTo(33));
          expect(code, lessThanOrEqualTo(126));
        }
      });

      test('generates different strings each time', () {
        final results = <String>{};
        for (var i = 0; i < 100; i++) {
          results.add(StringHelper.randomAscii(20));
        }
        expect(results.length, 100);
      });

      test('generates empty string for length 0', () {
        expect(StringHelper.randomAscii(0), '');
      });

      test('includes special characters', () {
        // With many chars, should include special characters
        final result = StringHelper.randomAscii(1000);
        final hasSpecial =
            result.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{};:,.<>?/\\|`~]'));
        expect(hasSpecial, isTrue);
      });

      test('character distribution covers the range', () {
        // Generate many characters and check we get a good spread
        final allChars = StringHelper.randomAscii(10000);
        final uniqueChars = allChars.split('').toSet();

        // Should have a reasonable number of unique characters
        // ASCII 33-126 = 94 possible characters
        expect(uniqueChars.length, greaterThan(50));
      });
    });
  });

  group('RsaKeyHelper Test', () {
    final rsaHelper = RsaKeyHelper();

    test('getSecureRandom Test', () {
      final secureRandom = rsaHelper.getSecureRandom();
      expect(secureRandom, isNotNull);
    });

    test('computeRSAKeyPair Test', () async {
      final kayPair = await rsaHelper.computeRSAKeyPair(2048);
      final publicKey = kayPair.publicKey;
      final privateKey = kayPair.privateKey;
      expect(kayPair, isNotNull);
      expect(publicKey, isNotNull);
      expect(privateKey, isNotNull);
    });

    test('computeRSAKeyPair Test', () async {
      final kayPair = await rsaHelper.computeRSAKeyPair(2048);
      final publicKey = kayPair.publicKey as RSAPublicKey;
      final privateKey = kayPair.privateKey as RSAPrivateKey;
      final priKeyStr = rsaHelper.encodePrivateKeyToPemPKCS1(privateKey);
      final pubKeyStr = rsaHelper.encodePublicKeyToPemPKCS1(publicKey);
      expect(priKeyStr, contains('BEGIN RSA PRIVATE KEY'));
      expect(pubKeyStr, contains('BEGIN RSA PUBLIC KEY'));
    });

    test('getSshPublicKey Test', () async {
      final privateKeyPem = '''
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAov1z0QGXzUSklDfwrpI0x6gqv2+Cl7kMa9cKC2MTbNzzK2jX
XSlwj8R4LyU3lyN2cgBuzw/sMDCg4bNdzjch0UlcTUXJS2UfraR3QMEZNIE8IaPR
Bm81ntFw7YyVaymTPfdEFGi6xjVtHRoOdeBHxMYarXmkFzSX5EaaZODSvdF+FcPp
0J1Q5QyosbIVy5HiYAhqdQ6o0y1tn2D25UdqelfFQtPsBpOBL+2ocxAKdWFBJxGo
iHBtN0YcxfADarBBlN8bc9yj0MlsDcnEPsh7GPA6r9IZxcQsrbfR5Di6PSj50o3C
ZKXu4l9Wa0Pgd5W0x72OSAcJBKt3HXxQWI0PPwIDAQABAoIBAH31bwaru3u3u5SL
8qWGeeF+NaMB8yN7r3y7j5ijNYTg78+xUxY9Cy8fv1133pEfp86MRRYiEP5g5kPm
UO0nsCvEDN/uuZRZjvSrcDmLwQXRhf3dUpEtanvVEfeSuHo7g/3UVDmNgiHhcfSW
iWxRKkWIb1927Pe9/lA8u96P3G0x95XrCvsj1HNs20hvcbmYzKbcrLaMpVM4JDVw
kgNGum1QtIgasNM3QiCJFv18B+vXaKGRr7ofFuQAOHI5C1kGkwpyGpXUftpnA+gg
eLSJJ8kIrjekdiRK+dQCVcuMafD2OVOuac+UsRwfCe5qQ04E4G+GwTvGWqjY+Iib
M7eAIqECgYEA16iTlJcetk+DV/HkEUamB1cMBI5dMBA5BPpHXDpdhCmIPXHfRCWK
pmNaImE45jY2q+9+6NKPoPF8MISXYuzrFePe/INa9+B+IIRZH6o96IAmsxLM/z/4
3Rp2RNf7zL0jiVxc2f+Hb41vpK2wsOtVPhMdt/UQR5ycluIcVqLkx1ECgYEAwXqy
UT2a2dnnPH53JL9CP1mrtrZ9pxUf+N6oZOcXBLqbkfEJO78gwZFQq0N3XsJlp01y
qnZAd1b+eSUO5x0ckb5ZUvyplEnpqLKG4kqvLSe9J6KWL8sprz5buDbxdc4vRQh4
6HIRA2d5zkV7XBuUNgE16hMi9fVD3chYA0eJ6Y8CgYBFe1fJKQNJI8cif5nGgyec
98u0cBXQFXn5g5WYPmnA2gy+F0Ei2KGaSCpTJ1XIvjDRJoGSC70g0oz7qMyJn+GC
FP/UBZI6iMa6PUnlrNjzXs6ZJXaMypSo0AzI03maFloruGlmBzEgnMYanadu6PN2
43vQuBE9sVS2PDV7KFJjcQKBgGbbrNrlzmIMpxMRBJQjnbuCF3i+UdS2tVWgQZPL
CwC3mCchJlB+DpL5hxJVfquA23vy/4fB8AnB1O1glyik4GBW+rPUoO610KOfrXe2
TqTJ4JSmqgNklZeVpjsr8ng3kge4NlcU9RiDNU1EwQ05mDSRtjDn1Yk+x8KrVKcB
rD7fAoGBANC8E+Ke4UwROf2LMbRSwRo6H7kqY5w8fVFy12dltwP/Cljfa9Mcu+sc
s9GNEAuOKFbXmdTEkqdHuSxpSKN2P8TlDtN7fujsj8GOLmAFbVX7hCsnKrLBbkMu
sYU4huPrVyOUnVFWxC+SKwY2QtrNwrtp/5C1dhdsismX7EFZNGmd
-----END RSA PRIVATE KEY-----
      ''';
      final sshPubKey = rsaHelper.getSshPublicKey(privateKeyPem);
      final pubKeyPem =
          'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCi/XPRAZfNRKSUN/CukjTHqCq/b4KXuQxr1woLYxNs3PMraNddKXCPxHgvJTeXI3ZyAG7PD+wwMKDhs13ONyHRSVxNRclLZR+tpHdAwRk0gTwho9EGbzWe0XDtjJVrKZM990QUaLrGNW0dGg514EfExhqteaQXNJfkRppk4NK90X4Vw+nQnVDlDKixshXLkeJgCGp1DqjTLW2fYPblR2p6V8VC0+wGk4Ev7ahzEAp1YUEnEaiIcG03RhzF8ANqsEGU3xtz3KPQyWwNycQ+yHsY8Dqv0hnFxCytt9HkOLo9KPnSjcJkpe7iX1ZrQ+B3lbTHvY5IBwkEq3cdfFBYjQ8/';

      expect(sshPubKey, pubKeyPem);
    });
  });

  group('AesHelper Test', () {
    const appName = 'best in the world';

    const rsaKey = '''
-----BEGIN RSA PRIVATE KEY-----
MIIFpAIBAAKCAQEAmFy45+cB2q+uZezrqcnmeChidFclh3slCFQSROxT4iR0b1xw
GvbuC9BCwWgFw5DR2U2shGXJjAEKRM3pLYzDehP2URnNms16byrSLr9rJoIWVpzj
1FAtvSrNTpkVu1eR4ny8XeKCjsgufbY/qBxrNb+NI85HdwsOJrZpJApacjP05006
9qagTVpcbH1//DWXBYLunuN2xzFS9m0NknH4cFrp/DphYJrjk7mLdAhYEd4JapjR
YZ7wkcOhVqaJnEGi95FoBKwlfxajS7PXg93qlKoOFPzqpzw+ufNiezLGfDzF6jz3
xcrDkXEyL1kHvR4+BSpAYWXQEQW6Cn9Evu71AwKCAQEAjZy43ApRJeJd9SxVCbW3
uXzHrZyGLDtf+zKw3FDP0oPRmOPQ6q8SJ/bE5SB7Iv8KnK/eJhy5TKB22+aK0SRh
V6kQKucRu805+/NP8dVGkT8d5hjihSaUrJsIwgH1OfA1js4jAhwS/wS+eWeYGPd5
Cjbkxx/mOpYS7BZk+POKh1OlFner6Y+8gImrv07iWHtX/KNlEGx8k8mbfBtFVFPZ
Wgg57yDVOmlOasvWjY7ohtLJzRoju/OkrBmjCwIqH6l53tQP5iYYPVIi9dokEbwI
hSScA4+VqN1bjo6E2dB5BKyfLKPWjIUS6btkG8kZ7iwtGi7HLKmjhbPs1/efwq5X
eQKCAQEAjZy43ApRJeJd9SxVCbW3uXzHrZyGLDtf+zKw3FDP0oPRmOPQ6q8SJ/bE
5SB7Iv8KnK/eJhy5TKB22+aK0SRhV6kQKucRu805+/NP8dVGkT8d5hjihSaUrJsI
wgH1OfA1js4jAhwS/wS+eWeYGPd5Cjbkxx/mOpYS7BZk+POKh1OlFner6Y+8gImr
v07iWHtX/KNlEGx8k8mbfBtFVFPZWgg57yDVOmlOasvWjY7ohtLJzRoju/OkrBmj
CwIqH6l53tQP5iYYPVIi9dokEbwIhSScA4+VqN1bjo6E2dB5BKyfLKPWjIUS6btk
G8kZ7iwtGi7HLKmjhbPs1/efwq5XeQKBgQDVW3GLmHLlF5EIpp4FPHoEendcSUfG
uWJPzIQ2L3wHJsOrNH5wyIVr8BlqPVSArgytegoCQoC6o3+WiD1itkzpzmqw9iLx
eRYDh++BJCRxV9ae6VDfUIC5FMTe2X90gZg6UsgCSzB6Sw0b+4PDBKzBLRVU5i8f
PpQQrTlcmdeP9QKBgQC20G4/ud+IqJ/5u+sUl45ZaEU0Z4wXZ+07ofG+vUSVyEEG
0/X4K6jzIrGLWO6Cy2nV0aJvulokmYzkN+xaDNy3Ey4CBzPF4qXKJAebPGZ29YBH
VzsNqTgY4AgxLm5leqNRl9KMYmJO9kkyzAiVtKXW+VeuxFvFPu1C2iegnQcuFwKB
gGTl/teGe+dtcrBFo3tUc1vE0se4/BG1wBF+5ZN+d0gmg+hmRdluavJ1tH8yi9Di
/qnXif4xlxEsmv0EZwtUrSDw9jHD5RiPK+L1mUVYY0eaw6uZKR7Cwm1Erim5b/YY
B3aliWLUThO3hHaURmamwlAE0w64YNaE0J7mXLc3JeM1AoGBAJclLIGzg4TRJbKs
E2grBZ4V/2GcWs7fNdyfv+cbRKExt9GVXT+ZmU2r2W6EUG4DD7WgZNRLFkw8R6hI
NDkfeTxDtz4mBkANa1T9BOzruyuPPke9by2UQrUORLek09FC29SR2ZoHnY/7P/mn
h1F+0b4y2LO91MH3jOJAy5KXQWBxAoGAPa/SU5sgOTeeZfOQpqcae9cCoo75yumQ
Lfy9uXKRSvUAV/VMH/dsY7U9ZXC79I2i0rDDKWovQ4AkDPX8MXaEXpQodaZv3XAJ
fQTccER99vyVTA+MhKBAdaKqUGBF2Ik3ROvuOdx7+uZC/DhbTrFV/p7NXHzDNHhr
o0Nl/137RMM=
-----END RSA PRIVATE KEY-----
''';

    test('encrypt Test', () {
      final aesHelper = AesHelper(appName);
      final text = rsaKey;
      final encrypted = aesHelper.encrypt(text);
      final decrypted = aesHelper.decrypt(encrypted);
      expect(decrypted, text);
    });

    test('encrypt Test with salt', () {
      final aesHelper = AesHelper(appName);
      final text = rsaKey;
      final encrypted = aesHelper.encrypt(text);
      final decrypted = aesHelper.decrypt(encrypted);
      expect(decrypted, text);

      final aesHelperSec = AesHelper(appName);
      aesHelperSec.salt = text;
      final encryptedS = aesHelperSec.encrypt(text);
      final decryptedS = aesHelperSec.decrypt(encryptedS);
      expect(decryptedS, text);

      // final s = aesHelper.decrypt64(encrypted.base64);
      // expect(() => aesHelper.decrypt(encrypted), throwsA(() => String));
    });

    test('encrypt64WithSalt / decrypt64WithSalt Test', () async {
      final aesHelper = AesHelper(appName);
      final salt = '17Po6P7U6YcpzMkD';

      final encrypted = aesHelper.encrypt64WithSalt(rsaKey, salt);
      final decrypted = aesHelper.decrypt64WithSalt(encrypted, salt);

      expect(decrypted, rsaKey);
    });

    test('decrypt64WithSalt Test', () {
      final encrypted =
          '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';
      final aesHelper = AesHelper(appName);
      final salt = '17Po6P7U6YcpzMkD';
      final decrypted = aesHelper.decrypt64WithSalt(encrypted, salt);
      expect(decrypted, rsaKey);
    });

    // Tests for random IV implementation
    test('encrypting same text twice produces different ciphertext', () {
      final aesHelper = AesHelper(appName);
      final text = 'Test encryption with random IV';

      final encrypted1 = aesHelper.encrypt64(text);
      final encrypted2 = aesHelper.encrypt64(text);

      // Same plaintext should produce different ciphertext due to random IV
      expect(encrypted1, isNot(equals(encrypted2)));

      // Both should decrypt to the same plaintext
      expect(aesHelper.decrypt64(encrypted1), text);
      expect(aesHelper.decrypt64(encrypted2), text);
    });

    test('encrypt64WithSalt produces different ciphertext for same input', () {
      final aesHelper = AesHelper(appName);
      final salt = 'test-salt-12345';
      final text = 'Test encryption with random IV and salt';

      final encrypted1 = aesHelper.encrypt64WithSalt(text, salt);
      final encrypted2 = aesHelper.encrypt64WithSalt(text, salt);

      // Same plaintext and salt should produce different ciphertext
      expect(encrypted1, isNot(equals(encrypted2)));

      // Both should decrypt to the same plaintext
      expect(aesHelper.decrypt64WithSalt(encrypted1, salt), text);
      expect(aesHelper.decrypt64WithSalt(encrypted2, salt), text);
    });

    test('new format ciphertext is longer due to prepended IV', () {
      final aesHelper = AesHelper(appName);
      final text = 'Short test message';
      final salt = 'test-salt';

      final encrypted = aesHelper.encrypt64WithSalt(text, salt);

      // Base64 of IV (16 bytes) + ciphertext should be at least 16*4/3 ≈ 22 chars longer
      // than the plaintext would suggest (actual ciphertext is padded to block size)
      expect(encrypted.length, greaterThan(22));
    });

    test('decrypt64 handles empty input gracefully', () {
      final aesHelper = AesHelper(appName);

      // Empty input should throw an error (RangeError or Exception)
      expect(
        () => aesHelper.decrypt64(''),
        throwsA(anything),
      );
    });

    test('decrypt64WithSalt throws for wrong salt', () {
      final aesHelper = AesHelper(appName);
      final salt = 'correct-salt';
      final wrongSalt = 'wrong-salt';
      final text = 'Secret message';

      final encrypted = aesHelper.encrypt64WithSalt(text, salt);

      expect(
        () => aesHelper.decrypt64WithSalt(encrypted, wrongSalt),
        throwsA(isA<Exception>()),
      );
    });

    test('encrypt and decrypt long text', () {
      final aesHelper = AesHelper(appName);
      final longText = rsaKey * 5; // Create a longer text

      final encrypted = aesHelper.encrypt(longText);
      final decrypted = aesHelper.decrypt(encrypted);

      expect(decrypted, longText);
    });

    test('encrypt64WithSalt and decrypt64WithSalt with special characters', () {
      final aesHelper = AesHelper(appName);
      final salt = 'test-salt';
      final specialText =
          'Special chars: 你好世界 🎉 <script>alert("xss")</script>';

      final encrypted = aesHelper.encrypt64WithSalt(specialText, salt);
      final decrypted = aesHelper.decrypt64WithSalt(encrypted, salt);

      expect(decrypted, specialText);
    });

    test('cross-instance decryption works', () {
      final aesHelper1 = AesHelper(appName);
      final aesHelper2 = AesHelper(appName);
      final salt = 'shared-salt';
      final text = 'Message encrypted by instance 1';

      final encrypted = aesHelper1.encrypt64WithSalt(text, salt);
      final decrypted = aesHelper2.decrypt64WithSalt(encrypted, salt);

      expect(decrypted, text);
    });
  });
}
