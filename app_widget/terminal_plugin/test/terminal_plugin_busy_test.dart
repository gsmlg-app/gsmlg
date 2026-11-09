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

class _AwareSession extends _Session implements ForegroundProcessAware {
  _AwareSession({this.busy = false, this.fails = false});

  final bool busy;
  final bool fails;

  @override
  Future<bool> hasForegroundProcess() async {
    if (fails) throw StateError('unavailable');
    return busy;
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

  group('TerminalPlugin.isBusy', () {
    test('is idle without a session', () async {
      expect(await plugin.isBusy(), isFalse);
    });

    test('follows the foreground state of a local session', () async {
      plugin.session = _AwareSession();
      expect(await plugin.isBusy(), isFalse);

      plugin.session = _AwareSession(busy: true);
      expect(await plugin.isBusy(), isTrue);
    });

    test('treats sessions without foreground info as busy', () async {
      plugin.session = _Session();
      expect(await plugin.isBusy(), isTrue);
    });

    test('treats a failing foreground query as busy', () async {
      plugin.session = _AwareSession(fails: true);
      expect(await plugin.isBusy(), isTrue);
    });
  });
}
