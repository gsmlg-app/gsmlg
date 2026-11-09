import 'dart:convert';

/// Encodes raw HTTP body bytes into a JSON-friendly representation.
abstract final class HttpBody {
  static const maxBinaryBytes = 1024 * 1024;

  static const _textMarkers = [
    'json',
    'xml',
    'event-stream',
    'x-www-form-urlencoded',
  ];

  static ({Object? body, String encoding, bool truncated}) encode(
    List<int> bytes,
    String? contentType,
  ) {
    if (bytes.isEmpty) return (body: null, encoding: 'none', truncated: false);
    final ct = contentType?.toLowerCase() ?? '';
    final isText = ct.startsWith('text/') || _textMarkers.any(ct.contains);
    if (isText) {
      String? text;
      try {
        text = utf8.decode(bytes);
      } on FormatException {
        text = null;
      }
      if (text != null) {
        if (ct.contains('json')) {
          try {
            return (body: jsonDecode(text), encoding: 'json', truncated: false);
          } on FormatException {
            // fall through to text
          }
        }
        return (body: text, encoding: 'text', truncated: false);
      }
    }
    final truncated = bytes.length > maxBinaryBytes;
    final kept = truncated ? bytes.sublist(0, maxBinaryBytes) : bytes;
    return (body: base64Encode(kept), encoding: 'base64', truncated: truncated);
  }
}
