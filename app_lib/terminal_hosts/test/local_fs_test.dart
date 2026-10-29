import 'dart:io' as io;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

void main() {
  group('LocalFileSystem', () {
    late LocalFileSystem fs;

    setUp(() {
      fs = LocalFileSystem();
    });

    group('constructor', () {
      test('creates instance', () {
        expect(fs, isA<LocalFileSystem>());
        expect(fs, isA<FileSystem>());
      });
    });

    group('currentDirectory', () {
      test('returns LocalDirectory', () {
        expect(fs.currentDirectory, isA<LocalDirectory>());
      });

      test('matches io.Directory.current', () {
        expect(fs.currentDirectory.path, equals(io.Directory.current.path));
      });
    });

    group('directory', () {
      test('returns LocalDirectory for path', () {
        final dir = fs.directory('/tmp');
        expect(dir, isA<LocalDirectory>());
        expect(dir.path, equals('/tmp'));
      });

      test('uses provided fileSystem', () {
        final dir = fs.directory('/any/path');
        expect(dir.fileSystem, equals(fs));
      });
    });

    group('file', () {
      test('returns LocalFile for path', () {
        final file = fs.file('/tmp/test.txt');
        expect(file, isA<LocalFile>());
        expect(file.path, equals('/tmp/test.txt'));
      });

      test('uses provided fileSystem', () {
        final file = fs.file('/any/path.txt');
        expect(file.fileSystem, equals(fs));
      });
    });

    group('link', () {
      test('returns LocalLink for path', () {
        final link = fs.link('/tmp/link');
        expect(link, isA<LocalLink>());
        expect(link.path, equals('/tmp/link'));
      });

      test('uses provided fileSystem', () {
        final link = fs.link('/any/link');
        expect(link.fileSystem, equals(fs));
      });
    });

    group('path', () {
      test('returns Context', () {
        expect(fs.path, isNotNull);
      });

      test('can perform path operations', () {
        final joined = fs.path.join('dir', 'file.txt');
        expect(joined, equals('dir/file.txt'));
      });

      test('can get basename', () {
        expect(fs.path.basename('/path/to/file.txt'), equals('file.txt'));
      });

      test('can get dirname', () {
        expect(fs.path.dirname('/path/to/file.txt'), equals('/path/to'));
      });
    });

    group('isWatchSupported', () {
      test('returns boolean', () {
        expect(fs.isWatchSupported, isA<bool>());
      });

      test('matches io.FileSystemEntity value', () {
        expect(
          fs.isWatchSupported,
          equals(io.FileSystemEntity.isWatchSupported),
        );
      });
    });

    group('stat', () {
      test('returns FileStat for existing path', () async {
        final stat = await fs.stat(io.Directory.current.path);
        expect(stat, isA<FileStat>());
        expect(stat, isA<LocalFileStat>());
      });

      test('stat has type property', () async {
        final stat = await fs.stat(io.Directory.current.path);
        expect(stat.type, equals(FileSystemEntityType.directory));
      });
    });

    group('type', () {
      test('returns directory for directory path', () async {
        final type = await fs.type(io.Directory.current.path);
        expect(type, equals(FileSystemEntityType.directory));
      });

      test('returns file for file path', () async {
        // /etc/hosts exists on macOS and Linux
        if (io.Platform.isMacOS || io.Platform.isLinux) {
          final type = await fs.type('/etc/hosts');
          expect(type, equals(FileSystemEntityType.file));
        }
      });

      test('throws FileSystemException for non-existent path', () async {
        expect(
          () => fs.type('/this/path/does/not/exist/12345'),
          throwsA(isA<FileSystemException>()),
        );
      });
    });

    group('identical', () {
      test('returns true for same path', () async {
        final path = io.Directory.current.path;
        expect(await fs.identical(path, path), isTrue);
      });

      test('returns false for different paths', () async {
        if (io.Platform.isMacOS || io.Platform.isLinux) {
          expect(await fs.identical('/tmp', '/var'), isFalse);
        }
      });
    });

    group('isFile helper', () {
      test('returns true for file', () async {
        if (io.Platform.isMacOS || io.Platform.isLinux) {
          expect(await fs.isFile('/etc/hosts'), isTrue);
        }
      });

      test('returns false for directory', () async {
        expect(await fs.isFile(io.Directory.current.path), isFalse);
      });
    });

    group('isDirectory helper', () {
      test('returns true for directory', () async {
        expect(await fs.isDirectory(io.Directory.current.path), isTrue);
      });

      test('returns false for file', () async {
        if (io.Platform.isMacOS || io.Platform.isLinux) {
          expect(await fs.isDirectory('/etc/hosts'), isFalse);
        }
      });
    });
  });

  group('LocalFileStat', () {
    late LocalFileStat stat;

    setUp(() async {
      final ioStat = await io.FileStat.stat(io.Directory.current.path);
      stat = LocalFileStat(ioStat);
    });

    test('size returns integer', () {
      expect(stat.size, isA<int>());
    });

    test('accessed returns DateTime', () {
      expect(stat.accessed, isA<DateTime>());
    });

    test('changed returns DateTime', () {
      expect(stat.changed, isA<DateTime>());
    });

    test('modified returns DateTime', () {
      expect(stat.modified, isA<DateTime>());
    });

    test('type returns FileSystemEntityType', () {
      expect(stat.type, isA<FileSystemEntityType>());
    });

    test('type matches actual entity type', () {
      expect(stat.type, equals(FileSystemEntityType.directory));
    });
  });

  group('LocalDirectory', () {
    late LocalFileSystem fs;
    late io.Directory tempDir;

    setUp(() async {
      fs = LocalFileSystem();
      tempDir = await io.Directory.systemTemp.createTemp('local_fs_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('path returns correct path', () {
      final dir = fs.directory(tempDir.path);
      expect(dir.path, equals(tempDir.path));
    });

    test('basename returns directory name', () {
      final dir = fs.directory(tempDir.path);
      expect(dir.basename, startsWith('local_fs_test_'));
    });

    test('dirname returns parent path', () {
      final dir = fs.directory(tempDir.path);
      expect(dir.dirname, equals(io.Directory.systemTemp.path));
    });

    test('parent returns parent directory', () {
      final dir = fs.directory(tempDir.path);
      final parent = dir.parent;
      expect(parent.path, equals(io.Directory.systemTemp.path));
    });

    test('exists returns true for existing directory', () async {
      final dir = fs.directory(tempDir.path);
      expect(await dir.exists(), isTrue);
    });

    test('exists returns false for non-existent directory', () async {
      final dir = fs.directory('${tempDir.path}/nonexistent');
      expect(await dir.exists(), isFalse);
    });

    test('create creates new directory', () async {
      final dir = fs.directory('${tempDir.path}/newdir');
      expect(await dir.exists(), isFalse);

      await dir.create();

      expect(await dir.exists(), isTrue);
    });

    test('create with recursive creates nested directories', () async {
      final dir = fs.directory('${tempDir.path}/a/b/c');
      expect(await dir.exists(), isFalse);

      await dir.create(recursive: true);

      expect(await dir.exists(), isTrue);
    });

    test('delete removes directory', () async {
      final subDir = io.Directory('${tempDir.path}/todelete');
      await subDir.create();
      expect(await subDir.exists(), isTrue);

      final dir = fs.directory(subDir.path);
      await dir.delete();

      expect(await subDir.exists(), isFalse);
    });

    test('rename moves directory', () async {
      final subDir = io.Directory('${tempDir.path}/original');
      await subDir.create();

      final dir = fs.directory(subDir.path);
      final renamed = await dir.rename('${tempDir.path}/renamed');

      expect(await subDir.exists(), isFalse);
      expect(await renamed.exists(), isTrue);
      expect(renamed.path, equals('${tempDir.path}/renamed'));
    });

    test('list returns stream of entities', () async {
      // Create some files and directories
      await io.File('${tempDir.path}/file1.txt').create();
      await io.File('${tempDir.path}/file2.txt').create();
      await io.Directory('${tempDir.path}/subdir').create();

      final dir = fs.directory(tempDir.path);
      final entities = await dir.list().toList();

      expect(entities.length, equals(3));
      expect(entities.whereType<LocalFile>().length, equals(2));
      expect(entities.whereType<LocalDirectory>().length, equals(1));
    });

    test('list with recursive traverses subdirectories', () async {
      await io.File('${tempDir.path}/file.txt').create();
      await io.Directory('${tempDir.path}/sub').create();
      await io.File('${tempDir.path}/sub/nested.txt').create();

      final dir = fs.directory(tempDir.path);
      final entities = await dir.list(recursive: true).toList();

      expect(entities.length, equals(3)); // file.txt, sub/, sub/nested.txt
    });

    test('absolute returns absolute path', () async {
      final relDir = fs.directory('.');
      final absDir = await relDir.absolute;

      // The path should be absolute (start with /)
      expect(absDir.path, startsWith('/'));
      // And should be a valid existing directory
      expect(await absDir.exists(), isTrue);
    });

    test('stat returns FileStat', () async {
      final dir = fs.directory(tempDir.path);
      final stat = await dir.stat();

      expect(stat, isA<FileStat>());
      expect(stat.type, equals(FileSystemEntityType.directory));
    });
  });

  group('LocalFile', () {
    late LocalFileSystem fs;
    late io.Directory tempDir;

    setUp(() async {
      fs = LocalFileSystem();
      tempDir = await io.Directory.systemTemp.createTemp('local_fs_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('path returns correct path', () {
      final file = fs.file('${tempDir.path}/test.txt');
      expect(file.path, equals('${tempDir.path}/test.txt'));
    });

    test('basename returns file name', () {
      final file = fs.file('${tempDir.path}/myfile.txt');
      expect(file.basename, equals('myfile.txt'));
    });

    test('dirname returns parent path', () {
      final file = fs.file('${tempDir.path}/myfile.txt');
      expect(file.dirname, equals(tempDir.path));
    });

    test('parent returns parent directory', () {
      final file = fs.file('${tempDir.path}/myfile.txt');
      final parent = file.parent;
      expect(parent.path, equals(tempDir.path));
    });

    test('exists returns false for non-existent file', () async {
      final file = fs.file('${tempDir.path}/nonexistent.txt');
      expect(await file.exists(), isFalse);
    });

    test('create creates new file', () async {
      final file = fs.file('${tempDir.path}/created.txt');
      expect(await file.exists(), isFalse);

      await file.create();

      expect(await file.exists(), isTrue);
    });

    test('create with recursive creates parent directories', () async {
      final file = fs.file('${tempDir.path}/a/b/file.txt');

      await file.create(recursive: true);

      expect(await file.exists(), isTrue);
    });

    test('writeAsString writes content', () async {
      final file = fs.file('${tempDir.path}/write.txt');
      await file.create();

      await file.writeAsString('Hello World');

      final content = await io.File('${tempDir.path}/write.txt').readAsString();
      expect(content, equals('Hello World'));
    });

    test('readAsString reads content', () async {
      final ioFile = io.File('${tempDir.path}/read.txt');
      await ioFile.writeAsString('Test content');

      final file = fs.file('${tempDir.path}/read.txt');
      final content = await file.readAsString();

      expect(content, equals('Test content'));
    });

    test('writeAsBytes writes bytes', () async {
      final file = fs.file('${tempDir.path}/bytes.bin');
      await file.create();

      await file.writeAsBytes(Uint8List.fromList([1, 2, 3, 4, 5]));

      final bytes = await io.File('${tempDir.path}/bytes.bin').readAsBytes();
      expect(bytes, equals([1, 2, 3, 4, 5]));
    });

    test('readAsBytes reads bytes', () async {
      final ioFile = io.File('${tempDir.path}/readbytes.bin');
      await ioFile.writeAsBytes([10, 20, 30]);

      final file = fs.file('${tempDir.path}/readbytes.bin');
      final bytes = await file.readAsBytes();

      expect(bytes, equals(Uint8List.fromList([10, 20, 30])));
    });

    test('delete removes file', () async {
      final ioFile = io.File('${tempDir.path}/todelete.txt');
      await ioFile.create();
      expect(await ioFile.exists(), isTrue);

      final file = fs.file(ioFile.path);
      await file.delete();

      expect(await ioFile.exists(), isFalse);
    });

    test('rename moves file', () async {
      final ioFile = io.File('${tempDir.path}/original.txt');
      await ioFile.writeAsString('content');

      final file = fs.file(ioFile.path);
      final renamed = await file.rename('${tempDir.path}/renamed.txt');

      expect(await ioFile.exists(), isFalse);
      expect(await renamed.exists(), isTrue);
      expect(await renamed.readAsString(), equals('content'));
    });

    test('copy duplicates file', () async {
      final ioFile = io.File('${tempDir.path}/source.txt');
      await ioFile.writeAsString('copied content');

      final file = fs.file(ioFile.path);
      final copied = await file.copy('${tempDir.path}/dest.txt');

      expect(await ioFile.exists(), isTrue);
      expect(await copied.exists(), isTrue);
      expect(await copied.readAsString(), equals('copied content'));
    });

    test('stat returns FileStat', () async {
      final ioFile = io.File('${tempDir.path}/forstat.txt');
      await ioFile.writeAsString('stat test');

      final file = fs.file(ioFile.path);
      final stat = await file.stat();

      expect(stat, isA<FileStat>());
      expect(stat.type, equals(FileSystemEntityType.file));
      expect(stat.size, greaterThan(0));
    });

    test('writeAsString with append mode', () async {
      final file = fs.file('${tempDir.path}/append.txt');
      await file.create();
      await file.writeAsString('First');
      await file.writeAsString('Second', mode: FileMode.append);

      final content = await file.readAsString();
      expect(content, equals('FirstSecond'));
    });

    test('absolute returns absolute path', () async {
      final file = fs.file('${tempDir.path}/abs.txt');
      await file.create();
      final absFile = await file.absolute;

      expect(absFile.path, startsWith('/'));
    });
  });

  group('LocalLink', () {
    late LocalFileSystem fs;
    late io.Directory tempDir;

    setUp(() async {
      fs = LocalFileSystem();
      tempDir = await io.Directory.systemTemp.createTemp('local_fs_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('path returns correct path', () {
      final link = fs.link('${tempDir.path}/mylink');
      expect(link.path, equals('${tempDir.path}/mylink'));
    });

    test('basename returns link name', () {
      final link = fs.link('${tempDir.path}/mylink');
      expect(link.basename, equals('mylink'));
    });

    test('create creates symbolic link', () async {
      final targetFile = io.File('${tempDir.path}/target.txt');
      await targetFile.writeAsString('target content');

      final link = fs.link('${tempDir.path}/mylink');
      await link.create(targetFile.path);

      expect(await link.exists(), isTrue);
    });

    test('target returns link target', () async {
      final targetFile = io.File('${tempDir.path}/target.txt');
      await targetFile.writeAsString('target content');

      final link = fs.link('${tempDir.path}/mylink');
      await link.create(targetFile.path);

      expect(await link.target(), equals(targetFile.path));
    });

    test('update changes link target', () async {
      final target1 = io.File('${tempDir.path}/target1.txt');
      await target1.writeAsString('first');
      final target2 = io.File('${tempDir.path}/target2.txt');
      await target2.writeAsString('second');

      final link = fs.link('${tempDir.path}/mylink');
      await link.create(target1.path);
      expect(await link.target(), equals(target1.path));

      await link.update(target2.path);
      expect(await link.target(), equals(target2.path));
    });

    test('delete removes link but not target', () async {
      final targetFile = io.File('${tempDir.path}/target.txt');
      await targetFile.writeAsString('content');

      final ioLink = io.Link('${tempDir.path}/mylink');
      await ioLink.create(targetFile.path);

      final link = fs.link(ioLink.path);
      await link.delete();

      expect(await ioLink.exists(), isFalse);
      expect(await targetFile.exists(), isTrue);
    });

    test('rename moves link', () async {
      final targetFile = io.File('${tempDir.path}/target.txt');
      await targetFile.writeAsString('content');

      final ioLink = io.Link('${tempDir.path}/original');
      await ioLink.create(targetFile.path);

      final link = fs.link(ioLink.path);
      final renamed = await link.rename('${tempDir.path}/renamed');

      expect(await ioLink.exists(), isFalse);
      expect(await renamed.exists(), isTrue);
      expect(await renamed.target(), equals(targetFile.path));
    });
  });

  group('FileSystemEntityType conversions', () {
    test('type mapping covers all cases', () async {
      final fs = LocalFileSystem();

      // Directory
      final dirType = await fs.type(io.Directory.current.path);
      expect(dirType, equals(FileSystemEntityType.directory));

      // File
      if (io.Platform.isMacOS || io.Platform.isLinux) {
        final fileType = await fs.type('/etc/hosts');
        expect(fileType, equals(FileSystemEntityType.file));
      }
    });
  });

  group('FileMode conversions', () {
    late LocalFileSystem fs;
    late io.Directory tempDir;

    setUp(() async {
      fs = LocalFileSystem();
      tempDir = await io.Directory.systemTemp.createTemp('filemode_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('FileMode.write overwrites content', () async {
      final file = fs.file('${tempDir.path}/mode.txt');
      await file.create();
      await file.writeAsString('first', mode: FileMode.write);
      await file.writeAsString('second', mode: FileMode.write);

      expect(await file.readAsString(), equals('second'));
    });

    test('FileMode.append appends content', () async {
      final file = fs.file('${tempDir.path}/append.txt');
      await file.create();
      await file.writeAsString('first', mode: FileMode.write);
      await file.writeAsString('second', mode: FileMode.append);

      expect(await file.readAsString(), equals('firstsecond'));
    });
  });
}
