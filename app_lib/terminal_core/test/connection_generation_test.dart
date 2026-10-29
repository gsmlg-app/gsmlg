import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_core/terminal_core.dart';

class _Host implements Host {
  final closed = Completer<void>();
  int disconnectCount = 0;

  @override
  Future<void> get done => closed.future;

  @override
  Future<void> disconnect() async => disconnectCount++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Connector extends HostConnector<_Host> {
  _Connector(this.attempts);

  final List<Completer<_Host>> attempts;

  @override
  Future<_Host> createHost() => attempts.removeAt(0).future;
}

void main() {
  test(
    'late connection completion cannot replace a newer connection',
    () async {
      final first = Completer<_Host>();
      final second = Completer<_Host>();
      final staleHost = _Host();
      final currentHost = _Host();
      final connector = _Connector([first, second]);
      addTearDown(connector.dispose);

      final firstConnect = connector.connect();
      await connector.disconnect();
      final secondConnect = connector.connect();
      second.complete(currentHost);
      await secondConnect;
      first.complete(staleHost);
      await firstConnect;

      expect(staleHost.disconnectCount, 1);
      expect(currentHost.disconnectCount, 0);
      expect(connector.host, same(currentHost));
      expect(connector.status, HostConnectorStatus.connected);
    },
  );

  test('a previous host finishing cannot disconnect its replacement', () async {
    final first = Completer<_Host>();
    final second = Completer<_Host>();
    final staleHost = _Host();
    final currentHost = _Host();
    final connector = _Connector([first, second]);
    addTearDown(connector.dispose);

    first.complete(staleHost);
    await connector.connect();
    await connector.disconnect();
    second.complete(currentHost);
    await connector.connect();
    staleHost.closed.completeError(StateError('old transport closed'));
    await Future<void>.delayed(Duration.zero);

    expect(connector.host, same(currentHost));
    expect(connector.status, HostConnectorStatus.connected);
  });
}
