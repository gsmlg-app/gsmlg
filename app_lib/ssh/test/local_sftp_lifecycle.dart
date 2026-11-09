import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_ssh/app_ssh.dart';

Future<void> until(bool Function() ready) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (!ready()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('SFTP sibling output');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

Future<void> main(List<String> arguments) async {
  final expectedFingerprint = arguments[4];
  final client = SSHClient(
    await SSHSocket.connect('127.0.0.1', int.parse(arguments[0]),
        timeout: const Duration(seconds: 5)),
    username: arguments[1],
    identities: SSHKeyPair.fromPem(File(arguments[2]).readAsStringSync()),
    onVerifyHostKeySha256: (type, fingerprint) =>
        type == 'ssh-ed25519' &&
        base64Encode(fingerprint).replaceAll('=', '') == expectedFingerprint,
    keepAliveInterval: null,
  );
  try {
    await client.authenticated.timeout(const Duration(seconds: 5));
    final sibling = await client.execute('/bin/sh');
    final output = StringBuffer();
    sibling.stdout.listen((data) => output.write(utf8.decode(data)));
    unawaited(sibling.stderr.drain<void>());
    for (var attempt = 0; attempt < 12; attempt++) {
      final sftp = await client.sftp();
      try {
        await sftp.handshake.timeout(const Duration(seconds: 5));
        final directory = await sftp.absolute(arguments[3]);
        final path = '$directory/fixture-$attempt.txt';
        final file = await sftp.open(path,
            mode: SftpFileOpenMode.read |
                SftpFileOpenMode.write |
                SftpFileOpenMode.create |
                SftpFileOpenMode.truncate);
        final expected = 'sftp-lifecycle-$attempt';
        await file.writeBytes(Uint8List.fromList(utf8.encode(expected)));
        final actual = utf8.decode(await file.readBytes());
        if (actual != expected) throw StateError('SFTP read/write mismatch');
        await file.close();
        if (!(await sftp.listdir(directory))
            .any((entry) => entry.filename == 'fixture-$attempt.txt')) {
          throw StateError('SFTP listing missing newly written file');
        }
        await sftp.remove(path);
      } finally {
        sftp.close();
        sftp.close();
      }
      sibling.stdin.add(utf8.encode("printf 'SIBLING_$attempt\\n'\n"));
      await until(() => output.toString().contains('SIBLING_$attempt\n'));
      final command =
          utf8.decode(await client.run("printf 'TRANSPORT_$attempt'"));
      if (command != 'TRANSPORT_$attempt') {
        throw StateError('SSH transport unusable');
      }
    }
    sibling.close();
    await sibling.done.timeout(const Duration(seconds: 2));
    stdout.writeln(
        'PASS: 12 SFTP list/read/write/remove sessions; repeated close; sibling shell and shared SSH transport usable after every close');
  } finally {
    client.close();
    await client.done;
  }
}
