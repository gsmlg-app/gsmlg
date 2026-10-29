import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_plugin/terminal_plugin.dart';
import 'package:xterm/xterm.dart';

void main() {
  void keyboardTest(
    String description,
    WidgetTesterCallback callback, {
    TargetPlatform platform = TargetPlatform.android,
  }) {
    testWidgets(
      description,
      callback,
      variant: TargetPlatformVariant.only(platform),
    );
  }

  Future<TerminalPlugin> pumpTerminal(
    WidgetTester tester, {
    double keyboardHeight = 300,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 900);
    tester.view.viewInsets = FakeViewPadding(bottom: keyboardHeight);
    addTearDown(tester.view.resetViewInsets);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final plugin = TerminalPlugin();
    addTearDown(plugin.terminal.dispose);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocale.localizationsDelegates,
        supportedLocales: AppLocale.supportedLocales,
        home: Scaffold(body: TerminalTabView(plugin)),
      ),
    );
    await tester.pump();
    return plugin;
  }

  keyboardTest('mobile keyboard exposes the terminal keys above the IME', (
    tester,
  ) async {
    await pumpTerminal(tester);

    for (final label in [
      'ESC',
      'TAB',
      'CTRL',
      'ALT',
      'HOME',
      'END',
      'PGUP',
      'PGDN',
      '←',
      '↓',
      '↑',
      '→',
    ]) {
      expect(find.text(label), findsOneWidget);
      expect(tester.getBottomRight(find.text(label)).dy, lessThan(600));
    }
    expect(tester.takeException(), isNull);
  });

  keyboardTest('extra keys hide with the mobile keyboard', (tester) async {
    await pumpTerminal(tester);
    expect(find.text('CTRL'), findsOneWidget);

    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pump();
    expect(find.text('CTRL'), findsNothing);

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();
    expect(find.text('CTRL'), findsOneWidget);
  });

  keyboardTest('desktop input keeps its existing layout', (tester) async {
    await pumpTerminal(tester);

    expect(find.text('CTRL'), findsNothing);
    expect(find.text('ESC'), findsNothing);
  }, platform: TargetPlatform.macOS);

  keyboardTest('Ctrl+C is sent once and the next letter is ordinary text', (
    tester,
  ) async {
    final plugin = await pumpTerminal(tester);
    final output = <String>[];
    plugin.terminal.onOutput = output.add;
    final terminal = tester.widget<TerminalView>(find.byType(TerminalView));

    await tester.tap(find.text('CTRL'));
    await tester.pump();
    expect(terminal.focusNode!.hasFocus, isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
    tester.testTextInput.enterText('c');
    await tester.pump();
    tester.testTextInput.enterText('d');
    await tester.pump();

    expect(output.join(), '\x03d');
  });

  keyboardTest('Alt preserves case and Ctrl+Alt sends the control byte', (
    tester,
  ) async {
    final plugin = await pumpTerminal(tester);
    final output = <String>[];
    plugin.terminal.onOutput = output.add;

    await tester.tap(find.text('ALT'));
    await tester.pump();
    tester.testTextInput.enterText('b');
    await tester.pump();
    await tester.tap(find.text('ALT'));
    await tester.pump();
    tester.testTextInput.enterText('B');
    await tester.pump();
    await tester.tap(find.text('CTRL'));
    await tester.tap(find.text('ALT'));
    await tester.pump();
    tester.testTextInput.enterText('C');
    await tester.pump();

    expect(output.join(), '\x1bb\x1bB\x1b\x03');
  });

  keyboardTest('non-ASCII and multi-character commits stay intact', (
    tester,
  ) async {
    final plugin = await pumpTerminal(tester);
    final output = <String>[];
    plugin.terminal.onOutput = output.add;

    for (final text in ['你好', '😀', ' b ']) {
      await tester.tap(find.text('CTRL'));
      await tester.pump();
      tester.testTextInput.enterText(text);
      await tester.pump();
    }

    expect(output.join(), '你好😀 b ');
  });

  keyboardTest('special keys keep terminal cursor mode and focus', (
    tester,
  ) async {
    final plugin = await pumpTerminal(tester);
    final output = <String>[];
    plugin.terminal.onOutput = output.add;
    plugin.terminal.write('\x1b[?1h');
    plugin.terminal.flush();

    for (final label in ['ESC', 'TAB', '←', '↓', '↑', '→']) {
      await tester.tap(find.text(label));
      await tester.pump();
    }

    expect(output.join(), '\x1b\t\x1bOD\x1bOB\x1bOA\x1bOC');
    final terminal = tester.widget<TerminalView>(find.byType(TerminalView));
    expect(terminal.focusNode!.hasFocus, isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
  });

  keyboardTest('hiding the keyboard clears an unused modifier', (tester) async {
    final plugin = await pumpTerminal(tester);
    final output = <String>[];
    plugin.terminal.onOutput = output.add;

    await tester.tap(find.text('CTRL'));
    await tester.pump();
    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pump();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();
    tester.testTextInput.enterText('c');
    await tester.pump();

    expect(output.join(), 'c');
  });

  keyboardTest('Enter actions consume an unused modifier', (tester) async {
    final plugin = await pumpTerminal(tester);
    final output = <String>[];
    plugin.terminal.onOutput = output.add;

    await tester.tap(find.text('CTRL'));
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.newline);
    await tester.pump();
    tester.testTextInput.enterText('c');
    await tester.pump();

    expect(output.join(), '\rc');
  });

  keyboardTest('keyboard events consume the virtual modifier once', (
    tester,
  ) async {
    final plugin = await pumpTerminal(tester);
    final output = <String>[];
    plugin.terminal.onOutput = output.add;

    await tester.tap(find.text('CTRL'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    await tester.pump();
    tester.testTextInput.enterText('c');
    await tester.pump();

    expect(output.join(), '\x03c');
  });

  keyboardTest('losing terminal focus clears the modifier and hides the row', (
    tester,
  ) async {
    final plugin = await pumpTerminal(tester);
    final output = <String>[];
    plugin.terminal.onOutput = output.add;
    final terminal = tester.widget<TerminalView>(find.byType(TerminalView));

    await tester.tap(find.text('CTRL'));
    await tester.pump();
    terminal.focusNode!.unfocus();
    await tester.pump();
    expect(find.text('CTRL'), findsNothing);
    terminal.focusNode!.requestFocus();
    await tester.pump();
    tester.testTextInput.enterText('c');
    await tester.pump();

    expect(output.join(), 'c');
  });

  keyboardTest('iOS also exposes the extra keys while its keyboard is open', (
    tester,
  ) async {
    await pumpTerminal(tester);

    expect(find.text('CTRL'), findsOneWidget);
    expect(find.text('ESC'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, platform: TargetPlatform.iOS);

  keyboardTest('iOS soft keyboard sends repeated backspaces after typing', (
    tester,
  ) async {
    final plugin = await pumpTerminal(tester);
    final output = <String>[];
    plugin.terminal.onOutput = output.add;

    _insertText(tester, 'abc');
    await tester.pump();
    for (var i = 0; i < 3; i++) {
      _deleteBackward(tester);
      await tester.pump();
    }
    _insertText(tester, 'z');
    await tester.pump();

    expect(output, ['abc', '\x7f', '\x7f', '\x7f', 'z']);
    expect(tester.takeException(), isNull);
  }, platform: TargetPlatform.iOS);

  keyboardTest('iOS Enter sends once and consumes the virtual modifier', (
    tester,
  ) async {
    final plugin = await pumpTerminal(tester);
    final output = <String>[];
    plugin.terminal.onOutput = output.add;

    _insertText(tester, 'ls -a');
    await tester.pump();
    await tester.tap(find.text('CTRL'));
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.newline);
    _insertText(tester, '\n');
    await tester.pump();
    _insertText(tester, 'c');
    await tester.pump();

    expect(output, ['ls -a', '\r', 'c']);
  }, platform: TargetPlatform.iOS);

  keyboardTest('iOS soft keyboard deletes text sent by the minus shortcut', (
    tester,
  ) async {
    final plugin = await pumpTerminal(tester);
    final output = <String>[];
    plugin.terminal.onOutput = output.add;

    await tester.tap(find.text('-'));
    await tester.pump();
    _deleteBackward(tester);
    await tester.pump();

    expect(output, ['-', '\x7f']);
  }, platform: TargetPlatform.iOS);

  keyboardTest('iOS soft keyboard deletion survives hiding and reopening', (
    tester,
  ) async {
    final plugin = await pumpTerminal(tester);
    final output = <String>[];
    plugin.terminal.onOutput = output.add;

    _insertText(tester, 'a');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.keyboard_hide));
    await tester.pump();
    await tester.tap(find.byType(TerminalView));
    await tester.pump(const Duration(milliseconds: 300));
    _deleteBackward(tester);
    await tester.pump();
    _insertText(tester, 'b');
    await tester.pump();
    _deleteBackward(tester);
    await tester.pump();

    expect(output, ['a', '\x7f', 'b', '\x7f']);
  }, platform: TargetPlatform.iOS);

  keyboardTest('iOS composition deletion stays local until text is committed', (
    tester,
  ) async {
    final plugin = await pumpTerminal(tester);
    final output = <String>[];
    plugin.terminal.onOutput = output.add;
    final prefix = tester.testTextInput.editingState!['text'] as String;

    for (final composing in ['ni', 'n']) {
      tester.testTextInput.updateEditingValue(
        TextEditingValue(
          text: '$prefix$composing',
          selection: TextSelection.collapsed(
            offset: prefix.length + composing.length,
          ),
          composing: TextRange(
            start: prefix.length,
            end: prefix.length + composing.length,
          ),
        ),
      );
      await tester.pump();
      expect(output, isEmpty);
    }
    tester.testTextInput.updateEditingValue(
      TextEditingValue(
        text: '$prefix你',
        selection: TextSelection.collapsed(offset: prefix.length + 1),
      ),
    );
    await tester.pump();
    _deleteBackward(tester);
    await tester.pump();

    expect(output, ['你', '\x7f']);
  }, platform: TargetPlatform.iOS);

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    keyboardTest(
      '${platform.name} minus shortcut sends literal text and retains focus',
      (tester) async {
        final plugin = await pumpTerminal(tester);
        final output = <String>[];
        plugin.terminal.onOutput = output.add;
        final terminal = tester.widget<TerminalView>(find.byType(TerminalView));

        await tester.tap(find.text('-'));
        await tester.pump();

        expect(output, ['-']);
        expect(terminal.focusNode!.hasFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);
      },
      platform: platform,
    );

    keyboardTest(
      '${platform.name} hide shortcut clears modifiers and terminal tap restores keyboard',
      (tester) async {
        final plugin = await pumpTerminal(tester);
        final output = <String>[];
        plugin.terminal.onOutput = output.add;
        final terminal = tester.widget<TerminalView>(find.byType(TerminalView));

        await tester.tap(find.text('CTRL'));
        await tester.tap(find.text('ALT'));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.keyboard_hide));
        await tester.pump();

        expect(terminal.focusNode!.hasFocus, isFalse);
        expect(tester.testTextInput.isVisible, isFalse);
        expect(find.text('CTRL'), findsNothing);
        expect(find.byIcon(Icons.keyboard_hide), findsNothing);

        await tester.tap(find.byType(TerminalView));
        await tester.pump(const Duration(milliseconds: 300));

        expect(terminal.focusNode!.hasFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);
        expect(find.text('CTRL'), findsOneWidget);
        expect(find.byIcon(Icons.keyboard_hide), findsOneWidget);
        _insertText(tester, 'c');
        await tester.pump();
        expect(output, ['c']);
      },
      platform: platform,
    );
  }

  keyboardTest('Ctrl supports space and punctuation control bytes', (
    tester,
  ) async {
    final plugin = await pumpTerminal(tester);
    final output = <String>[];
    plugin.terminal.onOutput = output.add;

    for (final text in [' ', '@', '[', '\\', ']', '^', '_', '?']) {
      await tester.tap(find.text('CTRL'));
      await tester.pump();
      tester.testTextInput.enterText(text);
      await tester.pump();
    }

    expect(output.join().codeUnits, [0, 0, 27, 28, 29, 30, 31, 127]);
  });

  keyboardTest('switching the plugin clears a pending modifier', (
    tester,
  ) async {
    await pumpTerminal(tester);
    final previousState = tester.state(find.byType(TerminalTabView));
    await tester.tap(find.text('CTRL'));
    await tester.pump();

    final replacement = TerminalPlugin();
    addTearDown(replacement.terminal.dispose);
    final output = <String>[];
    replacement.terminal.onOutput = output.add;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocale.localizationsDelegates,
        supportedLocales: AppLocale.supportedLocales,
        home: Scaffold(body: TerminalTabView(replacement)),
      ),
    );
    await tester.pump();
    expect(tester.state(find.byType(TerminalTabView)), same(previousState));
    await tester.tap(find.byType(TerminalView));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester
          .state<TerminalViewState>(find.byType(TerminalView))
          .hasInputConnection,
      isTrue,
    );
    tester.testTextInput.enterText('c');
    await tester.pump();

    expect(output.join(), 'c');
  });
}

void _insertText(WidgetTester tester, String text) {
  final value = TextEditingValue.fromJSON(tester.testTextInput.editingState!);
  final selection = value.selection;
  tester.testTextInput.updateEditingValue(
    TextEditingValue(
      text: value.text.replaceRange(selection.start, selection.end, text),
      selection: TextSelection.collapsed(offset: selection.start + text.length),
    ),
  );
}

void _deleteBackward(WidgetTester tester) {
  final value = TextEditingValue.fromJSON(tester.testTextInput.editingState!);
  final cursor = value.selection.baseOffset;
  if (cursor == 0) return;
  tester.testTextInput.updateEditingValue(
    TextEditingValue(
      text: value.text.replaceRange(cursor - 1, cursor, ''),
      selection: TextSelection.collapsed(offset: cursor - 1),
    ),
  );
}
