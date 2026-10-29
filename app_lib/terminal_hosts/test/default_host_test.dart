import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

void main() {
  group('createDefaultHostSpec', () {
    test('returns LocalHostSpec on desktop platforms', () {
      // Since this test runs on desktop (macOS, Linux, or Windows),
      // it should return LocalHostSpec
      if (!Platform.isAndroid && !Platform.isIOS) {
        final spec = createDefaultHostSpec();
        expect(spec, isA<LocalHostSpec>());
      }
    });

    test('uses "Local" as default name on desktop', () {
      if (!Platform.isAndroid && !Platform.isIOS) {
        final spec = createDefaultHostSpec();
        expect(spec.name, equals('Local'));
      }
    });

    test('accepts custom name parameter', () {
      if (!Platform.isAndroid && !Platform.isIOS) {
        final spec = createDefaultHostSpec(name: 'My Terminal');
        expect(spec.name, equals('My Terminal'));
      }
    });

    test('accepts environment parameter', () {
      if (!Platform.isAndroid && !Platform.isIOS) {
        final env = {'FOO': 'bar', 'BAZ': 'qux'};
        final spec = createDefaultHostSpec(environment: env) as LocalHostSpec;
        expect(spec.environment, equals(env));
      }
    });

    test('accepts initCommands parameter', () {
      if (!Platform.isAndroid && !Platform.isIOS) {
        final cmds = 'export PATH=/custom:\$PATH';
        final spec = createDefaultHostSpec(initCommands: cmds) as LocalHostSpec;
        expect(spec.initCommands, equals(cmds));
      }
    });

    test('passes all parameters through to spec', () {
      if (!Platform.isAndroid && !Platform.isIOS) {
        final spec =
            createDefaultHostSpec(
                  name: 'Dev Shell',
                  environment: {'DEBUG': '1'},
                  initCommands: 'alias ll="ls -la"',
                )
                as LocalHostSpec;

        expect(spec.name, equals('Dev Shell'));
        expect(spec.environment, hasLength(1));
        expect(spec.environment['DEBUG'], equals('1'));
        expect(spec.initCommands, equals('alias ll="ls -la"'));
      }
    });

    test('empty environment defaults to empty map', () {
      if (!Platform.isAndroid && !Platform.isIOS) {
        final spec = createDefaultHostSpec() as LocalHostSpec;
        expect(spec.environment, isEmpty);
      }
    });

    test('null initCommands defaults to null', () {
      if (!Platform.isAndroid && !Platform.isIOS) {
        final spec = createDefaultHostSpec() as LocalHostSpec;
        expect(spec.initCommands, isNull);
      }
    });
  });

  group('LocalHost', () {
    test('can be instantiated with default values', () {
      final host = LocalHost();
      expect(host, isA<LocalHost>());
    });

    test('accepts environment parameter', () {
      final host = LocalHost(environment: {'CUSTOM_VAR': 'custom_value'});
      expect(host, isA<LocalHost>());
    });

    test('accepts initCommands parameter', () {
      final host = LocalHost(initCommands: 'echo "Hello"');
      expect(host, isA<LocalHost>());
    });

    test(
      'startup commands are empty by default (no noisy script injection)',
      () {
        final commands = buildLocalShellStartupCommands();

        expect(commands, isEmpty);
      },
    );

    test(
      'startup commands are empty when only workingDirectory is provided',
      () {
        final commands = buildLocalShellStartupCommands(
          workingDirectory: '/Users/test/Projects/web-terminal',
        );

        expect(commands, isEmpty);
      },
    );

    test('startup commands return trimmed profile init commands when set', () {
      final commands = buildLocalShellStartupCommands(
        initCommands: '  alias ll="ls -la"  \n',
      );

      expect(commands, equals('alias ll="ls -la"'));
    });

    test('connectFileSystem returns LocalFileSystem', () async {
      final host = LocalHost();
      final fs = await host.connectFileSystem();
      expect(fs, isA<LocalFileSystem>());
    });

    test('disconnect completes done future', () async {
      final host = LocalHost();

      // Disconnect should complete the done future
      await host.disconnect();

      // done should now be complete
      await expectLater(host.done, completes);
    });

    test('done future completes after disconnect', () async {
      final host = LocalHost();
      var completed = false;

      // Listen for done completion
      host.done.then((_) => completed = true);

      // Should not be completed yet
      expect(completed, isFalse);

      // Disconnect
      await host.disconnect();

      // Wait for async completion
      await Future.delayed(Duration.zero);

      // Should be completed now
      expect(completed, isTrue);
    });
  });

  group('LocalExecutionResult', () {
    test('returns stdout from ProcessResult', () async {
      // Test by executing a simple command
      final host = LocalHost();
      final result = await host.execute('echo', args: ['hello']);

      expect(result.stdout, contains('hello'));
      expect(result.exitCode, equals(0));
    });

    test('returns stderr from ProcessResult on error', () async {
      final host = LocalHost();
      // Use 'ls' on a non-existent path to generate stderr
      final result = await host.execute('ls', args: ['/nonexistent12345']);

      expect(result.exitCode, isNot(0));
      expect(result.stderr, isNotEmpty);
    });

    test('returns correct exit code', () async {
      final host = LocalHost();

      // Successful command
      final successResult = await host.execute('true');
      expect(successResult.exitCode, equals(0));

      // Failed command
      final failResult = await host.execute('false');
      expect(failResult.exitCode, isNot(0));
    });

    test('accepts environment parameter in execute', () async {
      final host = LocalHost();

      // Execute with custom environment
      final result = await host.execute(
        'sh',
        args: ['-c', 'echo \$TEST_VAR'],
        environment: {'TEST_VAR': 'test_value'},
      );

      expect(result.stdout, contains('test_value'));
    });
  });

  group('LocalFileSystem', () {
    test('provides directory access', () async {
      final host = LocalHost();
      final fs = await host.connectFileSystem();

      final homeDir = fs.directory(Platform.environment['HOME']!);
      expect(await homeDir.exists(), isTrue);
    });

    test('provides file access', () async {
      final host = LocalHost();
      final fs = await host.connectFileSystem();

      // Check a file that should exist on most systems
      final testFile = fs.file('/etc/hosts');
      if (Platform.isMacOS || Platform.isLinux) {
        expect(await testFile.exists(), isTrue);
      }
    });
  });
}
