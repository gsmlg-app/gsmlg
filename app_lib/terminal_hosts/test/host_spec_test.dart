import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

void main() {
  group('LocalHostSpec', () {
    test('has default values', () {
      final spec = LocalHostSpec();

      expect(spec.name, equals('Local'));
      expect(spec.environment, isEmpty);
      expect(spec.initCommands, isNull);
    });

    test('accepts custom name', () {
      final spec = LocalHostSpec(name: 'My Shell');

      expect(spec.name, equals('My Shell'));
    });

    test('accepts environment variables', () {
      final spec = LocalHostSpec(environment: {'FOO': 'bar', 'BAZ': 'qux'});

      expect(spec.environment, hasLength(2));
      expect(spec.environment['FOO'], equals('bar'));
      expect(spec.environment['BAZ'], equals('qux'));
    });

    test('accepts init commands', () {
      final spec = LocalHostSpec(initCommands: 'export PATH=/custom:\$PATH');

      expect(spec.initCommands, equals('export PATH=/custom:\$PATH'));
    });

    test('createConnector returns LocalConnector', () {
      final spec = LocalHostSpec();
      final connector = spec.createConnector();

      expect(connector, isA<LocalConnector>());
    });

    test('passes profile parameters to connector', () {
      final spec = LocalHostSpec(
        name: 'Custom Profile',
        environment: {'EDITOR': 'vim'},
        initCommands: 'alias ll="ls -la"',
      );
      final connector = spec.createConnector() as LocalConnector;

      expect(connector.environment, hasLength(1));
      expect(connector.environment['EDITOR'], equals('vim'));
      expect(connector.initCommands, equals('alias ll="ls -la"'));
    });
  });

  group('AndroidHostSpec', () {
    test('has default values', () {
      final spec = AndroidHostSpec();

      expect(spec.name, equals('Android'));
      expect(spec.environment, isEmpty);
      expect(spec.initCommands, isNull);
    });

    test('accepts custom name', () {
      final spec = AndroidHostSpec(name: 'Android Shell');

      expect(spec.name, equals('Android Shell'));
    });

    test('accepts environment variables', () {
      final spec = AndroidHostSpec(environment: {'HOME': '/data/local/home'});

      expect(spec.environment, hasLength(1));
      expect(spec.environment['HOME'], equals('/data/local/home'));
    });

    test('accepts init commands', () {
      final spec = AndroidHostSpec(
        initCommands: 'export PATH=/custom/bin:\$PATH',
      );

      expect(spec.initCommands, equals('export PATH=/custom/bin:\$PATH'));
    });

    test('createConnector returns AndroidConnector', () {
      final spec = AndroidHostSpec();
      final connector = spec.createConnector();

      expect(connector, isA<AndroidConnector>());
    });

    test('passes profile parameters to connector', () {
      final spec = AndroidHostSpec(
        name: 'Dev Profile',
        environment: {'DEBUG': '1'},
        initCommands: 'source ~/.profile',
      );
      final connector = spec.createConnector() as AndroidConnector;

      expect(connector.environment, hasLength(1));
      expect(connector.environment['DEBUG'], equals('1'));
      expect(connector.initCommands, equals('source ~/.profile'));
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
      final spec = IosHostSpec(environment: {'LANG': 'en_US.UTF-8'});

      expect(spec.environment, hasLength(1));
      expect(spec.environment['LANG'], equals('en_US.UTF-8'));
    });

    test('accepts init commands', () {
      final spec = IosHostSpec(
        initCommands: 'export EDITOR=nano\nalias ll="ls -la"',
      );

      expect(spec.initCommands, contains('export EDITOR=nano'));
      expect(spec.initCommands, contains('alias ll'));
    });

    test('createConnector returns IosConnector', () {
      final spec = IosHostSpec();
      final connector = spec.createConnector();

      expect(connector, isA<IosConnector>());
    });

    test('passes profile parameters to connector', () {
      final spec = IosHostSpec(
        name: 'Work Profile',
        environment: {'TERM': 'xterm-256color'},
        initCommands: 'cd ~/Documents',
      );
      final connector = spec.createConnector() as IosConnector;

      expect(connector.environment, hasLength(1));
      expect(connector.environment['TERM'], equals('xterm-256color'));
      expect(connector.initCommands, equals('cd ~/Documents'));
    });
  });

  group('LocalConnector', () {
    test('has default values', () {
      final connector = LocalConnector();

      expect(connector.environment, isEmpty);
      expect(connector.initCommands, isNull);
    });

    test('accepts profile parameters', () {
      final connector = LocalConnector(
        environment: {'VAR': 'value'},
        initCommands: 'echo hello',
      );

      expect(connector.environment['VAR'], equals('value'));
      expect(connector.initCommands, equals('echo hello'));
    });
  });

  group('AndroidConnector', () {
    test('has default values', () {
      final connector = AndroidConnector();

      expect(connector.environment, isEmpty);
      expect(connector.initCommands, isNull);
    });

    test('accepts profile parameters', () {
      final connector = AndroidConnector(
        environment: {'DEBUG': 'true'},
        initCommands: 'cd ~',
      );

      expect(connector.environment['DEBUG'], equals('true'));
      expect(connector.initCommands, equals('cd ~'));
    });
  });

  group('IosConnector', () {
    test('has default values', () {
      final connector = IosConnector();

      expect(connector.environment, isEmpty);
      expect(connector.initCommands, isNull);
    });

    test('accepts profile parameters', () {
      final connector = IosConnector(
        environment: {'SHELL': '/bin/dash'},
        initCommands: 'export PS1="\$ "',
      );

      expect(connector.environment['SHELL'], equals('/bin/dash'));
      expect(connector.initCommands, equals('export PS1="\$ "'));
    });
  });
}
