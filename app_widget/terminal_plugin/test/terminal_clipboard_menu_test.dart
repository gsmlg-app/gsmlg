import 'package:app_locale/app_locale.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_plugin/terminal_plugin.dart';
import 'package:xterm/xterm.dart';

import 'terminal_plugin_test.dart' show MockHostSpec, MockExecutionSession;

void main() {
  late TerminalPlugin plugin;
  late PluginManager manager;
  late List<String> copies;
  late List<String> input;
  late bool allowed;

  setUp(() {
    copies = [];
    input = [];
    allowed = true;
    plugin = TerminalPlugin(remoteClipboardWritesAllowed: () => allowed);
    manager = PluginManager(MockHostSpec());
    manager.add(plugin);
    plugin.debugAttachSession(MockExecutionSession());
    plugin.terminal.onOutput = input.add;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copies.add((call.arguments as Map)['text'] as String);
      }
      if (call.method == 'Clipboard.getData') return {'text': 'local\ntext'};
      return null;
    });
  });

  tearDown(() {
    if (plugin.mounted) manager.remove(plugin);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<void> pumpTerminal(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocale.localizationsDelegates,
      supportedLocales: AppLocale.supportedLocales,
      home: Scaffold(
        appBar: AppBar(actions: [TerminalClipboardMenu(plugin: plugin)]),
        body: TerminalTabView(plugin),
      ),
    ));
    await tester.pump();
    plugin.terminal.write('hello world');
    plugin.terminal.flush();
    await tester.pump();
  }

  Finder checkedItem(String label) => find
      .ancestor(
        of: find.text(label),
        matching:
            find.byWidgetPredicate((widget) => widget is CheckedPopupMenuItem),
      )
      .first;

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Terminal clipboard and selection'));
    await tester.pumpAndSettle();
  }

  testWidgets('native menu copies selection and pastes with bracketed paste',
      (tester) async {
    await pumpTerminal(tester);
    plugin.terminalController.setSelection(
      plugin.terminal.buffer.createAnchor(0, 0),
      plugin.terminal.buffer.createAnchor(5, 0),
    );
    allowed = false;
    await openMenu(tester);
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();
    expect(copies, ['hello']);
    expect(input, isEmpty);

    plugin.terminal.write('\x1b[?2004h');
    plugin.terminal.flush();
    await openMenu(tester);
    await tester.tap(find.text('Paste'));
    await tester.pumpAndSettle();
    expect(input, ['\x1b[200~local\rtext\x1b[201~']);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('session trust defaults on and can be revoked and restored',
      (tester) async {
    await pumpTerminal(tester);
    await openMenu(tester);
    expect(
        tester
            .widget<CheckedPopupMenuItem>(
                checkedItem("Revoke this session's clipboard access"))
            .checked,
        isTrue);
    await tester.tap(checkedItem("Revoke this session's clipboard access"));
    await tester.pumpAndSettle();
    expect(plugin.remoteClipboard.trusted, isFalse);
    await openMenu(tester);
    await tester.tap(checkedItem('Trust this session for clipboard writes'));
    await tester.pumpAndSettle();
    expect(plugin.remoteClipboard.trusted, isTrue);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('global setting blocks session trust until enabled',
      (tester) async {
    await pumpTerminal(tester);
    allowed = false;
    await openMenu(tester);
    expect(
        tester
            .widget<CheckedPopupMenuItem>(
                checkedItem('Trust this session for clipboard writes'))
            .enabled,
        isFalse);
    expect(plugin.remoteClipboard.trusted, isFalse);
    await tester.tapAt(const Offset(1, 1));
    await tester.pumpAndSettle();

    allowed = true;
    await openMenu(tester);
    expect(plugin.remoteClipboard.trusted, isTrue);
    await tester.tap(checkedItem("Revoke this session's clipboard access"));
    await tester.pumpAndSettle();
    expect(plugin.remoteClipboard.trusted, isFalse);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('select text menu permits local drag while TUI mouse mode is on',
      (tester) async {
    await pumpTerminal(tester);
    plugin.terminal.write('\x1b[?1002h\x1b[?1006h');
    plugin.terminal.flush();
    await openMenu(tester);
    await tester.tap(checkedItem('Select text (pause mouse reporting)'));
    await tester.pumpAndSettle();
    expect(plugin.terminalController.suspendedPointerInputs, isTrue);
    final render = tester
        .state<TerminalViewState>(find.byType(TerminalView))
        .renderTerminal;
    Offset cell(int x) => render.localToGlobal(
          render.getOffset(CellOffset(x, 0)) +
              render.cellSize.center(Offset.zero),
        );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.down(cell(0));
    await mouse.moveTo(cell(8));
    await mouse.moveTo(cell(10));
    await mouse.up();
    await tester.pumpAndSettle();
    expect(plugin.terminalController.selection, isNotNull);
    expect(input, isEmpty);
    await openMenu(tester);
    await tester.tap(checkedItem('Select text (pause mouse reporting)'));
    await tester.pumpAndSettle();
    expect(plugin.terminalController.suspendedPointerInputs, isFalse);
    final history = plugin.terminal.buffer.getText();
    await tester.tapAt(cell(3));
    await tester.pumpAndSettle();
    expect(input, isNotEmpty);
    expect(plugin.terminal.buffer.getText(), history);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('native copy shortcut and paste shortcut preserve terminal input',
      (tester) async {
    await pumpTerminal(tester);
    plugin.terminalController.setSelection(
      plugin.terminal.buffer.createAnchor(0, 0),
      plugin.terminal.buffer.createAnchor(5, 0),
    );
    final apple = defaultTargetPlatform == TargetPlatform.macOS;
    final modifier =
        apple ? LogicalKeyboardKey.metaLeft : LogicalKeyboardKey.controlLeft;
    await tester.sendKeyDownEvent(modifier);
    if (!apple) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
    if (!apple) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyUpEvent(modifier);
    await tester.pump();
    expect(copies, ['hello']);
    expect(input, ['local\rtext']);
    input.clear();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    expect(input, ['\x03']);
  },
      variant: const TargetPlatformVariant({
        TargetPlatform.macOS,
        TargetPlatform.linux,
        TargetPlatform.windows,
      }));
}
