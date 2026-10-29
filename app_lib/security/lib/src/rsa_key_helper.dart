import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import "package:asn1lib/asn1lib.dart";
import "package:pointycastle/export.dart";

/// Helper class to handle RSA key generation and encoding
class RsaKeyHelper {
  /// Generate a [PublicKey] and [PrivateKey] pair
  ///
  /// Returns a [AsymmetricKeyPair] based on the [RSAKeyGenerator] with custom parameters,
  /// including a [SecureRandom]
  Future<AsymmetricKeyPair<PublicKey, PrivateKey>> computeRSAKeyPair(
      int bitLength) async {
    return await Isolate.run(() => generateRsaKeyPair(bitLength: bitLength));
  }

  String getPrivateKeyPem(AsymmetricKeyPair<PublicKey, PrivateKey> keyPair) {
    var privateKey = keyPair.privateKey as RSAPrivateKey;
    return encodePrivateKeyToPemPKCS1(privateKey);
  }

  /// Generates a [SecureRandom]
  ///
  /// Returns [FortunaRandom] to be used in the [AsymmetricKeyPair] generation
  SecureRandom getSecureRandom() {
    var secureRandom = FortunaRandom();
    var random = Random.secure();
    List<int> seeds = [];
    for (int i = 0; i < 32; i++) {
      seeds.add(random.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
  }

  /// Decode Public key from PEM Format
  ///
  /// Given a base64 encoded PEM [String] with correct headers and footers, return a
  /// [RSAPublicKey]
  ///
  /// *PKCS1*
  /// RSAPublicKey ::= SEQUENCE {
  ///    modulus           INTEGER,  -- n
  ///    publicExponent    INTEGER   -- e
  /// }
  ///
  /// *PKCS8*
  /// PublicKeyInfo ::= SEQUENCE {
  ///   algorithm       AlgorithmIdentifier,
  ///   PublicKey       BIT STRING
  /// }
  ///
  /// AlgorithmIdentifier ::= SEQUENCE {
  ///   algorithm       OBJECT IDENTIFIER,
  ///   parameters      ANY DEFINED BY algorithm OPTIONAL
  /// }
  RSAPublicKey parsePublicKeyFromPem(String pemString) {
    Uint8List publicKeyDER = decodePEM(pemString);
    var asn1Parser = ASN1Parser(publicKeyDER);
    var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

    ASN1Integer modulus, exponent;
    // Depending on the first element type, we either have PKCS1 or 2
    if (topLevelSeq.elements[0].runtimeType == ASN1Integer) {
      modulus = topLevelSeq.elements[0] as ASN1Integer;
      exponent = topLevelSeq.elements[1] as ASN1Integer;
    } else {
      var publicKeyBitString = topLevelSeq.elements[1];

      var publicKeyAsn = ASN1Parser(publicKeyBitString.contentBytes());
      ASN1Object publicKeySeq = publicKeyAsn.nextObject();
      modulus = ASN1Integer.fromBytes(publicKeySeq.encodedBytes);
      publicKeySeq = publicKeyAsn.nextObject();
      exponent = ASN1Integer.fromBytes(publicKeySeq.encodedBytes);
    }

    RSAPublicKey rsaPublicKey =
        RSAPublicKey(modulus.valueAsBigInteger, exponent.valueAsBigInteger);

    return rsaPublicKey;
  }

  /// Sign plain text with Private Key
  ///
  /// Given a plain text [String] and a [RSAPrivateKey], decrypt the text using
  /// a [RSAEngine] cipher
  String sign(String plainText, RSAPrivateKey privateKey) {
    var signer = RSASigner(SHA256Digest(), "0609608648016503040201");
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));
    return base64Encode(
        signer.generateSignature(createUint8ListFromString(plainText)).bytes);
  }

  /// Creates a [Uint8List] from a string to be signed
  Uint8List createUint8ListFromString(String s) {
    var codec = Utf8Codec(allowMalformed: true);
    return Uint8List.fromList(codec.encode(s));
  }

