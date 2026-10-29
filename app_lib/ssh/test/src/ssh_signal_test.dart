import 'package:test/test.dart';
import 'package:app_ssh/src/ssh_signal.dart';

void main() {
  group('SSHSignal', () {
    test('has all expected values', () {
      expect(SSHSignal.values.length, 13);
      expect(SSHSignal.ABRT, isNotNull);
      expect(SSHSignal.ALRM, isNotNull);
      expect(SSHSignal.FPE, isNotNull);
      expect(SSHSignal.HUP, isNotNull);
      expect(SSHSignal.ILL, isNotNull);
      expect(SSHSignal.INT, isNotNull);
      expect(SSHSignal.KILL, isNotNull);
      expect(SSHSignal.PIPE, isNotNull);
      expect(SSHSignal.QUIT, isNotNull);
      expect(SSHSignal.SEGV, isNotNull);
      expect(SSHSignal.TERM, isNotNull);
      expect(SSHSignal.USR1, isNotNull);
      expect(SSHSignal.USR2, isNotNull);
    });
  });

  group('SSHSignalX', () {
    group('name', () {
      test('ABRT returns ABRT', () {
        expect(SSHSignal.ABRT.name, 'ABRT');
      });

      test('ALRM returns ALRM', () {
        expect(SSHSignal.ALRM.name, 'ALRM');
      });

      test('FPE returns FPE', () {
        expect(SSHSignal.FPE.name, 'FPE');
      });

      test('HUP returns HUP', () {
        expect(SSHSignal.HUP.name, 'HUP');
      });

      test('ILL returns ILL', () {
        expect(SSHSignal.ILL.name, 'ILL');
      });

      test('INT returns INT', () {
        expect(SSHSignal.INT.name, 'INT');
      });

      test('KILL returns KILL', () {
        expect(SSHSignal.KILL.name, 'KILL');
      });

      test('PIPE returns PIPE', () {
        expect(SSHSignal.PIPE.name, 'PIPE');
      });

      test('QUIT returns QUIT', () {
        expect(SSHSignal.QUIT.name, 'QUIT');
      });

      test('SEGV returns SEGV', () {
        expect(SSHSignal.SEGV.name, 'SEGV');
      });

      test('TERM returns TERM', () {
        expect(SSHSignal.TERM.name, 'TERM');
      });

      test('USR1 returns USR1', () {
        expect(SSHSignal.USR1.name, 'USR1');
      });

      test('USR2 returns USR2', () {
        expect(SSHSignal.USR2.name, 'USR2');
      });

      test('all signals have unique names', () {
        final names = SSHSignal.values.map((s) => s.name).toSet();
        expect(names.length, SSHSignal.values.length);
      });
    });

    group('fromName', () {
      test('parses ABRT', () {
        expect(SSHSignalX.fromName('ABRT'), SSHSignal.ABRT);
      });

      test('parses ALRM', () {
        expect(SSHSignalX.fromName('ALRM'), SSHSignal.ALRM);
      });

      test('parses FPE', () {
        expect(SSHSignalX.fromName('FPE'), SSHSignal.FPE);
      });

      test('parses HUP', () {
        expect(SSHSignalX.fromName('HUP'), SSHSignal.HUP);
      });

      test('parses ILL', () {
        expect(SSHSignalX.fromName('ILL'), SSHSignal.ILL);
      });

      test('parses INT', () {
        expect(SSHSignalX.fromName('INT'), SSHSignal.INT);
      });

      test('parses KILL', () {
        expect(SSHSignalX.fromName('KILL'), SSHSignal.KILL);
      });

      test('parses PIPE', () {
        expect(SSHSignalX.fromName('PIPE'), SSHSignal.PIPE);
      });

      test('parses QUIT', () {
        expect(SSHSignalX.fromName('QUIT'), SSHSignal.QUIT);
      });

      test('parses SEGV', () {
        expect(SSHSignalX.fromName('SEGV'), SSHSignal.SEGV);
      });

      test('parses TERM', () {
        expect(SSHSignalX.fromName('TERM'), SSHSignal.TERM);
      });

      test('parses USR1', () {
        expect(SSHSignalX.fromName('USR1'), SSHSignal.USR1);
      });

      test('parses USR2', () {
        expect(SSHSignalX.fromName('USR2'), SSHSignal.USR2);
      });

      test('throws for unknown signal name', () {
        expect(() => SSHSignalX.fromName('UNKNOWN'), throwsArgumentError);
      });

      test('throws for lowercase name', () {
        expect(() => SSHSignalX.fromName('kill'), throwsArgumentError);
      });

      test('throws for empty string', () {
        expect(() => SSHSignalX.fromName(''), throwsArgumentError);
      });
    });

    group('roundtrip', () {
      test('name -> fromName -> same signal', () {
        for (final signal in SSHSignal.values) {
          final name = signal.name;
          final parsed = SSHSignalX.fromName(name);
          expect(parsed, signal);
        }
      });
    });

    group('common signals', () {
      test('SIGINT is available for Ctrl+C', () {
        expect(SSHSignal.INT.name, 'INT');
      });

      test('SIGTERM is available for graceful termination', () {
        expect(SSHSignal.TERM.name, 'TERM');
      });

      test('SIGKILL is available for forced termination', () {
        expect(SSHSignal.KILL.name, 'KILL');
      });

      test('SIGHUP is available for hangup', () {
        expect(SSHSignal.HUP.name, 'HUP');
      });

      test('SIGPIPE is available for broken pipe', () {
        expect(SSHSignal.PIPE.name, 'PIPE');
      });

      test('SIGSEGV is available for segfault', () {
        expect(SSHSignal.SEGV.name, 'SEGV');
      });
    });
  });
}
