import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/widgets.dart';

part 'event.dart';
part 'state.dart';
part 'tab_grouping.dart';

abstract interface class TerminalTabTitleRenamer {
  void renameTitle(String title);
}

class TerminalTabBloc extends Bloc<TerminalTabEvent, TerminalTabState> {
  TerminalTabBloc({String Function()? groupIdGenerator})
      : _groupIdGenerator = groupIdGenerator ?? _defaultGroupIdGenerator,
        super(TerminalTabInitial()) {
    on<TerminalTabStart>(_onTerminalTabStart);
    on<TerminalTabStop>(_onTerminalTabStop);
    on<TerminalTabOpenTab>(_onTerminalTabOpenTab);
    on<TerminalTabToggleFullscreen>(_onTerminalTabToggleFullscreen);
    on<TerminalTabSelectSession>(_onTerminalTabSelectSession);
    on<TerminalTabCloseSession>(_onTerminalTabCloseSession);
    on<TerminalTabReorderSessions>(_onTerminalTabReorderSessions);
    on<TerminalTabRenameSession>(_onTerminalTabRenameSession);
    on<TerminalTabNextTab>(_onTerminalTabNextTab);
    on<TerminalTabPreviousTab>(_onTerminalTabPreviousTab);
    on<TerminalTabGoToTab>(_onTerminalTabGoToTab);
    on<TerminalTabCreateGroup>(_onCreateGroup);
    on<TerminalTabMoveToGroup>(_onMoveToGroup);
    on<TerminalTabUngroup>(_onUngroup);
    on<TerminalTabMoveSessionsToGroup>(_onMoveSessionsToGroup);
    on<TerminalTabCreateGroupWithSessions>(_onCreateGroupWithSessions);
    on<TerminalTabUngroupSessions>(_onUngroupSessions);
    on<TerminalTabRenameGroup>(_onRenameGroup);
    on<TerminalTabToggleGroupCollapsed>(_onToggleGroupCollapsed);
    on<TerminalTabMoveTabBefore>(_onMoveTabBefore);
    on<TerminalTabRestoreGroups>(_onRestoreGroups);
    on<TerminalTabFinishGroupRestore>(_onFinishGroupRestore);
  }

  final String Function() _groupIdGenerator;

  static int _groupIdCounter = 0;

  static String _defaultGroupIdGenerator() =>
      'g${DateTime.now().microsecondsSinceEpoch}-${_groupIdCounter++}';

  void _onTerminalTabStart(
    TerminalTabStart event,
    Emitter<TerminalTabState> emit,
  ) {
    if (state is TerminalTabLoaded) {
      emit((state as TerminalTabLoaded).copyWith(isMounted: true));
    } else {
      final tabs = Tabs();
      final tabsDocument = TabsDocument();
      tabsDocument.setRoot(tabs);
      emit(TerminalTabLoaded(
        tabs: tabs,
        tabsDocument: tabsDocument,
        isMounted: true,
      ));
    }
  }

  void _onTerminalTabStop(
    TerminalTabStop event,
    Emitter<TerminalTabState> emit,
  ) {
    if (state is TerminalTabLoaded) {
      emit((state as TerminalTabLoaded).copyWith(isMounted: false));
    } else {
      emit(TerminalTabInitial());
    }
  }

  void _onTerminalTabOpenTab(
      TerminalTabOpenTab event, Emitter<TerminalTabState> emit) {
    if (state is TerminalTabLoaded) {
      final currentState = state as TerminalTabLoaded;
      currentState.tabs.add(event.tabItem);
      if (event.activate) {
        event.tabItem.activate();
      }
      final groupId = event.groupId;
      emit(currentState.copyWith(
        grouping: groupId == null
            ? null
            : currentState.grouping.assign(
                event.tabItem,
                groupId,
                keepEmptyGroups: true,
              ),
        incrementVersion: true,
      ));
    }
  }

  void _onTerminalTabToggleFullscreen(
    TerminalTabToggleFullscreen event,
    Emitter<TerminalTabState> emit,
  ) {
    if (state is TerminalTabLoaded) {
      final currentState = state as TerminalTabLoaded;
      emit(currentState.copyWith(isFullscreen: !currentState.isFullscreen));
    }
  }

  void _onTerminalTabSelectSession(
    TerminalTabSelectSession event,
    Emitter<TerminalTabState> emit,
  ) {
    if (state is TerminalTabLoaded) {
      final currentState = state as TerminalTabLoaded;
      // Find the tab with matching ID and activate it
      final tabItem = _findTabById(currentState.tabs, event.sessionId);
      if (tabItem != null) {
        tabItem.activate();
        emit(currentState.copyWith(incrementVersion: true));
      }
    }
  }

  void _onTerminalTabCloseSession(
    TerminalTabCloseSession event,
    Emitter<TerminalTabState> emit,
  ) {
    if (state is TerminalTabLoaded) {
      final currentState = state as TerminalTabLoaded;
      // Find and close the tab with matching ID
      final tabItem = _findTabById(currentState.tabs, event.sessionId);
      if (tabItem != null) {
        tabItem.dispose();
        emit(currentState.copyWith(incrementVersion: true));
      }
    }
  }

