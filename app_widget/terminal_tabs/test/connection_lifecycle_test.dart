import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_tabs/src/plugin_tab.dart';

class _Host implements Host {
  final closed = Completer<void>();
  int disconnectCount = 0;

  @override
  Future<void> get done => closed.future;

  @override
  Future<void> disconnect() async {
    disconnectCount++;
    if (!closed.isCompleted) closed.complete();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Connector extends HostConnector<_Host> {
  _Connector(this.pendingHost);

  final Future<_Host> pendingHost;

  @override
  Future<_Host> createHost() => pendingHost;
}

class _Spec implements HostSpec {
  _Spec(this.pendingHost);

  final Future<_Host> pendingHost;
  int connectorCount = 0;

  @override
  String get name => 'Test';

  @override
  HostConnector createConnector() {
    connectorCount++;
    return _Connector(pendingHost);
  }
}

class _Plugin extends Plugin {
  @override
  Widget build(BuildContext context) => const Text('Terminal');
}

Widget _view(PluginTab tab) => MaterialApp(home: tab.content.value);

void main() {
  testWidgets('closing the final tab disconnects its host once', (
    tester,
  ) async {
    final host = _Host();
    final plugin = _Plugin();
    final tab = PluginTab(plugin, PluginManager(_Spec(Future.value(host))));
    await tester.pumpWidget(_view(tab));
    await tester.pump();
    expect(plugin.connected, isTrue);

    tab.dispose();
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(host.disconnectCount, 1);
  });

  testWidgets('temporary widget unmount retains the live connection', (
    tester,
  ) async {
    final host = _Host();
    final spec = _Spec(Future.value(host));
    final plugin = _Plugin();
    final tab = PluginTab(plugin, PluginManager(spec));
    await tester.pumpWidget(_view(tab));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    expect(host.disconnectCount, 0);

    await tester.pumpWidget(_view(tab));
    await tester.pump();
    expect(plugin.connected, isTrue);
    expect(spec.connectorCount, 1);
    tab.dispose();
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('connection can finish while its tab view is hidden', (
    tester,
  ) async {
    final pending = Completer<_Host>();
    final host = _Host();
    final spec = _Spec(pending.future);
    final plugin = _Plugin();
    final tab = PluginTab(plugin, PluginManager(spec));
    await tester.pumpWidget(_view(tab));
    await tester.pumpWidget(const SizedBox());
    pending.complete(host);
    await tester.pump();
    expect(plugin.connected, isTrue);
    expect(host.disconnectCount, 0);

    await tester.pumpWidget(_view(tab));
    await tester.pump();
    expect(spec.connectorCount, 1);
    tab.dispose();
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('closing a pending connection releases its eventual host', (
    tester,
  ) async {
    final pending = Completer<_Host>();
    final host = _Host();
    final plugin = _Plugin();
    final tab = PluginTab(plugin, PluginManager(_Spec(pending.future)));
    await tester.pumpWidget(_view(tab));
    tab.dispose();
    await tester.pumpWidget(const SizedBox());
    pending.complete(host);
    await tester.pump();
    expect(host.disconnectCount, 1);
    expect(plugin.connected, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shared manager disconnects only after its final tab closes', (
    tester,
  ) async {
    final host = _Host();
    final manager = PluginManager(_Spec(Future.value(host)));
    final first = PluginTab(_Plugin(), manager);
    final second = PluginTab(_Plugin(), manager);
    await tester.pumpWidget(_view(first));
    await tester.pump();
    first.dispose();
    await tester.pumpWidget(_view(second));
    await tester.pump();
    expect(host.disconnectCount, 0);
    expect(second.plugin.connected, isTrue);

    second.dispose();
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(host.disconnectCount, 1);
  });
}
