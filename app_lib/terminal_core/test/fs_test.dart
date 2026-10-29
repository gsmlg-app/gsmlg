import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:terminal_core/terminal_core.dart';

// Mock FileSystem implementation for testing
class MockFileSystem extends FileSystem {
  final String _currentDir;
  final Map<String, FileStat> _stats = {};
  final Map<String, FileSystemEntityType> _types = {};
  bool _isWatchSupported = true;

  MockFileSystem({String currentDir = '/home/user'}) : _currentDir = currentDir;

  @override
  p.Context get path => p.posix;

  @override
  Directory get currentDirectory => MockDirectory(this, _currentDir);

  @override
  Directory directory(String path) => MockDirectory(this, path);

  @override
  File file(String path) => MockFile(this, path);

  @override
  Link link(String path) => MockLink(this, path);

  @override
  Future<FileStat> stat(String path) async {
    if (_stats.containsKey(path)) {
      return _stats[path]!;
    }
    return FileStat(
      changed: DateTime.now(),
      modified: DateTime.now(),
      accessed: DateTime.now(),
      type: FileSystemEntityType.unknown,
      size: 0,
    );
  }

  @override
  Future<bool> identical(String path1, String path2) async {
    return path1 == path2;
  }

  @override
  bool get isWatchSupported => _isWatchSupported;

  set isWatchSupported(bool value) => _isWatchSupported = value;

  @override
  Future<FileSystemEntityType> type(
    String path, {
    bool followLinks = true,
  }) async {
    return _types[path] ?? FileSystemEntityType.unknown;
  }

  void setType(String path, FileSystemEntityType type) {
    _types[path] = type;
  }

  void setStat(String path, FileStat stat) {
    _stats[path] = stat;
  }
}

// Mock File implementation
class MockFile with FileSystemEntity implements File {
  final MockFileSystem _fs;
  final String _path;
  bool _exists = false;
  Uint8List _content = Uint8List(0);

  MockFile(this._fs, this._path);

  @override
  String get path => _path;

  @override
  FileSystem get fileSystem => _fs;

  @override
  Future<bool> exists() async => _exists;

  void setExists(bool value) => _exists = value;

  @override
  Future<File> create({bool recursive = false}) async {
    _exists = true;
    return this;
  }

  @override
  Future<File> rename(String newPath) async {
    return MockFile(_fs, newPath).._exists = true;
  }

  @override
  Future<File> copy(String newPath) async {
    return MockFile(_fs, newPath)
      .._exists = true
      .._content = Uint8List.fromList(_content);
  }

  @override
  Future<File> get absolute async => this;

  @override
  Future<File> writeAsBytes(
    Uint8List bytes, {
    FileMode mode = FileMode.write,
    bool flush = false,
  }) async {
    _exists = true;
    _content = bytes;
    return this;
  }

  @override
  Future<File> writeAsString(
    String contents, {
    FileMode mode = FileMode.write,
    bool flush = false,
  }) async {
    _exists = true;
    _content = Uint8List.fromList(contents.codeUnits);
    return this;
  }

  @override
  Future<String> readAsString() async {
    return String.fromCharCodes(_content);
  }

  @override
  Future<Uint8List> readAsBytes() async {
    return _content;
  }

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) async {
    _exists = false;
    return this;
  }

  @override
  Stream<FileSystemEvent> watch({
    int events = FileSystemEvent.all,
    bool recursive = false,
  }) {
    return const Stream.empty();
  }
}

// Mock Directory implementation
class MockDirectory with FileSystemEntity implements Directory {
  final MockFileSystem _fs;
  final String _path;
  bool _exists = false;
  final List<FileSystemEntity> _children = [];

  MockDirectory(this._fs, this._path);

  @override
  String get path => _path;

  @override
  FileSystem get fileSystem => _fs;

  @override
  Future<bool> exists() async => _exists;

  void setExists(bool value) => _exists = value;