  void _onTerminalTabReorderSessions(
    TerminalTabReorderSessions event,
    Emitter<TerminalTabState> emit,
  ) {
    if (state is! TerminalTabLoaded) return;
    final currentState = state as TerminalTabLoaded;
    final children = currentState.tabs.children;

    if (event.sessionIds.length != children.length) return;

    final tabsById = <String, TabItem>{
      for (final child in children) child.hashCode.toString(): child,
    };
    if (tabsById.length != children.length) return;

    final reorderedTabs = <TabItem>[];
    for (final sessionId in event.sessionIds) {
      final tab = tabsById[sessionId];
      if (tab == null) return;
      reorderedTabs.add(tab);
    }

    var changed = false;
    for (var index = 0; index < reorderedTabs.length; index++) {
      final tab = reorderedTabs[index];
      if (currentState.tabs.indexOf(tab) != index) {
        currentState.tabs.move(tab, index);
        changed = true;
      }
    }

    if (changed) {
      emit(currentState.copyWith(incrementVersion: true));
    }
  }

  void _onTerminalTabRenameSession(
    TerminalTabRenameSession event,
    Emitter<TerminalTabState> emit,
  ) {
    if (state is! TerminalTabLoaded) return;
    final title = event.title.trim();
    if (title.isEmpty) return;

    final currentState = state as TerminalTabLoaded;
    final tabItem = _findTabById(currentState.tabs, event.sessionId);
    if (tabItem == null) return;

    if (tabItem is TerminalTabTitleRenamer) {
      (tabItem as TerminalTabTitleRenamer).renameTitle(title);
    } else {
      tabItem.title.value = Text(title);
    }
    emit(currentState.copyWith(incrementVersion: true));
  }

  void _onTerminalTabNextTab(
    TerminalTabNextTab event,
    Emitter<TerminalTabState> emit,
  ) {
    if (state is! TerminalTabLoaded) return;
    final currentState = state as TerminalTabLoaded;
    final children = currentState.tabs.children;
    if (children.isEmpty) return;
    final activeTab = currentState.tabs.activeTab;
    if (activeTab == null) return;
    final idx = children.indexOf(activeTab);
    final nextIdx = (idx + 1) % children.length;
    children[nextIdx].activate();
    emit(currentState.copyWith(incrementVersion: true));
  }

  void _onTerminalTabPreviousTab(
    TerminalTabPreviousTab event,
    Emitter<TerminalTabState> emit,
  ) {
    if (state is! TerminalTabLoaded) return;
    final currentState = state as TerminalTabLoaded;
    final children = currentState.tabs.children;
    if (children.isEmpty) return;
    final activeTab = currentState.tabs.activeTab;
    if (activeTab == null) return;
    final idx = children.indexOf(activeTab);
    final prevIdx = (idx - 1 + children.length) % children.length;
    children[prevIdx].activate();
    emit(currentState.copyWith(incrementVersion: true));
  }

  void _onTerminalTabGoToTab(
    TerminalTabGoToTab event,
    Emitter<TerminalTabState> emit,
  ) {
    if (state is! TerminalTabLoaded) return;
    final currentState = state as TerminalTabLoaded;
    final children = currentState.tabs.children;
    if (children.isEmpty) return;
    final targetIdx = event.index == 8 ? children.length - 1 : event.index;
    if (targetIdx < 0 || targetIdx >= children.length) return;
    children[targetIdx].activate();
    emit(currentState.copyWith(incrementVersion: true));
  }

  void _emitGrouping(
    Emitter<TerminalTabState> emit,
    TerminalTabLoaded current,
    TabGrouping grouping,
  ) {
    if (identical(grouping, current.grouping)) return;
    emit(current.copyWith(grouping: grouping, incrementVersion: true));
  }

  void _onCreateGroup(
    TerminalTabCreateGroup event,
    Emitter<TerminalTabState> emit,
  ) {
    final current = state;
    if (current is! TerminalTabLoaded) return;
    final tab = _findTabById(current.tabs, event.sessionId);
    if (tab == null) return;
    _emitGrouping(
      emit,
      current,
      current.grouping.createGroup(
        id: _groupIdGenerator(),
        name: event.name,
        tab: tab,
      ),
    );
  }

  void _onMoveToGroup(
    TerminalTabMoveToGroup event,
    Emitter<TerminalTabState> emit,
  ) {
    final current = state;
    if (current is! TerminalTabLoaded) return;
    final tab = _findTabById(current.tabs, event.sessionId);
    if (tab == null) return;
    _emitGrouping(
      emit,
      current,
      _moveIntoGroup(current, current.grouping, tab, event.groupId),
    );
  }

  /// Assigns [tab] to [groupId] and moves it, in the global tab order, to
  /// just after the group's last other member.
  TabGrouping _moveIntoGroup(
    TerminalTabLoaded current,
    TabGrouping grouping,
    TabItem tab,
    String groupId,
  ) {
    final next = grouping.assign(tab, groupId);
    if (identical(next, grouping)) return grouping;
    final children = current.tabs.children;
    final oldIndex = children.indexOf(tab);
    var lastOther = -1;
    for (var i = 0; i < children.length; i++) {
      if (i != oldIndex && next.groupIdOf(children[i]) == groupId) {
        lastOther = i;
      }
    }
    if (lastOther >= 0) {
      current.tabs.move(tab, oldIndex < lastOther ? lastOther : lastOther + 1);
    }
    return next;
  }

