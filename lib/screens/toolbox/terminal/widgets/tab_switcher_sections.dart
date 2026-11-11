import 'package:flutter/foundation.dart';

import 'terminal_app_bar.dart';

/// A tab group as shown by the tab switcher.
@immutable
class TabSwitcherGroup {
  const TabSwitcherGroup({
    required this.id,
    required this.name,
    required this.collapsed,
  });

  final String id;
  final String name;
  final bool collapsed;
}

/// Everything the tab switcher renders, in global tab order.
@immutable
class TabSwitcherData {
  const TabSwitcherData({
    required this.sessions,
    required this.currentSessionId,
    this.groups = const <TabSwitcherGroup>[],
    this.ungroupedCollapsed = false,
  });

  final List<SessionInfo> sessions;
  final String? currentSessionId;

  /// Groups in creation order.
  final List<TabSwitcherGroup> groups;
  final bool ungroupedCollapsed;
}

/// One block of cards in the tab switcher.
@immutable
class TabSwitcherSection {
  const TabSwitcherSection({
    required this.groupId,
    required this.name,
    required this.sessions,
    required this.collapsed,
  });

  /// Null for the ungrouped section.
  final String? groupId;
  final String name;
  final List<SessionInfo> sessions;

  /// Effective collapse state; the current tab's section is always open.
  final bool collapsed;
}

/// Splits [data] into switcher sections: the current tab's section first,
/// then the remaining groups in creation order, then ungrouped tabs. Empty
/// sections are omitted.
List<TabSwitcherSection> buildSwitcherSections(
  TabSwitcherData data, {
  required String ungroupedLabel,
  bool currentGroupOnly = false,
}) {
  final groupIds = <String>{for (final group in data.groups) group.id};
  String? sectionKey(SessionInfo session) {
    final id = session.groupId;
    return id != null && groupIds.contains(id) ? id : null;
  }

  final bySection = <String?, List<SessionInfo>>{};
  String? currentKey;
  var hasCurrent = false;
  for (final session in data.sessions) {
    final key = sectionKey(session);
    (bySection[key] ??= <SessionInfo>[]).add(session);
    if (session.id == data.currentSessionId) {
      currentKey = key;
      hasCurrent = true;
    }
  }

  final sections = <TabSwitcherSection>[
    for (final group in data.groups)
      if (bySection[group.id] case final sessions?)
        TabSwitcherSection(
          groupId: group.id,
          name: group.name,
          sessions: List<SessionInfo>.unmodifiable(sessions),
          collapsed: group.collapsed,
        ),
    if (bySection[null] case final sessions?)
      TabSwitcherSection(
        groupId: null,
        name: ungroupedLabel,
        sessions: List<SessionInfo>.unmodifiable(sessions),
        collapsed: data.ungroupedCollapsed,
      ),
  ];
  if (!hasCurrent) return sections;

  final index = sections.indexWhere(
    (TabSwitcherSection s) => s.groupId == currentKey,
  );
  final current = sections.removeAt(index);
  final open = TabSwitcherSection(
    groupId: current.groupId,
    name: current.name,
    sessions: current.sessions,
    collapsed: false,
  );
  if (currentGroupOnly) return <TabSwitcherSection>[open];
  return <TabSwitcherSection>[open, ...sections];
}
