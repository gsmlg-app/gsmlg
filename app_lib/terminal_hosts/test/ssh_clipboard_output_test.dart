import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_hosts/src/ssh_shell_wrapper.dart';

void main() {
  test(
    'shell PID filtering preserves fragmented OSC 52 before and after marker',
    () {
      const clipboard = '\x1b]52;c;aGVsbG8=\x07';
      const clipboardST = '\x1b]52;c;aGVsbG8=\x1b\\';
      final filter = ShellPidFilter();
      final input = '$clipboard${shellPidMarkerPrefix}42\x07$clipboardST';
      final output = BytesBuilder();
      for (final byte in ascii.encode(input)) {
        output.add(filter.process(Uint8List.fromList([byte])));
      }
      output.add(filter.flush());
      expect(ascii.decode(output.takeBytes()), '$clipboard$clipboardST');
      expect(filter.pid, 42);
    },
  );
}