  /// Decode Private key from PEM Format
  ///
  /// Given a base64 encoded PEM [String] with correct headers and footers, return a
  /// [RSAPrivateKey]
  RSAPrivateKey parsePrivateKeyFromPem(String pemString) {
    Uint8List privateKeyDER = decodePEM(pemString);
    var asn1Parser = ASN1Parser(privateKeyDER);
    var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

    ASN1Integer modulus, privateExponent, p, q;
    // Depending on the number of elements, we will either use PKCS1 or PKCS8
    if (topLevelSeq.elements.length == 3) {
      var privateKey = topLevelSeq.elements[2];

      asn1Parser = ASN1Parser(privateKey.contentBytes());
      var pkSeq = asn1Parser.nextObject() as ASN1Sequence;

      modulus = pkSeq.elements[1] as ASN1Integer;
      privateExponent = pkSeq.elements[3] as ASN1Integer;
      p = pkSeq.elements[4] as ASN1Integer;
      q = pkSeq.elements[5] as ASN1Integer;
    } else {
      modulus = topLevelSeq.elements[1] as ASN1Integer;
      privateExponent = topLevelSeq.elements[3] as ASN1Integer;
      p = topLevelSeq.elements[4] as ASN1Integer;
      q = topLevelSeq.elements[5] as ASN1Integer;
    }

    RSAPrivateKey rsaPrivateKey = RSAPrivateKey(
        modulus.valueAsBigInteger,
        privateExponent.valueAsBigInteger,
        p.valueAsBigInteger,
        q.valueAsBigInteger);

    return rsaPrivateKey;
  }

  Uint8List decodePEM(String pem) {
    return base64.decode(removePemHeaderAndFooter(pem));
  }

  String removePemHeaderAndFooter(String pem) {
    var str = pem.replaceAll(RegExp(r'-----[A-Z ]+-----'), '');
    str = str.replaceAll(RegExp(r'\s+'), '');

    return str;
  }

  /// Encode Private key to PEM Format
  ///
  /// Given [RSAPrivateKey] returns a base64 encoded [String] with standard PEM headers and footers
  String encodePrivateKeyToPemPKCS1(RSAPrivateKey privateKey) {
    var topLevel = ASN1Sequence();

    var version = ASN1Integer(BigInt.from(0));
    var modulus = ASN1Integer(privateKey.n!);
    var publicExponent = ASN1Integer(privateKey.publicExponent!);
    var privateExponent = ASN1Integer(privateKey.privateExponent!);
    var p = ASN1Integer(privateKey.p!);
    var q = ASN1Integer(privateKey.q!);
    var dP = privateKey.privateExponent! % (privateKey.p! - BigInt.from(1));
    var exp1 = ASN1Integer(dP);
    var dQ = privateKey.privateExponent! % (privateKey.q! - BigInt.from(1));
    var exp2 = ASN1Integer(dQ);
    var iQ = privateKey.q!.modInverse(privateKey.p!);
    var co = ASN1Integer(iQ);

    topLevel.add(version);
    topLevel.add(modulus);
    topLevel.add(publicExponent);
    topLevel.add(privateExponent);
    topLevel.add(p);
    topLevel.add(q);
    topLevel.add(exp1);
    topLevel.add(exp2);
    topLevel.add(co);

    var dataBase64 = base64.encode(topLevel.encodedBytes);

    return """-----BEGIN RSA PRIVATE KEY-----\r\n${_splitStringToParts(dataBase64).join('\r\n')}\r\n-----END RSA PRIVATE KEY-----""";
  }

  /// Encode Public key to PEM Format
  ///
  /// Given [RSAPublicKey] returns a base64 encoded [String] with standard PEM headers and footers
  String encodePublicKeyToPemPKCS1(RSAPublicKey publicKey) {
    var topLevel = ASN1Sequence();

    topLevel.add(ASN1Integer(publicKey.modulus!));
    topLevel.add(ASN1Integer(publicKey.exponent!));

    var dataBase64 = base64.encode(topLevel.encodedBytes);
    return """-----BEGIN RSA PUBLIC KEY-----\r\n$dataBase64\r\n-----END RSA PUBLIC KEY-----""";
  }

  RSAPublicKey publicKeyFromPrivateKey(RSAPrivateKey privateKey) {
    // The modulus (n) is the same for both public and private keys
    final modulus = privateKey.modulus!;
    // The public exponent (e) is stored in the private key
    final publicExponent = privateKey.publicExponent!;

    return RSAPublicKey(modulus, publicExponent);
  }

  String getSshPublicKey(String privateKeyPem) {
    final privateKey = parsePrivateKeyFromPem(privateKeyPem);
    final publicKey = publicKeyFromPrivateKey(privateKey);
    final parts = encodeRsaPublicKeyToSsh(publicKey);
    return parts;
  }

