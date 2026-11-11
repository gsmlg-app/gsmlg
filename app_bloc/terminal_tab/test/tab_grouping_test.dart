import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';

void main() {
  late TabItem a;
  late TabItem b;
  late TabItem c;

  setUp(() {
    a = TabItem();
    b = TabItem();
    c = TabItem();
  });

  List<String> ids(TabGrouping grouping) =>
      grouping.groups.map((TabGroup group) => group.id).toList();

  group('TabGrouping', () {
    test('createGroup adds the group and assigns the tab', () {
      final grouping = const TabGrouping().createGroup(
        id: 'g1',
        name: 'web',
        tab: a,
      );

      expect(grouping.groups.single, const TabGroup(id: 'g1', name: 'web'));
      expect(grouping.groupIdOf(a), 'g1');
      expect(grouping.groupOf(a)?.name, 'web');
    });

    test('createGroup trims the name and rejects blank', () {
      const original = TabGrouping();

      final trimmed = original.createGroup(id: 'g1', name: '  web  ', tab: a);
      final blank = original.createGroup(id: 'g1', name: '   ', tab: a);

      expect(trimmed.groups.single.name, 'web');
      expect(blank, same(original));
    });

    test('assign moves a tab and deletes the emptied group', () {
      final grouping = const TabGrouping()
          .createGroup(id: 'g1', name: 'one', tab: a)
          .createGroup(id: 'g2', name: 'two', tab: b)
          .assign(a, 'g2');

      expect(ids(grouping), ['g2']);
      expect(grouping.groupIdOf(a), 'g2');
      expect(grouping.groupIdOf(b), 'g2');
    });

    test('assign null ungroups and deletes the emptied group', () {
      final grouping = const TabGrouping()
          .createGroup(id: 'g1', name: 'one', tab: a)
          .assign(a, null);

      expect(grouping.groupIdOf(a), isNull);
      expect(grouping.groups, isEmpty);
    });

    test('assign to unknown id is a no-op', () {
      final original = const TabGrouping().createGroup(
        id: 'g1',
        name: 'one',
        tab: a,
      );

      expect(original.assign(b, 'missing'), same(original));
    });

    test('renameGroup trims and ignores blank', () {
      final original = const TabGrouping().createGroup(
        id: 'g1',
        name: 'one',
        tab: a,
      );

      expect(original.renameGroup('g1', '  api ').groups.single.name, 'api');
      expect(original.renameGroup('g1', '  '), same(original));
    });

    test('toggleCollapsed flips one group, and null flips ungrouped', () {
      final original = const TabGrouping()
          .createGroup(id: 'g1', name: 'one', tab: a)
          .createGroup(id: 'g2', name: 'two', tab: b);

      final toggled = original.toggleCollapsed('g1');
      expect(toggled.groupById('g1')!.collapsed, isTrue);
      expect(toggled.groupById('g2')!.collapsed, isFalse);
      expect(toggled.ungroupedCollapsed, isFalse);

      final ungrouped = original.toggleCollapsed(null);
      expect(ungrouped.ungroupedCollapsed, isTrue);
      expect(ungrouped.groupById('g1')!.collapsed, isFalse);
    });

    test('retainTabs drops closed tabs and empty groups', () {
      final grouping = const TabGrouping()
          .createGroup(id: 'g1', name: 'one', tab: a)
          .createGroup(id: 'g2', name: 'two', tab: b)
          .assign(c, 'g2')
          .retainTabs(<TabItem>[c]);

      expect(ids(grouping), ['g2']);
      expect(grouping.groupIdOf(a), isNull);
      expect(grouping.groupIdOf(b), isNull);
      expect(grouping.groupIdOf(c), 'g2');
    });

    test('retainTabs returns the same instance when nothing changes', () {
      final original = const TabGrouping().createGroup(
        id: 'g1',
        name: 'one',
        tab: a,
      );

      expect(original.retainTabs(<TabItem>[a, b]), same(original));
    });

    test('operations never reorder remaining groups', () {
      final grouping = const TabGrouping()
          .createGroup(id: 'g1', name: 'one', tab: a)
          .createGroup(id: 'g2', name: 'two', tab: b)
          .createGroup(id: 'g3', name: 'three', tab: c)
          .assign(b, null);

      expect(ids(grouping), ['g1', 'g3']);
    });
  });
}
