import 'package:app_security/app_security.dart';
import 'package:asn1lib/asn1lib.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:test/test.dart';

void main() {
  final helper = RsaKeyHelper();
  final privateKey = RSAPrivateKey(
    BigInt.from(3233),
    BigInt.from(2753),
    BigInt.from(61),
    BigInt.from(53),
  );

  test('PKCS#1 serialization preserves public and private exponents', () {
    final pem = helper.encodePrivateKeyToPemPKCS1(privateKey);
    final sequence =
        ASN1Parser(helper.decodePEM(pem)).nextObject() as ASN1Sequence;

    expect(
      (sequence.elements[2] as ASN1Integer).valueAsBigInteger,
      BigInt.from(17),
    );
    expect(
      (sequence.elements[3] as ASN1Integer).valueAsBigInteger,
      BigInt.from(2753),
    );
  });

  test('serialized public fields match the displayed SSH public key', () {
    final pem = helper.encodePrivateKeyToPemPKCS1(privateKey);
    final sequence =
        ASN1Parser(helper.decodePEM(pem)).nextObject() as ASN1Sequence;
    final modulus = (sequence.elements[1] as ASN1Integer).valueAsBigInteger;
    final publicExponent =
        (sequence.elements[2] as ASN1Integer).valueAsBigInteger;
    final serializedPublicKey = helper.encodeRsaPublicKeyToSsh(
      RSAPublicKey(modulus, publicExponent),
    );

    expect(serializedPublicKey, helper.getSshPublicKey(pem));
  });
}
