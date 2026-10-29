# App SSH

A pure Dart SSH client library, forked from [dartssh2](https://pub.dev/packages/dartssh2) with enhancements for the Web Terminal app.

## Features

- **SSH2 Protocol**: Full SSH2 client implementation in pure Dart
- **Multiple Auth Methods**: Password, public key, keyboard-interactive authentication
- **SFTP Support**: Complete SFTP subsystem for file operations
- **Port Forwarding**: Local and remote port forwarding support
- **Session Execution**: Interactive shell sessions and single command execution
- **Customizable Algorithms**: Configurable cipher, MAC, key exchange, and host key algorithms
- **HTTP over SSH**: HTTP client tunneled through SSH connections

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  app_ssh:
    path: ../app_lib/ssh
```

## Usage

### Basic SSH Connection

```dart
import 'package:app_ssh/app_ssh.dart';

// Connect via socket
final socket = await SSHSocket.connect('hostname', 22);

// Create client with password auth
final client = SSHClient(
  socket,
  username: 'user',
  onPasswordRequest: () => 'password',
);

// Wait for authentication
await client.authenticated;
```

### Public Key Authentication

```dart
final client = SSHClient(
  socket,
  username: 'user',
  identities: [
    SSHKeyPair.fromPem(privateKeyPem),
  ],
);
```

### Execute Command

```dart
final session = await client.execute('ls -la');
await session.stdout.listen(print).asFuture();
final exitCode = await session.exitCode;
```

### Interactive Shell

```dart
final shell = await client.shell();
shell.stdout.listen(stdout.write);
stdin.pipe(shell.stdin);
await shell.done;
```

### SFTP Operations

```dart
final sftp = await client.sftp();

// List directory
final items = await sftp.listdir('/home/user');

// Read file
final file = await sftp.open('/path/to/file');
final content = await file.readBytes();
await file.close();

// Write file
final output = await sftp.open('/path/to/output', mode: SftpFileOpenMode.create);
await output.writeBytes(data);
await output.close();

// Upload/download with streaming
await sftp.uploadFile(localPath, remotePath);
await sftp.downloadFile(remotePath, localPath);
```

### Port Forwarding

```dart
// Local forwarding
final localForward = await client.forwardLocal('localhost', 8080);

// Remote forwarding
final remoteForward = await client.forwardRemote(address: '0.0.0.0', port: 8080);
```

## Components

### SSHClient

Main SSH client class for establishing connections.

### SSHSession

Represents a single command execution session.

### SftpClient

SFTP subsystem client for file operations.

### SSHKeyPair

SSH key pair for public key authentication.

| Factory | Description |
|---------|-------------|
| `SSHKeyPair.fromPem(String)` | Parse PEM-encoded private key |
| `SSHKeyPair.ed25519()` | Generate Ed25519 key pair |
| `SSHKeyPair.rsa()` | Generate RSA key pair |

### SSHAlgorithms

Configure supported algorithms:
- Cipher types (AES, ChaCha20)
- MAC types (HMAC-SHA2, ETM variants)
- Key exchange (Curve25519, ECDH, DH)
- Host key (Ed25519, RSA, ECDSA)

## Supported Algorithms

### Ciphers
- `aes128-ctr`, `aes192-ctr`, `aes256-ctr`
- `aes128-gcm@openssh.com`, `aes256-gcm@openssh.com`
- `chacha20-poly1305@openssh.com`

### Key Exchange
- `curve25519-sha256`
- `ecdh-sha2-nistp256`, `ecdh-sha2-nistp384`, `ecdh-sha2-nistp521`
- `diffie-hellman-group-exchange-sha256`

### Host Keys
- `ssh-ed25519`
- `rsa-sha2-256`, `rsa-sha2-512`
- `ecdsa-sha2-nistp256`, `ecdsa-sha2-nistp384`, `ecdsa-sha2-nistp521`

## Origin

This package is a fork of [dartssh2](https://pub.dev/packages/dartssh2), modified and maintained for the Web Terminal application.
