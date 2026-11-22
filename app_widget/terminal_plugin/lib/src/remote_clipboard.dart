import 'dart:async';

import 'package:flutter/services.dart';
import 'package:xterm/osc52_clipboard_write.dart';

/// Applies local policy to OSC 52 events from a terminal parser.
///
/// This deliberately has no clipboard reader or transport writer. Each session
/// defaults to trusted, subject to the global write policy. Manual revocation
/// lasts until the next session.
class RemoteClipboard {
  RemoteClipboard({
    required this.writesAllowed,
    Future<void> Function(String text)? writeClipboard,
  }) : _writeClipboard = writeClipboard ?? _writeNativeClipboard;

  static const maxDecodedBytes = Osc52ClipboardWrite.maxDecodedBytes;

  final bool Function() writesAllowed;
  final Future<void> Function(String text) _writeClipboard;

  bool get sessionActive => _sessionActive;
  bool _sessionActive = false;
  bool get trusted => _trusted && writesAllowed();
  bool _trusted = false;
  int _generation = 0;
  (String, int, bool Function()?)? _pending;
  bool _writing = false;

  void startSession() {
    _generation++;
    _pending = null;
    _trusted = true;
    _sessionActive = true;
  }

  void endSession() {
    _generation++;
    _pending = null;
    _trusted = false;
    _sessionActive = false;
  }

  void setTrusted(bool trusted) {
    _generation++;
    _pending = null;
    _trusted = trusted && _sessionActive && writesAllowed();
  }

  bool get _canWrite => _sessionActive && trusted;

  /// Receives parsed OSC arguments; incomplete sequences stay in the parser.
  void handleOSC(String code, List<String> args) {
    if (!_canWrite) return;
    final text = Osc52ClipboardWrite.decode(code, args);
    if (text != null) writeValidated(text);
  }

  /// Enqueue one validated write with current session and effect authority.
  void writeValidated(String text, {bool Function()? stillEligible}) {
    if (!_canWrite || (stillEligible != null && !stillEligible())) return;
    _pending = (text, _generation, stillEligible);
    if (!_writing) {
      _writing = true;
      unawaited(Future<void>.microtask(_drain));
    }
  }

  Future<void> _drain() async {
    try {
      while (_pending != null) {
        final (text, generation, stillEligible) = _pending!;
        _pending = null;
        if (generation != _generation ||
            !_canWrite ||
            (stillEligible != null && !stillEligible())) {
          continue;
        }
        try {
          await _writeClipboard(text);
        } catch (_) {
          // Clipboard errors must not interrupt the terminal or expose data.
        }
      }
    } finally {
      _writing = false;
    }
  }

  static Future<void> _writeNativeClipboard(String text) =>
      Clipboard.setData(ClipboardData(text: text));
}
