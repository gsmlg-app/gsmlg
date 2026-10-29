import 'package:app_database/app_database.dart';
import 'package:app_security/app_security.dart';

/// Application name constant used for encryption
const String appName = 'Web Terminal';

/// Extension methods for SshKey to provide encryption functionality
extension SshKeyEncryption on SshKey {
  /// Decrypts and returns the private key PEM
  String getPrivateKeyPem() {
    final aesHelper = AesHelper(appName);
    final keyPem = aesHelper.decrypt64WithSalt('$content', '$salt');
    return keyPem;
  }

  /// Gets the SSH public key from the private key
  String getPublicKeyPem() {
    final keyPem = getPrivateKeyPem();
    final rsaKeyHelper = RsaKeyHelper();
    return rsaKeyHelper.getSshPublicKey(keyPem);
  }

  /// Gets the algorithm as SshKeyAlgorithm enum
  SshKeyAlgorithm? get algorithmEnum {
    return SshKeyAlgorithm.fromValue(algorithm);
  }
}
