import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xterm/xterm.dart';

void main() {
  group('MacOptionKeyBehavior.sendsMeta', () {
    test('leftMeta only treats left Option as Meta', () {
      const behavior = MacOptionKeyBehavior.leftMeta;
      expect(behavior.sendsMeta(leftOption: true, rightOption: false), isTrue);
      expect(behavior.sendsMeta(leftOption: false, rightOption: true), isFalse);
    });

    test('bothMeta treats both Options as Meta', () {
      const behavior = MacOptionKeyBehavior.bothMeta;
      expect(behavior.sendsMeta(leftOption: true, rightOption: false), isTrue);
      expect(behavior.sendsMeta(leftOption: false, rightOption: true), isTrue);
    });

    test('normal never treats Option as Meta', () {
      const behavior = MacOptionKeyBehavior.normal;
      expect(behavior.sendsMeta(leftOption: true, rightOption: false), isFalse);
      expect(behavior.sendsMeta(leftOption: false, rightOption: true), isFalse);
    });
  });

  group('macOptionMetaInput', () {
    test('sends ESC + lowercase letter', () {
      expect(macOptionMetaInput(0x62, shift: false), '\x1bb');
    });

    test('sends ESC + uppercase letter with Shift', () {
      expect(macOptionMetaInput(0x62, shift: true), '\x1bB');
    });

    test('sends ESC + digit and punctuation', () {
      expect(macOptionMetaInput(0x31, shift: false), '\x1b1');
      expect(macOptionMetaInput(0x2e, shift: false), '\x1b.');
      expect(macOptionMetaInput(0x20, shift: false), '\x1b ');
    });

    test('shifts US punctuation with Shift', () {
      expect(macOptionMetaInput(0x2e, shift: true), '\x1b>');
      expect(macOptionMetaInput(0x2c, shift: true), '\x1b<');
      expect(macOptionMetaInput(0x3e, shift: true), '\x1b>');
    });

    test('returns null for control characters', () {
      expect(macOptionMetaInput(0x08, shift: false), isNull);
      expect(macOptionMetaInput(0x7f, shift: false), isNull);
    });
  });

  group('default input handler on macOS', () {
    List<String> send(
      TerminalKey key, {
      bool alt = false,
      bool shift = false,
      TerminalTargetPlatform platform = TerminalTargetPlatform.macos,
    }) {
      final output = <String>[];
      Terminal(onOutput: output.add, platform: platform)
          .keyInput(key, alt: alt, shift: shift);
      return output;
    }

    test('Option+Left/Right send word jump sequences', () {
      expect(send(TerminalKey.arrowLeft, alt: true), ['\x1bb']);
      expect(send(TerminalKey.arrowRight, alt: true), ['\x1bf']);
    });

    test('Option+Backspace sends ESC DEL', () {
      expect(send(TerminalKey.backspace, alt: true), ['\x1b\x7f']);
    });

    test('Option+letter is left to text input', () {
      expect(send(TerminalKey.keyB, alt: true), isEmpty);
    });

    test('non-macOS Alt handling is unchanged', () {
      const platform = TerminalTargetPlatform.unknown;
      expect(
        send(TerminalKey.arrowLeft, alt: true, platform: platform),
        ['\x1b[1;5D'],
      );
      expect(
        send(TerminalKey.backspace, alt: true, platform: platform),
        ['\x17'],
      );
      expect(
        send(TerminalKey.keyB, alt: true, platform: platform),
        ['\x1bB'],
      );
    });
  });

  group('TerminalView Option key on macOS', () {
    Future<List<String>> pumpTerminal(
      WidgetTester tester, {
      MacOptionKeyBehavior behavior = MacOptionKeyBehavior.leftMeta,
      TerminalTargetPlatform platform = TerminalTargetPlatform.macos,
    }) async {
      final output = <String>[];
      final terminal = Terminal(onOutput: output.add, platform: platform);
      await tester.pumpWidget(
        MaterialApp(
          home: TerminalView(
            terminal,
            autofocus: true,
            hardwareKeyboardOnly: true,
            macOptionKeyBehavior: behavior,
          ),
        ),
      );
      await tester.pump();
      return output;
    }

    Future<void> pressWithOption(
      WidgetTester tester,
      LogicalKeyboardKey option,
      LogicalKeyboardKey key, {
      bool shift = false,
    }) async {
      await tester.sendKeyDownEvent(option, platform: 'macos');
      if (shift) {
        await tester.sendKeyDownEvent(
          LogicalKeyboardKey.shiftLeft,
          platform: 'macos',
        );
      }
      await tester.sendKeyEvent(key, platform: 'macos');
      if (shift) {
        await tester.sendKeyUpEvent(
          LogicalKeyboardKey.shiftLeft,
          platform: 'macos',
        );
      }
      await tester.sendKeyUpEvent(option, platform: 'macos');
      await tester.pump();
    }

    testWidgets('leftMeta: left Option+b sends ESC b', (tester) async {
      final output = await pumpTerminal(tester);
      await pressWithOption(
        tester,
        LogicalKeyboardKey.altLeft,
        LogicalKeyboardKey.keyB,
      );
      expect(output, ['\x1bb']);
    });

    testWidgets('leftMeta: left Option+Shift+b sends ESC B', (tester) async {
      final output = await pumpTerminal(tester);
      await pressWithOption(
        tester,
        LogicalKeyboardKey.altLeft,
        LogicalKeyboardKey.keyB,
        shift: true,
      );
      expect(output, ['\x1bB']);
    });

    testWidgets('leftMeta: left Option+. sends ESC .', (tester) async {
      final output = await pumpTerminal(tester);
      await pressWithOption(
        tester,
        LogicalKeyboardKey.altLeft,
        LogicalKeyboardKey.period,
      );
      expect(output, ['\x1b.']);
    });

    testWidgets('leftMeta: right Option+b types text', (tester) async {
      final output = await pumpTerminal(tester);
      await pressWithOption(
        tester,
        LogicalKeyboardKey.altRight,
        LogicalKeyboardKey.keyB,
      );
      expect(output, <String>['b']);
    });

    testWidgets('bothMeta: right Option+b sends ESC b', (tester) async {
      final output = await pumpTerminal(
        tester,
        behavior: MacOptionKeyBehavior.bothMeta,
      );
      await pressWithOption(
        tester,
        LogicalKeyboardKey.altRight,
        LogicalKeyboardKey.keyB,
      );
      expect(output, ['\x1bb']);
    });

    testWidgets('normal: left Option+b types text', (tester) async {
      final output = await pumpTerminal(
        tester,
        behavior: MacOptionKeyBehavior.normal,
      );
      await pressWithOption(
        tester,
        LogicalKeyboardKey.altLeft,
        LogicalKeyboardKey.keyB,
      );
      expect(output, <String>['b']);
    });

    for (final behavior in MacOptionKeyBehavior.values) {
      testWidgets('${behavior.name}: Option word jumps and ESC DEL',
          (tester) async {
        final output = await pumpTerminal(tester, behavior: behavior);
        for (final option in <LogicalKeyboardKey>[
          LogicalKeyboardKey.altLeft,
          LogicalKeyboardKey.altRight,
        ]) {
          await pressWithOption(tester, option, LogicalKeyboardKey.arrowLeft);
          await pressWithOption(tester, option, LogicalKeyboardKey.arrowRight);
          await pressWithOption(tester, option, LogicalKeyboardKey.backspace);
        }
        expect(output, <String>[
          '\x1bb',
          '\x1bf',
          '\x1b\x7f',
          '\x1bb',
          '\x1bf',
          '\x1b\x7f',
        ]);
      });
    }

    testWidgets('non-macOS terminal ignores the Option setting',
        (tester) async {
      final output = await pumpTerminal(
        tester,
        platform: TerminalTargetPlatform.unknown,
      );
      await pressWithOption(
        tester,
        LogicalKeyboardKey.altLeft,
        LogicalKeyboardKey.keyB,
      );
      expect(output, ['\x1bB']);
    });
  });
}
