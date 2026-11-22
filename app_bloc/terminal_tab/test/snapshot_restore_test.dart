import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';

void main() {
  late TerminalTabBloc bloc;
  Future<TerminalTabLoaded> apply(TerminalTabEvent event) async {
    final next = bloc.stream.first;
    bloc.add(event);
    return await next as TerminalTabLoaded;
  }

  setUp(() async {
    bloc = TerminalTabBloc();
    await apply(TerminalTabStart());
  });
  tearDown(() async {
    for (final tab in (bloc.state as TerminalTabLoaded).allTabs.toList()) {
      tab.dispose();
    }
    await bloc.close();
  });
  test('workspace replacement publishes exactly one complete layout', () async {
    final old = TabItem();
    await apply(TerminalTabOpenTab(old));
    final first = TabItem(), second = TabItem();
    final emitted = <TerminalTabState>[];
    final subscription = bloc.stream.listen(emitted.add);
    final state = await apply(TerminalTabApplySnapshot(
        tabs: [first, second],
        activeIndex: 1,
        grouping: TabGrouping(
            groups: [const TabGroup(id: 'new', name: 'API')],
            membership: {first: 'new'})));
    expect(state.allTabs, [first, second]);
    expect(state.activeTab, second);
    expect(state.grouping.groupOf(first)?.name, 'API');
    expect(old.parent, isNull);
    expect(emitted, hasLength(1));
    await subscription.cancel();
  });
  test('group replacement keeps tabs in other groups and can append', () async {
    final old = TabItem(), kept = TabItem();
    await apply(TerminalTabOpenTab(old));
    await apply(TerminalTabOpenTab(kept));
    await apply(TerminalTabCreateGroup(old.hashCode.toString(), 'old'));
    final id = (bloc.state as TerminalTabLoaded).grouping.groupIdOf(old)!;
    final restored = TabItem();
    final state = await apply(TerminalTabApplySnapshot(
        tabs: [restored],
        groupOnly: true,
        targetGroupId: id,
        grouping: TabGrouping(
            groups: [const TabGroup(id: 'fresh', name: 'saved')],
            membership: {restored: 'fresh'})));
    expect(state.allTabs, [kept, restored]);
    expect(state.grouping.groups.single.id, 'fresh');
    final appended = TabItem();
    expect(
        (await apply(TerminalTabApplySnapshot(
                tabs: [appended], grouping: const TabGrouping(), append: true)))
            .allTabs,
        [kept, restored, appended]);
  });
  test('retry preserves membership without duplicate group records', () async {
    final failed = TabItem(), sibling = TabItem();
    await apply(TerminalTabOpenTab(failed));
    await apply(TerminalTabOpenTab(sibling));
    await apply(TerminalTabCreateGroup(failed.hashCode.toString(), 'API'));
    final group = (bloc.state as TerminalTabLoaded).grouping.groups.single;
    await apply(TerminalTabMoveToGroup(sibling.hashCode.toString(), group.id));
    final retry = TabItem();
    final state = await apply(TerminalTabApplySnapshot(
        tabs: [retry],
        replaceTab: failed,
        grouping: TabGrouping(groups: [group], membership: {retry: group.id})));
    expect(state.grouping.groups, [group]);
    expect(state.grouping.groupIdOf(retry), group.id);
    expect(state.grouping.groupIdOf(sibling), group.id);
  });
}
