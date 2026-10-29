import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_plugin/terminal_plugin.dart';

class _Session implements ExecutionSession {
  final outputController = StreamController<Uint8List>.broadcast();
  final exited = Completer<int>();
  int acknowledgments = 0;
  int closeCount = 0;

  @override
  Stream<Uint8List> get output => outputController.stream;

  @override
  Future<int> get exitCode => exited.future;

  @override
  void ackRead() => acknowledgments++;

  @override
  Future<void> close() async {
    closeCount++;
    if (!exited.isCompleted) exited.complete(0);
    await outputController.close();
  }

  @override
  Future<void> resize(int width, int height) async {}

  @override
  Future<void> write(Uint8List data) async {}
}

class _Host implements Host {
  _Host(this.pendingSession);

  final Future<ExecutionSession> pendingSession;
  final closed = Completer<void>();

  @override
  Future<ExecutionSession> shell({
    int width = 80,
    int height = 25,
    Map<String, String>? environment,
  }) =>
      pendingSession;

  @override
  Future<void> disconnect() async {
    if (!closed.isCompleted) closed.complete();
  }

  @override
  Future<void> get done => closed.future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Spec implements HostSpec {
  @override
  String get name => 'Test';

  @override
  HostConnector createConnector() => throw UnimplementedError();
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late TerminalPlugin plugin;
  late PluginManager manager;

  setUp(() {
    plugin = TerminalPlugin();
    manager = PluginManager(_Spec());
    manager.add(plugin);
  });

  tearDown(() async {
    if (plugin.mounted) manager.remove(plugin);
    await _settle();
    plugin.terminal.dispose();
  });

  test('acknowledges incomplete UTF-8 chunks before decoding emits text',
      () async {
    final session = _Session();
    manager.didConnected(_Host(Future.value(session)));
    await _settle();
    session.outputController.add(Uint8List.fromList([0xe4]));
    await _settle();
    expect(session.acknowledgments, 1);

    session.outputController.add(Uint8List.fromList([0xb8, 0xad]));
    await _settle();
    plugin.terminal.flush();
    expect(session.acknowledgments, 2);
    expect(plugin.terminal.buffer.getText().trim(), '中');
  });

  test('malformed output does not stop subsequent chunks', () async {
    final session = _Session();
    manager.didConnected(_Host(Future.value(session)));
    await _settle();
    session.outputController.add(Uint8List.fromList([0xff]));
    session.outputController.add(Uint8List.fromList('next'.codeUnits));
    await _settle();
    plugin.terminal.flush();
    expect(session.acknowledgments, 2);
    expect(plugin.terminal.buffer.getText(), contains('next'));
  });

  test('unmount closes session and cancels its output subscription', () async {
    final session = _Session();
    manager.didConnected(_Host(Future.value(session)));
    await _settle();
    manager.remove(plugin);
    await _settle();
    expect(session.closeCount, 1);
    expect(session.outputController.hasListener, isFalse);
    expect(plugin.session, isNull);
  });

  test('unmount closes a shell that finishes opening afterward', () async {
    final pending = Completer<ExecutionSession>();
    final session = _Session();
    manager.didConnected(_Host(pending.future));
    manager.remove(plugin);
    pending.complete(session);
    await _settle();
    expect(session.closeCount, 1);
    expect(plugin.session, isNull);
    expect(session.outputController.hasListener, isFalse);
  });

  test('late shell opening cannot replace the reconnected session', () async {
    final pending = Completer<ExecutionSession>();
    final staleSession = _Session();
    final currentSession = _Session();
    manager.didConnected(_Host(pending.future));
    manager.didDisconnected();
    manager.didConnected(_Host(Future.value(currentSession)));
    await _settle();

    pending.complete(staleSession);
    await _settle();
    expect(staleSession.closeCount, 1);
    expect(currentSession.closeCount, 0);
    expect(plugin.session, same(currentSession));
    expect(plugin.mounted, isTrue);
  });

  test('natural exit removes plugin without closing its session again',
      () async {
    final session = _Session();
    manager.didConnected(_Host(Future.value(session)));
    await _settle();
    session.exited.complete(0);
    await _settle();
    expect(plugin.mounted, isFalse);
    expect(session.closeCount, 0);
    expect(session.outputController.hasListener, isFalse);
    await session.outputController.close();
  });
}
