import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_plugin/src/zmodem/io_zmodem_file_access.dart';
import 'package:terminal_plugin/src/zmodem/zmodem_file_access.dart';

void main() {
  group('sanitizeRemoteFileName', () {
    test('keeps only the last path component', () {
      expect(sanitizeRemoteFileName('dir/sub/a.txt'), 'a.txt');
      expect(sanitizeRemoteFileName(r'C:\x\y.bin'), 'y.bin');
    });

    test('replaces empty and dot names', () {
      expect(sanitizeRemoteFileName('..'), 'download');
      expect(sanitizeRemoteFileName('.'), 'download');
      expect(sanitizeRemoteFileName(''), 'download');
      expect(sanitizeRemoteFileName('dir/'), 'download');
    });

    test('drops NUL characters', () {
      expect(sanitizeRemoteFileName('a\u0000b'), 'ab');
    });
  });

  group('uniqueFileName', () {
    test('adds a browser-style counter before the extension', () {
      final existing = {'/d/a.txt', '/d/a (1).txt'};
      expect(uniqueFileName('/d', 'a.txt', existing.contains), 'a (2).txt');
    });

    test('uses the last extension only', () {
      final existing = {'/d/archive.tar.gz'};
      expect(
        uniqueFileName('/d', 'archive.tar.gz', existing.contains),
        'archive.tar (1).gz',
      );
    });

    test('handles names without an extension', () {
      final existing = {'/d/Makefile'};
      expect(
          uniqueFileName('/d', 'Makefile', existing.contains), 'Makefile (1)');
    });

    test('keeps the name when nothing clashes', () {
      expect(uniqueFileName('/d', 'new.txt', (_) => false), 'new.txt');
    });
  });

  group('IoZmodemFileAccess', () {
    late Directory tmp;

    setUp(() => tmp = Directory.systemTemp.createTempSync('zmodem-files-'));
    tearDown(() => tmp.deleteSync(recursive: true));

    IoZmodemFileAccess access() => IoZmodemFileAccess(
          settings: () =>
              (mode: ZmodemDownloadMode.saveToFolder, directory: tmp.path),
        );

    test('saveToFolder resolves the configured directory', () async {
      expect(await access().resolveDownloadDirectory(), tmp.path);
    });

    test('createDownload never overwrites', () async {
      final files = access();
      final first = await files.createDownload(tmp.path, 'x.bin');
      first.sink.add([1, 2, 3]);
      await first.complete();
      final second = await files.createDownload(tmp.path, 'x.bin');
      await second.complete();

      expect(first.path, endsWith('/x.bin'));
      expect(second.path, endsWith('/x (1).bin'));
      expect(File(first.path).readAsBytesSync(), [1, 2, 3]);
    });

    test('createDownload sanitizes the remote name', () async {
      final target = await access().createDownload(tmp.path, '../etc/passwd');
      await target.complete();

      expect(target.path, '${tmp.path}/passwd');
    });

    test('discard removes the partial file and complete keeps it', () async {
      final files = access();
      final kept = await files.createDownload(tmp.path, 'kept.bin');
      kept.sink.add([1]);
      await kept.complete();
      final dropped = await files.createDownload(tmp.path, 'dropped.bin');
      dropped.sink.add([1]);
      await dropped.discard();

      expect(File(kept.path).existsSync(), isTrue);
      expect(File(dropped.path).existsSync(), isFalse);
    });

    test('local files read from an offset', () async {
      final file = File('${tmp.path}/up.bin')..writeAsBytesSync([1, 2, 3, 4]);
      final local = ZmodemLocalFile(path: file.path, name: 'up.bin', length: 4);

      final bytes = await local.read(2).expand((chunk) => chunk).toList();

      expect(bytes, [3, 4]);
    });
  });
}
