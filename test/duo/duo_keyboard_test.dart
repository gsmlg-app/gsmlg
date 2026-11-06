import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/duo/duo_keyboard.dart';

void main() {
  group('keyboard config codec', () {
    test('round-trips input type, action and flags', () {
      const config = TextInputConfiguration(
        inputType: TextInputType.multiline,
        inputAction: TextInputAction.newline,
        autocorrect: false,
        enableSuggestions: false,
        textCapitalization: TextCapitalization.sentences,
      );
      final restored = decodeKeyboardConfig(encodeKeyboardConfig(config));
      expect(restored.inputType, TextInputType.multiline);
      expect(restored.inputAction, TextInputAction.newline);
      expect(restored.autocorrect, isFalse);
      expect(restored.enableSuggestions, isFalse);
      expect(restored.textCapitalization, TextCapitalization.sentences);
    });

    test('keeps number options', () {
      final config = TextInputConfiguration(
        inputType: const TextInputType.numberWithOptions(decimal: true),
      );
      final restored = decodeKeyboardConfig(encodeKeyboardConfig(config));
      expect(
        restored.inputType,
        const TextInputType.numberWithOptions(decimal: true),
      );
    });
  });

  group('DuoKeyboardRouter', () {
    late List<Map<String, dynamic>> sent;
    late DuoKeyboardRouter router;

    setUp(() {
      sent = [];
      router = DuoKeyboardRouter(sent.add)..install();
    });

    tearDown(() => router.uninstall());

    testWidgets('takes over an already focused input connection', (
      tester,
    ) async {
      router.uninstall();
      final controller = TextEditingController(text: 'existing draft');
      final focusNode = FocusNode();
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TextField(controller: controller, focusNode: focusNode),
          ),
        ),
      );
      await tester.tap(find.byType(TextField));
      await tester.pump();
      controller.value = const TextEditingValue(
        text: 'existing draft',
        selection: TextSelection.collapsed(offset: 8),
        composing: TextRange(start: 0, end: 8),
      );
      await tester.pump();
      final value = controller.value;

      // ChannelBuffers runs its handler in the registration zone, outside
      // the widget test's fake clock. Let the platform reply complete there.
      await tester.runAsync(() async {
        router.install();
        await Future<void>.delayed(Duration.zero);
      });
      await tester.pump();

      final attach = sent.lastWhere(
        (message) => message['type'] == DuoKeyboardMessages.attach,
      );
      expect(attach['value'], value.toJSON());
      expect(focusNode.hasFocus, isTrue);
      expect(controller.value, value);
      expect(
        tester.testTextInput.setClientArgs!['inputType']['name'],
        'TextInputType.none',
      );

      router.handleMessage({
        'type': DuoKeyboardMessages.update,
        'session': attach['session'],
        'value': const TextEditingValue(text: 'remote edit').toJSON(),
      });
      await tester.pump();
      expect(controller.text, 'remote edit');

      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('restores the focused platform connection on disconnect', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'keep draft');
      final focusNode = FocusNode();
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(TextField));
      await tester.pump();
      controller.value = const TextEditingValue(
        text: 'keep draft',
        selection: TextSelection.collapsed(offset: 4),
        composing: TextRange(start: 0, end: 4),
      );
      await tester.pump();
      final value = controller.value;
      final oldSession = sent.lastWhere(
        (message) => message['type'] == DuoKeyboardMessages.attach,
      )['session'];

      await tester.runAsync(() async {
        router.uninstall();
        await Future<void>.delayed(Duration.zero);
      });
      await tester.pump();

      expect(
        tester.testTextInput.setClientArgs!['inputType']['name'],
        'TextInputType.multiline',
      );
      expect(tester.testTextInput.isVisible, isTrue);
      expect(focusNode.hasFocus, isTrue);
      expect(controller.value, value);
      tester.testTextInput.enterText('local edit');
      await tester.pump();
      expect(controller.text, 'local edit');

      await tester.runAsync(() async {
        router.install();
        await Future<void>.delayed(Duration.zero);
      });
      await tester.pump();
      final attach = sent.lastWhere(
        (message) => message['type'] == DuoKeyboardMessages.attach,
      );
      expect(attach['session'], isNot(oldSession));
      expect((attach['value'] as Map)['text'], 'local edit');
      router.handleMessage({
        'type': DuoKeyboardMessages.update,
        'session': oldSession,
        'value': const TextEditingValue(text: 'stale edit').toJSON(),
      });
      await tester.pump();
      expect(controller.text, 'local edit');

      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('mirrors a focused primary field to the secondary', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'ab');
      String? submitted;
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TextField(
              controller: controller,
              onSubmitted: (value) => submitted = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      final attach = sent.lastWhere(
        (m) => m['type'] == DuoKeyboardMessages.attach,
      );
      expect((attach['value'] as Map)['text'], 'ab');
      final session = attach['session'];

      router.handleMessage({
        'type': DuoKeyboardMessages.update,
        'session': session,
        'value': const TextEditingValue(
          text: 'abc',
          selection: TextSelection.collapsed(offset: 3),
        ).toJSON(),
      });
      await tester.pump();
      expect(controller.text, 'abc');

      sent.clear();
      controller.text = 'reset';
      await tester.pump();
      expect(
        sent.any(
          (m) =>
              m['type'] == DuoKeyboardMessages.state &&
              (m['value'] as Map)['text'] == 'reset',
        ),
        isTrue,
      );

      router.handleMessage({
        'type': DuoKeyboardMessages.action,
        'session': session,
        'action': TextInputAction.done.name,
      });
      await tester.pump();
      expect(submitted, 'reset');
    });

    testWidgets('ignores updates from a stale session', (tester) async {
      final controller = TextEditingController(text: 'keep');
      await tester.pumpWidget(
        MaterialApp(
          home: Material(child: TextField(controller: controller)),
        ),
      );
      await tester.tap(find.byType(TextField));
      await tester.pump();
      final session =
          sent.lastWhere(
                (m) => m['type'] == DuoKeyboardMessages.attach,
              )['session']
              as int;

      router.handleMessage({
        'type': DuoKeyboardMessages.update,
        'session': session - 1,
        'value': const TextEditingValue(text: 'stale').toJSON(),
      });
      await tester.pump();
      expect(controller.text, 'keep');
    });
  });

  group('DuoKeyboardProxy', () {
    for (final (name, value, expected)
        in <(String, TextEditingValue, TextEditingValue)>[
          (
            'last character',
            const TextEditingValue(
              text: 'example.comx',
              selection: TextSelection.collapsed(offset: 12),
            ),
            const TextEditingValue(
              text: 'example.com',
              selection: TextSelection.collapsed(offset: 11),
            ),
          ),
          (
            'character before the cursor',
            const TextEditingValue(
              text: 'abxcd',
              selection: TextSelection.collapsed(offset: 3),
            ),
            const TextEditingValue(
              text: 'abcd',
              selection: TextSelection.collapsed(offset: 2),
            ),
          ),
          (
            'reversed selection',
            const TextEditingValue(
              text: 'example.com',
              selection: TextSelection(baseOffset: 7, extentOffset: 0),
            ),
            const TextEditingValue(
              text: '.com',
              selection: TextSelection.collapsed(offset: 0),
            ),
          ),
          (
            'Chinese character',
            const TextEditingValue(
              text: '中文',
              selection: TextSelection.collapsed(offset: 2),
            ),
            const TextEditingValue(
              text: '中',
              selection: TextSelection.collapsed(offset: 1),
            ),
          ),
          (
            'joined emoji',
            TextEditingValue(
              text: 'x👨‍👩‍👧‍👦',
              selection: TextSelection.collapsed(offset: 'x👨‍👩‍👧‍👦'.length),
            ),
            const TextEditingValue(
              text: 'x',
              selection: TextSelection.collapsed(offset: 1),
            ),
          ),
          (
            'combining character',
            const TextEditingValue(
              text: 'xe\u0301',
              selection: TextSelection.collapsed(offset: 3),
            ),
            const TextEditingValue(
              text: 'x',
              selection: TextSelection.collapsed(offset: 1),
            ),
          ),
        ]) {
      testWidgets('relays Android backspace for $name', (tester) async {
        final sent = <Map<String, dynamic>>[];
        final proxy = DuoKeyboardProxy(sent.add);
        addTearDown(proxy.dispose);
        proxy.handleMessage({
          'type': DuoKeyboardMessages.attach,
          'session': 7,
          'config': encodeKeyboardConfig(const TextInputConfiguration()),
          'value': value.toJSON(),
        });

        expect(await tester.sendKeyEvent(LogicalKeyboardKey.backspace), isTrue);

        expect(proxy.currentTextEditingValue, expected);
        expect(sent, [
          {
            'type': DuoKeyboardMessages.update,
            'session': 7,
            'value': expected.toJSON(),
          },
        ]);
        expect(tester.testTextInput.editingState, expected.toJSON());
      });
    }

    testWidgets('handles held backspace without deleting again on key up', (
      tester,
    ) async {
      final sent = <Map<String, dynamic>>[];
      final proxy = DuoKeyboardProxy(sent.add);
      addTearDown(proxy.dispose);
      proxy.handleMessage({
        'type': DuoKeyboardMessages.attach,
        'session': 1,
        'config': encodeKeyboardConfig(const TextInputConfiguration()),
        'value': const TextEditingValue(
          text: 'abcd',
          selection: TextSelection.collapsed(offset: 4),
        ).toJSON(),
      });

      await tester.sendKeyDownEvent(LogicalKeyboardKey.backspace);
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.backspace);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.backspace);
      expect(proxy.currentTextEditingValue?.text, 'ab');
      expect(sent.map((m) => (m['value'] as Map)['text']), ['abc', 'ab']);

      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      expect(sent, hasLength(2));
      proxy.close();
      expect(await tester.sendKeyEvent(LogicalKeyboardKey.backspace), isFalse);
      expect(sent, hasLength(2));
    });

    testWidgets('consumes backspace at the start without changing the value', (
      tester,
    ) async {
      final sent = <Map<String, dynamic>>[];
      final proxy = DuoKeyboardProxy(sent.add);
      addTearDown(proxy.dispose);
      proxy.handleMessage({
        'type': DuoKeyboardMessages.attach,
        'session': 1,
        'config': encodeKeyboardConfig(const TextInputConfiguration()),
        'value': const TextEditingValue(
          text: 'keep',
          selection: TextSelection.collapsed(offset: 0),
        ).toJSON(),
      });

      expect(await tester.sendKeyEvent(LogicalKeyboardKey.backspace), isTrue);
      expect(proxy.currentTextEditingValue?.text, 'keep');
      expect(sent, isEmpty);
    });

    testWidgets('forwards IME edits and actions with the session', (
      tester,
    ) async {
      final sent = <Map<String, dynamic>>[];
      final proxy = DuoKeyboardProxy(sent.add);
      addTearDown(proxy.dispose);

      proxy.handleMessage({
        'type': DuoKeyboardMessages.attach,
        'session': 7,
        'config': encodeKeyboardConfig(const TextInputConfiguration()),
        'value': const TextEditingValue(text: 'hi').toJSON(),
      });
      expect(proxy.active, isTrue);
      expect(proxy.currentTextEditingValue?.text, 'hi');

      proxy.updateEditingValue(const TextEditingValue(text: 'hi!'));
      proxy.performAction(TextInputAction.send);
      expect(sent, [
        {
          'type': DuoKeyboardMessages.update,
          'session': 7,
          'value': const TextEditingValue(text: 'hi!').toJSON(),
        },
        {'type': DuoKeyboardMessages.action, 'session': 7, 'action': 'send'},
      ]);

      proxy.handleMessage({'type': DuoKeyboardMessages.detach, 'session': 6});
      expect(proxy.active, isTrue);
      proxy.handleMessage({'type': DuoKeyboardMessages.detach, 'session': 7});
      expect(proxy.active, isFalse);
    });
  });
}
