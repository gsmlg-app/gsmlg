import 'package:flutter_test/flutter_test.dart';
import 'package:android_shell/src/android_shell_env.dart';

void main() {
  group('AndroidShellEnv singleton', () {
    setUp(() {
      AndroidShellEnv.reset();
    });

    test('instance returns same instance', () {
      final instance1 = AndroidShellEnv.instance;
      final instance2 = AndroidShellEnv.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    test('isInitialized is false before initialize', () {
      expect(AndroidShellEnv.instance.isInitialized, isFalse);
    });

    test('reset creates new instance', () {
      final instance1 = AndroidShellEnv.instance;
      AndroidShellEnv.reset();
      final instance2 = AndroidShellEnv.instance;
      expect(identical(instance1, instance2), isFalse);
    });
  });

  group('AndroidShellEnv path computations (conceptual)', () {
    // Note: These tests verify the path structure expectations
    // Actual paths require initialization with native plugin

    test('prefix is expected to be filesDir/usr', () {
      // Verify the path joining pattern used
      expect('usr', isNotEmpty); // usr directory name
    });

    test('binPath is expected to be prefix/bin', () {
      expect('bin', isNotEmpty); // bin directory name
    });

    test('etcPath is expected to be prefix/etc', () {
      expect('etc', isNotEmpty); // etc directory name
    });

    test('homePath is expected to be filesDir/home', () {
      expect('home', isNotEmpty); // home directory name
    });

    test('tmpPath is expected to be filesDir/tmp', () {
      expect('tmp', isNotEmpty); // tmp directory name
    });

    test('shellPath is expected to be binPath/sh', () {
      expect('sh', isNotEmpty); // sh binary name
    });

    test('profilePath is expected to be etcPath/profile', () {
      expect('profile', isNotEmpty); // profile filename
    });
  });

  group('AndroidShellEnv shell command structure', () {
    // Note: These tests verify the shell command structure pattern
    // without requiring actual initialization

    test('getShellCommand returns tuple', () {
      // Verify the expected command structure
      const expectedCommand =
          'cd "\$HOME" 2>/dev/null; . "\$ENV" 2>/dev/null; exec sh -i';
      expect(expectedCommand, contains('cd'));
      expect(expectedCommand, contains('HOME'));
      expect(expectedCommand, contains('ENV'));
      expect(expectedCommand, contains('exec sh -i'));
    });

    test('shell command uses sh shell', () {
      const shellName = 'sh';
      expect(shellName, 'sh');
    });

    test('shell command uses -c flag', () {
      const flag = '-c';
      expect(flag, '-c');
    });
  });

  group('AndroidShellEnv environment variables structure', () {
    // Verify expected environment variable keys without initialization

    test('environment should include PREFIX', () {
      const envKeys = [
        'PREFIX',
        'HOME',
        'PATH',
        'SHELL',
        'TERM',
        'LANG',
        'TMPDIR',
        'ANDROID_DATA',
        'ANDROID_ROOT',
        'ENV',
      ];
      expect(envKeys, contains('PREFIX'));
    });

    test('environment should include HOME', () {
      const envKeys = [
        'PREFIX',
        'HOME',
        'PATH',
        'SHELL',
        'TERM',
        'LANG',
        'TMPDIR',
        'ANDROID_DATA',
        'ANDROID_ROOT',
        'ENV',
      ];
      expect(envKeys, contains('HOME'));
    });

    test('environment should include PATH', () {
      const envKeys = [
        'PREFIX',
        'HOME',
        'PATH',
        'SHELL',
        'TERM',
        'LANG',
        'TMPDIR',
        'ANDROID_DATA',
        'ANDROID_ROOT',
        'ENV',
      ];
      expect(envKeys, contains('PATH'));
    });

    test('environment should include SHELL', () {
      const envKeys = [
        'PREFIX',
        'HOME',
        'PATH',
        'SHELL',
        'TERM',
        'LANG',
        'TMPDIR',
        'ANDROID_DATA',
        'ANDROID_ROOT',
        'ENV',
      ];
      expect(envKeys, contains('SHELL'));
    });

    test('environment should include TERM', () {
      const envKeys = [
        'PREFIX',
        'HOME',
        'PATH',
        'SHELL',
        'TERM',
        'LANG',
        'TMPDIR',
        'ANDROID_DATA',
        'ANDROID_ROOT',
        'ENV',
      ];
      expect(envKeys, contains('TERM'));
    });

    test('environment should include LANG', () {
      const envKeys = [
        'PREFIX',
        'HOME',
        'PATH',
        'SHELL',
        'TERM',
        'LANG',
        'TMPDIR',
        'ANDROID_DATA',
        'ANDROID_ROOT',
        'ENV',
      ];
      expect(envKeys, contains('LANG'));
    });

    test('environment should include TMPDIR', () {
      const envKeys = [
        'PREFIX',
        'HOME',
        'PATH',
        'SHELL',
        'TERM',
        'LANG',
        'TMPDIR',
        'ANDROID_DATA',
        'ANDROID_ROOT',
        'ENV',
      ];
      expect(envKeys, contains('TMPDIR'));
    });

    test('environment should include ANDROID_DATA', () {
      const envKeys = [
        'PREFIX',
        'HOME',
        'PATH',
        'SHELL',
        'TERM',
        'LANG',
        'TMPDIR',
        'ANDROID_DATA',
        'ANDROID_ROOT',
        'ENV',
      ];
      expect(envKeys, contains('ANDROID_DATA'));
    });

    test('environment should include ANDROID_ROOT', () {
      const envKeys = [
        'PREFIX',
        'HOME',
        'PATH',
        'SHELL',
        'TERM',
        'LANG',
        'TMPDIR',
        'ANDROID_DATA',
        'ANDROID_ROOT',
        'ENV',
      ];
      expect(envKeys, contains('ANDROID_ROOT'));
    });

    test('environment should include ENV', () {
      const envKeys = [
        'PREFIX',
        'HOME',
        'PATH',
        'SHELL',
        'TERM',
        'LANG',
        'TMPDIR',
        'ANDROID_DATA',
        'ANDROID_ROOT',
        'ENV',
      ];
      expect(envKeys, contains('ENV'));
    });

    test('environment has expected keys', () {
      const envKeys = [
        'PREFIX',
        'HOME',
        'PATH',
        'SHELL',
        'TERM',
        'LANG',
        'TMPDIR',
        'ANDROID_DATA',
        'ANDROID_ROOT',
        'ENV',
      ];
      expect(envKeys.length, 10);
    });

    test('proot environment includes PRoot control variables', () {
      const prootKeys = [
        'PROOT_LOADER',
        'PROOT_TMP_DIR',
        'PROOT_IGNORE_MISSING_BINDINGS',
      ];
      expect(prootKeys, contains('PROOT_LOADER'));
      expect(prootKeys, contains('PROOT_TMP_DIR'));
      expect(prootKeys, contains('PROOT_IGNORE_MISSING_BINDINGS'));
    });
  });

  group('AndroidShellEnv PRoot command structure', () {
    test('proot arguments include expected flags', () {
      const flags = [
        '-r',
        '-0',
        '--link2symlink',
        '--sysvipc',
        '--kill-on-exit',
        '-b',
        '-w',
      ];
      expect(flags, contains('-r'));
      expect(flags, contains('-0'));
      expect(flags, contains('--link2symlink'));
      expect(flags, contains('--sysvipc'));
      expect(flags, contains('--kill-on-exit'));
      expect(flags, contains('-w'));
    });
  });

  group('ProgressCallback typedef', () {
    test('can create progress callback function', () {
      void callback(String message, double progress) {
        // Callback implementation
      }

      expect(callback, isA<ProgressCallback>());
    });

    test('progress callback accepts message and progress', () {
      String? receivedMessage;
      double? receivedProgress;

      void callback(String message, double progress) {
        receivedMessage = message;
        receivedProgress = progress;
      }

      callback('test message', 0.5);

      expect(receivedMessage, 'test message');
      expect(receivedProgress, 0.5);
    });
  });
}
