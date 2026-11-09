/// Fixed redaction rules for captured HTTP headers and query parameters.
abstract final class Redaction {
  static const redacted = '[REDACTED]';

  static const _headerNames = {
    'authorization',
    'proxy-authorization',
    'x-api-key',
    'api-key',
    'cookie',
    'set-cookie',
    'x-amz-security-token',
    'x-goog-api-key',
  };

  static const _queryKeys = {
    'key',
    'api_key',
    'apikey',
    'access_token',
    'token'
  };

  /// Returns a copy of [h] with secret header values replaced by `[REDACTED]`.
  /// Header name casing is preserved.
  static Map<String, List<String>> headers(
    Map<String, List<String>> h, {
    Set<String> extra = const {},
  }) {
    final secret = {..._headerNames, ...extra.map((e) => e.toLowerCase())};
    return {
      for (final e in h.entries)
        e.key: secret.contains(e.key.toLowerCase())
            ? const [redacted]
            : List<String>.of(e.value),
    };
  }

  /// Returns [u] with the values of secret query parameters redacted.
  /// Note: [Uri.toString] percent-encodes the brackets; use [query] for the
  /// literal `[REDACTED]` text.
  static Uri uri(Uri u) => u.hasQuery ? u.replace(query: query(u.query)) : u;

  /// Redacts secret parameter values in a raw query string.
  static String query(String q) => q.split('&').map((pair) {
        final i = pair.indexOf('=');
        if (i < 0) return pair;
        final raw = pair.substring(0, i);
        String? name;
        try {
          name = Uri.decodeQueryComponent(raw);
        } on ArgumentError {
          name = null; // Undecodable name: fail closed and redact the value.
        }
        return name == null || _queryKeys.contains(name.toLowerCase())
            ? '${pair.substring(0, i)}=$redacted'
            : pair;
      }).join('&');

  /// Replaces occurrences of [u] in [text] (e.g. an exception message) with
  /// [u] whose secret query values are redacted.
  static String inText(String text, Uri u) {
    if (!u.hasQuery) return text;
    final raw = u.toString();
    final safe = raw.replaceFirst('?${u.query}', '?${query(u.query)}');
    return text.replaceAll(raw, safe);
  }
}
