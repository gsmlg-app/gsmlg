import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart' as pc;

/// Manages self-signed TLS certificates for the TOFU (Trust On First Use) model.
///
/// On first run, generates an RSA-2048 key pair and a self-signed X.509 v3
/// certificate. The certificate CN is set to the machine hostname with SANs
/// for all local non-loopback IP addresses. Files are stored under
/// `~/.gsmlg-monitor/`.
class CertManager {
  CertManager({this.regenCert = false});

  final bool regenCert;

  late final String fingerprint;
  late final String certPath;
  late final String keyPath;

  static String get _configDir {
    final home =
        Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '.';
    return '$home/.gsmlg-monitor';
  }

  /// Initializes the certificate manager.
  ///
  /// Generates a new certificate if [regenCert] is true or if cert/key files
  /// do not yet exist. Returns a [SecurityContext] suitable for
  /// `HttpServer.bindSecure`.
  Future<SecurityContext> initialize() async {
    final dir = Directory(_configDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    certPath = '${dir.path}/cert.pem';
    keyPath = '${dir.path}/key.pem';

    final certFile = File(certPath);
    final keyFile = File(keyPath);

    if (regenCert || !certFile.existsSync() || !keyFile.existsSync()) {
      print('Generating new self-signed certificate...');
      await _generateCertificate(certFile, keyFile);
    }

    // Compute fingerprint from cert PEM
    final certPem = certFile.readAsStringSync();
    fingerprint = _computeFingerprint(certPem);

    print('Certificate fingerprint: $fingerprint');

    // Create SecurityContext
    final context = SecurityContext();
    context.useCertificateChain(certPath);
    context.usePrivateKey(keyPath);

    return context;
  }

  Future<void> _generateCertificate(File certFile, File keyFile) async {
    // Generate RSA-2048 key pair
    final secureRandom = pc.FortunaRandom();
    final seedSource = Random.secure();
    final seeds = List<int>.generate(32, (_) => seedSource.nextInt(256));
    secureRandom.seed(pc.KeyParameter(Uint8List.fromList(seeds)));

    final keyGen = pc.RSAKeyGenerator()
      ..init(
        pc.ParametersWithRandom(
          pc.RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64),
          secureRandom,
        ),
      );

    final pair = keyGen.generateKeyPair();
    final publicKey = pair.publicKey;
    final privateKey = pair.privateKey;

    // Gather SANs: all non-loopback IP addresses
    final sanIps = await _gatherLocalIps();

    // Build self-signed X.509 v3 certificate
    final hostname = Platform.localHostname;
    final now = DateTime.now().toUtc();
    final notAfter = now.add(const Duration(days: 365));

    final certDer = _buildSelfSignedCert(
      publicKey: publicKey,
      privateKey: privateKey,
      cn: hostname,
      sanIps: sanIps,
      notBefore: now,
      notAfter: notAfter,
      secureRandom: secureRandom,
    );

    // PEM encode
    final certPem = _derToPem(certDer, 'CERTIFICATE');
    final keyDer = _encodePrivateKeyDer(privateKey);
    final keyPem = _derToPem(keyDer, 'RSA PRIVATE KEY');

    certFile.writeAsStringSync(certPem);
    keyFile.writeAsStringSync(keyPem);

    // Restrict key file permissions on Unix
    if (!Platform.isWindows) {
      Process.runSync('chmod', ['600', keyFile.path]);
    }
  }

