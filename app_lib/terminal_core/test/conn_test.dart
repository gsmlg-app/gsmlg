import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_core/terminal_core.dart';

/// Mock Host implementation for testing.
class MockHost implements Host {
  final Completer<void> _doneCompleter = Completer<void>();
  bool disconnectCalled = false;

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
    throw UnimplementedError();
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
    disconnectCalled = true;
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete();
    }
  }

  @override
  Future<void> get done => _doneCompleter.future;

  void simulateDone() {
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete();
    }
  }

  void simulateError(Object error) {
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.completeError(error);
    }
  }
}

/// Mock HostSpec implementation for testing.
class MockHostSpec implements HostSpec {
  @override
  final String name;

  final HostConnector Function() connectorFactory;

  MockHostSpec({this.name = 'Mock', required this.connectorFactory});

  @override
  HostConnector createConnector() => connectorFactory();
}

/// Concrete HostConnector for testing.
class TestHostConnector extends HostConnector<MockHost> {
  MockHost? mockHostToReturn;
  bool createHostCalled = false;
  bool shouldThrowOnConnect = false;

  @override
  Future<MockHost> createHost() async {
    createHostCalled = true;
    if (shouldThrowOnConnect) {
      throw Exception('Connection failed');
    }
    mockHostToReturn ??= MockHost();
    return mockHostToReturn!;
  }
}

