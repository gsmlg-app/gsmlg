import 'dart:convert';

import 'package:app_logging/app_logging.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('valid json parsed', () {
    final r = HttpBody.encode(utf8.encode('{"a":1}'), 'application/json');
    expect(r.encoding, 'json');
    expect(r.body, {'a': 1});
  });
  test('invalid json falls back to text', () {
    final r = HttpBody.encode(utf8.encode('{nope'), 'application/json');
    expect(r.encoding, 'text');
    expect(r.body, '{nope');
  });
  test('invalid utf8 text -> base64', () {
    expect(
        HttpBody.encode([0xff, 0xfe, 0xfd], 'text/plain').encoding, 'base64');
  });
  test('2 MiB binary truncated to 1 MiB', () {
    final r = HttpBody.encode(
      List.filled(2 * 1024 * 1024, 7),
      'application/octet-stream',
    );
    expect(r.truncated, isTrue);
    expect(base64Decode(r.body! as String).length, 1048576);
  });
  test('empty -> none', () {
    final r = HttpBody.encode([], 'application/json');
    expect((r.body, r.encoding), (null, 'none'));
  });
  test('event-stream is text', () {
    expect(
      HttpBody.encode(utf8.encode('data: x'), 'text/event-stream').encoding,
      'text',
    );
  });
}
