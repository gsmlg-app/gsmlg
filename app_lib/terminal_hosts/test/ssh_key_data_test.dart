import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

void main() {
  group('SshKeyData', () {
    test('creates instance with content only', () {
      const keyData = SshKeyData(
        content:
            '-----BEGIN RSA PRIVATE KEY-----\ntest\n-----END RSA PRIVATE KEY-----',
      );

      expect(keyData.content, contains('BEGIN RSA PRIVATE KEY'));
      expect(keyData.passphrase, isNull);
    });

    test('creates instance with content and passphrase', () {
      const keyData = SshKeyData(
        content:
            '-----BEGIN RSA PRIVATE KEY-----\ntest\n-----END RSA PRIVATE KEY-----',
        passphrase: 'secret123',
      );

      expect(keyData.content, contains('BEGIN RSA PRIVATE KEY'));
      expect(keyData.passphrase, equals('secret123'));
    });

    test('handles empty content', () {
      const keyData = SshKeyData(content: '');

      expect(keyData.content, isEmpty);
      expect(keyData.passphrase, isNull);
    });

    test('handles multiline PEM content', () {
      const pemContent = '''-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAlwAAAAdzc2gtcn
NhAAAAAwEAAQAAAIEA0Z3qX2BTLS4e0Jb3LB4R5w8+PnDHf5FpPf0d9DKCFoQpP4G1a8nf
-----END OPENSSH PRIVATE KEY-----''';

      final keyData = SshKeyData(content: pemContent);

      expect(keyData.content, contains('BEGIN OPENSSH PRIVATE KEY'));
      expect(keyData.content, contains('END OPENSSH PRIVATE KEY'));
    });
  });
}