  @override
  Future<Directory> create({bool recursive = false}) async {
    _exists = true;
    return this;
  }

  @override
  Future<Directory> rename(String newPath) async {
    return MockDirectory(_fs, newPath).._exists = true;
  }

  @override
  Future<Directory> get absolute async => this;

  @override
  Stream<FileSystemEntity> list({
    bool recursive = false,
    bool followLinks = true,
  }) {
    return Stream.fromIterable(_children);
  }

  void addChild(FileSystemEntity entity) {
    _children.add(entity);
  }

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) async {
    _exists = false;
    return this;
  }

  @override
  Stream<FileSystemEvent> watch({
    int events = FileSystemEvent.all,
    bool recursive = false,
  }) {
    return const Stream.empty();
  }
}

// Mock Link implementation
class MockLink with FileSystemEntity implements Link {
  final MockFileSystem _fs;
  final String _path;
  bool _exists = false;
  String _target = '';

  MockLink(this._fs, this._path);

  @override
  String get path => _path;

  @override
  FileSystem get fileSystem => _fs;

  @override
  Future<bool> exists() async => _exists;

  void setExists(bool value) => _exists = value;

  @override
  Future<Link> create(String target, {bool recursive = false}) async {
    _exists = true;
    _target = target;
    return this;
  }

  @override
  Future<Link> update(String target) async {
    _target = target;
    return this;
  }

  @override
  Future<String> target() async => _target;

  @override
  Future<Link> rename(String newPath) async {
    return MockLink(_fs, newPath)
      .._exists = true
      .._target = _target;
  }

  @override
  Future<Link> get absolute async => this;

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) async {
    _exists = false;
    return this;
  }

  @override
  Stream<FileSystemEvent> watch({
    int events = FileSystemEvent.all,
    bool recursive = false,
  }) {
    return const Stream.empty();
  }
}

