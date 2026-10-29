import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_plugin/src/terminal_extra_keys.dart';
import 'package:xterm/xterm.dart';

void main() {
  const labels = [
    'ESC',
    'TAB',
    'CTRL',
    'ALT',
    'HOME',
    'END',
    'PGUP',
    '←',
    '↓',
    '↑',
    '→',
    'PGDN',
    '-',
  ];
  const slotLabels = [...labels, 'Hide'];

  Future<void> pumpKeys(
    WidgetTester tester, {
    double width = 360,
    double textScale = 1,
    bool ctrlPressed = false,
    bool altPressed = false,
    VoidCallback? onToggleCtrl,
    VoidCallback? onToggleAlt,
    ValueChanged<TerminalKey>? onKey,
    ValueChanged<String>? onText,
    VoidCallback? onHideKeyboard,
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocale.localizationsDelegates,
        supportedLocales: AppLocale.supportedLocales,
        theme: ThemeData(brightness: brightness),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              child: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
                child: TerminalExtraKeys(
                  ctrlPressed: ctrlPressed,
                  altPressed: altPressed,
                  onToggleCtrl: onToggleCtrl ?? () {},
                  onToggleAlt: onToggleAlt ?? () {},
                  onKey: onKey ?? (_) {},
                  onText: onText ?? (_) {},
                  onHideKeyboard: onHideKeyboard ?? () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  for (final width in [320.0, 360.0, 576.0, 671.0]) {
    testWidgets('width $width shows two ordered rows of seven keys',
        (tester) async {
      await pumpKeys(tester, width: width);

      for (var index = 0; index < slotLabels.length; index++) {
        final key = find.bySemanticsLabel(slotLabels[index]);
        expect(find.byTooltip(slotLabels[index]), findsOneWidget);
        final rect = tester.getRect(key);
        expect(rect.height, 48);
        expect(rect.width, closeTo(width / 7, 0.01));
        expect(rect.top, index < 7 ? 0 : 48);
        expect(rect.left, closeTo((index % 7) * width / 7, 0.01));
      }
      expect(find.byIcon(Icons.keyboard_hide), findsOneWidget);
      expect(tester.getRect(find.bySemanticsLabel('Hide')).right,
          closeTo(width, 0.01));
      expect(tester.getSize(find.byType(TerminalExtraKeys)).height, 96);
      expect(tester.takeException(), isNull);
    });
  }

  for (final width in [672.0, 720.0]) {
    testWidgets('width $width shows all fourteen keys in one row',
        (tester) async {
      await pumpKeys(tester, width: width);

      for (var index = 0; index < slotLabels.length; index++) {
        final rect = tester.getRect(find.bySemanticsLabel(slotLabels[index]));
        expect(rect.top, 0);
        expect(rect.left, closeTo(index * width / 14, 0.01));
        expect(rect.width, closeTo(width / 14, 0.01));
        expect(rect.height, 48);
      }
      expect(tester.getSize(find.byType(TerminalExtraKeys)).height, 48);
      expect(tester.takeException(), isNull);
    });
  }

  for (final brightness in Brightness.values) {
    testWidgets('large text fits narrow keys in ${brightness.name} mode',
        (tester) async {
      await pumpKeys(
        tester,
        width: 320,
        textScale: 4,
        brightness: brightness,
      );

      for (final label in slotLabels) {
        final rect = tester.getRect(find.bySemanticsLabel(label));
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(320.01));
        expect(rect.height, 48);
      }
      for (final label in labels) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.byIcon(Icons.keyboard_hide), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('non-modifier keys send the matching terminal key',
      (tester) async {
    final sent = <TerminalKey>[];
    await pumpKeys(tester, onKey: sent.add);

    for (final label in labels
        .where((label) => label != 'CTRL' && label != 'ALT' && label != '-')) {
      await tester.tap(find.text(label));
    }

    expect(sent, [
      TerminalKey.escape,
      TerminalKey.tab,
      TerminalKey.home,
      TerminalKey.end,
      TerminalKey.pageUp,
      TerminalKey.arrowLeft,
      TerminalKey.arrowDown,
      TerminalKey.arrowUp,
      TerminalKey.arrowRight,
      TerminalKey.pageDown,
    ]);
  });

  testWidgets('minus sends literal text and hide invokes only its callback',
      (tester) async {
    final text = <String>[];
    final keys = <TerminalKey>[];
    var hides = 0;
    var modifierTaps = 0;
    await pumpKeys(
      tester,
      onText: text.add,
      onKey: keys.add,
      onHideKeyboard: () => hides++,
      onToggleCtrl: () => modifierTaps++,
      onToggleAlt: () => modifierTaps++,
    );

    await tester.tap(find.text('-'));
    expect(text, ['-']);
    expect(hides, 0);
    await tester.tap(find.byIcon(Icons.keyboard_hide));
    expect(hides, 1);
    expect(text, ['-']);
    expect(keys, isEmpty);
    expect(modifierTaps, 0);
    expect(find.byTooltip('Hide'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Hide')),
      matchesSemantics(
        label: 'Hide',
        textDirection: TextDirection.ltr,
        isButton: true,
        hasTapAction: true,
      ),
    );
  });

  testWidgets('modifier callbacks leave state ownership with the parent',
      (tester) async {
    var ctrlTaps = 0;
    var altTaps = 0;
    final sent = <TerminalKey>[];
    await pumpKeys(
      tester,
      onToggleCtrl: () => ctrlTaps++,
      onToggleAlt: () => altTaps++,
      onKey: sent.add,
    );
    await tester.tap(find.text('CTRL'));
    await tester.tap(find.text('ALT'));
    await tester.pump();

    expect(ctrlTaps, 1);
    expect(altTaps, 1);
    expect(sent, isEmpty);
    for (final label in ['CTRL', 'ALT']) {
      expect(
        tester.getSemantics(find.bySemanticsLabel(label)),
        matchesSemantics(
          label: label,
          textDirection: TextDirection.ltr,
          isButton: true,
          hasToggledState: true,
          hasTapAction: true,
        ),
      );
    }

    await pumpKeys(tester, ctrlPressed: true, altPressed: true);

    for (final label in ['CTRL', 'ALT']) {
      expect(
        tester.getSemantics(find.bySemanticsLabel(label)),
        matchesSemantics(
          label: label,
          textDirection: TextDirection.ltr,
          isButton: true,
          hasToggledState: true,
          isToggled: true,
          hasTapAction: true,
        ),
      );
    }
  });

  testWidgets('tapping input keys retains terminal focus and the soft keyboard',
      (tester) async {
    final terminalFocus = FocusNode();
    addTearDown(terminalFocus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocale.localizationsDelegates,
        supportedLocales: AppLocale.supportedLocales,
        home: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: TerminalView(
                  Terminal(),
                  focusNode: terminalFocus,
                  autofocus: true,
                ),
              ),
              TerminalExtraKeys(
                ctrlPressed: false,
                altPressed: false,
                onToggleCtrl: () {},
                onToggleAlt: () {},
                onKey: (_) {},
                onText: (_) {},
                onHideKeyboard: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(terminalFocus.hasFocus, isTrue);
    expect(tester.testTextInput.isVisible, isTrue);

    for (final label in labels) {
      await tester.tap(find.text(label));
      await tester.pump();
      expect(terminalFocus.hasFocus, isTrue, reason: label);
      expect(tester.testTextInput.isVisible, isTrue, reason: label);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
