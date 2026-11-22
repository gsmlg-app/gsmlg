import 'dart:convert';
import 'dart:typed_data';

/// Validates write-only OSC 52 content without reading any clipboard.
abstract final class Osc52ClipboardWrite {
  static const maxDecodedBytes = 100 * 1024;
  static const _maxEncodedLength = ((maxDecodedBytes + 2) ~/ 3) * 4;
  static final _base64Pattern = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
  static final _selectionPattern = RegExp(r'^[cpqs0-7]+$');

  static String? decode(String code, List<String> args) {
    if (code != '52' || args.length != 2 || !_targetsClipboard(args[0])) {
      return null;
    }
    final bytes = _decodeBase64Payload(args[1]);
    if (bytes == null) return null;
    try {
      return utf8.decode(bytes);
    } on FormatException {
      return null;
    }
  }

  static bool _targetsClipboard(String selection) {
    if (selection.isEmpty) return true;
    return _selectionPattern.hasMatch(selection) && selection.contains('c');
  }

  static Uint8List? _decodeBase64Payload(String payload) {
    if (payload == '?' ||
        payload.length > _maxEncodedLength ||
        !_base64Pattern.hasMatch(payload)) {
      return null;
    }

    final String normalized;
    if (payload.contains('=')) {
      if (payload.length % 4 != 0) return null;
      normalized = payload;
    } else {
      final remainder = payload.length % 4;
      if (remainder == 1) return null;
      normalized =
          remainder == 0 ? payload : '$payload${'=' * (4 - remainder)}';
    }

    if (normalized.length > _maxEncodedLength) return null;

    try {
      final bytes = base64.decode(normalized);
      if (bytes.length > maxDecodedBytes) return null;
      return bytes;
    } on FormatException {
      return null;
    }
  }
}
