import 'package:test/test.dart';
import 'package:xterm/xterm.dart';

void main() {
  group('Terminal hostile escape input', () {
    final inputs = <String, String>{
      'huge DCH': '\x1b[9223372036854775808P',
      'huge SD': '\x1b[9223372036854775808T',
      'huge SU': '\x1b[9223372036854775808S',
      'huge ECH': '\x1b[9223372036854775808X',
      'huge ICH': '\x1b[9223372036854775808@',
      'huge IL': '\x1b[9223372036854775808L',
      'huge DL': '\x1b[9223372036854775808M',
      'huge CUP': '\x1b[9223372036854775808;9223372036854775808H',
      'truncated SGR 38': 'a\x1b[38mb\x1b[48;2;1mc',
    };

    for (final entry in inputs.entries) {
      test('${entry.key} does not throw', () {
        final terminal = Terminal();
        terminal.write('abc');
        expect(() => terminal.write(entry.value), returnsNormally);
        expect(() => terminal.write('ok'), returnsNormally);
      });
    }

    test('huge REP finishes quickly', () {
      final terminal = Terminal();
      final stopwatch = Stopwatch()..start();
      terminal.write('a\x1b[2000000000b');
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
    });
  });
}
