import 'package:test/test.dart';
import 'package:xterm/src/core/input/keys.dart';
import 'package:xterm/src/core/input/keytab/keytab.dart';

void main() {
  group('Keytab', () {
    group('construction', () {
      test('can be created with name and records', () {
        final keytab = Keytab(name: 'test', records: []);
        expect(keytab.name, equals('test'));
        expect(keytab.records, isEmpty);
      });

      test('name can be null', () {
        final keytab = Keytab(name: null, records: []);
        expect(keytab.name, isNull);
      });
    });

    group('parse', () {
      test('parses simple key binding', () {
        final keytab = Keytab.parse(r'key Enter : "\r"');
        final record = keytab.find(TerminalKey.enter);
        expect(record, isNotNull);
      });

      test('parses multiple key bindings', () {
        final keytab = Keytab.parse('''
key Enter : "\\r"
key Tab : "\\t"
''');
        expect(keytab.find(TerminalKey.enter), isNotNull);
        expect(keytab.find(TerminalKey.tab), isNotNull);
      });

      test('parses keytab name', () {
        final keytab = Keytab.parse('keyboard "MyKeytab"\nkey Enter : "\\r"');
        expect(keytab.name, equals('MyKeytab'));
      });
    });

    group('defaultKeytab', () {
      test('has records', () {
        expect(Keytab.defaultKeytab.records, isNotEmpty);
      });

      test('has Enter key binding', () {
        final record = Keytab.defaultKeytab.find(TerminalKey.enter);
        expect(record, isNotNull);
      });

      test('has Tab key binding', () {
        final record = Keytab.defaultKeytab.find(TerminalKey.tab);
        expect(record, isNotNull);
      });

      test('has Escape key binding', () {
        final record = Keytab.defaultKeytab.find(TerminalKey.escape);
        expect(record, isNotNull);
      });

      test('has Backspace key binding', () {
        final record = Keytab.defaultKeytab.find(TerminalKey.backspace);
        expect(record, isNotNull);
      });

      test('has arrow key bindings', () {
        expect(Keytab.defaultKeytab.find(TerminalKey.arrowUp), isNotNull);
        expect(Keytab.defaultKeytab.find(TerminalKey.arrowDown), isNotNull);
        expect(Keytab.defaultKeytab.find(TerminalKey.arrowLeft), isNotNull);
        expect(Keytab.defaultKeytab.find(TerminalKey.arrowRight), isNotNull);
      });

      test('has function key bindings', () {
        expect(Keytab.defaultKeytab.find(TerminalKey.f1), isNotNull);
        expect(Keytab.defaultKeytab.find(TerminalKey.f2), isNotNull);
        expect(Keytab.defaultKeytab.find(TerminalKey.f12), isNotNull);
      });
    });

    group('find()', () {
      test('can match keyPad', () {
        final keytab = Keytab.parse(r'key Home +KeyPad : "TEST"');
        final record = keytab.find(TerminalKey.home, keyPad: true);
        expect(record!.action.unescapedValue(), 'TEST');

        final record1 = keytab.find(TerminalKey.home);
        expect(record1, isNull);
      });

      test('returns null for non-matching key', () {
        final keytab = Keytab.parse(r'key A : "A"');
        final record = keytab.find(TerminalKey.keyB);
        expect(record, isNull);
      });

      test('finds matching key', () {
        final keytab = Keytab.parse(r'key Enter : "ENTER"');
        final record = keytab.find(TerminalKey.enter);
        expect(record!.action.unescapedValue(), 'ENTER');
      });

      test('find parameters have correct defaults', () {
        // Test that find() works with just the key
        final keytab = Keytab.defaultKeytab;
        final record = keytab.find(TerminalKey.enter);
        expect(record, isNotNull);
      });

      test('find with ctrl false by default', () {
        final keytab = Keytab.defaultKeytab;
        // Default keytab has Enter without modifiers
        final record = keytab.find(TerminalKey.enter, ctrl: false);
        expect(record, isNotNull);
      });

      test('find with alt false by default', () {
        final keytab = Keytab.defaultKeytab;
        final record = keytab.find(TerminalKey.enter, alt: false);
        expect(record, isNotNull);
      });

      test('find with shift false by default', () {
        final keytab = Keytab.defaultKeytab;
        final record = keytab.find(TerminalKey.enter, shift: false);
        expect(record, isNotNull);
      });
    });

    group('special keys', () {
      test('Home key', () {
        final keytab = Keytab.parse(r'key Home : "\e[H"');
        final record = keytab.find(TerminalKey.home);
        expect(record, isNotNull);
      });

      test('End key', () {
        final keytab = Keytab.parse(r'key End : "\e[F"');
        final record = keytab.find(TerminalKey.end);
        expect(record, isNotNull);
      });

      test('Insert key', () {
        final keytab = Keytab.parse(r'key Insert : "\e[2~"');
        final record = keytab.find(TerminalKey.insert);
        expect(record, isNotNull);
      });

      test('Delete key', () {
        final keytab = Keytab.parse(r'key Delete : "\e[3~"');
        final record = keytab.find(TerminalKey.delete);
        expect(record, isNotNull);
      });

      test('PageUp key', () {
        final keytab = Keytab.parse(r'key PgUp : "\e[5~"');
        final record = keytab.find(TerminalKey.pageUp);
        expect(record, isNotNull);
      });

      test('PageDown key', () {
        final keytab = Keytab.parse(r'key PgDown : "\e[6~"');
        final record = keytab.find(TerminalKey.pageDown);
        expect(record, isNotNull);
      });
    });
  });
}
