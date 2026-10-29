import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/toolbox/terminal/widgets/tab_switcher.dart';
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
    List<DisplayFeature> displayFeatures = const [],
    ValueChanged<List<String>>? onReorder,
    void Function(String sessionId, String title)? onRename,
  }) async {
    final result = ValueNotifier<TabSwitcherResult?>(null);

    await tester.pumpWidget(
      MaterialApp(
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
                    sessions: tabSessions,
                    currentSessionId: '1',
                    onReorder: onReorder,
                    onRename: onRename,
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

  group('Tab switcher', () {
    testWidgets('confirms and returns selected tabs to close', (tester) async {
      final result = await pumpTabSwitcher(tester);

      await tester.tap(find.byTooltip('Select tabs'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('tab-switcher-card-2')));
      await tester.tap(find.byKey(const ValueKey('tab-switcher-card-3')));
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

    testWidgets('reorder button starts reorder and confirms new order', (
      tester,
    ) async {
      final reordered = <List<String>>[];
      await pumpTabSwitcher(tester, onReorder: reordered.add);

      await tester.tap(find.byTooltip('Reorder tabs'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Done reordering'), findsOneWidget);

      final dragStart = tester.getCenter(
        find.byKey(const ValueKey('tab-switcher-card-1')),
      );
      final dragEnd = tester.getCenter(
        find.byKey(const ValueKey('tab-switcher-card-3')),
      );
      final gesture = await tester.startGesture(dragStart);
      await gesture.moveTo(dragEnd);
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Done reordering'));
      await tester.pumpAndSettle();

      expect(reordered, [
        ['2', '3', '1'],
      ]);
    });

    testWidgets('long press opens rename input and updates title', (
      tester,
    ) async {
      final renamed = <String, String>{};
      await pumpTabSwitcher(
        tester,
        onRename: (sessionId, title) {
          renamed[sessionId] = title;
        },
      );

      await tester.longPress(find.byKey(const ValueKey('tab-switcher-card-2')));
      await tester.pumpAndSettle();

      expect(find.text('Rename Tab'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Build logs');
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      expect(renamed, {'2': 'Build logs'});
      expect(find.text('Build logs'), findsOneWidget);
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