  String encodeRsaPublicKeyToSsh(RSAPublicKey publicKey) {
    // Helper function to encode a string with its length prefix
    Uint8List encodeString(List<int> value) {
      final length = value.length;
      final lengthBytes = Uint8List(4)
        ..buffer.asByteData().setUint32(0, length, Endian.big);
      return Uint8List.fromList([...lengthBytes, ...value]);
    }

    // SSH key format requires specific headers
    const sshRsaHeader = 'ssh-rsa';

    // Extract the modulus (n) and exponent (e) from the public key
    final exponent = _encodeMPInt(publicKey.exponent!);
    final modulus = _encodeMPInt(publicKey.modulus!);

    // Encode the parts using SSH key format
    final sshEncoded = <int>[];

    // Add the ssh-rsa header
    sshEncoded.addAll(encodeString(sshRsaHeader.codeUnits));

    // Add the exponent
    sshEncoded.addAll(encodeString(exponent));

    // Add the modulus
    sshEncoded.addAll(encodeString(modulus));

    // Base64 encode the result
    final base64Key = base64Encode(sshEncoded);

    // Return the final SSH public key format string
    return '$sshRsaHeader $base64Key';
  }

  List<String> _splitStringToParts(String text, {int chunkSize = 64}) {
    final parts = <String>[];
    var start = 0;
    while (start < text.length) {
      final end = min(start + chunkSize, text.length);
      parts.add(text.substring(start, end));
      start = end;
    }
    return parts;
  }

  //----------------------------------------------------------------
  /// Encode a multiple precision integer.
  ///
  /// Returns a sequence of bytes that represents the [value] as a multiple
  /// precision integer. See section 5 of
  /// [RFC 4251](https://tools.ietf.org/html/rfc4251#section-5) for a definition
  /// of this format.
  ///
  /// Note: the returned value is just the number and does not have any bytes
  /// to indicate its length.
  Uint8List _encodeMPInt(BigInt value) {
    if (value == BigInt.zero) {
      return Uint8List(0); // no bytes in representation
    } else if (!value.isNegative) {
      // Positive multiple precision integer

      var e = value;

      final numBytes = 2 + ((e.bitLength - 1) ~/ 8);
      final bytes = Uint8List(numBytes);

      // Extract each byte of the number, starting with least-significant-byte
      // (the right most byte and working back to the beginning)

      var i = numBytes - 1;

      while (1 <= i) {
        final b = e & BigInt.from(0xFF); // least significant byte
        e = e >> 8;
        bytes[i--] = b.toInt();
      }
      assert(e == BigInt.zero);

      // The padding byte is only needed if the first real byte has its MSB set

      bytes[0] = 0x00; // padding byte
      final start = (bytes[1] & 0x80 != 0) ? 0 : 1; // use padding byte or not

      return bytes.sublist(start);
    } else {
      // Negative multiple precision integer: represent as twos-complement

      final x = (value.abs() - BigInt.one).bitLength + 1;
      var bytesToHoldTwosComplement = x ~/ 8;
      if (x % 8 != 0) {
        bytesToHoldTwosComplement += 1; // to hold additional bits
      }
      assert(0 < bytesToHoldTwosComplement);

      final msbContrib = BigInt.two.pow((bytesToHoldTwosComplement * 8) - 1);
      var e = value + msbContrib; // without negative MSB contribution
      assert(!e.isNegative);

      final numBytes = bytesToHoldTwosComplement + 1;
      final bytes = Uint8List(numBytes);

      // Encode e using ones-complement, starting with the
      // least-significant-byte
      // (the right most byte and working back to the beginning)

      var i = numBytes - 1;

      while (1 <= i) {
        final b = (e & BigInt.from(0xFF)); // least significant byte, bit-neg
        e = e >> 8;
        bytes[i--] = b.toInt();
      }
      assert(e == BigInt.zero);

      // Incorporate negative 2 ^ (N - 1) factor

      if (bytes[1] & 0x80 != 0x80) {
        // MSB on first byte is not set: can use it for the MSB
        bytes[1] |= 0x80; // set the MSB on the first byte
        return bytes.sublist(1); // result without the extra padding byte
      } else {
        // MSB on first byte is already set: need to use the padding byte
        bytes[0] = 0x80; // set the MSB on padding byte and zero the rest of it
        return bytes; // result is the padding byte and the other bytes
      }
    }
  }
}

/// Generate a [PublicKey] and [PrivateKey] pair
///
/// Returns a [AsymmetricKeyPair] based on the [RSAKeyGenerator] with custom parameters,
/// including a [SecureRandom]
AsymmetricKeyPair<PublicKey, PrivateKey> generateRsaKeyPair(
    {int bitLength = 2048}) {
  var secureRandom = FortunaRandom();
  var random = Random.secure();
  List<int> seeds = [];
  for (int i = 0; i < 32; i++) {
    seeds.add(random.nextInt(255));
  }
  secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
  var rsapars = RSAKeyGeneratorParameters(BigInt.from(65537), bitLength, 5);
  var params = ParametersWithRandom(rsapars, secureRandom);
  var keyGenerator = RSAKeyGenerator();
  keyGenerator.init(params);
  return keyGenerator.generateKeyPair();
}
