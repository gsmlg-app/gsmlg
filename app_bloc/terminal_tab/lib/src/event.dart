part of 'bloc.dart';

@immutable
sealed class TerminalTabEvent {}

class TerminalTabStart extends TerminalTabEvent {}

class TerminalTabStop extends TerminalTabEvent {}

class TerminalTabOpenTab extends TerminalTabEvent {
  final TabItem tabItem;
  final bool activate;

  /// Group to restore the tab into. Only tab restore sets this; new tabs
  /// always start ungrouped. Unknown ids leave the tab ungrouped.
  final String? groupId;

  TerminalTabOpenTab(this.tabItem, {this.activate = true, this.groupId});
}

/// Toggles fullscreen mode (hides/shows navigation shell).
class TerminalTabToggleFullscreen extends TerminalTabEvent {}

/// Selects a session by its ID (used by AppBar session selector).
class TerminalTabSelectSession extends TerminalTabEvent {
  final String sessionId;

  TerminalTabSelectSession(this.sessionId);
}

/// Closes a session by its ID.
class TerminalTabCloseSession extends TerminalTabEvent {
  final String sessionId;

  TerminalTabCloseSession(this.sessionId);
}

/// Reorders sessions to match the provided session ID order.
class TerminalTabReorderSessions extends TerminalTabEvent {
  final List<String> sessionIds;

  TerminalTabReorderSessions(List<String> sessionIds)
      : sessionIds = List.unmodifiable(sessionIds);
}

/// Renames a session by its ID.
class TerminalTabRenameSession extends TerminalTabEvent {
  final String sessionId;
  final String title;

  TerminalTabRenameSession(this.sessionId, this.title);
}

/// Activates the next tab (wraps around).
class TerminalTabNextTab extends TerminalTabEvent {}

/// Activates the previous tab (wraps around).
class TerminalTabPreviousTab extends TerminalTabEvent {}

/// Activates the tab at a specific index (0-based).
/// Index 8 always activates the last tab (Ctrl+9 convention).
class TerminalTabGoToTab extends TerminalTabEvent {
  final int index;

  TerminalTabGoToTab(this.index);
}

/// Creates a group named [name] and moves the tab [sessionId] into it.
class TerminalTabCreateGroup extends TerminalTabEvent {
  final String sessionId;
  final String name;

  TerminalTabCreateGroup(this.sessionId, this.name);
}

/// Moves the tab [sessionId] into the existing group [groupId], placing it
/// after the group's last other member in the global tab order.
class TerminalTabMoveToGroup extends TerminalTabEvent {
  final String sessionId;
  final String groupId;

  TerminalTabMoveToGroup(this.sessionId, this.groupId);
}

/// Removes the tab [sessionId] from its group.
class TerminalTabUngroup extends TerminalTabEvent {
  final String sessionId;

  TerminalTabUngroup(this.sessionId);
}

/// Renames the group [groupId].
class TerminalTabRenameGroup extends TerminalTabEvent {
  final String groupId;
  final String name;

  TerminalTabRenameGroup(this.groupId, this.name);
}

/// Toggles collapse of the group [groupId], or of the ungrouped section when
/// [groupId] is null.
class TerminalTabToggleGroupCollapsed extends TerminalTabEvent {
  final String? groupId;

  TerminalTabToggleGroupCollapsed(this.groupId);
}

/// Moves the tab [sessionId] immediately before [targetSessionId] in the
/// global tab order and into the target's group. No other tab moves.
class TerminalTabMoveTabBefore extends TerminalTabEvent {
  final String sessionId;
  final String targetSessionId;

  TerminalTabMoveTabBefore(this.sessionId, this.targetSessionId);
}

/// Restores saved groups before restored tabs are reopened.
class TerminalTabRestoreGroups extends TerminalTabEvent {
  final List<TabGroup> groups;
  final bool ungroupedCollapsed;

  TerminalTabRestoreGroups(
    List<TabGroup> groups, {
    this.ungroupedCollapsed = false,
  }) : groups = List.unmodifiable(groups);
}

/// Ends tab restore: removes restored groups whose tabs did not come back.
class TerminalTabFinishGroupRestore extends TerminalTabEvent {}

/// Moves several tabs into the existing group [groupId], keeping their
/// relative order, after the group's last other member.
class TerminalTabMoveSessionsToGroup extends TerminalTabEvent {
  final List<String> sessionIds;
  final String groupId;

  TerminalTabMoveSessionsToGroup(List<String> sessionIds, this.groupId)
      : sessionIds = List.unmodifiable(sessionIds);
}

/// Creates a group named [name] containing all [sessionIds].
class TerminalTabCreateGroupWithSessions extends TerminalTabEvent {
  final List<String> sessionIds;
  final String name;

  TerminalTabCreateGroupWithSessions(List<String> sessionIds, this.name)
      : sessionIds = List.unmodifiable(sessionIds);
}

/// Removes several tabs from their groups.
class TerminalTabUngroupSessions extends TerminalTabEvent {
  final List<String> sessionIds;

  TerminalTabUngroupSessions(List<String> sessionIds)
      : sessionIds = List.unmodifiable(sessionIds);
}