void main() {
  group('HostConnectorStatus', () {
    test('has all expected values', () {
      expect(HostConnectorStatus.values.length, 5);
      expect(HostConnectorStatus.initialized, isNotNull);
      expect(HostConnectorStatus.connecting, isNotNull);
      expect(HostConnectorStatus.connected, isNotNull);
      expect(HostConnectorStatus.disconnected, isNotNull);
      expect(HostConnectorStatus.aborted, isNotNull);
    });

    test('values are in expected order', () {
      expect(HostConnectorStatus.values[0], HostConnectorStatus.initialized);
      expect(HostConnectorStatus.values[1], HostConnectorStatus.connecting);
      expect(HostConnectorStatus.values[2], HostConnectorStatus.connected);
      expect(HostConnectorStatus.values[3], HostConnectorStatus.disconnected);
      expect(HostConnectorStatus.values[4], HostConnectorStatus.aborted);
    });
  });

  group('HostConnector', () {
    late TestHostConnector connector;

    setUp(() {
      connector = TestHostConnector();
    });

    tearDown(() {
      connector.dispose();
    });

    group('initial state', () {
      test('status is initialized', () {
        expect(connector.status, HostConnectorStatus.initialized);
      });

      test('host is null', () {
        expect(connector.host, isNull);
      });
    });

    group('connect', () {
      test('transitions through connecting to connected', () async {
        final statuses = <HostConnectorStatus>[];
        connector.addListener(() {
          statuses.add(connector.status);
        });

        await connector.connect();

        expect(statuses, contains(HostConnectorStatus.connecting));
        expect(statuses.last, HostConnectorStatus.connected);
        expect(connector.status, HostConnectorStatus.connected);
      });

      test('host is set after connection', () async {
        await connector.connect();

        expect(connector.host, isNotNull);
        expect(connector.host, isA<MockHost>());
      });

      test('createHost is called', () async {
        expect(connector.createHostCalled, isFalse);

        await connector.connect();

        expect(connector.createHostCalled, isTrue);
      });

      test('does nothing if already connecting', () async {
        connector.mockHostToReturn = MockHost();

        // Start first connection but don't await
        final firstConnect = connector.connect();

        // Try to connect again while already connecting
        await connector.connect();

        // Finish first connection
        await firstConnect;

        // createHost should only have been called once
        expect(connector.createHostCalled, isTrue);
      });

      test('does nothing if already connected', () async {
        await connector.connect();

        connector.createHostCalled = false;

        // Try to connect again while already connected
        await connector.connect();

        // createHost should not have been called again
        expect(connector.createHostCalled, isFalse);
      });

      test('transitions to disconnected on connection error', () async {
        connector.shouldThrowOnConnect = true;

        await connector.connect();

        expect(connector.status, HostConnectorStatus.disconnected);
        expect(connector.host, isNull);
      });
    });

    group('disconnect', () {
      test('disconnects the host', () async {
        await connector.connect();
        final host = connector.host!;

        await connector.disconnect();

        expect(host.disconnectCalled, isTrue);
      });

      test('sets host to null', () async {
        await connector.connect();
        expect(connector.host, isNotNull);

        await connector.disconnect();

        expect(connector.host, isNull);
      });

      test('transitions to disconnected status', () async {
        await connector.connect();

        await connector.disconnect();

        expect(connector.status, HostConnectorStatus.disconnected);
      });

      test('can disconnect when not connected', () async {
        expect(connector.status, HostConnectorStatus.initialized);

        await connector.disconnect();

        expect(connector.status, HostConnectorStatus.disconnected);
      });
    });

    group('host done handling', () {
      test('transitions to disconnected when host completes', () async {
        final mockHost = MockHost();
        connector.mockHostToReturn = mockHost;

        await connector.connect();
        expect(connector.status, HostConnectorStatus.connected);

        // Simulate host completing
        mockHost.simulateDone();

        // Wait for the done future to propagate
        await Future.delayed(Duration.zero);

        expect(connector.status, HostConnectorStatus.disconnected);
        expect(connector.host, isNull);
      });

      test('transitions to aborted when host errors', () async {
        final mockHost = MockHost();
        connector.mockHostToReturn = mockHost;

        await connector.connect();
        expect(connector.status, HostConnectorStatus.connected);

        // Simulate host error
        mockHost.simulateError(Exception('Connection lost'));

        // Wait for the error to propagate
        await Future.delayed(Duration.zero);

        expect(connector.status, HostConnectorStatus.aborted);
        expect(connector.host, isNull);
      });
    });

    group('listener notifications', () {
      test('notifies on status change', () async {
        var notifyCount = 0;
        connector.addListener(() {
          notifyCount++;
        });

        await connector.connect();

        // Should notify for connecting and connected
        expect(notifyCount, greaterThanOrEqualTo(2));
      });

      test('does not notify when status is same', () async {
        await connector.connect();

        var notifyCount = 0;
        connector.addListener(() {
          notifyCount++;
        });

        // Try to connect again (should not change status)
        await connector.connect();

        expect(notifyCount, 0);
      });

      test('can remove listener', () async {
        var notifyCount = 0;
        void listener() {
          notifyCount++;
        }

        connector.addListener(listener);
        connector.removeListener(listener);

        await connector.connect();

        expect(notifyCount, 0);
      });
    });

    group('ChangeNotifier behavior', () {
      test('extends ChangeNotifier', () {
        expect(connector, isA<ChangeNotifier>());
      });
    });
  });

  group('HostSpec', () {
    test('MockHostSpec creates connector via factory', () {
      late TestHostConnector createdConnector;
      final spec = MockHostSpec(
        name: 'Test Host',
        connectorFactory: () {
          createdConnector = TestHostConnector();
          return createdConnector;
        },
      );

      final connector = spec.createConnector();

      expect(connector, createdConnector);
    });

    test('name is accessible', () {
      final spec = MockHostSpec(
        name: 'My Test Host',
        connectorFactory: TestHostConnector.new,
      );

      expect(spec.name, 'My Test Host');
    });
  });

  group('connection lifecycle', () {
    test('full lifecycle: connect -> disconnect', () async {
      final connector = TestHostConnector();
      final statuses = <HostConnectorStatus>[];
      connector.addListener(() {
        statuses.add(connector.status);
      });

      expect(connector.status, HostConnectorStatus.initialized);

      await connector.connect();
      expect(connector.status, HostConnectorStatus.connected);

      await connector.disconnect();
      expect(connector.status, HostConnectorStatus.disconnected);

      expect(
        statuses,
        containsAllInOrder([
          HostConnectorStatus.connecting,
          HostConnectorStatus.connected,
          HostConnectorStatus.disconnected,
        ]),
      );

      connector.dispose();
    });

    test('reconnect after disconnect', () async {
      final connector = TestHostConnector();

      await connector.connect();
      await connector.disconnect();

      connector.createHostCalled = false;
      connector.mockHostToReturn = MockHost();

      await connector.connect();

      expect(connector.status, HostConnectorStatus.connected);
      expect(connector.createHostCalled, isTrue);
      expect(connector.host, isNotNull);

      connector.dispose();
    });

    test('reconnect after error', () async {
      final connector = TestHostConnector();
      connector.shouldThrowOnConnect = true;

      await connector.connect();
      expect(connector.status, HostConnectorStatus.disconnected);

      connector.shouldThrowOnConnect = false;
      connector.createHostCalled = false;

      await connector.connect();

      expect(connector.status, HostConnectorStatus.connected);
      expect(connector.createHostCalled, isTrue);

      connector.dispose();
    });

    test('reconnect after abort', () async {
      final mockHost = MockHost();
      final connector = TestHostConnector();
      connector.mockHostToReturn = mockHost;

      await connector.connect();
      mockHost.simulateError(Exception('Network error'));
      await Future.delayed(Duration.zero);

      expect(connector.status, HostConnectorStatus.aborted);

      connector.createHostCalled = false;
      connector.mockHostToReturn = MockHost();

      await connector.connect();

      expect(connector.status, HostConnectorStatus.connected);

      connector.dispose();
    });
  });
}
