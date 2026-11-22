import 'dart:convert';
import 'dart:typed_data';

/// Start of the escape sequence the wrapped shell prints with its pid.
const shellPidMarkerPrefix = '\x1b]1337;WebTerminalShellPid=';

const _bel = 0x07;
const _maxScanBytes = 64 * 1024;

/// Command that starts the user's login shell through `/bin/sh`, first
/// printing the shell's pid and changing into [workingDirectory].
///
/// `exec` keeps the pid, so the login shell has the pid it reports. The
/// command contains no single quotes or `\\`, so it means the same to the
/// user's login shell whether that is POSIX, fish or csh.
String wrappedShellCommand({String? workingDirectory}) {
  final script = StringBuffer(
    'printf "\\033]1337;WebTerminalShellPid=%s\\007" "\$\$"; ',
  );
  if (workingDirectory != null && workingDirectory.isNotEmpty) {
    script.write(
      'cd "\$(printf "${_octalEscape(workingDirectory)}")" 2>/dev/null; ',
    );
  }
  script.write('exec "\${SHELL:-/bin/sh}" -l');
  return "exec /bin/sh -c '$script'";
}

/// Command that prints the working directory of process [pid], using
/// `/proc` on Linux and `lsof` elsewhere.
String workingDirectoryQueryCommand(int pid) =>
    "exec /bin/sh -c 'readlink /proc/$pid/cwd 2>/dev/null || "
    'lsof -a -p $pid -d cwd -Fn 2>/dev/null | sed -n "s/^n//p"\'';

/// The directory printed by [workingDirectoryQueryCommand], or null.
String? parseWorkingDirectoryQuery(String output) {
  final line = const LineSplitter().convert(output).firstOrNull?.trim();
  if (line == null || !line.startsWith('/')) return null;
  return line;
}

String _octalEscape(String text) => [
  for (final byte in utf8.encode(text))
    '\\${byte.toRadixString(8).padLeft(3, '0')}',
].join();

/// Removes the pid marker printed by [wrappedShellCommand] from the start of
/// a session's output.
///
/// Output before and after the marker passes through unchanged. Only the
/// first marker is removed; scanning stops after it or after 64 KB.
class ShellPidFilter {
  static final _prefix = ascii.encode(shellPidMarkerPrefix);

  final _pending = BytesBuilder(copy: true);
  var _scanned = 0;
  var _done = false;

  /// The pid the shell reported, once its marker has been seen.
  int? pid;

  /// Whether the filter has stopped looking for the marker.
  bool get isDone => _done;

  /// Bytes retained while an incomplete marker is being checked.
  int get pendingBytes => _pending.length;

  /// Returns the part of [chunk] that can be shown now.
  Uint8List process(Uint8List chunk) {
    if (_done) return chunk;
    _scanned += chunk.length;
    _pending.add(chunk);
    final data = _pending.takeBytes();

    final start = _indexOf(data, _prefix);
    if (start < 0) {
      if (_scanned > _maxScanBytes) return _finish(data);
      final keep = _partialPrefixLength(data);
      _pending.add(Uint8List.sublistView(data, data.length - keep));
      return Uint8List.sublistView(data, 0, data.length - keep);
    }

    var end = start + _prefix.length;
    while (end < data.length && _isDigit(data[end])) {
      end++;
    }
    if (end == data.length) {
      if (_scanned > _maxScanBytes) return _finish(data);
      _pending.add(Uint8List.sublistView(data, start));
      return Uint8List.sublistView(data, 0, start);
    }
    final digits = ascii.decode(data.sublist(start + _prefix.length, end));
    if (data[end] != _bel || digits.isEmpty) return _finish(data);

    final parsedPid = int.tryParse(digits);
    if (parsedPid == null || parsedPid <= 0) return _finish(data);
    pid = parsedPid;
    _done = true;
    return Uint8List.fromList([
      ...Uint8List.sublistView(data, 0, start),
      ...Uint8List.sublistView(data, end + 1),
    ]);
  }

  /// Releases anything held back while looking for the marker.
  Uint8List flush() => _finish(_pending.takeBytes());

  Uint8List _finish(Uint8List data) {
    _done = true;
    return data;
  }

  static bool _isDigit(int byte) => byte >= 0x30 && byte <= 0x39;

  static int _indexOf(Uint8List data, List<int> pattern) {
    outer:
    for (var i = 0; i + pattern.length <= data.length; i++) {
      for (var j = 0; j < pattern.length; j++) {
        if (data[i + j] != pattern[j]) continue outer;
      }
      return i;
    }
    return -1;
  }

  /// Length of the longest suffix of [data] that starts the marker.
  static int _partialPrefixLength(Uint8List data) {
    final max = data.length < _prefix.length ? data.length : _prefix.length - 1;
    outer:
    for (var length = max; length > 0; length--) {
      final offset = data.length - length;
      for (var j = 0; j < length; j++) {
        if (data[offset + j] != _prefix[j]) continue outer;
      }
      return length;
    }
    return 0;
  }
}
