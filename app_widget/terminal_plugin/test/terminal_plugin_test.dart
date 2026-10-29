import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_plugin/terminal_plugin.dart';
import 'package:xterm/xterm.dart';

/// Mock implementation of Host for testing.
class MockHost implements Host {
  final _doneCompleter = Completer<void>();

  @override
  Future<void> get done => _doneCompleter.future;

  @override
  Future<void> disconnect() async {
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete();
    }
  }

  @override
  Future<FileSystem> connectFileSystem() {
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
    return MockExecutionSession();
  }
}

class MockExecutionSession implements ExecutionSession {
  final _outputController = StreamController<Uint8List>.broadcast();
  final _exitCodeCompleter = Completer<int>();
  bool isClosed = false;

  @override
  Stream<Uint8List> get output => _outputController.stream;

  @override
  Future<int> get exitCode => _exitCodeCompleter.future;

  @override
  Future<void> write(Uint8List data) async {}

  @override
  Future<void> resize(int width, int height) async {}

  @override
  Future<void> close() async {
    isClosed = true;
    if (!_exitCodeCompleter.isCompleted) {
      _exitCodeCompleter.complete(0);
    }
    await _outputController.close();
  }

  /// Send output to the terminal
  void sendOutput(String text) {
    _outputController.add(Uint8List.fromList(text.codeUnits));
  }

  /// Signal exit
  void exit(int code) {
    if (!_exitCodeCompleter.isCompleted) {
      _exitCodeCompleter.complete(code);
    }
  }

  @override
  void ackRead() {
    // Mock implementation, no-op
  }
}

/// Mock HostConnector for testing.
class MockHostConnector extends HostConnector<MockHost> {
  final MockHost mockHost;

  MockHostConnector(this.mockHost);

  @override
  Future<MockHost> createHost() async => mockHost;
}

/// Mock HostSpec for testing.
class MockHostSpec implements HostSpec {
  final MockHost? mockHost;

  MockHostSpec({this.mockHost});

  @override
  String get name => 'Mock Host';

  @override
  HostConnector createConnector() => MockHostConnector(mockHost ?? MockHost());
}

