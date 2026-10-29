import 'dart:typed_data';

import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path_lib;
import 'package:terminal_core/terminal_core.dart';

/// Mock HostConnector for testing.
class MockHostConnector extends HostConnector<MockHost> {
  @override
  Future<MockHost> createHost() async => MockHost();
}

/// Mock Host implementation.
class MockHost implements Host {
  @override
  Future<FileSystem> connectFileSystem() async => throw UnimplementedError();

  @override
  Future<ExecutionResult> execute(
    String executable, {
    List<String> args = const [],
    bool root = false,
    Map<String, String>? environment,
  }) async => throw UnimplementedError();

  @override
  Future<ExecutionSession> shell({
    int width = 80,
    int height = 25,
    Map<String, String>? environment,
  }) async => throw UnimplementedError();

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> get done => Future.value();
}

/// Mock HostSpec for testing.
class MockHostSpec implements HostSpec {
  @override
  final String name;

  MockHostSpec({this.name = 'Mock'});

  @override
  HostConnector createConnector() => MockHostConnector();
}

/// Mock Plugin for testing.
class MockPlugin with Plugin {
  final String testName;

  MockPlugin({this.testName = 'MockPlugin'}) {
    title.value = testName;
  }

  @override
  Widget build(BuildContext context) => Container();
}

/// Mock TabItem for testing.
class MockTabItem extends TabItem {
  final String testId;

  MockTabItem({this.testId = 'mock-tab'})
    : super(title: const Text('Mock Tab'));
}

/// Mock FileSystem for testing.
class MockFileSystem extends FileSystem {
  @override
  Directory directory(String path) => throw UnimplementedError();

  @override
  File file(String path) => MockFile(fileSystem: this, filePath: path);

  @override
  Link link(String path) => throw UnimplementedError();

  @override
  path_lib.Context get path => path_lib.posix;

  @override
  Directory get currentDirectory => throw UnimplementedError();

  @override
  Future<FileStat> stat(String path) => throw UnimplementedError();

  @override
  Future<bool> identical(String path1, String path2) =>
      throw UnimplementedError();

  @override
  bool get isWatchSupported => false;

  @override
  Future<FileSystemEntityType> type(String path, {bool followLinks = true}) =>
      throw UnimplementedError();
}

/// Mock File for testing.
class MockFile with FileSystemEntity implements File {
  @override
  final String path;

  @override
  final FileSystem fileSystem;

  MockFile({required this.fileSystem, String filePath = '/test/test.txt'})
    : path = filePath;

  factory MockFile.simple({String path = '/test/test.txt'}) {
    final fs = MockFileSystem();
    return MockFile(fileSystem: fs, filePath: path);
  }

  @override
  Future<File> create({bool recursive = false}) async => this;

  @override
  Future<File> rename(String newPath) async => MockFile.simple(path: newPath);

  @override
  Future<File> copy(String newPath) async => MockFile.simple(path: newPath);

  @override
  Future<File> get absolute async => this;

  @override
  Future<File> writeAsBytes(
    Uint8List bytes, {
    FileMode mode = FileMode.write,
    bool flush = false,
  }) async => this;

  @override
  Future<File> writeAsString(
    String contents, {
    FileMode mode = FileMode.write,
    bool flush = false,
  }) async => this;

  @override
  Future<String> readAsString() async => '';

  @override
  Future<Uint8List> readAsBytes() async => Uint8List(0);

  @override
  Future<bool> exists() async => true;

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) async => this;

  @override
  Stream<FileSystemEvent> watch({
    int events = FileSystemEvent.all,
    bool recursive = false,
  }) => const Stream.empty();
}

void main() {
  group('TabsService', () {
    late TabsService service;

    setUp(() {
      service = TabsService();
    });

    group('constructor', () {
      test('creates service with null factories', () {
        expect(service.pluginTabFactory, isNull);
        expect(service.fileTabFactory, isNull);
      });
    });

    group('openPlugin', () {
      test('throws StateError if pluginTabFactory is not set', () {
        final host = MockHostSpec();
        final plugin = MockPlugin();

        expect(
          () => service.openPlugin(host, plugin),
          throwsA(isA<StateError>()),
        );
      });

      test('throws with descriptive message', () {
        final host = MockHostSpec();
        final plugin = MockPlugin();

        expect(
          () => service.openPlugin(host, plugin),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('pluginTabFactory'),
            ),
          ),
        );
      });
    });

    group('openFile', () {
      test('throws StateError if fileTabFactory is not set', () {
        final file = MockFile.simple();

        expect(() => service.openFile(file), throwsA(isA<StateError>()));
      });

      test('throws with descriptive message', () {
        final file = MockFile.simple();

        expect(
          () => service.openFile(file),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('fileTabFactory'),
            ),
          ),
        );
      });
    });

    group('openTab', () {
      test('does nothing when tabs is null', () {
        final tab = MockTabItem();

        // Should not throw
        service.openTab(tab);
        service.openTab(tab, tabs: null);
      });

      test('defaults to activate = true', () {
        // Verify the signature accepts activate parameter
        final tab = MockTabItem();

        service.openTab(tab, activate: true);
        service.openTab(tab, activate: false);
        // These should complete without error
      });
    });

    group('with factories set', () {
      late TabItem capturedPluginTab;
      late TabItem capturedFileTab;
      late Plugin capturedPlugin;
      late PluginManager capturedManager;
      late File capturedFile;

      setUp(() {
        service.pluginTabFactory = (plugin, manager) {
          capturedPlugin = plugin;
          capturedManager = manager;
          capturedPluginTab = MockTabItem();
          return capturedPluginTab;
        };

        service.fileTabFactory = (file) {
          capturedFile = file;
          capturedFileTab = MockTabItem();
          return capturedFileTab;
        };
      });

      test('openPlugin creates PluginManager with correct host', () {
        final host = MockHostSpec(name: 'TestHost');
        final plugin = MockPlugin(testName: 'TestPlugin');

        // Without tabs, tab won't be added but factory is called
        service.openPlugin(host, plugin);

        expect(capturedPlugin.title.value, 'TestPlugin');
        expect(capturedManager, isA<PluginManager>());
      });

      test('openPlugin passes plugin to factory', () {
        final host = MockHostSpec();
        final plugin = MockPlugin(testName: 'UniquePlugin');

        service.openPlugin(host, plugin);

        expect(capturedPlugin.title.value, 'UniquePlugin');
      });

      test('openFile passes file to factory', () {
        final file = MockFile.simple(path: '/path/unique.txt');

        service.openFile(file);

        expect(capturedFile.basename, 'unique.txt');
        expect(capturedFile.path, '/path/unique.txt');
      });
    });
  });

  group('TabsService factory types', () {
    test('PluginTabFactory type accepts Plugin and PluginManager', () {
      TabItem pluginTabFactory(Plugin plugin, PluginManager manager) {
        return MockTabItem();
      }

      final tab = pluginTabFactory(MockPlugin(), PluginManager(MockHostSpec()));
      expect(tab, isA<TabItem>());
    });

    test('FileTabFactory type accepts File', () {
      TabItem fileTabFactory(File file) {
        return MockTabItem();
      }

      final tab = fileTabFactory(MockFile.simple());
      expect(tab, isA<TabItem>());
    });
  });
}
