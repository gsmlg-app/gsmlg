import 'package:app_logging/app_logging.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('redacts authorization, keeps name casing', () {
    final r = Redaction.headers({
      'Authorization': ['Bearer x'],
      'Accept': ['a'],
    });
    expect(r['Authorization'], ['[REDACTED]']);
    expect(r['Accept'], ['a']);
  });
  test('extra headers case-insensitive', () {
    final r = Redaction.headers({
      'x-my-key': ['s']
    }, extra: {
      'X-My-Key'
    });
    expect(r['x-my-key'], ['[REDACTED]']);
  });
  test('redacts query params', () {
    final u = Redaction.uri(Uri.parse('https://h/p?api_key=abc&q=1&Token=z'));
    expect(u.queryParameters, {
      'api_key': '[REDACTED]',
      'q': '1',
      'Token': '[REDACTED]',
    });
  });
  test('malformed percent escape does not throw', () {
    expect(
      Redaction.query('%zz=1&api_key=abc'),
      '%zz=[REDACTED]&api_key=[REDACTED]',
    );
    expect(
      () => HttpMessageCapture.request(
        method: 'GET',
        url: Uri.parse('http://h/p?%zz=1&api_key=abc'),
        headers: {},
        bodyBytes: [],
      ),
      returnsNormally,
    );
  });
}
