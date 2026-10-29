import 'package:test/test.dart';
import 'package:app_ssh/src/utils/string.dart';

void main() {
  group('StirngX', () {
    group('octal', () {
      test('parses 0', () {
        expect('0'.octal, 0);
      });

      test('parses 1', () {
        expect('1'.octal, 1);
      });

      test('parses 7', () {
        expect('7'.octal, 7);
      });

      test('parses 10 (octal) to 8 (decimal)', () {
        expect('10'.octal, 8);
      });

      test('parses 100 (octal) to 64 (decimal)', () {
        expect('100'.octal, 64);
      });

      test('parses 777 (octal) to 511 (decimal)', () {
        expect('777'.octal, 511);
      });

      test('parses common Unix permissions 755', () {
        expect('755'.octal, 493);
      });

      test('parses common Unix permissions 644', () {
        expect('644'.octal, 420);
      });

      test('parses common Unix permissions 666', () {
        expect('666'.octal, 438);
      });

      test('parses common Unix permissions 600', () {
        expect('600'.octal, 384);
      });

      test('parses leading zeros', () {
        expect('0755'.octal, 493);
        expect('00755'.octal, 493);
      });

      test('parses large octal values', () {
        // 7777 octal = 4095 decimal
        expect('7777'.octal, 4095);
      });

      test('throws on invalid octal digit 8', () {
        expect(() => '8'.octal, throwsFormatException);
      });

      test('throws on invalid octal digit 9', () {
        expect(() => '9'.octal, throwsFormatException);
      });

      test('throws on non-numeric characters', () {
        expect(() => 'abc'.octal, throwsFormatException);
      });

      test('throws on mixed valid/invalid', () {
        expect(() => '78'.octal, throwsFormatException);
      });

      test('throws on empty string', () {
        expect(() => ''.octal, throwsFormatException);
      });
    });
  });
}
