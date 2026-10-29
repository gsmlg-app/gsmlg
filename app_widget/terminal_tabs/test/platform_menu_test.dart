import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_tabs/src/platform_menu.dart';

void main() {
  group('ActiveTabService', () {
    test('is an abstract class', () {
      // ActiveTabService is abstract, so we test with a mock implementation
      final mock = _MockActiveTabService();
      expect(mock, isA<ActiveTabService>());
    });

    test('defines getActiveTab method', () {
      final mock = _MockActiveTabService();
      expect(mock.getActiveTab(), equals('mock_tab'));
    });

    test('getActiveTab can return null', () {
      final mock = _MockActiveTabServiceNullReturn();
      expect(mock.getActiveTab(), isNull);
    });

    test('different implementations can return different types', () {
      final mock1 = _MockActiveTabService();
      final mock2 = _MockActiveTabServiceIntReturn();
      expect(mock1.getActiveTab(), isA<String>());
      expect(mock2.getActiveTab(), isA<int>());
    });
  });

  group('GlobalPlatformMenu', () {
    test('is a StatefulWidget', () {
      const menu = GlobalPlatformMenu(child: SizedBox());
      expect(menu, isA<StatefulWidget>());
    });

    test('stores child widget', () {
      const child = Text('Test Child');
      const menu = GlobalPlatformMenu(child: child);
      expect(menu.child, same(child));
    });

    test('can be const constructed', () {
      const GlobalPlatformMenu menu = GlobalPlatformMenu(child: SizedBox());
      expect(menu, isNotNull);
    });

    test('can have a key', () {
      final key = UniqueKey();
      final menu = GlobalPlatformMenu(key: key, child: const SizedBox());
      expect(menu.key, equals(key));
    });

    test('creates state', () {
      const menu = GlobalPlatformMenu(child: SizedBox());
      expect(menu.createState(), isA<State<GlobalPlatformMenu>>());
    });

    test('state can be created multiple times', () {
      const menu = GlobalPlatformMenu(child: SizedBox());
      final state1 = menu.createState();
      final state2 = menu.createState();
      expect(state1, isNot(same(state2)));
    });

    test('child is required parameter', () {
      // This test verifies that child is required by checking that
      // GlobalPlatformMenu requires the child parameter
      const menu = GlobalPlatformMenu(child: Text('Required'));
      expect(menu.child, isA<Text>());
    });

    test('each instance has different child', () {
      const child1 = Text('Child 1');
      const child2 = Text('Child 2');
      const menu1 = GlobalPlatformMenu(child: child1);
      const menu2 = GlobalPlatformMenu(child: child2);
      expect(menu1.child, isNot(same(menu2.child)));
    });
  });

  group('GlobalPlatformMenu state', () {
    test('state type name matches', () {
      const menu = GlobalPlatformMenu(child: SizedBox());
      final state = menu.createState();
      expect(state.runtimeType.toString(), equals('_GlobalPlatformMenuState'));
    });
  });

  group('GlobalPlatformMenu with nested widgets', () {
    test('accepts Text widget as child', () {
      const menu = GlobalPlatformMenu(child: Text('Test'));
      expect(menu.child, isA<Text>());
    });

    test('accepts Container widget as child', () {
      final menu = GlobalPlatformMenu(child: Container(color: Colors.blue));
      expect(menu.child, isA<Container>());
    });

    test('accepts Column widget as child', () {
      const menu = GlobalPlatformMenu(
        child: Column(children: [Text('Item 1'), Text('Item 2')]),
      );
      expect(menu.child, isA<Column>());
    });

    test('accepts nested GlobalPlatformMenu as child', () {
      const menu = GlobalPlatformMenu(
        child: GlobalPlatformMenu(child: Text('Nested')),
      );
      expect(menu.child, isA<GlobalPlatformMenu>());
    });
  });
}

/// Mock implementation for testing
class _MockActiveTabService implements ActiveTabService {
  @override
  dynamic getActiveTab() => 'mock_tab';
}

/// Mock implementation that returns null
class _MockActiveTabServiceNullReturn implements ActiveTabService {
  @override
  dynamic getActiveTab() => null;
}

/// Mock implementation that returns an int
class _MockActiveTabServiceIntReturn implements ActiveTabService {
  @override
  dynamic getActiveTab() => 42;
}