  /// Gathers all local non-loopback IPv4/IPv6 addresses.
  Future<List<InternetAddress>> _gatherLocalIps() async {
    final results = <InternetAddress>[];
    try {
      final interfaces = await NetworkInterface.list();
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback) {
            results.add(addr);
          }
        }
      }
    } catch (_) {
      // If we cannot enumerate interfaces, proceed without SANs.
    }
    return results;
  }

  Uint8List _buildSelfSignedCert({
    required pc.RSAPublicKey publicKey,
    required pc.RSAPrivateKey privateKey,
    required String cn,
    required List<InternetAddress> sanIps,
    required DateTime notBefore,
    required DateTime notAfter,
    required pc.SecureRandom secureRandom,
  }) {
    // Build TBSCertificate
    final tbs = _buildTbsCertificate(
      publicKey: publicKey,
      cn: cn,
      sanIps: sanIps,
      notBefore: notBefore,
      notAfter: notAfter,
      secureRandom: secureRandom,
    );

    // Sign with SHA-256/RSA
    final signer = pc.RSASigner(pc.SHA256Digest(), '0609608648016503040201');
    signer.init(true, pc.PrivateKeyParameter<pc.RSAPrivateKey>(privateKey));
    final signature = signer.generateSignature(tbs);

    // Build Certificate = SEQUENCE { tbs, signatureAlgorithm, signatureValue }
    final signAlgSeq = _asn1Sequence([
      _asn1Oid([1, 2, 840, 113549, 1, 1, 11]), // sha256WithRSAEncryption
      _asn1Null(),
    ]);

    final signBits = _asn1BitString(signature.bytes);

    return _asn1Sequence([tbs, signAlgSeq, signBits]);
  }

  Uint8List _buildTbsCertificate({
    required pc.RSAPublicKey publicKey,
    required String cn,
    required List<InternetAddress> sanIps,
    required DateTime notBefore,
    required DateTime notAfter,
    required pc.SecureRandom secureRandom,
  }) {
    // version [0] EXPLICIT INTEGER v3 (2)
    final version = _asn1Explicit(0, _asn1Integer(BigInt.from(2)));

    // serialNumber
    final serial = _asn1Integer(BigInt.from(secureRandom.nextUint32()));

    // signature algorithm
    final signAlg = _asn1Sequence([
      _asn1Oid([1, 2, 840, 113549, 1, 1, 11]), // sha256WithRSAEncryption
      _asn1Null(),
    ]);

    // issuer = subject (self-signed)
    final subject = _asn1Sequence([
      _asn1Set([
        _asn1Sequence([
          _asn1Oid([2, 5, 4, 3]), // CN
          _asn1Utf8String(cn),
        ]),
      ]),
    ]);

    // validity
    final validity = _asn1Sequence([
      _asn1UtcTime(notBefore),
      _asn1UtcTime(notAfter),
    ]);

    // subjectPublicKeyInfo
    final pubKeyInfo = _asn1Sequence([
      _asn1Sequence([
        _asn1Oid([1, 2, 840, 113549, 1, 1, 1]), // rsaEncryption
        _asn1Null(),
      ]),
      _asn1BitString(
        _asn1Sequence([
          _asn1Integer(publicKey.modulus!),
          _asn1Integer(publicKey.publicExponent!),
        ]),
      ),
    ]);

    // Extensions [3] EXPLICIT SEQUENCE
    final extensions = _buildExtensions(cn, sanIps);

    return _asn1Sequence([
      version,
      serial,
      signAlg,
      subject, // issuer
      validity,
      subject, // subject
      pubKeyInfo,
      extensions,
    ]);
  }

  /// Build X.509 v3 extensions: Subject Alternative Name (DNS + IPs).
  Uint8List _buildExtensions(String cn, List<InternetAddress> sanIps) {
    // Build SAN GeneralNames sequence
    final sanEntries = <Uint8List>[];

    // dNSName [2] for hostname
    sanEntries.add(_asn1ImplicitString(2, cn));

    // iPAddress [7] for each non-loopback IP
    for (final ip in sanIps) {
      sanEntries.add(_asn1ImplicitBytes(7, ip.rawAddress));
    }

    final sanValue = _asn1Sequence(sanEntries);

    // Extension: subjectAltName (2.5.29.17)
    final sanExtension = _asn1Sequence([
      _asn1Oid([2, 5, 29, 17]), // subjectAltName
      _asn1OctetString(sanValue), // extnValue (DER-encoded GeneralNames)
    ]);

    final extensionsSeq = _asn1Sequence([sanExtension]);

    // [3] EXPLICIT wrapper
    return _asn1Explicit(3, extensionsSeq);
  }

  Uint8List _encodePrivateKeyDer(pc.RSAPrivateKey key) {
    return _asn1Sequence([
      _asn1Integer(BigInt.zero), // version
      _asn1Integer(key.modulus!),
      _asn1Integer(key.publicExponent!),
      _asn1Integer(key.privateExponent!),
      _asn1Integer(key.p!),
      _asn1Integer(key.q!),
      _asn1Integer(key.privateExponent! % (key.p! - BigInt.one)), // d mod (p-1)
      _asn1Integer(key.privateExponent! % (key.q! - BigInt.one)), // d mod (q-1)
      _asn1Integer(key.q!.modInverse(key.p!)), // q^-1 mod p
    ]);
  }

  String _computeFingerprint(String certPem) {
    final lines = certPem.split('\n');
    final b64 = lines.where((l) => !l.startsWith('-----')).join();
    final der = base64.decode(b64);
    final digest = pc.SHA256Digest().process(Uint8List.fromList(der));
    return 'SHA256:${digest.map((b) => b.toRadixString(16).padLeft(2, '0')).join(':')}';
  }

  String _derToPem(Uint8List der, String label) {
    final b64 = base64.encode(der);
    final lines = <String>['-----BEGIN $label-----'];
    for (var i = 0; i < b64.length; i += 64) {
      lines.add(b64.substring(i, i + 64 > b64.length ? b64.length : i + 64));
    }
    lines.add('-----END $label-----');
    return lines.join('\n');
  }

  // ---------------------------------------------------------------------------
  // ASN.1 DER encoding helpers
  // ---------------------------------------------------------------------------

  Uint8List _asn1Sequence(List<Uint8List> items) =>
      _asn1Tag(0x30, _concat(items));

  Uint8List _asn1Set(List<Uint8List> items) => _asn1Tag(0x31, _concat(items));

  Uint8List _asn1Integer(BigInt value) {
    var bytes = _bigIntToBytes(value);
    // Ensure positive integers have leading zero if high bit set
    if (bytes.isNotEmpty && bytes[0] & 0x80 != 0) {
      bytes = Uint8List.fromList([0, ...bytes]);
    }
    return _asn1Tag(0x02, bytes);
  }

  Uint8List _asn1BitString(Uint8List data) =>
      _asn1Tag(0x03, Uint8List.fromList([0, ...data]));

  Uint8List _asn1OctetString(Uint8List data) => _asn1Tag(0x04, data);

  Uint8List _asn1Null() => Uint8List.fromList([0x05, 0x00]);

  Uint8List _asn1Utf8String(String s) =>
      _asn1Tag(0x0C, Uint8List.fromList(utf8.encode(s)));

  Uint8List _asn1UtcTime(DateTime dt) {
    final s =
        '${(dt.year % 100).toString().padLeft(2, '0')}'
        '${dt.month.toString().padLeft(2, '0')}'
        '${dt.day.toString().padLeft(2, '0')}'
        '${dt.hour.toString().padLeft(2, '0')}'
        '${dt.minute.toString().padLeft(2, '0')}'
        '${dt.second.toString().padLeft(2, '0')}Z';
    return _asn1Tag(0x17, Uint8List.fromList(utf8.encode(s)));
  }

  Uint8List _asn1Oid(List<int> components) {
    final bytes = <int>[];
    bytes.add(components[0] * 40 + components[1]);
    for (var i = 2; i < components.length; i++) {
      var value = components[i];
      if (value < 128) {
        bytes.add(value);
      } else {
        final encoded = <int>[];
        encoded.add(value & 0x7F);
        value >>= 7;
        while (value > 0) {
          encoded.add((value & 0x7F) | 0x80);
          value >>= 7;
        }
        bytes.addAll(encoded.reversed);
      }
    }
    return _asn1Tag(0x06, Uint8List.fromList(bytes));
  }

  /// Context-specific EXPLICIT tag wrapper: [tag] EXPLICIT content.
  Uint8List _asn1Explicit(int tag, Uint8List content) =>
      _asn1Tag(0xA0 | tag, content);

  /// Context-specific IMPLICIT tag for a UTF-8 string (e.g. dNSName [2]).
  Uint8List _asn1ImplicitString(int tag, String value) =>
      _asn1Tag(0x80 | tag, Uint8List.fromList(utf8.encode(value)));

  /// Context-specific IMPLICIT tag for raw bytes (e.g. iPAddress [7]).
  Uint8List _asn1ImplicitBytes(int tag, Uint8List data) =>
      _asn1Tag(0x80 | tag, data);

  Uint8List _asn1Tag(int tag, Uint8List content) {
    final len = _encodeLength(content.length);
    return Uint8List.fromList([tag, ...len, ...content]);
  }

  Uint8List _encodeLength(int length) {
    if (length < 128) return Uint8List.fromList([length]);
    final bytes = <int>[];
    var l = length;
    while (l > 0) {
      bytes.insert(0, l & 0xFF);
      l >>= 8;
    }
    return Uint8List.fromList([0x80 | bytes.length, ...bytes]);
  }

  Uint8List _bigIntToBytes(BigInt value) {
    if (value == BigInt.zero) return Uint8List.fromList([0]);
    final isNeg = value.isNegative;
    var v = isNeg ? -value : value;
    final bytes = <int>[];
    while (v > BigInt.zero) {
      bytes.insert(0, (v & BigInt.from(0xFF)).toInt());
      v >>= 8;
    }
    if (isNeg) {
      // Two's complement
      for (var i = 0; i < bytes.length; i++) {
        bytes[i] = (~bytes[i]) & 0xFF;
      }
      var carry = 1;
      for (var i = bytes.length - 1; i >= 0 && carry > 0; i--) {
        final sum = bytes[i] + carry;
        bytes[i] = sum & 0xFF;
        carry = sum >> 8;
      }
    }
    return Uint8List.fromList(bytes);
  }

  Uint8List _concat(List<Uint8List> items) {
    final builder = BytesBuilder();
    for (final item in items) {
      builder.add(item);
    }
    return builder.toBytes();
  }
}
