import 'dart:ui';

import 'package:app_locale/app_locale.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/toolbox/terminal/widgets/tab_switcher.dart';
import 'package:gsmlg/screens/toolbox/terminal/widgets/tab_switcher_sections.dart';
import 'package:gsmlg/screens/toolbox/terminal/widgets/terminal_app_bar.dart';

void main() {
  const sessions = [
    SessionInfo(id: '1', name: '1 ~'),
    SessionInfo(id: '2', name: '2 ~', isRunning: true),
    SessionInfo(id: '3', name: '3 ~'),
  ];

  Future<ValueNotifier<TabSwitcherResult?>> pumpTabSwitcher(
    WidgetTester tester, {
    List<SessionInfo> tabSessions = sessions,
    ValueNotifier<TabSwitcherData>? data,
    List<DisplayFeature> displayFeatures = const [],
    bool currentGroupOnly = false,
    TabSwitcherCallbacks callbacks = const TabSwitcherCallbacks(),
  }) async {
    final result = ValueNotifier<TabSwitcherResult?>(null);
    final source =
        data ??
        ValueNotifier<TabSwitcherData>(
          TabSwitcherData(sessions: tabSessions, currentSessionId: '1'),
        );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocale.localizationsDelegates,
        supportedLocales: AppLocale.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(displayFeatures: displayFeatures),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result.value = await showTabSwitcher(
                    context,
                    data: source,
                    currentGroupOnly: currentGroupOnly,
                    callbacks: callbacks,
                  );
                },
                child: const Text('Open switcher'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open switcher'));
    await tester.pumpAndSettle();
    return result;
  }

  Finder card(String id) => find.byKey(ValueKey('tab-switcher-card-$id'));

  Finder header(String? groupId) =>
      find.byKey(ValueKey('tab-switcher-section-${groupId ?? 'ungrouped'}'));

  const grouped = TabSwitcherData(
    sessions: [
      SessionInfo(id: '1', name: 'one'),
      SessionInfo(id: '2', name: 'two', groupId: 'g1'),
      SessionInfo(id: '3', name: 'three'),
    ],
    currentSessionId: '2',
    groups: [TabSwitcherGroup(id: 'g1', name: 'api', collapsed: false)],
  );

  group('Tab switcher', () {
    testWidgets('confirms and returns selected tabs to close', (tester) async {
      final result = await pumpTabSwitcher(tester);

      await tester.tap(find.byTooltip('Select tabs'));
      await tester.pumpAndSettle();

      await tester.tap(card('2'));
      await tester.tap(card('3'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Close selected tabs'));
      await tester.pumpAndSettle();

      expect(find.text('Close 2 Tabs?'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Close'));
      await tester.pumpAndSettle();

      final closeResult = result.value;
      expect(closeResult, isA<TabSwitcherCloseSelected>());
      expect((closeResult as TabSwitcherCloseSelected).sessionIds, ['2', '3']);
    });

    testWidgets('dragging a card onto another calls onMoveBefore once', (
      tester,
    ) async {
      final moves = <(String, String)>[];
      await pumpTabSwitcher(
        tester,
        callbacks: TabSwitcherCallbacks(
          onMoveBefore: (id, target) => moves.add((id, target)),
        ),
      );

      await tester.tap(find.byTooltip('Reorder tabs'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Done reordering'), findsOneWidget);

      final gesture = await tester.startGesture(tester.getCenter(card('1')));
      await gesture.moveTo(tester.getCenter(card('3')));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(moves, [('1', '3')]);

      await tester.tap(find.byTooltip('Done reordering'));
      await tester.pumpAndSettle();
      expect(moves, hasLength(1));
    });

    testWidgets('reorder mode applies drags immediately and has no Cancel', (
      tester,
    ) async {
      await pumpTabSwitcher(tester);

      await tester.tap(find.byTooltip('Reorder tabs'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Cancel reordering'), findsNothing);
      expect(find.textContaining('Esc Done'), findsOneWidget);
      expect(find.textContaining('Esc Cancel'), findsNothing);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Switch Tab'), findsOneWidget);
    });

    testWidgets('long press opens a menu whose Rename updates title', (
      tester,
    ) async {
      final data = ValueNotifier<TabSwitcherData>(
        const TabSwitcherData(sessions: sessions, currentSessionId: '1'),
      );
      final renamed = <String, String>{};
      await pumpTabSwitcher(
        tester,
        data: data,
        callbacks: TabSwitcherCallbacks(
          onRename: (sessionId, title) {
            renamed[sessionId] = title;
            data.value = TabSwitcherData(
              sessions: [
                for (final s in data.value.sessions)
                  s.id == sessionId ? SessionInfo(id: s.id, name: title) : s,
              ],
              currentSessionId: '1',
            );
          },
        ),
      );

      await tester.longPress(card('2'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename…'));
      await tester.pumpAndSettle();

      expect(find.text('Rename Tab'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Build logs');
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      expect(renamed, {'2': 'Build logs'});
      expect(find.text('Build logs'), findsOneWidget);
    });

    testWidgets('shows sections with name and count, current group first', (
      tester,
    ) async {
      await pumpTabSwitcher(
        tester,
        data: ValueNotifier<TabSwitcherData>(grouped),
      );

      expect(find.text('api · 1'), findsOneWidget);
      expect(find.text('Ungrouped · 2'), findsOneWidget);
      expect(
        tester.getTopLeft(header('g1')).dy,
        lessThan(tester.getTopLeft(header(null)).dy),
      );
    });

    testWidgets('header tap toggles and collapsed sections hide cards', (
      tester,
    ) async {
      final data = ValueNotifier<TabSwitcherData>(grouped);
      final toggled = <String?>[];
      await pumpTabSwitcher(
        tester,
        data: data,
        callbacks: TabSwitcherCallbacks(onToggleCollapsed: toggled.add),
      );

      await tester.tap(header(null));
      await tester.pumpAndSettle();
      expect(toggled, [null]);

      data.value = TabSwitcherData(
        sessions: grouped.sessions,
        currentSessionId: '2',
        groups: grouped.groups,
        ungroupedCollapsed: true,
      );
      await tester.pumpAndSettle();

      expect(card('3'), findsNothing);
      expect(card('2'), findsOneWidget);
      expect(find.text('Ungrouped · 2'), findsOneWidget);
    });

    testWidgets('context menu moves a tab to an existing group', (
      tester,
    ) async {
      final moves = <(String, String)>[];
      await pumpTabSwitcher(
        tester,
        data: ValueNotifier<TabSwitcherData>(grouped),
        callbacks: TabSwitcherCallbacks(
          onMoveToGroup: (id, groupId) => moves.add((id, groupId)),
        ),
      );

      await tester.tap(card('3'), buttons: kSecondaryButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Move to group'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('api').last);
      await tester.pumpAndSettle();

      expect(moves, [('3', 'g1')]);
    });

    testWidgets('context menu creates a new group with the tab', (
      tester,
    ) async {
      final created = <(String, String)>[];
      await pumpTabSwitcher(
        tester,
        data: ValueNotifier<TabSwitcherData>(grouped),
        callbacks: TabSwitcherCallbacks(
          onCreateGroup: (id, name) => created.add((id, name)),
        ),
      );

      await tester.longPress(card('1'));
      await tester.pumpAndSettle();
      expect(find.text('Remove from group'), findsNothing);
      await tester.tap(find.text('New group…'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'web');
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      expect(created, [('1', 'web')]);
    });

    testWidgets('context menu removes a tab from its group', (tester) async {
      final ungrouped = <String>[];
      await pumpTabSwitcher(
        tester,
        data: ValueNotifier<TabSwitcherData>(grouped),
        callbacks: TabSwitcherCallbacks(onUngroup: ungrouped.add),
      );

      await tester.longPress(card('2'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove from group'));
      await tester.pumpAndSettle();

      expect(ungrouped, ['2']);
    });

    testWidgets('select mode moves the selected tabs to a group', (
      tester,
    ) async {
      final moves = <(List<String>, String)>[];
      await pumpTabSwitcher(
        tester,
        data: ValueNotifier<TabSwitcherData>(grouped),
        callbacks: TabSwitcherCallbacks(
          onMoveSessionsToGroup: (ids, groupId) => moves.add((ids, groupId)),
        ),
      );

      await tester.tap(find.byTooltip('Select tabs'));
      await tester.pumpAndSettle();
      await tester.tap(card('1'));
      await tester.tap(card('3'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Group selected tabs'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Move to group'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('api').last);
      await tester.pumpAndSettle();

      expect(moves.single.$1, ['1', '3']);
      expect(moves.single.$2, 'g1');
      expect(find.text('Select Tabs'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('select mode puts the selected tabs into a new group', (
      tester,
    ) async {
      final created = <(List<String>, String)>[];
      await pumpTabSwitcher(
        tester,
        data: ValueNotifier<TabSwitcherData>(grouped),
        callbacks: TabSwitcherCallbacks(
          onCreateGroupWithSessions: (ids, name) => created.add((ids, name)),
        ),
      );

      await tester.tap(find.byTooltip('Select tabs'));
      await tester.pumpAndSettle();
      await tester.tap(card('1'));
      await tester.tap(card('2'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Group selected tabs'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('New group…'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'web');
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      expect(created.single.$1, ['1', '2']);
      expect(created.single.$2, 'web');
    });

    testWidgets('select mode removes the selected tabs from their groups', (
      tester,
    ) async {
      final ungrouped = <List<String>>[];
      await pumpTabSwitcher(
        tester,
        data: ValueNotifier<TabSwitcherData>(grouped),
        callbacks: TabSwitcherCallbacks(onUngroupSessions: ungrouped.add),
      );

      await tester.tap(find.byTooltip('Select tabs'));
      await tester.pumpAndSettle();
      await tester.tap(card('3'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Group selected tabs'));
      await tester.pumpAndSettle();
      expect(find.text('Remove from group'), findsNothing);
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      await tester.tap(card('2'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Group selected tabs'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove from group'));
      await tester.pumpAndSettle();

      expect(ungrouped.single, ['2', '3']);
    });

    testWidgets('group button is disabled with nothing selected', (
      tester,
    ) async {
      await pumpTabSwitcher(
        tester,
        data: ValueNotifier<TabSwitcherData>(grouped),
      );

      await tester.tap(find.byTooltip('Select tabs'));
      await tester.pumpAndSettle();

      final button = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.create_new_folder_outlined),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('group header menu renames and closes the group', (
      tester,
    ) async {
      final renamed = <(String, String)>[];
      final closed = <String>[];
      final result = await pumpTabSwitcher(
        tester,
        data: ValueNotifier<TabSwitcherData>(grouped),
        callbacks: TabSwitcherCallbacks(
          onRenameGroup: (id, name) => renamed.add((id, name)),
          onCloseGroup: closed.add,
        ),
      );

      await tester.longPress(header('g1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename group…'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'backend');
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      await tester.tap(header('g1'), buttons: kSecondaryButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Close group'));
      await tester.pumpAndSettle();

      expect(renamed, [('g1', 'backend')]);
      expect(closed, ['g1']);
      expect(result.value, isNull);
      expect(find.text('Switch Tab'), findsOneWidget);
    });

    testWidgets('ungrouped header has no group menu', (tester) async {
      await pumpTabSwitcher(
        tester,
        data: ValueNotifier<TabSwitcherData>(grouped),
      );

      await tester.longPress(header(null));
      await tester.pumpAndSettle();

      expect(find.text('Rename group…'), findsNothing);
    });

    testWidgets('currentGroupOnly shows only the current section', (
      tester,
    ) async {
      await pumpTabSwitcher(
        tester,
        data: ValueNotifier<TabSwitcherData>(grouped),
        currentGroupOnly: true,
      );

      expect(card('2'), findsOneWidget);
      expect(card('1'), findsNothing);
      expect(card('3'), findsNothing);
      expect(find.text('api'), findsOneWidget);
      expect(find.text('Switch Tab'), findsNothing);
    });

    testWidgets('live data removes a closed tab without error', (tester) async {
      final data = ValueNotifier<TabSwitcherData>(grouped);
      await pumpTabSwitcher(tester, data: data);

      data.value = TabSwitcherData(
        sessions: grouped.sessions.where((s) => s.id != '2').toList(),
        currentSessionId: '1',
        groups: const [],
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(card('2'), findsNothing);
      expect(header('g1'), findsNothing);
    });

    testWidgets('cards keep a maximum size with few tabs', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pumpTabSwitcher(tester);

      for (final id in ['1', '2', '3']) {
        final size = tester.getSize(card(id));
        expect(size.width, lessThanOrEqualTo(160));
        expect(size.height, lessThanOrEqualTo(100));
      }
      expect(tester.getTopLeft(card('3')).dy, tester.getTopLeft(card('1')).dy);
    });

    testWidgets('down arrow moves by the rendered column count', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final many = [
        for (var i = 1; i <= 8; i++) SessionInfo(id: '$i', name: 'tab $i'),
      ];
      final result = await pumpTabSwitcher(tester, tabSessions: many);

      final first = tester.getTopLeft(card('1'));
      final rowStarts = [
        for (var i = 2; i <= 8; i++)
          if (tester.getTopLeft(card('$i')).dy > first.dy) i,
      ];
      final belowFirst = rowStarts.first;

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect((result.value as TabSwitcherSelect).sessionId, '$belowFirst');
    });

    testWidgets('arrow keys skip collapsed sections', (tester) async {
      final result = await pumpTabSwitcher(
        tester,
        data: ValueNotifier<TabSwitcherData>(
          const TabSwitcherData(
            sessions: [
              SessionInfo(id: '1', name: 'one', groupId: 'a'),
              SessionInfo(id: '2', name: 'two', groupId: 'b'),
              SessionInfo(id: '3', name: 'three', groupId: 'c'),
            ],
            currentSessionId: '1',
            groups: [
              TabSwitcherGroup(id: 'a', name: 'A', collapsed: false),
              TabSwitcherGroup(id: 'b', name: 'B', collapsed: true),
              TabSwitcherGroup(id: 'c', name: 'C', collapsed: false),
            ],
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      final selected = result.value;
      expect(selected, isA<TabSwitcherSelect>());
      expect((selected as TabSwitcherSelect).sessionId, '3');
    });

    testWidgets('does not overflow compact cards with many sessions', (
      tester,
    ) async {
      final manySessions = List.generate(
        25,
        (index) =>
            SessionInfo(id: '${index + 1}', name: '${index + 1} ~/workspace'),
      );

      await pumpTabSwitcher(tester, tabSessions: manySessions);

      expect(tester.takeException(), isNull);
    });
  });

  group('Tab switcher display features', () {
    final manySessions = List.generate(
      25,
      (index) => SessionInfo(id: '${index + 1}', name: 'Session ${index + 1}'),
    );
    const viewport = Size(1200, 1000);

    void setViewport(WidgetTester tester, Size size) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    Rect panelRect(WidgetTester tester) => tester.getRect(
      find
          .ancestor(
            of: find.text('Switch Tab'),
            matching: find.byType(Material),
          )
          .first,
    );

    testWidgets('ordinary large screens keep the centered size limit', (
      tester,
    ) async {
      setViewport(tester, viewport);
      await pumpTabSwitcher(tester, tabSessions: manySessions);

      final rect = panelRect(tester);
      expect(rect.center, viewport.center(Offset.zero));
      expect(rect.width, 560);
      expect(rect.height, lessThanOrEqualTo(520));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'ordinary compact screens constrain the panel to the viewport',
      (tester) async {
        const compactViewport = Size(360, 480);
        setViewport(tester, compactViewport);
        await pumpTabSwitcher(tester);

        final rect = panelRect(tester);
        expect(rect.center, compactViewport.center(Offset.zero));
        expect(rect.width, lessThanOrEqualTo(compactViewport.width));
        expect(rect.height, lessThanOrEqualTo(compactViewport.height));
        expect(tester.takeException(), isNull);
      },
    );

    for (final state in [
      DisplayFeatureState.postureHalfOpened,
      DisplayFeatureState.postureFlat,
    ]) {
      for (final vertical in [true, false]) {
        testWidgets(
          'zero-area ${vertical ? 'vertical' : 'horizontal'} fold in ${state.name} keeps the whole viewport',
          (tester) async {
            setViewport(tester, viewport);
            await pumpTabSwitcher(tester, tabSessions: manySessions);
            final ordinaryRect = panelRect(tester);
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pumpAndSettle();
            await pumpTabSwitcher(
              tester,
              tabSessions: manySessions,
              displayFeatures: [
                DisplayFeature(
                  bounds: vertical
                      ? const Rect.fromLTWH(600, 0, 0, 1000)
                      : const Rect.fromLTWH(0, 500, 1200, 0),
                  type: DisplayFeatureType.fold,
                  state: state,
                ),
              ],
            );

            final rect = panelRect(tester);
            expect(rect.center, viewport.center(Offset.zero));
            expect(rect, ordinaryRect);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }

    for (final vertical in [true, false]) {
      testWidgets(
        '${vertical ? 'vertical' : 'horizontal'} occluding hinge keeps the panel in one sub-screen',
        (tester) async {
          setViewport(tester, viewport);
          final hinge = vertical
              ? const Rect.fromLTWH(580, 0, 40, 1000)
              : const Rect.fromLTWH(0, 480, 1200, 40);
          await pumpTabSwitcher(
            tester,
            tabSessions: manySessions,
            displayFeatures: [
              DisplayFeature(
                bounds: hinge,
                type: DisplayFeatureType.hinge,
                state: DisplayFeatureState.unknown,
              ),
            ],
          );

          final rect = panelRect(tester);
          expect(rect.overlaps(hinge), isFalse);
          if (vertical) {
            expect(rect.right, lessThanOrEqualTo(hinge.left));
            expect(rect.center, const Offset(290, 500));
          } else {
            expect(rect.bottom, lessThanOrEqualTo(hinge.top));
            expect(rect.center, const Offset(600, 240));
          }
          expect(rect.width, lessThanOrEqualTo(560));
          expect(rect.height, lessThanOrEqualTo(520));
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
