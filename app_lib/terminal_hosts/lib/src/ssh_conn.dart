import 'dart:async';

import 'package:app_ssh/app_ssh.dart';
import 'package:flutter/foundation.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/ssh_host.dart';
import 'package:terminal_hosts/src/ssh_host_key_store.dart';

/// Default timeout for SSH socket connection.
const Duration kSshConnectionTimeout = Duration(seconds: 30);

/// Default timeout for SSH authentication.
const Duration kSshAuthenticationTimeout = Duration(seconds: 60);

/// SSH key data for authentication.
class SshKeyData {
  /// PEM-encoded private key content.
  final String content;

  /// Passphrase for encrypted keys (null for unencrypted).
  final String? passphrase;

  const SshKeyData({required this.content, this.passphrase});
}

/// Exception thrown when SSH connection fails.
class SshConnectionException implements Exception {
  final String message;
  final Object? cause;

  const SshConnectionException(this.message, [this.cause]);

  @override
  String toString() => cause != null ? '$message: $cause' : message;
}

/// Exception thrown when SSH authentication fails.
class SshAuthenticationException implements Exception {
  final String message;
  final Object? cause;

  const SshAuthenticationException(this.message, [this.cause]);

  @override
  String toString() => cause != null ? '$message: $cause' : message;
}

/// Exception thrown when SSH key parsing fails.
class SshKeyParseException implements Exception {
  final String message;
  final Object? cause;

  const SshKeyParseException(this.message, [this.cause]);

  @override
  String toString() => cause != null ? '$message: $cause' : message;
}

/// Exception thrown when SSH connection or authentication times out.
class SshTimeoutException implements Exception {
  final String message;
  final Duration timeout;

  const SshTimeoutException(this.message, this.timeout);

  @override
  String toString() => '$message (timeout: ${timeout.inSeconds}s)';
}

class SSHConnector extends HostConnector<SSHHost> {
  final SshHost record;

  /// Optional SSH key for key-based authentication.
  /// When provided and [record.identityType] is key, this will be used
  /// instead of password authentication.
  final SshKeyData? keyData;

  final SSHHostkeyVerifyHandler? verifyHostKey;
  final FutureOr<String?> Function()? passwordProvider;

  /// Timeout for establishing the socket connection.
  final Duration connectionTimeout;

  /// Timeout for SSH authentication after connection is established.
  final Duration authenticationTimeout;

  SSHConnector(
    this.record, {
    this.keyData,
    this.verifyHostKey,
    this.passwordProvider,
    this.connectionTimeout = kSshConnectionTimeout,
    this.authenticationTimeout = kSshAuthenticationTimeout,
  });

  @override
  Future<SSHHost> createHost() async {
    // Validate required fields
    final hostname = record.hostname;
    final port = record.port;
    final username = record.username;

    if (hostname == null || hostname.isEmpty) {
      throw const SshConnectionException('Hostname is required');
    }
    if (port == null || port <= 0 || port > 65535) {
      throw const SshConnectionException('Invalid port number');
    }
    if (username == null || username.isEmpty) {
      throw const SshAuthenticationException('Username is required');
    }
    if (verifyHostKey == null) {
      throw const SshHostKeyVerificationException(
        'SSH host key verification is required',
      );
    }

    // Establish socket connection with timeout
    final SSHSocket socket;
    try {
      socket = await SSHSocket.connect(hostname, port).timeout(
        connectionTimeout,
        onTimeout: () {
          throw SshTimeoutException(
            'Connection to $hostname:$port timed out',
            connectionTimeout,
          );
        },
      );
    } on SshTimeoutException {
      rethrow;
    } catch (error) {
      throw SshConnectionException(
        'Failed to connect to $hostname:$port',
        error,
      );
    }

    // Determine authentication method
    final identityType = SshIdentityType.fromValue(record.identityType);
    final useKeyAuth = identityType == SshIdentityType.key && keyData != null;

    // Parse SSH key if using key authentication
    List<SSHKeyPair>? identities;
    if (useKeyAuth) {
      if (keyData!.content.isEmpty) {
        socket.close();
        throw const SshKeyParseException('SSH key content is empty');
      }
      try {
        final parsed = SSHKeyPair.fromPem(
          keyData!.content,
          keyData!.passphrase,
        );
        // Add SHA-1 fallback for RSA keys to support older SSH servers
        // (e.g. OpenSSH < 7.8 which doesn't support rsa-sha2-256).
        identities = <SSHKeyPair>[];
        for (final key in parsed) {
          identities.add(key);
          if (key is RsaPrivateKey) {
            identities.add(key.withSignatureType(SSHRsaSignatureType.sha1));
          } else if (key is OpenSSHRsaKeyPair) {
            identities.add(key.withSignatureType(SSHRsaSignatureType.sha1));
          }
        }
        for (final id in identities) {
          debugPrint('[SSH] Key identity: name=${id.name}, type=${id.type}');
        }
      } catch (error) {
        socket.close();
        throw SshKeyParseException('Failed to parse SSH key', error);
      }
    }

    // Create SSH client
    final client = SSHClient(
      socket,
      username: username,
      onPasswordRequest: passwordProvider,
      onVerifyHostKeySha256: verifyHostKey,
      identities: identities,
      printDebug: debugPrint,
    );

    // Authenticate with timeout
    try {
      await client.authenticated.timeout(
        authenticationTimeout,
        onTimeout: () {
          client.close();
          throw SshTimeoutException(
            'Authentication for $username@$hostname timed out',
            authenticationTimeout,
          );
        },
      );
    } on SshTimeoutException {
      rethrow;
    } on SSHHostkeyError catch (error) {
      client.close();
      throw SshHostKeyVerificationException(error.toString());
    } catch (error) {
      client.close();
      throw SshAuthenticationException(
        'Authentication failed for $username@$hostname',
        error,
      );
    }

    return SSHHost(client);
  }
}
