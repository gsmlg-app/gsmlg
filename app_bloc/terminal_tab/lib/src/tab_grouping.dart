part of 'bloc.dart';

/// A user-named group of terminal tabs.
@immutable
final class TabGroup extends Equatable {
  const TabGroup(
      {required this.id, required this.name, this.collapsed = false});

  final String id;
  final String name;
  final bool collapsed;

  TabGroup copyWith({String? name, bool? collapsed}) {
    return TabGroup(
      id: id,
      name: name ?? this.name,
      collapsed: collapsed ?? this.collapsed,
    );
  }

  @override
  List<Object?> get props => <Object?>[id, name, collapsed];
}

/// Immutable record of which tabs belong to which [TabGroup].
///
/// Groups are kept in creation order and are never empty: any operation that
/// leaves a group without members removes it.
@immutable
final class TabGrouping extends Equatable {
  const TabGrouping({
    this.groups = const <TabGroup>[],
    this.membership = const <TabItem, String>{},
    this.ungroupedCollapsed = false,
  });

  final List<TabGroup> groups;
  final Map<TabItem, String> membership;
  final bool ungroupedCollapsed;

  String? groupIdOf(TabItem tab) => membership[tab];

  TabGroup? groupById(String id) {
    for (final group in groups) {
      if (group.id == id) return group;
    }
    return null;
  }

  TabGroup? groupOf(TabItem tab) {
    final id = membership[tab];
    return id == null ? null : groupById(id);
  }

  TabGrouping createGroup({
    required String id,
    required String name,
    required TabItem tab,
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || groupById(id) != null) return this;
    return _copy(
      groups: <TabGroup>[...groups, TabGroup(id: id, name: trimmed)],
      membership: <TabItem, String>{...membership, tab: id},
    ).dropEmptyGroups();
  }

  /// Moves [tab] into [groupId], or ungroups it when [groupId] is null.
  ///
  /// Groups left empty are removed unless [keepEmptyGroups] is set, which tab
  /// restore uses while groups are still waiting for their tabs.
  TabGrouping assign(
    TabItem tab,
    String? groupId, {
    bool keepEmptyGroups = false,
  }) {
    if (groupId != null && groupById(groupId) == null) return this;
    if (membership[tab] == groupId) return this;
    final next = Map<TabItem, String>.of(membership);
    if (groupId == null) {
      next.remove(tab);
    } else {
      next[tab] = groupId;
    }
    final assigned = _copy(membership: next);
    return keepEmptyGroups ? assigned : assigned.dropEmptyGroups();
  }

  TabGrouping renameGroup(String id, String name) {
    final trimmed = name.trim();
    final group = groupById(id);
    if (trimmed.isEmpty || group == null || group.name == trimmed) return this;
    return _copy(
      groups: <TabGroup>[
        for (final g in groups) g.id == id ? g.copyWith(name: trimmed) : g,
      ],
    );
  }

  /// Toggles collapse of [groupId], or of the ungrouped section when null.
  TabGrouping toggleCollapsed(String? groupId) {
    if (groupId == null) {
      return _copy(ungroupedCollapsed: !ungroupedCollapsed);
    }
    if (groupById(groupId) == null) return this;
    return _copy(
      groups: <TabGroup>[
        for (final g in groups)
          g.id == groupId ? g.copyWith(collapsed: !g.collapsed) : g,
      ],
    );
  }

  /// Forgets tabs that are no longer open and removes groups left empty.
  TabGrouping retainTabs(Iterable<TabItem> liveTabs) {
    final live = liveTabs.toSet();
    if (membership.keys.every(live.contains)) return this;
    return _copy(
      membership: <TabItem, String>{
        for (final entry in membership.entries)
          if (live.contains(entry.key)) entry.key: entry.value,
      },
    ).dropEmptyGroups();
  }

  /// Removes groups that have no member tabs.
  TabGrouping dropEmptyGroups() {
    final used = membership.values.toSet();
    if (groups.every((TabGroup g) => used.contains(g.id))) return this;
    return _copy(
      groups: <TabGroup>[
        for (final g in groups)
          if (used.contains(g.id)) g,
      ],
    );
  }

  TabGrouping _copy({
    List<TabGroup>? groups,
    Map<TabItem, String>? membership,
    bool? ungroupedCollapsed,
  }) {
    return TabGrouping(
      groups: List<TabGroup>.unmodifiable(groups ?? this.groups),
      membership: Map<TabItem, String>.unmodifiable(
        membership ?? this.membership,
      ),
      ungroupedCollapsed: ungroupedCollapsed ?? this.ungroupedCollapsed,
    );
  }

  @override
  List<Object?> get props => <Object?>[groups, membership, ungroupedCollapsed];
}
