import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_tabs/src/add_host_tab.dart';

void main() {
  group('AddHostTab', () {
    test('extends TabItem', () {
      final tab = AddHostTab();
      expect(tab, isA<TabItem>());
    });

    test('title is set to Connect text', () {
      final tab = AddHostTab();
      final titleWidget = tab.title.value;
      expect(titleWidget, isA<Text>());
      expect((titleWidget as Text).data, equals('Connect'));
    });

    test('content is set to AddHostTabView', () {
      final tab = AddHostTab();
      expect(tab.content.value, isA<AddHostTabView>());
    });

    test('creates new instance each time', () {
      final tab1 = AddHostTab();
      final tab2 = AddHostTab();
      expect(tab1, isNot(same(tab2)));
    });

    test('each instance has separate title ValueNotifier', () {
      final tab1 = AddHostTab();
      final tab2 = AddHostTab();
      expect(tab1.title, isNot(same(tab2.title)));
    });

    test('each instance has separate content ValueNotifier', () {
      final tab1 = AddHostTab();
      final tab2 = AddHostTab();
      expect(tab1.content, isNot(same(tab2.content)));
    });
  });

  group('AddHostTabView', () {
    test('is a StatefulWidget', () {
      const view = AddHostTabView();
      expect(view, isA<StatefulWidget>());
    });

    test('can be const constructed', () {
      const AddHostTabView view = AddHostTabView();
      expect(view, isNotNull);
    });

    test('can have a key', () {
      final key = UniqueKey();
      final view = AddHostTabView(key: key);
      expect(view.key, equals(key));
    });

    test('creates state', () {
      const view = AddHostTabView();
      expect(view.createState(), isA<State<AddHostTabView>>());
    });

    test('state can be created multiple times', () {
      const view = AddHostTabView();
      final state1 = view.createState();
      final state2 = view.createState();
      expect(state1, isNot(same(state2)));
    });
  });
}
