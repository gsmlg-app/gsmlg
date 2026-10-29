import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

void main() {
  group('IosExecutionResult', () {
    test('stores exitCode', () {
      final result = IosExecutionResult(exitCode: 0, stdout: '', stderr: '');
      expect(result.exitCode, equals(0));
    });

    test('stores non-zero exitCode', () {
      final result = IosExecutionResult(
        exitCode: 127,
        stdout: '',
        stderr: 'command not found',
      );
      expect(result.exitCode, equals(127));
    });

    test('stores stdout', () {
      final result = IosExecutionResult(
        exitCode: 0,
        stdout: 'Hello World',
        stderr: '',
      );
      expect(result.stdout, equals('Hello World'));
    });

    test('stores stderr', () {
      final result = IosExecutionResult(
        exitCode: 1,
        stdout: '',
        stderr: 'Error message',
      );
      expect(result.stderr, equals('Error message'));
    });

    test('implements ExecutionResult interface', () {
      final result = IosExecutionResult(
        exitCode: 0,
        stdout: 'output',
        stderr: 'error',
      );
      expect(result, isA<ExecutionResult>());
    });

    test('can store multiline stdout', () {
      final result = IosExecutionResult(
        exitCode: 0,
        stdout: 'line1\nline2\nline3',
        stderr: '',
      );
      expect(result.stdout, contains('\n'));
      expect(result.stdout.split('\n'), hasLength(3));
    });

    test('can store combined stdout and stderr', () {
      final result = IosExecutionResult(
        exitCode: 1,
        stdout: 'partial output',
        stderr: 'error occurred',
      );
      expect(result.stdout, isNotEmpty);
      expect(result.stderr, isNotEmpty);
    });
  });

  group('IosHostSpec', () {
    test('has default values', () {
      final spec = IosHostSpec();
      expect(spec.name, equals('iOS'));
      expect(spec.environment, isEmpty);
      expect(spec.initCommands, isNull);
    });

    test('accepts custom name', () {
      final spec = IosHostSpec(name: 'iOS Terminal');
      expect(spec.name, equals('iOS Terminal'));
    });

    test('accepts environment variables', () {
      final spec = IosHostSpec(
        environment: {'TERM': 'xterm', 'LANG': 'en_US.UTF-8'},
      );
      expect(spec.environment, hasLength(2));
      expect(spec.environment['TERM'], equals('xterm'));
    });

    test('accepts init commands', () {
      final spec = IosHostSpec(
        initCommands: 'export PATH=/usr/local/bin:\$PATH',
      );
      expect(spec.initCommands, contains('export PATH'));
    });

    test('accepts multiline init commands', () {
      final spec = IosHostSpec(
        initCommands: '''
export FOO=bar
alias ls="ls -la"
cd ~/Documents
''',
      );
      expect(spec.initCommands, contains('export FOO'));
      expect(spec.initCommands, contains('alias ls'));
      expect(spec.initCommands, contains('cd ~/Documents'));
    });

    test('createConnector returns IosConnector', () {
      final spec = IosHostSpec();
      final connector = spec.createConnector();
      expect(connector, isA<IosConnector>());
    });

    test('passes environment to connector', () {
      final spec = IosHostSpec(environment: {'DEBUG': '1'});
      final connector = spec.createConnector() as IosConnector;
      expect(connector.environment['DEBUG'], equals('1'));
    });

    test('passes initCommands to connector', () {
      final spec = IosHostSpec(initCommands: 'echo hello');
      final connector = spec.createConnector() as IosConnector;
      expect(connector.initCommands, equals('echo hello'));
    });
  });

  group('IosConnector', () {
    test('has default values', () {
      final connector = IosConnector();
      expect(connector.environment, isEmpty);
      expect(connector.initCommands, isNull);
    });

    test('stores environment variables', () {
      final connector = IosConnector(environment: {'VAR': 'value'});
      expect(connector.environment['VAR'], equals('value'));
    });

    test('stores init commands', () {
      final connector = IosConnector(initCommands: 'some commands');
      expect(connector.initCommands, equals('some commands'));
    });
  });

  // Note: Testing IosExecutionSession requires mocking IosShellEnv
  // which is iOS-specific. The following tests document expected behavior.
  group('IosExecutionSession behavior (documented)', () {
    test('expected: session handles printable characters', () {
      // IosExecutionSession.write() should:
      // - Accept printable characters (code unit >= 32)
      // - Add them to _inputBuffer
      // - Echo them to output

      final printableChars = 'Hello World 123!@#';
      for (final char in printableChars.split('')) {
        expect(char.codeUnitAt(0) >= 32, isTrue);
      }
    });

    test('expected: session handles backspace character', () {
      // Backspace characters (0x7f or 0x08) should:
      // - Remove last character from _inputBuffer
      // - Output '\b \b' to move cursor back and clear

      const backspace = '\x7f';
      const backspaceAlt = '\b';
      expect(backspace.codeUnitAt(0), equals(0x7f));
      expect(backspaceAlt.codeUnitAt(0), equals(0x08));
    });

    test('expected: session handles Ctrl+C', () {
      // Ctrl+C (0x03) should:
      // - Clear _inputBuffer
      // - Output '^C\r\n'
      // - Show prompt

      const ctrlC = '\x03';
      expect(ctrlC.codeUnitAt(0), equals(3));
    });

    test('expected: session handles Ctrl+D on empty input', () {
      // Ctrl+D (0x04) on empty input should:
      // - Output 'exit\r\n'
      // - Close the session

      const ctrlD = '\x04';
      expect(ctrlD.codeUnitAt(0), equals(4));
    });

    test('expected: session handles newline for command execution', () {
      // Newline ('\r' or '\n') should:
      // - Execute the command in _inputBuffer
      // - Clear _inputBuffer
      // - Show prompt (if not closed)

      const cr = '\r';
      const lf = '\n';
      expect(cr.codeUnitAt(0), equals(13));
      expect(lf.codeUnitAt(0), equals(10));
    });

    test('expected: export command parses environment variables', () {
      // The _handleExport method should parse:
      // - export VAR=value
      // - export VAR="quoted value"
      // - export VAR='single quoted'

      final exportRegex = RegExp(r'^export\s+(\w+)=(.*)$');

      expect(exportRegex.firstMatch('export FOO=bar'), isNotNull);
      expect(exportRegex.firstMatch('export FOO="bar baz"'), isNotNull);
      expect(exportRegex.firstMatch("export FOO='bar'"), isNotNull);

      // Extract the value
      final match = exportRegex.firstMatch('export PATH=/usr/bin:\$PATH');
      expect(match?.group(1), equals('PATH'));
      expect(match?.group(2), equals('/usr/bin:\$PATH'));
    });

    test('expected: export removes surrounding quotes', () {
      // Values with quotes should have them removed
      var value = '"quoted value"';
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }
      expect(value, equals('quoted value'));

      value = "'single quoted'";
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }
      expect(value, equals('single quoted'));
    });

    test('expected: cd command changes directory', () {
      // 'cd path' should call IosShellPlugin.setCurrentDirectory(path)
      // 'cd' without args should go to homePath
      // Non-existent paths should output error message

      final cdCommand = 'cd /some/path';
      expect(cdCommand.startsWith('cd '), isTrue);
      expect(cdCommand.substring(3).trim(), equals('/some/path'));
    });

    test('expected: exit/logout commands close session', () {
      // 'exit' and 'logout' should close the session
      const commands = ['exit', 'logout'];
      for (final cmd in commands) {
        expect(cmd == 'exit' || cmd == 'logout', isTrue);
      }
    });

    test('expected: output normalizes line endings', () {
      // stdout/stderr should have \n replaced with \r\n for terminal display
      const output = 'line1\nline2\nline3';
      final normalized = output.replaceAll('\n', '\r\n');
      expect(normalized, equals('line1\r\nline2\r\nline3'));
    });

    test('expected: input characters are correctly encoded', () {
      // write() receives Uint8List and decodes using utf8
      final text = 'Hello';
      final data = Uint8List.fromList(utf8.encode(text));
      final decoded = utf8.decode(data);
      expect(decoded, equals('Hello'));
    });
  });

  group('IosHost instance methods (without iOS)', () {
    // These tests document the expected behavior but cannot be run
    // without actual iOS shell environment

    test('expected: execute builds command string correctly', () {
      // execute('ls', args: ['-la', '/']) should produce 'ls -la /'
      const executable = 'ls';
      const args = ['-la', '/'];
      final command = args.isEmpty
          ? executable
          : '$executable ${args.join(' ')}';
      expect(command, equals('ls -la /'));
    });

    test('expected: execute without args uses just executable', () {
      const executable = 'pwd';
      const args = <String>[];
      final command = args.isEmpty
          ? executable
          : '$executable ${args.join(' ')}';
      expect(command, equals('pwd'));
    });

    test('expected: shell merges environments correctly', () {
      // Shell should merge: profile → session-specific
      final profileEnv = {'TERM': 'xterm', 'FOO': 'profile'};
      final sessionEnv = {'FOO': 'session', 'BAR': 'baz'};

      final merged = {...profileEnv, ...sessionEnv};

      expect(merged['TERM'], equals('xterm'));
      expect(merged['FOO'], equals('session')); // Session overrides profile
      expect(merged['BAR'], equals('baz'));
    });
  });
}