  /// Tabs for [sessionIds] in global tab order.
  List<TabItem> _tabsInOrder(TerminalTabLoaded current, List<String> ids) {
    final wanted = ids.toSet();
    return [
      for (final tab in current.tabs.children)
        if (wanted.contains(tab.hashCode.toString())) tab,
    ];
  }

  void _onMoveSessionsToGroup(
    TerminalTabMoveSessionsToGroup event,
    Emitter<TerminalTabState> emit,
  ) {
    final current = state;
    if (current is! TerminalTabLoaded) return;
    var grouping = current.grouping;
    for (final tab in _tabsInOrder(current, event.sessionIds)) {
      grouping = _moveIntoGroup(current, grouping, tab, event.groupId);
    }
    _emitGrouping(emit, current, grouping);
  }

  void _onCreateGroupWithSessions(
    TerminalTabCreateGroupWithSessions event,
    Emitter<TerminalTabState> emit,
  ) {
    final current = state;
    if (current is! TerminalTabLoaded) return;
    final tabs = _tabsInOrder(current, event.sessionIds);
    if (tabs.isEmpty) return;
    final groupId = _groupIdGenerator();
    var grouping = current.grouping.createGroup(
      id: groupId,
      name: event.name,
      tab: tabs.first,
    );
    if (identical(grouping, current.grouping)) return;
    for (final tab in tabs.skip(1)) {
      grouping = _moveIntoGroup(current, grouping, tab, groupId);
    }
    _emitGrouping(emit, current, grouping);
  }

  void _onUngroupSessions(
    TerminalTabUngroupSessions event,
    Emitter<TerminalTabState> emit,
  ) {
    final current = state;
    if (current is! TerminalTabLoaded) return;
    var grouping = current.grouping;
    for (final tab in _tabsInOrder(current, event.sessionIds)) {
      grouping = grouping.assign(tab, null);
    }
    _emitGrouping(emit, current, grouping);
  }

  void _onUngroup(TerminalTabUngroup event, Emitter<TerminalTabState> emit) {
    final current = state;
    if (current is! TerminalTabLoaded) return;
    final tab = _findTabById(current.tabs, event.sessionId);
    if (tab == null) return;
    _emitGrouping(emit, current, current.grouping.assign(tab, null));
  }

  void _onRenameGroup(
    TerminalTabRenameGroup event,
    Emitter<TerminalTabState> emit,
  ) {
    final current = state;
    if (current is! TerminalTabLoaded) return;
    _emitGrouping(
      emit,
      current,
      current.grouping.renameGroup(event.groupId, event.name),
    );
  }

  void _onToggleGroupCollapsed(
    TerminalTabToggleGroupCollapsed event,
    Emitter<TerminalTabState> emit,
  ) {
    final current = state;
    if (current is! TerminalTabLoaded) return;
    _emitGrouping(
      emit,
      current,
      current.grouping.toggleCollapsed(event.groupId),
    );
  }

  void _onMoveTabBefore(
    TerminalTabMoveTabBefore event,
    Emitter<TerminalTabState> emit,
  ) {
    final current = state;
    if (current is! TerminalTabLoaded) return;
    final tab = _findTabById(current.tabs, event.sessionId);
    final target = _findTabById(current.tabs, event.targetSessionId);
    if (tab == null || target == null || identical(tab, target)) return;

    final oldIndex = current.tabs.indexOf(tab);
    final targetIndex = current.tabs.indexOf(target);
    current.tabs.move(
      tab,
      oldIndex < targetIndex ? targetIndex - 1 : targetIndex,
    );
    final grouping = current.grouping.assign(
      tab,
      current.grouping.groupIdOf(target),
    );
    emit(current.copyWith(grouping: grouping, incrementVersion: true));
  }

  void _onRestoreGroups(
    TerminalTabRestoreGroups event,
    Emitter<TerminalTabState> emit,
  ) {
    final current = state;
    if (current is! TerminalTabLoaded) return;
    final grouping = TabGrouping(
      groups: event.groups,
      membership: current.grouping.membership,
      ungroupedCollapsed: event.ungroupedCollapsed,
    );
    emit(current.copyWith(grouping: grouping, incrementVersion: true));
  }

  void _onFinishGroupRestore(
    TerminalTabFinishGroupRestore event,
    Emitter<TerminalTabState> emit,
  ) {
    final current = state;
    if (current is! TerminalTabLoaded) return;
    _emitGrouping(emit, current, current.grouping.dropEmptyGroups());
  }

  /// Finds a TabItem by its hashCode string representation.
  TabItem? _findTabById(Tabs tabs, String id) {
    for (final child in tabs.children) {
      if (child.hashCode.toString() == id) {
        return child;
      }
    }
    return null;
  }
}