void main() {
  group('FileSystemEntityType', () {
    test('has all expected values', () {
      expect(FileSystemEntityType.values, hasLength(6));
      expect(FileSystemEntityType.values, contains(FileSystemEntityType.file));
      expect(
        FileSystemEntityType.values,
        contains(FileSystemEntityType.directory),
      );
      expect(FileSystemEntityType.values, contains(FileSystemEntityType.link));
      expect(
        FileSystemEntityType.values,
        contains(FileSystemEntityType.socket),
      );
      expect(FileSystemEntityType.values, contains(FileSystemEntityType.pipe));
      expect(
        FileSystemEntityType.values,
        contains(FileSystemEntityType.unknown),
      );
    });

    test('file type has correct name', () {
      expect(FileSystemEntityType.file.name, 'file');
    });

    test('directory type has correct name', () {
      expect(FileSystemEntityType.directory.name, 'directory');
    });

    test('link type has correct name', () {
      expect(FileSystemEntityType.link.name, 'link');
    });
  });

  group('FileMode', () {
    test('has all expected values', () {
      expect(FileMode.values, hasLength(5));
      expect(FileMode.values, contains(FileMode.read));
      expect(FileMode.values, contains(FileMode.write));
      expect(FileMode.values, contains(FileMode.append));
      expect(FileMode.values, contains(FileMode.writeOnly));
      expect(FileMode.values, contains(FileMode.writeOnlyAppend));
    });

    test('read mode has correct name', () {
      expect(FileMode.read.name, 'read');
    });

    test('write mode has correct name', () {
      expect(FileMode.write.name, 'write');
    });

    test('append mode has correct name', () {
      expect(FileMode.append.name, 'append');
    });
  });

  group('FileStat', () {
    test('creates with required parameters', () {
      final now = DateTime.now();
      final stat = FileStat(
        changed: now,
        modified: now,
        accessed: now,
        type: FileSystemEntityType.file,
        size: 1024,
      );

      expect(stat.changed, now);
      expect(stat.modified, now);
      expect(stat.accessed, now);
      expect(stat.type, FileSystemEntityType.file);
      expect(stat.size, 1024);
    });

    test('stores different timestamps', () {
      final changed = DateTime(2025, 1, 1);
      final modified = DateTime(2025, 1, 2);
      final accessed = DateTime(2025, 1, 3);

      final stat = FileStat(
        changed: changed,
        modified: modified,
        accessed: accessed,
        type: FileSystemEntityType.directory,
        size: 4096,
      );

      expect(stat.changed, changed);
      expect(stat.modified, modified);
      expect(stat.accessed, accessed);
    });

    test('can represent zero size', () {
      final stat = FileStat(
        changed: DateTime.now(),
        modified: DateTime.now(),
        accessed: DateTime.now(),
        type: FileSystemEntityType.file,
        size: 0,
      );

      expect(stat.size, 0);
    });

    test('can represent large file size', () {
      final largeSize = 1024 * 1024 * 1024 * 100; // 100 GB
      final stat = FileStat(
        changed: DateTime.now(),
        modified: DateTime.now(),
        accessed: DateTime.now(),
        type: FileSystemEntityType.file,
        size: largeSize,
      );

      expect(stat.size, largeSize);
    });

    test('stores all entity types', () {
      for (final type in FileSystemEntityType.values) {
        final stat = FileStat(
          changed: DateTime.now(),
          modified: DateTime.now(),
          accessed: DateTime.now(),
          type: type,
          size: 0,
        );
        expect(stat.type, type);
      }
    });
  });

  group('FileSystemEvent', () {
    test('create constant has correct value', () {
      expect(FileSystemEvent.create, 1 << 0);
      expect(FileSystemEvent.create, 1);
    });

    test('modify constant has correct value', () {
      expect(FileSystemEvent.modify, 1 << 1);
      expect(FileSystemEvent.modify, 2);
    });

    test('delete constant has correct value', () {
      expect(FileSystemEvent.delete, 1 << 2);
      expect(FileSystemEvent.delete, 4);
    });

    test('move constant has correct value', () {
      expect(FileSystemEvent.move, 1 << 3);
      expect(FileSystemEvent.move, 8);
    });

    test('all combines all event types', () {
      final expectedAll =
          FileSystemEvent.create |
          FileSystemEvent.modify |
          FileSystemEvent.delete |
          FileSystemEvent.move;

      expect(FileSystemEvent.all, expectedAll);
      expect(FileSystemEvent.all, 15);
    });

    test('creates with all parameters', () {
      final event = FileSystemEvent(
        FileSystemEvent.create,
        '/path/to/file',
        false,
      );

      expect(event.type, FileSystemEvent.create);
      expect(event.path, '/path/to/file');
      expect(event.isDirectory, false);
    });

    test('creates directory event', () {
      final event = FileSystemEvent(
        FileSystemEvent.delete,
        '/path/to/dir',
        true,
      );

      expect(event.type, FileSystemEvent.delete);
      expect(event.path, '/path/to/dir');
      expect(event.isDirectory, true);
    });

    test('event types can be combined with OR', () {
      final createOrModify = FileSystemEvent.create | FileSystemEvent.modify;
      expect(createOrModify, 3);

      final allExceptMove =
          FileSystemEvent.create |
          FileSystemEvent.modify |
          FileSystemEvent.delete;
      expect(allExceptMove, 7);
    });
  });

  group('FileSystemException', () {
    test('creates with message and path', () {
      final exception = FileSystemException('File not found', '/path/to/file');

      expect(exception.message, 'File not found');
      expect(exception.path, '/path/to/file');
    });

    test('toString includes message and path', () {
      final exception = FileSystemException('Permission denied', '/etc/passwd');
      final str = exception.toString();

      expect(str, contains('FileSystemException'));
      expect(str, contains('Permission denied'));
      expect(str, contains('/etc/passwd'));
    });

    test('handles empty message', () {
      final exception = FileSystemException('', '/path');
      expect(exception.message, '');
    });

    test('handles empty path', () {
      final exception = FileSystemException('Error', '');
      expect(exception.path, '');
    });

    test('handles special characters in path', () {
      final exception = FileSystemException(
        'Error',
        '/path/with spaces/and "quotes"',
      );
      expect(exception.path, '/path/with spaces/and "quotes"');
    });
  });

  group('FileSystem', () {
    late MockFileSystem fs;

    setUp(() {
      fs = MockFileSystem();
    });

    test('can be implemented', () {
      expect(fs, isA<FileSystem>());
    });

    test('currentDirectory returns Directory', () {
      expect(fs.currentDirectory, isA<Directory>());
      expect(fs.currentDirectory.path, '/home/user');
    });

    test('directory returns Directory at path', () {
      final dir = fs.directory('/tmp');
      expect(dir, isA<Directory>());
      expect(dir.path, '/tmp');
    });

    test('file returns File at path', () {
      final file = fs.file('/tmp/test.txt');
      expect(file, isA<File>());
      expect(file.path, '/tmp/test.txt');
    });

    test('link returns Link at path', () {
      final link = fs.link('/tmp/link');
      expect(link, isA<Link>());
      expect(link.path, '/tmp/link');
    });

    test('path provides Context for path manipulation', () {
      expect(fs.path, isA<p.Context>());
      expect(fs.path.join('/home', 'user'), '/home/user');
    });

    test('stat returns FileStat', () async {
      final stat = await fs.stat('/test');
      expect(stat, isA<FileStat>());
    });

    test('stat returns custom stat when set', () async {
      final now = DateTime.now();
      fs.setStat(
        '/test',
        FileStat(
          changed: now,
          modified: now,
          accessed: now,
          type: FileSystemEntityType.file,
          size: 1024,
        ),
      );

      final stat = await fs.stat('/test');
      expect(stat.size, 1024);
      expect(stat.type, FileSystemEntityType.file);
    });

    test('identical returns true for same paths', () async {
      expect(await fs.identical('/path/a', '/path/a'), isTrue);
    });

    test('identical returns false for different paths', () async {
      expect(await fs.identical('/path/a', '/path/b'), isFalse);
    });

    test('isWatchSupported returns boolean', () {
      expect(fs.isWatchSupported, isTrue);
      fs.isWatchSupported = false;
      expect(fs.isWatchSupported, isFalse);
    });

    test('type returns FileSystemEntityType', () async {
      fs.setType('/test', FileSystemEntityType.file);
      expect(await fs.type('/test'), FileSystemEntityType.file);
    });

    test('type returns unknown for non-existent path', () async {
      expect(await fs.type('/nonexistent'), FileSystemEntityType.unknown);
    });

    test('isFile returns true for files', () async {
      fs.setType('/test.txt', FileSystemEntityType.file);
      expect(await fs.isFile('/test.txt'), isTrue);
    });

    test('isFile returns false for directories', () async {
      fs.setType('/dir', FileSystemEntityType.directory);
      expect(await fs.isFile('/dir'), isFalse);
    });

    test('isDirectory returns true for directories', () async {
      fs.setType('/dir', FileSystemEntityType.directory);
      expect(await fs.isDirectory('/dir'), isTrue);
    });

    test('isDirectory returns false for files', () async {
      fs.setType('/test.txt', FileSystemEntityType.file);
      expect(await fs.isDirectory('/test.txt'), isFalse);
    });

    test('isLink returns true for links', () async {
      fs.setType('/link', FileSystemEntityType.link);
      expect(await fs.isLink('/link'), isTrue);
    });

    test('isLink returns false for files', () async {
      fs.setType('/test.txt', FileSystemEntityType.file);
      expect(await fs.isLink('/test.txt'), isFalse);
    });
  });

  group('File', () {
    late MockFileSystem fs;
    late MockFile file;

    setUp(() {
      fs = MockFileSystem();
      file = fs.file('/test.txt') as MockFile;
    });

    test('implements File and FileSystemEntity', () {
      expect(file, isA<File>());
      expect(file, isA<FileSystemEntity>());
    });

    test('path returns file path', () {
      expect(file.path, '/test.txt');
    });

    test('fileSystem returns the file system', () {
      expect(file.fileSystem, same(fs));
    });

    test('basename returns file name', () {
      expect(file.basename, 'test.txt');
    });

    test('dirname returns parent path', () {
      expect(file.dirname, '/');
    });

    test('parent returns parent Directory', () {
      expect(file.parent, isA<Directory>());
      expect(file.parent.path, '/');
    });

    test('exists returns false initially', () async {
      expect(await file.exists(), isFalse);
    });

    test('create sets exists to true', () async {
      await file.create();
      expect(await file.exists(), isTrue);
    });

    test('rename returns new File', () async {
      final renamed = await file.rename('/renamed.txt');
      expect(renamed.path, '/renamed.txt');
    });

    test('copy returns new File with same content', () async {
      await file.writeAsString('Hello');
      final copied = await file.copy('/copy.txt');
      expect(copied.path, '/copy.txt');
      expect(await (copied as MockFile).readAsString(), 'Hello');
    });

    test('writeAsBytes stores bytes', () async {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      await file.writeAsBytes(bytes);
      expect(await file.readAsBytes(), bytes);
    });

    test('writeAsString stores string', () async {
      await file.writeAsString('Hello, World!');
      expect(await file.readAsString(), 'Hello, World!');
    });

    test('readAsString returns written content', () async {
      await file.writeAsString('Test content');
      expect(await file.readAsString(), 'Test content');
    });

    test('readAsBytes returns written bytes', () async {
      final bytes = Uint8List.fromList([65, 66, 67]); // ABC
      await file.writeAsBytes(bytes);
      expect(await file.readAsBytes(), bytes);
    });

    test('delete sets exists to false', () async {
      await file.create();
      expect(await file.exists(), isTrue);
      await file.delete();
      expect(await file.exists(), isFalse);
    });

    test('absolute returns File', () async {
      expect(await file.absolute, isA<File>());
    });

    test('stat returns FileStat', () async {
      expect(await file.stat(), isA<FileStat>());
    });

    test('watch returns Stream', () {
      expect(file.watch(), isA<Stream<FileSystemEvent>>());
    });

    test('cachedStat returns null by default', () {
      expect(file.cachedStat, isNull);
    });
  });

  group('Directory', () {
    late MockFileSystem fs;
    late MockDirectory dir;

    setUp(() {
      fs = MockFileSystem();
      dir = fs.directory('/home/user/documents') as MockDirectory;
    });

    test('implements Directory and FileSystemEntity', () {
      expect(dir, isA<Directory>());
      expect(dir, isA<FileSystemEntity>());
    });

    test('path returns directory path', () {
      expect(dir.path, '/home/user/documents');
    });

    test('fileSystem returns the file system', () {
      expect(dir.fileSystem, same(fs));
    });

    test('basename returns directory name', () {
      expect(dir.basename, 'documents');
    });

    test('dirname returns parent path', () {
      expect(dir.dirname, '/home/user');
    });

    test('parent returns parent Directory', () {
      expect(dir.parent, isA<Directory>());
      expect(dir.parent.path, '/home/user');
    });

    test('exists returns false initially', () async {
      expect(await dir.exists(), isFalse);
    });

    test('create sets exists to true', () async {
      await dir.create();
      expect(await dir.exists(), isTrue);
    });

    test('rename returns new Directory', () async {
      final renamed = await dir.rename('/home/user/docs');
      expect(renamed.path, '/home/user/docs');
    });

    test('list returns Stream of children', () async {
      final file = fs.file('/home/user/documents/test.txt');
      dir.addChild(file);

      final children = await dir.list().toList();
      expect(children.length, 1);
      expect(children.first.path, '/home/user/documents/test.txt');
    });

    test('list returns empty Stream when no children', () async {
      final children = await dir.list().toList();
      expect(children, isEmpty);
    });

    test('delete sets exists to false', () async {
      await dir.create();
      expect(await dir.exists(), isTrue);
      await dir.delete();
      expect(await dir.exists(), isFalse);
    });

    test('absolute returns Directory', () async {
      expect(await dir.absolute, isA<Directory>());
    });

    test('stat returns FileStat', () async {
      expect(await dir.stat(), isA<FileStat>());
    });

    test('watch returns Stream', () {
      expect(dir.watch(), isA<Stream<FileSystemEvent>>());
    });
  });

  group('Link', () {
    late MockFileSystem fs;
    late MockLink link;

    setUp(() {
      fs = MockFileSystem();
      link = fs.link('/home/user/mylink') as MockLink;
    });

    test('implements Link and FileSystemEntity', () {
      expect(link, isA<Link>());
      expect(link, isA<FileSystemEntity>());
    });

    test('path returns link path', () {
      expect(link.path, '/home/user/mylink');
    });

    test('fileSystem returns the file system', () {
      expect(link.fileSystem, same(fs));
    });

    test('basename returns link name', () {
      expect(link.basename, 'mylink');
    });

    test('dirname returns parent path', () {
      expect(link.dirname, '/home/user');
    });

    test('parent returns parent Directory', () {
      expect(link.parent, isA<Directory>());
      expect(link.parent.path, '/home/user');
    });

    test('exists returns false initially', () async {
      expect(await link.exists(), isFalse);
    });

    test('create sets exists to true and stores target', () async {
      await link.create('/target/path');
      expect(await link.exists(), isTrue);
      expect(await link.target(), '/target/path');
    });

    test('update changes target', () async {
      await link.create('/old/target');
      await link.update('/new/target');
      expect(await link.target(), '/new/target');
    });

    test('target returns stored target', () async {
      await link.create('/the/target');
      expect(await link.target(), '/the/target');
    });

    test('rename returns new Link with same target', () async {
      await link.create('/target');
      final renamed = await link.rename('/home/user/renamed');
      expect(renamed.path, '/home/user/renamed');
      expect(await renamed.target(), '/target');
    });

    test('delete sets exists to false', () async {
      await link.create('/target');
      expect(await link.exists(), isTrue);
      await link.delete();
      expect(await link.exists(), isFalse);
    });

    test('absolute returns Link', () async {
      expect(await link.absolute, isA<Link>());
    });

    test('stat returns FileStat', () async {
      expect(await link.stat(), isA<FileStat>());
    });

    test('watch returns Stream', () {
      expect(link.watch(), isA<Stream<FileSystemEvent>>());
    });
  });

  group('FileSystemEntity mixin', () {
    late MockFileSystem fs;

    setUp(() {
      fs = MockFileSystem();
    });

    test('basename handles root path', () {
      final file = fs.file('/');
      expect(file.basename, '/');
    });

    test('basename handles nested path', () {
      final file = fs.file('/a/b/c/file.txt');
      expect(file.basename, 'file.txt');
    });

    test('dirname handles root path', () {
      final file = fs.file('/file.txt');
      expect(file.dirname, '/');
    });

    test('dirname handles nested path', () {
      final file = fs.file('/a/b/c/file.txt');
      expect(file.dirname, '/a/b/c');
    });

    test('parent chain works correctly', () {
      final file = fs.file('/a/b/file.txt');
      final parent1 = file.parent;
      expect(parent1.path, '/a/b');

      final parent2 = parent1.parent;
      expect(parent2.path, '/a');

      final parent3 = parent2.parent;
      expect(parent3.path, '/');
    });

    test('cachedStat returns null by default in mixin', () {
      final file = fs.file('/test');
      expect(file.cachedStat, isNull);
    });
  });
}
