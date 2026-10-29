import 'package:flutter_test/flutter_test.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';

void main() {
  group('ShellProfileParsing extension', () {
    ShellProfile createProfile({
      String environmentVariables = '{}',
      String aliases = '{}',
      int shellType = 1,
    }) {
      return ShellProfile(
        id: 1,
        name: 'Test',
        shellType: shellType,
        environmentVariables: environmentVariables,
        aliases: aliases,
        fontFamily: 'monospace',
        fontSize: 14.0,
        colorTheme: 'default',
        workingDirectory: '',
        startupCommand: '',
        cursorStyle: 0,
        scrollbackLines: 10000,
        isDefault: false,
        inheritCurrentState: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    test('parsedEnvironmentVariables returns empty map for empty JSON', () {
      final profile = createProfile();
      expect(profile.parsedEnvironmentVariables, isEmpty);
    });

    test('parsedEnvironmentVariables parses valid JSON', () {
      final profile = createProfile(
        environmentVariables: '{"PATH": "/usr/bin", "TERM": "xterm-256color"}',
      );
      final vars = profile.parsedEnvironmentVariables;
      expect(vars['PATH'], '/usr/bin');
      expect(vars['TERM'], 'xterm-256color');
    });

    test('parsedEnvironmentVariables returns empty map for invalid JSON', () {
      final profile = createProfile(environmentVariables: 'not valid json');
      expect(profile.parsedEnvironmentVariables, isEmpty);
    });

    test('parsedAliases returns empty map for empty JSON', () {
      final profile = createProfile();
      expect(profile.parsedAliases, isEmpty);
    });

    test('parsedAliases parses valid JSON', () {
      final profile = createProfile(
        aliases: '{"ll": "ls -la", "gs": "git status"}',
      );
      final aliases = profile.parsedAliases;
      expect(aliases['ll'], 'ls -la');
      expect(aliases['gs'], 'git status');
    });

    test('parsedShellType returns correct ShellType for sh', () {
      final profile = createProfile(shellType: 1);
      expect(profile.parsedShellType, ShellType.sh);
    });

    test('parsedShellType returns correct ShellType for bash', () {
      final profile = createProfile(shellType: 2);
      expect(profile.parsedShellType, ShellType.bash);
    });

    test('parsedShellType returns correct ShellType for zsh', () {
      final profile = createProfile(shellType: 3);
      expect(profile.parsedShellType, ShellType.zsh);
    });

    test('parsedShellType returns correct ShellType for fish', () {
      final profile = createProfile(shellType: 4);
      expect(profile.parsedShellType, ShellType.fish);
    });

    test('parsedShellType defaults to sh for unknown value', () {
      final profile = createProfile(shellType: 99);
      expect(profile.parsedShellType, ShellType.sh);
    });

    test('generateInitCommands produces export statements', () {
      final profile = createProfile(
        environmentVariables: '{"MY_VAR": "value"}',
      );
      final commands = profile.generateInitCommands();
      expect(commands, contains("export MY_VAR='value'"));
    });

    test('generateInitCommands produces alias statements', () {
      final profile = createProfile(
        aliases: '{"ll": "ls -la"}',
      );
      final commands = profile.generateInitCommands();
      expect(commands, contains("alias ll='ls -la'"));
    });

    test('generateInitCommands escapes single quotes', () {
      final profile = createProfile(
        environmentVariables: '{"GREETING": "Hello\'World"}',
      );
      final commands = profile.generateInitCommands();
      // Should escape the single quote in the value
      expect(commands, contains("export GREETING='Hello'\\''World'"));
    });
  });

  group('ShellProfileEncoder', () {
    test('encodeEnvironmentVariables creates valid JSON', () {
      final json = ShellProfileEncoder.encodeEnvironmentVariables({
        'PATH': '/usr/bin',
        'HOME': '/home/user',
      });
      expect(json, '{"PATH":"/usr/bin","HOME":"/home/user"}');
    });

    test('encodeAliases creates valid JSON', () {
      final json = ShellProfileEncoder.encodeAliases({
        'll': 'ls -la',
        'cls': 'clear',
      });
      expect(json, '{"ll":"ls -la","cls":"clear"}');
    });
  });
}
