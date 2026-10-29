import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/widgets.dart';

part 'event.dart';
part 'state.dart';

abstract interface class TerminalTabTitleRenamer {
  void renameTitle(String title);
}

class TerminalTabBloc extends Bloc<TerminalTabEvent, TerminalTabState> {
  TerminalTabBloc() : super(TerminalTabInitial()) {
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
  }

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
      emit(currentState.copyWith(incrementVersion: true));
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
