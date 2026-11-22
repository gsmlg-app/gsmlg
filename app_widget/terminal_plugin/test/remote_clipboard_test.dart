import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_plugin/src/remote_clipboard.dart';
import 'package:terminal_plugin/terminal_plugin.dart';

import 'terminal_plugin_test.dart' show MockHostSpec;

class _Session implements ExecutionSession {
  final controller = StreamController<Uint8List>(sync: true);
  final exited = Completer<int>();
  final input = <int>[];
  int acknowledgments = 0;

  @override
  Stream<Uint8List> get output => controller.stream;
  @override
  Future<int> get exitCode => exited.future;
  @override
  void ackRead() => acknowledgments++;
  @override
  Future<void> resize(int width, int height) async {}
  @override
  Future<void> write(Uint8List data) async => input.addAll(data);
  @override
  Future<void> close() async {
    if (!exited.isCompleted) exited.complete(0);
    await controller.close();
  }
}

String _osc(String text, {String end = '\x07'}) =>
    '\x1b]52;c;${base64.encode(utf8.encode(text))}$end';

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TerminalPlugin plugin;
  late PluginManager manager;
  late _Session session;
  late List<String> writes;
  late List<String> methods;
  late bool enabled;
  late bool failClipboard;
  Completer<void>? clipboardWait;

  void send(String text) {
    session.controller.add(Uint8List.fromList(utf8.encode(text)));
    plugin.terminal.flush();
  }

  setUp(() {
    writes = [];
    methods = [];
    enabled = true;
    failClipboard = false;
    clipboardWait = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      methods.add(call.method);
      if (call.method == 'Clipboard.setData') {
        if (failClipboard) throw PlatformException(code: 'unavailable');
        writes.add((call.arguments as Map)['text'] as String);
        await clipboardWait?.future;
      }
      if (call.method == 'Clipboard.getData') return {'text': 'local secret'};
      return null;
    });
    plugin = TerminalPlugin(remoteClipboardWritesAllowed: () => enabled);
    manager = PluginManager(MockHostSpec());
    manager.add(plugin);
    session = _Session();
    plugin.debugAttachSession(session);
  });

  tearDown(() async {
    clipboardWait?.complete();
    if (plugin.mounted) manager.remove(plugin);
    await _settle();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  for (final end in ['\x07', '\x1b\\']) {
    test('writes OSC 52 with ${end == '\x07' ? 'BEL' : 'ST'} termination',
        () async {
      send(_osc('hello', end: end));
      await _settle();
      expect(writes, ['hello']);
      expect(plugin.terminal.buffer.getText().trim(), isEmpty);
    });

    test('handles every byte in a separate SSH output chunk with $end',
        () async {
      final bytes =
          utf8.encode('你好${_osc('Unicode 😀\nsecond line', end: end)}!');
      for (final byte in bytes) {
        session.controller.add(Uint8List.fromList([byte]));
        plugin.terminal.flush();
      }
      await _settle();
      expect(writes, ['Unicode 😀\nsecond line']);
      expect(plugin.terminal.buffer.getText().trim(), '你好!');
      expect(session.acknowledgments, bytes.length);
    });
  }

  test('rejects malformed Base64, invalid UTF-8 and extra arguments', () async {
    for (final payload in [
      '***',
      'a',
      'a=',
      '=',
      '==',
      'YQ=',
      'a==',
      'YQ===',
      'Y Q==',
      '%59Q==',
      '_w==',
      '/w==',
      'aGVs;bG8=',
    ]) {
      send('\x1b]52;c;$payload\x07');
    }
    await _settle();
    expect(writes, isEmpty);
    expect(plugin.terminal.buffer.getText().trim(), isEmpty);
  });

  test('accepts valid unpadded Base64 up to 100 KiB and rejects larger',
      () async {
    send('\x1b]52;c;YQ\x07');
    await _settle();
    expect(writes, ['a']);
    writes.clear();

    send('\x1b]52;c;YWI\x07');
    await _settle();
    expect(writes, ['ab']);
    writes.clear();

    final unpaddedHello =
        base64.encode(utf8.encode('hello')).replaceAll('=', '');
    send('\x1b]52;c;$unpaddedHello\x1b\\');
    await _settle();
    expect(writes, ['hello']);
    writes.clear();

    final maxUnpadded = base64
        .encode(utf8.encode('x' * RemoteClipboard.maxDecodedBytes))
        .replaceAll('=', '');
    send('\x1b]52;c;$maxUnpadded\x07');
    await _settle();
    expect(writes.single.length, RemoteClipboard.maxDecodedBytes);
    writes.clear();

    final oversizedUnpadded = base64
        .encode(utf8.encode('x' * (RemoteClipboard.maxDecodedBytes + 1)))
        .replaceAll('=', '');
    send('\x1b]52;c;$oversizedUnpadded\x07');
    await _settle();
    expect(writes, isEmpty);
  });

  test('accepts multi-target selection lists that include c', () async {
    for (final target in ['c', 'cp', 'pc', 'c0', 'cs', '0c7']) {
      writes.clear();
      send('\x1b]52;$target;${base64.encode(utf8.encode(target))}\x07');
      await _settle();
      expect(writes, [target]);
    }
  });

  test('ignores unsupported or malformed selection targets', () async {
    for (final target in ['p', 's', 'q', '0', 'ps', 'z', 'cx', 'cp?']) {
      send('\x1b]52;$target;aGVsbG8=\x07');
    }
    await _settle();
    expect(methods, isEmpty);
  });

  test('accepts exactly 100 KiB and rejects larger decoded payloads', () async {
    send(_osc('x' * RemoteClipboard.maxDecodedBytes));
    await _settle();
    expect(writes.single.length, RemoteClipboard.maxDecodedBytes);
    writes.clear();
    for (final extra in [1, 3, 100]) {
      send(_osc('x' * (RemoteClipboard.maxDecodedBytes + extra)));
    }
    await _settle();
    expect(writes, isEmpty);
    send('still usable');
    expect(plugin.terminal.buffer.getText().trim(), 'still usable');
  });

  test('an empty payload clears the clipboard and empty selection uses it',
      () async {
    send('\x1b]52;;\x07');
    await _settle();
    expect(writes, ['']);
  });

  test('never reads or replies to clipboard queries, even in trusted sessions',
      () async {
    send('\x1b]52;c;?\x07\x1b]52;;?\x1b\\\x1b]52;cp;?\x07');
    await _settle();
    expect(methods, isEmpty);
    expect(session.input, isEmpty);
  });

  test('global configuration is checked for each write', () async {
    enabled = false;
    send(_osc('blocked'));
    await _settle();
    expect(writes, isEmpty);
  });

  test('new interactive sessions allow clipboard writes by default', () async {
    expect(plugin.remoteClipboard.trusted, isTrue);
    send(_osc('allowed'));
    await _settle();
    expect(writes, ['allowed']);
  });

  test('sessions follow the global setting even when it loads after connecting',
      () async {
    plugin.didDisconnected();
    enabled = false;
    session = _Session();
    plugin.debugAttachSession(session);
    expect(plugin.remoteClipboard.trusted, isFalse);
    send(_osc('blocked'));
    await _settle();
    expect(writes, isEmpty);
    enabled = true;
    expect(plugin.remoteClipboard.trusted, isTrue);
    send(_osc('allowed'));
    await _settle();
    expect(writes, ['allowed']);
  });

  test('manual revocation lasts until trust is explicitly restored', () async {
    plugin.setRemoteClipboardTrusted(false);
    enabled = false;
    enabled = true;
    expect(plugin.remoteClipboard.trusted, isFalse);
    send(_osc('blocked'));
    await _settle();
    expect(writes, isEmpty);
    plugin.setRemoteClipboardTrusted(true);
    send(_osc('allowed'));
    await _settle();
    expect(writes, ['allowed']);
  });

  test('cannot grant trust while globally disabled or without a session', () {
    enabled = false;
    plugin.setRemoteClipboardTrusted(true);
    expect(plugin.remoteClipboard.trusted, isFalse);
    enabled = true;
    plugin.didDisconnected();
    plugin.setRemoteClipboardTrusted(true);
    expect(plugin.remoteClipboard.trusted, isFalse);
  });

  test('Clipboard API failure leaves terminal output and later writes usable',
      () async {
    failClipboard = true;
    send('${_osc('failed')}after');
    await _settle();
    expect(plugin.terminal.buffer.getText().trim(), 'after');
    failClipboard = false;
    send(_osc('recovered'));
    await _settle();
    expect(writes, ['recovered']);
  });

  test('does not wait for the OS clipboard to process SSH output or input',
      () async {
    clipboardWait = Completer<void>();
    send(_osc('first'));
    await _settle();
    send('${_osc('second')}rendered');
    plugin.terminal.textInput('input');
    expect(plugin.terminal.buffer.getText().trim(), 'rendered');
    expect(session.acknowledgments, 2);
    expect(utf8.decode(session.input), 'input');
    expect(writes, ['first']);
    clipboardWait!.complete();
    clipboardWait = null;
    await _settle();
    expect(writes, ['first', 'second']);
  });

  test('revocation discards clipboard work that has not started', () async {
    send(_osc('queued'));
    plugin.setRemoteClipboardTrusted(false);
    await _settle();
    expect(writes, isEmpty);
  });

  test('granting trust does not replay already buffered untrusted output',
      () async {
    plugin.setRemoteClipboardTrusted(false);
    session.controller.add(Uint8List.fromList(utf8.encode(_osc('untrusted'))));
    plugin.setRemoteClipboardTrusted(true);
    await _settle();
    expect(writes, isEmpty);
  });

  test('global disabling suppresses writes waiting for the OS clipboard',
      () async {
    clipboardWait = Completer<void>();
    send(_osc('first'));
    await _settle();
    send(_osc('pending'));
    enabled = false;
    clipboardWait!.complete();
    clipboardWait = null;
    await _settle();
    expect(writes, ['first']);
  });

  test('bounds pending work to the newest write while the clipboard is busy',
      () async {
    clipboardWait = Completer<void>();
    send(_osc('first'));
    await _settle();
    for (var index = 0; index < 50; index++) {
      send(_osc('pending $index'));
    }
    clipboardWait!.complete();
    clipboardWait = null;
    await _settle();
    expect(writes, ['first', 'pending 49']);
  });

  test('reconnect restores default trust and clears incomplete sequences',
      () async {
    send('history\x1b]52;c;aGVs');
    plugin.setRemoteClipboardTrusted(false);
    plugin.didDisconnected();
    expect(plugin.remoteClipboard.trusted, isFalse);
    final previous = session;
    session = _Session();
    plugin.debugAttachSession(session);
    expect(plugin.remoteClipboard.trusted, isTrue);
    send(_osc('new session'));
    await _settle();
    expect(writes, ['new session']);
    expect(plugin.terminal.buffer.getText().trim(), 'history');
    expect(previous.controller.hasListener, isFalse);
  });

  test('disconnect drops already buffered clipboard events', () async {
    session.controller.add(Uint8List.fromList(utf8.encode(_osc('stale'))));
    plugin.didDisconnected();
    plugin.terminal.flush();
    await _settle();
    expect(writes, isEmpty);
  });

  test('OSC title, ANSI, alternate screen and normal output remain functional',
      () async {
    send('history\r\n\x1b]0;title\x07\x1b[31mred\x1b[0m${_osc('copied')}');
    await _settle();
    expect(plugin.terminal.buffer.getText(), contains('history\nred'));
    expect(plugin.terminalTitle, 'title');
    send('\x1b[?1049hTUI${_osc('alternate')}');
    await _settle();
    expect(writes, ['copied', 'alternate']);
    expect(plugin.terminal.buffer.getText(), contains('TUI'));
    send('\x1b[?1049l');
    expect(plugin.terminal.buffer.getText(), contains('history\nred'));
  });

  for (final end in ['\x07', '\x1b\\']) {
    test('tmux escaped OSC 52 uses the same security policy with $end',
        () async {
      final inner = _osc('tmux', end: end).replaceAll('\x1b', '\x1b\x1b');
      final wrapped = '\x1bPtmux;$inner\x1b\\';
      for (final byte in utf8.encode(wrapped)) {
        session.controller.add(Uint8List.fromList([byte]));
        plugin.terminal.flush();
      }
      await _settle();
      expect(writes, ['tmux']);
      expect(plugin.terminal.buffer.getText().trim(), isEmpty);
      enabled = false;
      send(wrapped);
      await _settle();
      expect(writes, ['tmux']);
    });
  }

  test('clipboard writer can be injected without an OS clipboard', () async {
    final injected = <String>[];
    final injectedPlugin = TerminalPlugin(
      remoteClipboardWritesAllowed: () => true,
      writeClipboard: (text) async => injected.add(text),
    );
    final injectedManager = PluginManager(MockHostSpec());
    injectedManager.add(injectedPlugin);
    final injectedSession = _Session();
    injectedPlugin.debugAttachSession(injectedSession);
    addTearDown(() {
      if (injectedPlugin.mounted) injectedManager.remove(injectedPlugin);
    });

    injectedSession.controller.add(
      Uint8List.fromList(utf8.encode('\x1b]52;cp;aGk\x1b\\')),
    );
    injectedPlugin.terminal.flush();
    await _settle();
    expect(injected, ['hi']);
    expect(methods, isEmpty);
  });
}
