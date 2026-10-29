import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_core/terminal_core.dart';

// Mock HostSpec implementation
class MockHostSpec implements HostSpec {
  @override
  final String name = 'Mock Host';

  @override
  HostConnector createConnector() {
    return MockHostConnector();
  }
}

// Mock Host implementation
class MockHost implements Host {
  final Completer<void> _doneCompleter = Completer<void>();
  bool _disconnected = false;

  @override
  Future<FileSystem> connectFileSystem() async {
    throw UnimplementedError();
  }

  @override
  Future<ExecutionResult> execute(
    String executable, {
    List<String> args = const [],
    bool root = false,
    Map<String, String>? environment,
  }) async {
    return MockExecutionResult(
      exitCode: 0,
      stdout: 'executed: $executable',
      stderr: '',
    );
  }

  @override
  Future<ExecutionSession> shell({
    int width = 80,
    int height = 25,
    Map<String, String>? environment,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> disconnect() async {
    if (!_disconnected) {
      _disconnected = true;
      _doneCompleter.complete();
    }
  }

  @override
  Future<void> get done => _doneCompleter.future;
}

// Mock ExecutionResult implementation
class MockExecutionResult implements ExecutionResult {
  MockExecutionResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  @override
  final int exitCode;

  @override
  final String stdout;

  @override
  final String stderr;
}

// Mock HostConnector implementation
class MockHostConnector extends HostConnector<MockHost> {
  MockHost? mockHost;
  bool createHostCalled = false;

  @override
  Future<MockHost> createHost() async {
    createHostCalled = true;
    mockHost = MockHost();
    return mockHost!;
  }
}

// Test Plugin implementation
class TestPlugin with Plugin {
  bool didMountedCalled = false;
  bool didUnmountedCalled = false;
  bool didConnectedCalled = false;
  bool didDisconnectedCalled = false;
  HostConnectorStatus? lastStatus;

  @override
  void didMounted() {
    didMountedCalled = true;
    super.didMounted();
  }

  @override
  void didUnmounted() {
    didUnmountedCalled = true;
    super.didUnmounted();
  }

  @override
  void didConnected() {
    didConnectedCalled = true;
    super.didConnected();
  }

  @override
  void didDisconnected() {
    didDisconnectedCalled = true;
    super.didDisconnected();
  }

  @override
  void onConnectionStatus(HostConnectorStatus status) {
    lastStatus = status;
    super.onConnectionStatus(status);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

void main() {
  group('Plugin', () {
    late TestPlugin plugin;

    setUp(() {
      plugin = TestPlugin();
    });

    test('initial state is not mounted', () {
      expect(plugin.mounted, isFalse);
      expect(plugin.connected, isFalse);
    });

    test('title is initially null', () {
      expect(plugin.title.value, isNull);
    });

    test('title can be set', () {
      plugin.title.value = 'Test Title';
      expect(plugin.title.value, 'Test Title');
    });

    test('accessing hostSpec before mount throws', () {
      expect(() => plugin.hostSpec, throwsA(isA<Exception>()));
    });

    test('accessing host before connect throws', () {
      expect(() => plugin.host, throwsA(isA<Exception>()));
    });

    test('accessing manager before mount throws', () {
      expect(() => plugin.manager, throwsA(isA<StateError>()));
    });
  });

  group('PluginManager', () {
    late PluginManager manager;
    late MockHostSpec hostSpec;
    late TestPlugin plugin;

    setUp(() {
      hostSpec = MockHostSpec();
      manager = PluginManager(hostSpec);
      plugin = TestPlugin();
    });

    test('initial state is not connected', () {
      expect(manager.isConnected, isFalse);
    });

    test('plugins list is initially empty', () {
      expect(manager.plugins, isEmpty);
    });

    test('add mounts plugin', () {
      manager.add(plugin);

      expect(plugin.mounted, isTrue);
      expect(plugin.didMountedCalled, isTrue);
      expect(manager.plugins, contains(plugin));
    });

    test('add makes hostSpec available', () {
      manager.add(plugin);

      expect(plugin.hostSpec, hostSpec);
      expect(plugin.hostSpec.name, 'Mock Host');
    });

    test('remove unmounts plugin', () {
      manager.add(plugin);
      manager.remove(plugin);

      expect(plugin.mounted, isFalse);
      expect(plugin.didUnmountedCalled, isTrue);
      expect(manager.plugins, isNot(contains(plugin)));
    });

    test('cannot add already mounted plugin', () {
      manager.add(plugin);

      expect(() => manager.add(plugin), throwsA(isA<Exception>()));
    });

    test('cannot remove unmounted plugin', () {
      expect(() => manager.remove(plugin), throwsA(isA<Exception>()));
    });

    test('didConnected connects all plugins', () {
      final plugin1 = TestPlugin();
      final plugin2 = TestPlugin();
      final host = MockHost();

      manager.add(plugin1);
      manager.add(plugin2);

      expect(plugin1.connected, isFalse);
      expect(plugin2.connected, isFalse);

      manager.didConnected(host);

      expect(manager.isConnected, isTrue);
      expect(plugin1.connected, isTrue);
      expect(plugin2.connected, isTrue);
      expect(plugin1.didConnectedCalled, isTrue);
      expect(plugin2.didConnectedCalled, isTrue);
    });

    test('plugin added after connection is auto-connected', () {
      final host = MockHost();
      manager.didConnected(host);

      manager.add(plugin);

      expect(plugin.connected, isTrue);
      expect(plugin.didConnectedCalled, isTrue);
    });

    test('didDisconnected disconnects all plugins', () {
      final plugin1 = TestPlugin();
      final plugin2 = TestPlugin();
      final host = MockHost();

      manager.add(plugin1);
      manager.add(plugin2);
      manager.didConnected(host);

      manager.didDisconnected();

      expect(manager.isConnected, isFalse);
      expect(plugin1.connected, isFalse);
      expect(plugin2.connected, isFalse);
      expect(plugin1.didDisconnectedCalled, isTrue);
      expect(plugin2.didDisconnectedCalled, isTrue);
    });

    test('cannot call didConnected twice', () {
      final host = MockHost();
      manager.didConnected(host);

      expect(() => manager.didConnected(host), throwsA(isA<Exception>()));
    });

    test('cannot call didDisconnected when not connected', () {
      expect(() => manager.didDisconnected(), throwsA(isA<Exception>()));
    });

    test('didConnectionStatusChanged notifies all plugins', () {
      final plugin1 = TestPlugin();
      final plugin2 = TestPlugin();

      manager.add(plugin1);
      manager.add(plugin2);

      manager.didConnectionStatusChanged(HostConnectorStatus.connecting);

      expect(plugin1.lastStatus, HostConnectorStatus.connecting);
      expect(plugin2.lastStatus, HostConnectorStatus.connecting);
    });

    test('notifies listeners when plugin added', () {
      var notified = false;
      manager.addListener(() => notified = true);

      manager.add(plugin);

      expect(notified, isTrue);
    });

    test('notifies listeners when plugin removed', () {
      manager.add(plugin);
      var notified = false;
      manager.addListener(() => notified = true);

      manager.remove(plugin);

      expect(notified, isTrue);
    });

    test('plugins list is unmodifiable', () {
      manager.add(plugin);

      expect(
        () => manager.plugins.add(TestPlugin()),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('HostConnectorStatus', () {
    test('has all expected values', () {
      expect(HostConnectorStatus.values, hasLength(5));
      expect(
        HostConnectorStatus.values,
        contains(HostConnectorStatus.initialized),
      );
      expect(
        HostConnectorStatus.values,
        contains(HostConnectorStatus.connecting),
      );
      expect(
        HostConnectorStatus.values,
        contains(HostConnectorStatus.connected),
      );
      expect(
        HostConnectorStatus.values,
        contains(HostConnectorStatus.disconnected),
      );
      expect(HostConnectorStatus.values, contains(HostConnectorStatus.aborted));
    });
  });

  group('HostConnector', () {
    late MockHostConnector connector;

    setUp(() {
      connector = MockHostConnector();
    });

    test('initial status is initialized', () {
      expect(connector.status, HostConnectorStatus.initialized);
    });

    test('host is initially null', () {
      expect(connector.host, isNull);
    });

    test('connect changes status to connecting then connected', () async {
      final statuses = <HostConnectorStatus>[];
      connector.addListener(() => statuses.add(connector.status));

      await connector.connect();

      expect(statuses, [
        HostConnectorStatus.connecting,
        HostConnectorStatus.connected,
      ]);
    });

    test('connect creates host', () async {
      await connector.connect();

      expect(connector.createHostCalled, isTrue);
      expect(connector.host, isNotNull);
    });

    test('connect is idempotent when connected', () async {
      await connector.connect();
      connector.createHostCalled = false;

      await connector.connect();

      expect(connector.createHostCalled, isFalse);
    });

    test('connect is idempotent when connecting', () async {
      // Start connection but don't await
      final future = connector.connect();
      connector.createHostCalled = false;

      await connector.connect();

      await future;
      expect(connector.createHostCalled, isFalse);
    });

    test('disconnect changes status to disconnected', () async {
      await connector.connect();

      await connector.disconnect();

      expect(connector.status, HostConnectorStatus.disconnected);
      expect(connector.host, isNull);
    });

    test('disconnect calls host.disconnect', () async {
      await connector.connect();
      final host = connector.mockHost!;

      await connector.disconnect();

      expect(host.done, completes);
    });

    test('notifies listeners on status change', () async {
      var notifyCount = 0;
      connector.addListener(() => notifyCount++);

      await connector.connect();

      // connecting + connected = 2 notifications
      expect(notifyCount, 2);
    });
  });

  group('ExecutionResult interface', () {
    test('MockExecutionResult stores values correctly', () {
      final result = MockExecutionResult(
        exitCode: 42,
        stdout: 'output',
        stderr: 'error',
      );

      expect(result.exitCode, 42);
      expect(result.stdout, 'output');
      expect(result.stderr, 'error');
    });
  });
}
