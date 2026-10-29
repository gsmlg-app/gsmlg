import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_tabs/src/context_menu.dart';

void main() {
  group('DropdownContextMenu', () {
    test('is a StatefulWidget', () {
      final tabs = Tabs();
      final menu = DropdownContextMenu(tabs);
      expect(menu, isA<StatefulWidget>());
    });

    test('stores tabs reference', () {
      final tabs = Tabs();
      final menu = DropdownContextMenu(tabs);
      expect(menu.tabs, same(tabs));
    });

    test('can be constructed with key', () {
      final tabs = Tabs();
      final key = UniqueKey();
      final menu = DropdownContextMenu(tabs, key: key);
      expect(menu.key, equals(key));
    });

    test('creates state', () {
      final tabs = Tabs();
      final menu = DropdownContextMenu(tabs);
      expect(menu.createState(), isA<DropdownContextMenuState>());
    });

    test('state can be created multiple times', () {
      final tabs = Tabs();
      final menu = DropdownContextMenu(tabs);
      final state1 = menu.createState();
      final state2 = menu.createState();
      expect(state1, isNot(same(state2)));
    });

    test('each widget instance has different tabs', () {
      final tabs1 = Tabs();
      final tabs2 = Tabs();
      final menu1 = DropdownContextMenu(tabs1);
      final menu2 = DropdownContextMenu(tabs2);
      expect(menu1.tabs, isNot(same(menu2.tabs)));
    });

    test('empty tabs container is accepted', () {
      final tabs = Tabs();
      expect(tabs.children, isEmpty);
      final menu = DropdownContextMenu(tabs);
      expect(menu.tabs.children, isEmpty);
    });

    test('tabs with children is accepted', () {
      final tabs = Tabs();
      tabs.add(
        TabItem()
          ..title.value = const Text('Tab 1')
          ..content.value = const Text('Content 1'),
      );
      tabs.add(
        TabItem()
          ..title.value = const Text('Tab 2')
          ..content.value = const Text('Content 2'),
      );

      final menu = DropdownContextMenu(tabs);
      expect(menu.tabs.children.length, equals(2));
    });
  });

  group('DropdownContextMenuState', () {
    test('type is DropdownContextMenuState', () {
      final tabs = Tabs();
      final menu = DropdownContextMenu(tabs);
      final state = menu.createState();
      expect(state.runtimeType.toString(), equals('DropdownContextMenuState'));
    });

    test('creates fresh state for each instance', () {
      final tabs = Tabs();
      final menu = DropdownContextMenu(tabs);
      final state1 = menu.createState();
      final state2 = menu.createState();
      expect(identical(state1, state2), isFalse);
    });
  });

  group('Tabs integration', () {
    test('Tabs can be empty', () {
      final tabs = Tabs();
      expect(tabs.children, isEmpty);
    });

    test('Tabs can have children', () {
      final tabs = Tabs();
      final tabItem = TabItem();
      tabs.add(tabItem);
      expect(tabs.children, contains(tabItem));
    });

    test('Tabs can have active tab', () {
      final tabs = Tabs();
      final tabItem = TabItem()
        ..title.value = const Text('Active')
        ..content.value = const Text('Content');
      tabs.add(tabItem);
      tabItem.activate();
      expect(tabs.activeTab, same(tabItem));
    });
  });
}
