import 'dart:convert';
import 'dart:typed_data';

import 'package:app_ssh/app_ssh.dart';
import 'package:app_ssh/src/hostkey/hostkey_rsa.dart';
import 'package:asn1lib/asn1lib.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  final originalPem = fixture('ssh-rsa/id_rsa');
  final originalSequence = ASN1Parser(SSHPem.decode(originalPem).content)
      .nextObject() as ASN1Sequence;
  final legacySequence = ASN1Sequence();
  for (var i = 0; i < originalSequence.elements.length; i++) {
    legacySequence.add(originalSequence.elements[i == 2 ? 3 : i]);
  }
  final legacyPem = SSHPem(
    'RSA PRIVATE KEY',
    {},
    legacySequence.encodedBytes,
  ).encode();
  final expectedPublicBlob = base64.decode(
    fixture('ssh-rsa/id_rsa.pub').split(' ')[1],
  );
  final expectedPublicKey = SSHRsaPublicKey.decode(expectedPublicBlob);

  test('legacy RSA key matches its authorized public key and signs', () {
    final key = SSHKeyPair.fromPem(legacyPem).single as RsaPrivateKey;
    final data = Uint8List.fromList('legacy RSA authentication'.codeUnits);

    expect(key.toPublicKey().encode(), expectedPublicBlob);
    expect(expectedPublicKey.verify(data, key.sign(data)), isTrue);
  });

  test('legacy RSA key serializes with the recovered public exponent', () {
    final key = SSHKeyPair.fromPem(legacyPem).single as RsaPrivateKey;
    final repairedSequence = ASN1Parser(SSHPem.decode(key.toPem()).content)
        .nextObject() as ASN1Sequence;

    expect(
      (repairedSequence.elements[2] as ASN1Integer).valueAsBigInteger,
      expectedPublicKey.e,
    );
    expect(
      (repairedSequence.elements[3] as ASN1Integer).valueAsBigInteger,
      (originalSequence.elements[3] as ASN1Integer).valueAsBigInteger,
    );
  });

  test('valid RSA key retains its encoded public exponent', () {
    final key = SSHKeyPair.fromPem(originalPem).single as RsaPrivateKey;

    expect(key.e, expectedPublicKey.e);
    expect(key.toPublicKey().encode(), expectedPublicBlob);
  });
}
