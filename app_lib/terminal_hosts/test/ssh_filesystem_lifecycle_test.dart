import 'package:app_ssh/app_ssh.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

class _Sftp extends Fake implements SftpClient {
  int closes = 0;
  Object? error;
  @override
  Future<String> absolute(String path) async {
    if (error != null) throw error!;
    return '/remote';
  }

  @override
  void close() {
    closes++;
  }
}

class _Client extends Fake implements SSHClient {
  _Client(this.fileSystem);
  final _Sftp fileSystem;
  int closes = 0;
  @override
  Future<SftpClient> sftp() async => fileSystem;
  @override
  void close() {
    closes++;
  }
}

void main() {
  test(
    'filesystem initialization failure closes SFTP, keeps SSH transport',
    () async {
      final sftp = _Sftp()..error = StateError('fixture absolute failure');
      final client = _Client(sftp);
      await expectLater(SSHHost(client).connectFileSystem(), throwsStateError);
      expect(sftp.closes, 1);
      expect(client.closes, 0);
    },
  );

  test('filesystem close is idempotent and retains SSH transport', () async {
    final sftp = _Sftp();
    final client = _Client(sftp);
    final fs = await SSHHost(client).connectFileSystem();
    expect(fs.currentDirectory.path, '/remote');
    await fs.close();
    await fs.close();
    expect(sftp.closes, 1);
    expect(client.closes, 0);
  });
}