void main() {
  group('TerminalPlugin', () {
    late TerminalPlugin plugin;
    late PluginManager manager;
    late MockHost mockHost;
    late MockHostSpec mockHostSpec;

    setUp(() {
      plugin = TerminalPlugin();
      mockHost = MockHost();
      mockHostSpec = MockHostSpec(mockHost: mockHost);
      manager = PluginManager(mockHostSpec);
    });

    tearDown(() {
      if (plugin.mounted) {
        if (plugin.connected) {
          manager.didDisconnected();
        }
        manager.remove(plugin);
      }
    });

    test('extends Plugin', () {
      expect(plugin, isA<Plugin>());
    });

    test('has Terminal instance', () {
      expect(plugin.terminal, isA<Terminal>());
    });

    test('has TerminalController', () {
      expect(plugin.terminalController, isA<TerminalController>());
    });

    test('terminal maxLines defaults to 10000', () {
      expect(plugin.terminal.maxLines, 10000);
    });

    test('custom scrollback lines', () {
      final customPlugin = TerminalPlugin(scrollbackLines: 5000);
      expect(customPlugin.terminal.maxLines, 5000);
    });

    test('profile font settings', () {
      final customPlugin = TerminalPlugin(
        profileFontSize: 18.0,
        profileFontFamily: 'JetBrains Mono',
        profileCursorType: TerminalCursorType.underline,
      );
      expect(customPlugin.profileFontSize, 18.0);
      expect(customPlugin.profileFontFamily, 'JetBrains Mono');
      expect(customPlugin.profileCursorType, TerminalCursorType.underline);
    });

    test('initially not mounted', () {
      expect(plugin.mounted, isFalse);
    });

    test('initially not connected', () {
      expect(plugin.connected, isFalse);
    });

    test('session is initially null', () {
      expect(plugin.session, isNull);
    });

    group('lifecycle', () {
      test('didMounted sets title to "Connecting"', () {
        manager.add(plugin);
        expect(plugin.title.value, 'Connecting');
      });

      test('mounted becomes true after add', () {
        manager.add(plugin);
        expect(plugin.mounted, isTrue);
      });

      test('connected becomes true after didConnected', () async {
        manager.add(plugin);
        manager.didConnected(mockHost);

        expect(plugin.connected, isTrue);
      });

      test('didConnected sets title to "Terminal"', () async {
        manager.add(plugin);
        manager.didConnected(mockHost);

        // Wait for async operations
        await Future.delayed(const Duration(milliseconds: 50));

        expect(plugin.title.value, 'Terminal');
      });

      test('didConnected leaves terminal buffer empty before shell output',
          () async {
        manager.add(plugin);
        manager.didConnected(mockHost);

        await Future.delayed(const Duration(milliseconds: 50));

        expect(plugin.terminal.buffer.getText().trim(), isEmpty);
      });

      test('didDisconnected sets title to "Disconnected"', () async {
        manager.add(plugin);
        manager.didConnected(mockHost);
        await Future.delayed(const Duration(milliseconds: 50));

        manager.didDisconnected();

        expect(plugin.title.value, 'Disconnected');
      });

      test('didDisconnected sets session to null', () async {
        manager.add(plugin);
        manager.didConnected(mockHost);
        await Future.delayed(const Duration(milliseconds: 50));

        manager.didDisconnected();

        expect(plugin.session, isNull);
      });
    });

    group('onConnectionStatus', () {
      test('connecting status sets title to "Connecting"', () {
        manager.add(plugin);
        plugin.onConnectionStatus(HostConnectorStatus.connecting);
        expect(plugin.title.value, 'Connecting');
      });

      test('connected status sets title to "Terminal"', () {
        manager.add(plugin);
        plugin.onConnectionStatus(HostConnectorStatus.connected);
        expect(plugin.title.value, 'Terminal');
      });

      test('disconnected status sets title to "Disconnected"', () {
        manager.add(plugin);
        plugin.onConnectionStatus(HostConnectorStatus.disconnected);
        expect(plugin.title.value, 'Disconnected');
      });
    });

    group('terminal callbacks', () {
      test('onTitleChange updates terminalTitle', () {
        manager.add(plugin);

        // Trigger the onTitleChange callback
        plugin.terminal.onTitleChange?.call('New Title');

        expect(plugin.terminalTitle, 'New Title');
      });

      test('OSC 7 working directory updates title', () {
        manager.add(plugin);

        plugin.terminal.write(
          '\x1b]7;file://localhost/Users/test/Projects/web-terminal\x07',
        );
        plugin.terminal.flush();

        expect(plugin.title.value, '/Users/test/Projects/web-terminal');
      });

      test('OSC 7 working directory accepts spaces', () {
        manager.add(plugin);

        plugin.terminal.write(
          '\x1b]7;file://localhost/Users/test/My Project\x07',
        );
        plugin.terminal.flush();

        expect(plugin.title.value, '/Users/test/My Project');
      });

      test('OSC 7 working directory remains title source', () {
        manager.add(plugin);

        plugin.terminal.write(
          '\x1b]7;file://localhost/Users/test/Projects/web-terminal\x07',
        );
        plugin.terminal.flush();
        plugin.terminal.onTitleChange?.call('vim');

        expect(plugin.title.value, '/Users/test/Projects/web-terminal');
      });
    });

    group('manager integration', () {
      test('can be added to manager', () {
        expect(() => manager.add(plugin), returnsNormally);
        expect(manager.plugins, contains(plugin));
      });

      test('can be removed from manager', () {
        manager.add(plugin);
        expect(() => manager.remove(plugin), returnsNormally);
        expect(manager.plugins, isNot(contains(plugin)));
      });

      test('hostSpec is available after mount', () {
        manager.add(plugin);
        expect(plugin.hostSpec, isA<HostSpec>());
      });

      test('host is available after connection', () async {
        manager.add(plugin);
        manager.didConnected(mockHost);
        expect(plugin.host, isA<Host>());
      });
    });

    group('TerminalTabView', () {
      testWidgets('creates a TerminalView widget', (tester) async {
        manager.add(plugin);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TerminalTabView(plugin),
            ),
          ),
        );

        expect(find.byType(TerminalView), findsOneWidget);
      });

      testWidgets('wraps content in SafeArea', (tester) async {
        manager.add(plugin);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TerminalTabView(plugin),
            ),
          ),
        );

        expect(find.byType(SafeArea), findsOneWidget);
      });
    });
  });

  group('MockExecutionSession', () {
    test('can send output', () async {
      final session = MockExecutionSession();
      final outputs = <String>[];

      session.output.listen((data) {
        outputs.add(String.fromCharCodes(data));
      });

      session.sendOutput('Hello, World!');
      await Future.delayed(const Duration(milliseconds: 10));

      expect(outputs, contains('Hello, World!'));
    });

    test('close completes exitCode', () async {
      final session = MockExecutionSession();

      await session.close();

      expect(await session.exitCode, 0);
    });

    test('exit sets specific exit code', () async {
      final session = MockExecutionSession();

      session.exit(42);

      expect(await session.exitCode, 42);
    });
  });
}
