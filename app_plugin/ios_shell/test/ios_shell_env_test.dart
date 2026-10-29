import 'package:flutter_test/flutter_test.dart';
import 'package:ios_shell/src/ios_shell_env.dart';

void main() {
  group('IosExecutionResult', () {
    test('can be created with required parameters', () {
      final result = IosExecutionResult(
        exitCode: 0,
        stdout: 'output',
        stderr: '',
      );
      expect(result, isNotNull);
    });

    test('stores exitCode correctly', () {
      final result = IosExecutionResult(exitCode: 42, stdout: '', stderr: '');
      expect(result.exitCode, 42);
    });

    test('stores stdout correctly', () {
      final result = IosExecutionResult(
        exitCode: 0,
        stdout: 'Hello, World!',
        stderr: '',
      );
      expect(result.stdout, 'Hello, World!');
    });

    test('stores stderr correctly', () {
      final result = IosExecutionResult(
        exitCode: 1,
        stdout: '',
        stderr: 'Error occurred',
      );
      expect(result.stderr, 'Error occurred');
    });

    test('success returns true when exitCode is 0', () {
      final result = IosExecutionResult(
        exitCode: 0,
        stdout: 'output',
        stderr: '',
      );
      expect(result.success, isTrue);
    });

    test('success returns false when exitCode is non-zero', () {
      final result = IosExecutionResult(
        exitCode: 1,
        stdout: '',
        stderr: 'error',
      );
      expect(result.success, isFalse);
    });

    test('success returns false when exitCode is negative', () {
      final result = IosExecutionResult(
        exitCode: -1,
        stdout: '',
        stderr: 'killed',
      );
      expect(result.success, isFalse);
    });

    test('can have both stdout and stderr', () {
      final result = IosExecutionResult(
        exitCode: 1,
        stdout: 'partial output',
        stderr: 'warning message',
      );
      expect(result.stdout, 'partial output');
      expect(result.stderr, 'warning message');
    });

    test('handles empty strings', () {
      final result = IosExecutionResult(exitCode: 0, stdout: '', stderr: '');
      expect(result.stdout, isEmpty);
      expect(result.stderr, isEmpty);
    });

    test('handles multiline output', () {
      final result = IosExecutionResult(
        exitCode: 0,
        stdout: 'line1\nline2\nline3',
        stderr: '',
      );
      expect(result.stdout.split('\n').length, 3);
    });
  });

  group('IosShellEnv singleton', () {
    setUp(() {
      IosShellEnv.reset();
    });

    test('instance returns same instance', () {
      final instance1 = IosShellEnv.instance;
      final instance2 = IosShellEnv.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    test('isInitialized is false before initialize', () {
      expect(IosShellEnv.instance.isInitialized, isFalse);
    });

    test('reset creates new instance', () {
      final instance1 = IosShellEnv.instance;
      IosShellEnv.reset();
      final instance2 = IosShellEnv.instance;
      expect(identical(instance1, instance2), isFalse);
    });

    test('shellPath returns dash', () {
      expect(IosShellEnv.instance.shellPath, 'dash');
    });

    test('getShellCommand returns correct tuple', () {
      final (cmd, args) = IosShellEnv.instance.getShellCommand();
      expect(cmd, 'dash');
      expect(args, ['-l']);
    });
  });
}
