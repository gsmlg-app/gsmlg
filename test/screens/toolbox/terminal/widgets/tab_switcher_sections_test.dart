import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/toolbox/terminal/widgets/tab_switcher_sections.dart';
import 'package:gsmlg/screens/toolbox/terminal/widgets/terminal_app_bar.dart';

void main() {
  const label = 'Ungrouped';
  const sessions = <SessionInfo>[
    SessionInfo(id: 's1', name: 'one'),
    SessionInfo(id: 's2', name: 'two', groupId: 'g1'),
    SessionInfo(id: 's3', name: 'three'),
    SessionInfo(id: 's4', name: 'four', groupId: 'g1'),
    SessionInfo(id: 's5', name: 'five', groupId: 'g2'),
  ];
  const groups = <TabSwitcherGroup>[
    TabSwitcherGroup(id: 'g1', name: 'api', collapsed: false),
    TabSwitcherGroup(id: 'g2', name: 'web', collapsed: false),
  ];

  List<String> names(List<TabSwitcherSection> sections) =>
      sections.map((TabSwitcherSection s) => s.name).toList();

  List<String> sessionIds(TabSwitcherSection section) =>
      section.sessions.map((SessionInfo s) => s.id).toList();

  test("current tab's group comes first", () {
    final sections = buildSwitcherSections(
      const TabSwitcherData(
        sessions: sessions,
        currentSessionId: 's5',
        groups: groups,
      ),
      ungroupedLabel: label,
    );

    expect(names(sections), <String>['web', 'api', 'Ungrouped']);
    expect(sections.last.groupId, isNull);
  });

  test('sessions keep relative global order within a section', () {
    final sections = buildSwitcherSections(
      const TabSwitcherData(
        sessions: sessions,
        currentSessionId: 's1',
        groups: groups,
      ),
      ungroupedLabel: label,
    );

    final api = sections.firstWhere((TabSwitcherSection s) => s.name == 'api');
    expect(sessionIds(api), <String>['s2', 's4']);
    expect(names(sections), <String>['Ungrouped', 'api', 'web']);
  });

  test('ungrouped section is last and omitted when empty', () {
    final sections = buildSwitcherSections(
      const TabSwitcherData(
        sessions: <SessionInfo>[
          SessionInfo(id: 's2', name: 'two', groupId: 'g1'),
          SessionInfo(id: 's5', name: 'five', groupId: 'g2'),
        ],
        currentSessionId: 's2',
        groups: groups,
      ),
      ungroupedLabel: label,
    );

    expect(names(sections), <String>['api', 'web']);
  });

  test('empty groups are omitted', () {
    final sections = buildSwitcherSections(
      const TabSwitcherData(
        sessions: <SessionInfo>[SessionInfo(id: 's1', name: 'one')],
        currentSessionId: 's1',
        groups: groups,
      ),
      ungroupedLabel: label,
    );

    expect(names(sections), <String>['Ungrouped']);
  });

  test('unknown groupId counts as ungrouped', () {
    final sections = buildSwitcherSections(
      const TabSwitcherData(
        sessions: <SessionInfo>[
          SessionInfo(id: 's1', name: 'one', groupId: 'missing'),
          SessionInfo(id: 's2', name: 'two', groupId: 'g1'),
        ],
        currentSessionId: 's2',
        groups: groups,
      ),
      ungroupedLabel: label,
    );

    expect(names(sections), <String>['api', 'Ungrouped']);
    expect(sessionIds(sections.last), <String>['s1']);
  });

  test('currentGroupOnly returns only the current section', () {
    final sections = buildSwitcherSections(
      const TabSwitcherData(
        sessions: sessions,
        currentSessionId: 's3',
        groups: groups,
      ),
      ungroupedLabel: label,
      currentGroupOnly: true,
    );

    expect(names(sections), <String>['Ungrouped']);
    expect(sessionIds(sections.single), <String>['s1', 's3']);
  });

  test('currentGroupOnly without a current tab returns all sections', () {
    final sections = buildSwitcherSections(
      const TabSwitcherData(
        sessions: sessions,
        currentSessionId: null,
        groups: groups,
      ),
      ungroupedLabel: label,
      currentGroupOnly: true,
    );

    expect(names(sections), <String>['api', 'web', 'Ungrouped']);
  });

  test('collapse state comes from data, but the current section is open', () {
    final sections = buildSwitcherSections(
      const TabSwitcherData(
        sessions: sessions,
        currentSessionId: 's2',
        groups: <TabSwitcherGroup>[
          TabSwitcherGroup(id: 'g1', name: 'api', collapsed: true),
          TabSwitcherGroup(id: 'g2', name: 'web', collapsed: true),
        ],
        ungroupedCollapsed: true,
      ),
      ungroupedLabel: label,
    );

    expect(sections.map((TabSwitcherSection s) => s.collapsed).toList(), <bool>[
      false,
      true,
      true,
    ]);
  });
}
