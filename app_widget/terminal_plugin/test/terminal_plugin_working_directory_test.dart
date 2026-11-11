import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_plugin/terminal_plugin.dart';

class _Session implements ExecutionSession {
  @override
  Stream<Uint8List> get output => const Stream<Uint8List>.empty();

  @override
  Future<int> get exitCode => Future<int>.value(0);

  @override
  void ackRead() {}

  @override
  Future<void> close() async {}

  @override
  Future<void> resize(int width, int height) async {}

  @override
  Future<void> write(Uint8List data) async {}
}

class _AwareSession extends _Session implements WorkingDirectoryAware {
  _AwareSession(this.directory, {this.fails = false});

  final String? directory;
  final bool fails;

  @override
  Future<String?> currentWorkingDirectory() async {
    if (fails) throw StateError('unavailable');
    return directory;
  }
}

void main() {
  late TerminalPlugin plugin;

  setUp(() {
    plugin = TerminalPlugin();
  });

  tearDown(() {
    plugin.terminal.dispose();
  });

  group('TerminalPlugin.liveWorkingDirectory', () {
    test('is null without a session', () async {
      expect(await plugin.liveWorkingDirectory(), isNull);
    });

    test('reads the directory from a session that knows it', () async {
      plugin.session = _AwareSession('/Users/me/project');
      expect(await plugin.liveWorkingDirectory(), '/Users/me/project');
    });

    test('is null for sessions that cannot report it', () async {
      plugin.session = _Session();
      expect(await plugin.liveWorkingDirectory(), isNull);
    });

    test('is null when the lookup fails or is empty', () async {
      plugin.session = _AwareSession('/x', fails: true);
      expect(await plugin.liveWorkingDirectory(), isNull);

      plugin.session = _AwareSession('');
      expect(await plugin.liveWorkingDirectory(), isNull);
    });
  });
}
