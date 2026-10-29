import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_tabs/src/playground.dart';

void main() {
  group('PlaygroundTab', () {
    test('extends TabItem', () {
      final tab = PlaygroundTab();
      expect(tab, isA<TabItem>());
    });

    test('title is set to Playground text', () {
      final tab = PlaygroundTab();
      final titleWidget = tab.title.value;
      expect(titleWidget, isA<Text>());
      expect((titleWidget as Text).data, equals('Playground'));
    });

    test('content is set to PlaygroundView', () {
      final tab = PlaygroundTab();
      expect(tab.content.value, isA<PlaygroundView>());
    });

    test('creates new instance each time', () {
      final tab1 = PlaygroundTab();
      final tab2 = PlaygroundTab();
      expect(tab1, isNot(same(tab2)));
    });

    test('each instance has separate title ValueNotifier', () {
      final tab1 = PlaygroundTab();
      final tab2 = PlaygroundTab();
      expect(tab1.title, isNot(same(tab2.title)));
    });

    test('each instance has separate content ValueNotifier', () {
      final tab1 = PlaygroundTab();
      final tab2 = PlaygroundTab();
      expect(tab1.content, isNot(same(tab2.content)));
    });
  });

  group('PlaygroundView', () {
    test('is a StatefulWidget', () {
      const view = PlaygroundView();
      expect(view, isA<StatefulWidget>());
    });

    test('can be const constructed', () {
      const PlaygroundView view = PlaygroundView();
      expect(view, isNotNull);
    });

    test('can have a key', () {
      final key = UniqueKey();
      final view = PlaygroundView(key: key);
      expect(view.key, equals(key));
    });

    test('creates state', () {
      const view = PlaygroundView();
      expect(view.createState(), isA<State<PlaygroundView>>());
    });

    test('state can be created multiple times', () {
      const view = PlaygroundView();
      final state1 = view.createState();
      final state2 = view.createState();
      expect(state1, isNot(same(state2)));
    });
  });

  group('PlaygroundView widget', () {
    testWidgets('renders Stack', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PlaygroundView()));

      expect(find.byType(Stack), findsOneWidget);
    });

    testWidgets('renders SizedBox with 300x300', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PlaygroundView()));

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, equals(300));
      expect(sizedBox.height, equals(300));
    });

    testWidgets('renders Hello text', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PlaygroundView()));

      expect(find.text('Hello'), findsOneWidget);
    });
  });
}
