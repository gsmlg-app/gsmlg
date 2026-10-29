import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_shell/ios_shell.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('app.gsmlg/ios_shell');
  late Directory fixture;
  late IosExecutionSession session;
  late StreamSubscription<Uint8List> subscription;
  late StringBuffer output;
  late List<MethodCall> calls;
  PlatformException? catalogError;
  Completer<Map<String, Object>>? execution;

  setUp(() async {
    fixture = await Directory.systemTemp.createTemp('ios_session_commands_');
    calls = [];
    catalogError = null;
    execution = null;
    IosShellEnv.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          switch (call.method) {
            case 'initialize':
              return {'documentsPath': fixture.path, 'tmpPath': fixture.path};
            case 'listCommands':
              if (catalogError != null) throw catalogError!;
              return ['lua', 'curl', 'cd', 'curl', 'python3'];
            case 'execute':
              if (execution != null) return execution!.future;
              return {'exitCode': 0, 'stdout': 'native output\n', 'stderr': ''};
            default:
              throw StateError('Unexpected method: ${call.method}');
          }
        });
    final env = IosShellEnv.instance;
    await env.initialize();
    session = IosExecutionSession(env);
    output = StringBuffer();
    final prompt = Completer<void>();
    subscription = session.output.listen((data) {
      final text = utf8.decode(data);
      output.write(text);
      if (text.endsWith(' \$ ') && !prompt.isCompleted) prompt.complete();
    });
    await prompt.future.timeout(const Duration(seconds: 5));
    output.clear();
    calls.clear();
  });

  tearDown(() async {
    await session.close();
    await subscription.cancel();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    IosShellEnv.reset();
    await fixture.delete(recursive: true);
  });

  Future<void> enter(String command) async {
    await session.write(Uint8List.fromList(utf8.encode('$command\r')));
    await Future<void>.delayed(Duration.zero);
  }

  test(
    'help lists the native catalog and session builtins once in order',
    () async {
      await enter('help');

      expect(
        output.toString(),
        contains('cd  clear  curl  exit  help  logout  lua  python3\r\n'),
      );
      expect(calls.map((call) => call.method), ['listCommands']);
    },
  );

  test('clear clears the terminal and returns to the prompt', () async {
    await enter('clear');

    expect(output.toString(), contains('\x1b[2J\x1b[H'));
    expect(output.toString(), endsWith(' \$ '));
    expect(calls, isEmpty);
  });

  test('native commands still execute and display their output', () async {
    await enter('curl --version');

    expect(calls.single.method, 'execute');
    expect(calls.single.arguments, {'command': 'curl --version'});
    expect(output.toString(), contains('native output\r\n'));
  });

  test(
    'overlapping Enter events execute the submitted line only once',
    () async {
      execution = Completer<Map<String, Object>>();
      await session.write(Uint8List.fromList(utf8.encode('ls -a')));
      final first = session.write(Uint8List.fromList([13]));
      await Future<void>.delayed(Duration.zero);
      final second = session.write(Uint8List.fromList([13]));
      await Future<void>.delayed(Duration.zero);
      execution!.complete({
        'exitCode': 0,
        'stdout': '.\n..\n.hidden\nsample.txt\n',
        'stderr': '',
      });
      await Future.wait([first, second]);
      await Future<void>.delayed(Duration.zero);

      expect(calls.map((call) => call.arguments), [
        {'command': 'ls -a'},
      ]);
      expect('.hidden'.allMatches(output.toString()), hasLength(1));
    },
  );

  test(
    'a failed catalog lookup reports an error and leaves the session usable',
    () async {
      catalogError = PlatformException(code: 'CATALOG_UNAVAILABLE');
      await enter('help');

      expect(output.toString(), contains('CATALOG_UNAVAILABLE'));
      expect(output.toString(), endsWith(' \$ '));

      await enter('lua -v');
      expect(calls.last.arguments, {'command': 'lua -v'});
      expect(output.toString(), contains('native output\r\n'));
    },
  );
}
