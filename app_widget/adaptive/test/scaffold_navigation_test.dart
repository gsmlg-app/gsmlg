import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_bloc/navigation_bloc.dart';

void main() {
  for (final width in [750.0, 1300.0]) {
    testWidgets('route replacement preserves hidden navigation at $width', (
      tester,
    ) async {
      await _setSize(tester, width);
      await tester.pumpWidget(const _RouteHarness());
      await tester.pumpAndSettle();
      final firstScaffold = tester.state(
        find.byKey(const ValueKey('first-scaffold')),
      );

      await tester.tap(find.byTooltip('Hide navigation'));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byTooltip('Show navigation'), findsOneWidget);

      Navigator.of(
        tester.element(find.byKey(const ValueKey('first-scaffold'))),
      ).pushReplacementNamed('second');
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('first-scaffold')), findsNothing);
      expect(find.byKey(const ValueKey('second-scaffold')), findsOneWidget);
      expect(firstScaffold.mounted, isFalse);
      expect(
        tester.state(find.byKey(const ValueKey('second-scaffold'))),
        isNot(same(firstScaffold)),
      );
      expect(find.text('Route second'), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byTooltip('Show navigation'), findsOneWidget);

      await tester.tap(find.byTooltip('Show navigation'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<NavigationRail>(find.byType(NavigationRail))
            .selectedIndex,
        2,
      );
      expect(tester.takeException(), isNull);
    });

    for (final extended in [false, true]) {
      testWidgets(
        'route replacement preserves explicit extension $extended from $width',
        (tester) async {
          await _setSize(tester, width);
          await tester.pumpWidget(const _RouteHarness());
          await tester.pumpAndSettle();
          final rail = find.byType(NavigationRail);
          final initiallyExtended =
              tester.widget<NavigationRail>(rail).extended;
          if (initiallyExtended == extended) {
            await tester.tap(
              find.byTooltip(
                extended ? 'Collapse navigation' : 'Expand navigation',
              ),
            );
            await tester.pumpAndSettle();
          }
          await tester.tap(
            find.byTooltip(
              extended ? 'Expand navigation' : 'Collapse navigation',
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.widget<NavigationRail>(rail).extended, extended);
          await tester.tap(find.byTooltip('Hide navigation'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Show navigation'));
          await tester.pumpAndSettle();
          expect(tester.widget<NavigationRail>(rail).extended, extended);
          final firstScaffold = tester.state(
            find.byKey(const ValueKey('first-scaffold')),
          );

          Navigator.of(
            tester.element(find.byKey(const ValueKey('first-scaffold'))),
          ).pushReplacementNamed('second');
          await tester.pumpAndSettle();
          // Use a breakpoint whose automatic extension differs from the user's
          // choice, so a new rail's default cannot accidentally pass the test.
          tester.view.physicalSize = Size(extended ? 750 : 1300, 1000);
          await tester.pumpAndSettle();

          expect(find.byKey(const ValueKey('first-scaffold')), findsNothing);
          expect(find.byKey(const ValueKey('second-scaffold')), findsOneWidget);
          expect(firstScaffold.mounted, isFalse);
          expect(
            tester.state(find.byKey(const ValueKey('second-scaffold'))),
            isNot(same(firstScaffold)),
          );
          expect(find.text('Route second'), findsOneWidget);
          expect(tester.widget<NavigationRail>(rail).extended, extended);
          expect(tester.widget<NavigationRail>(rail).selectedIndex, 2);
          expect(
            find.byTooltip(
              extended ? 'Collapse navigation' : 'Expand navigation',
            ),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('global preferences survive narrow layout and route replacement',
      (
    tester,
  ) async {
    await _setSize(tester, 1300);
    await tester.pumpWidget(const _RouteHarness());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Collapse navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Hide navigation'));
    await tester.pumpAndSettle();

    tester.view.physicalSize = const Size(400, 1000);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byTooltip('Show navigation'), findsNothing);
    final firstScaffold = tester.state(
      find.byKey(const ValueKey('first-scaffold')),
    );
    Navigator.of(
      tester.element(find.byKey(const ValueKey('first-scaffold'))),
    ).pushReplacementNamed('second');
    await tester.pumpAndSettle();
    expect(firstScaffold.mounted, isFalse);
    expect(find.byKey(const ValueKey('second-scaffold')), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      2,
    );

    tester.view.physicalSize = const Size(1300, 1000);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsNothing);
    await tester.tap(find.byTooltip('Show navigation'));
    await tester.pumpAndSettle();
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.extended, isFalse);
    expect(rail.selectedIndex, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('caller extension override does not replace global preference', (
    tester,
  ) async {
    await _setSize(tester, 1300);
    final changes = <bool>[];
    await tester.pumpWidget(
      _RouteHarness(
        initialExtension: false,
        firstExtensionOverride: false,
        onFirstExtendedChange: changes.add,
      ),
    );
    await tester.pumpAndSettle();
    final firstContext = tester.element(
      find.byKey(const ValueKey('first-scaffold')),
    );
    final navigationBloc = firstContext.read<NavigationBloc>();
    expect(navigationBloc.state.isExtended, isFalse);
    await tester.tap(find.byTooltip('Expand navigation'));
    await tester.pumpAndSettle();
    expect(changes, [true]);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
      isFalse,
    );
    expect(navigationBloc.state.isExtended, isFalse);

    Navigator.of(firstContext).pushReplacementNamed('second');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('first-scaffold')), findsNothing);
    expect(find.byKey(const ValueKey('second-scaffold')), findsOneWidget);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
      isFalse,
    );
    expect(navigationBloc.state.isExtended, isFalse);
    expect(changes, [true]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('common scaffold enables the rail collapse control by default', (
    tester,
  ) async {
    await _setSize(tester, 1300);
    await tester.pumpWidget(
      MaterialApp(
        home: AppAdaptiveScaffold(
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.explore), label: 'Explore'),
          ],
          body: (_) => const _DraftBody(title: 'Chat'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Collapse navigation'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final width in [750.0, 1300.0]) {
    testWidgets('sidebar controls hide and restore navigation at width $width',
        (
      tester,
    ) async {
      await _setSize(tester, width);
      await tester.pumpWidget(const _Harness());
      await tester.pumpAndSettle();

      final rail = find.byType(NavigationRail);
      final hide = find.byTooltip('Hide navigation');
      expect(rail, findsOneWidget);
      expect(hide, findsOneWidget);
      expect(find.byTooltip('Show navigation'), findsNothing);

      final railRect = tester.getRect(rail);
      final hideRect = tester.getRect(hide);
      expect(hideRect.right, lessThanOrEqualTo(railRect.right));
      expect(hideRect.right, greaterThan(railRect.center.dx));
      expect(
        hideRect.bottom,
        lessThan(tester.getCenter(find.byIcon(Icons.home)).dy),
      );
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(tester.widget<NavigationRail>(rail).selectedIndex, 0);

      final originalBody = tester.state<_DraftBodyState>(
        find.byType(_DraftBody),
      );
      await tester.enterText(find.byType(TextField), 'Keep this chat draft');
      await tester.tap(hide);
      await tester.pumpAndSettle();

      expect(rail, findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byTooltip('Hide navigation'), findsNothing);
      final show = find.byTooltip('Show navigation');
      expect(show, findsOneWidget);
      final bodyRect = tester.getRect(find.byType(_DraftBody));
      final showRect = tester.getRect(show);
      final scaffoldRect = tester.getRect(find.byType(AppAdaptiveScaffold));
      expect(showRect.left, greaterThanOrEqualTo(scaffoldRect.left));
      expect(showRect.left, lessThan(scaffoldRect.left + 24));
      expect(showRect.top, greaterThanOrEqualTo(scaffoldRect.top));
      expect(showRect.top, lessThan(scaffoldRect.top + 24));
      expect(showRect.bottom, lessThanOrEqualTo(bodyRect.top));
      expect(bodyRect.left, 0);
      expect(bodyRect.width, width);
      expect(
          tester.state<_DraftBodyState>(find.byType(_DraftBody)), originalBody);
      expect(find.text('Keep this chat draft'), findsOneWidget);

      await tester.tap(show);
      await tester.pumpAndSettle();

      expect(rail, findsOneWidget);
      expect(find.byTooltip('Hide navigation'), findsOneWidget);
      expect(find.byTooltip('Show navigation'), findsNothing);
      expect(tester.widget<NavigationRail>(rail).selectedIndex, 0);
      expect(
          tester.state<_DraftBodyState>(find.byType(_DraftBody)), originalBody);
      expect(find.text('Keep this chat draft'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'rail expands and collapses without changing selection at $width', (
      tester,
    ) async {
      await _setSize(tester, width);
      final changes = <bool>[];
      await tester.pumpWidget(_Harness(onExtendedChange: changes.add));
      await tester.pumpAndSettle();

      final rail = find.byType(NavigationRail);
      final initiallyExtended = tester.widget<NavigationRail>(rail).extended;
      final originalWidth = tester.getSize(rail).width;
      final toggle = find.byTooltip(
        initiallyExtended ? 'Collapse navigation' : 'Expand navigation',
      );
      expect(toggle, findsOneWidget);
      expect(
        find.byIcon(
          initiallyExtended ? Icons.chevron_left : Icons.chevron_right,
        ),
        findsOneWidget,
      );
      await tester.tap(toggle);
      await tester.pumpAndSettle();

      expect(tester.widget<NavigationRail>(rail).extended, !initiallyExtended);
      expect(
        tester.getSize(rail).width,
        initiallyExtended
            ? lessThan(originalWidth)
            : greaterThan(originalWidth),
      );
      expect(tester.widget<NavigationRail>(rail).selectedIndex, 1);
      expect(changes, [!initiallyExtended]);

      await tester.tap(find.byTooltip('Hide navigation'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Show navigation'));
      await tester.pumpAndSettle();
      expect(tester.widget<NavigationRail>(rail).extended, !initiallyExtended);

      await tester.tap(
        find.byTooltip(
          initiallyExtended ? 'Expand navigation' : 'Collapse navigation',
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<NavigationRail>(rail).extended, initiallyExtended);
      expect(changes, [!initiallyExtended, initiallyExtended]);
      expect(tester.takeException(), isNull);
    });
  }

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('narrow ${platform.name} retains bottom navigation', (
      tester,
    ) async {
      await _setSize(tester, 400);
      await tester.pumpWidget(_Harness(platform: platform));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byTooltip('Hide navigation'), findsNothing);
      expect(find.byTooltip('Show navigation'), findsNothing);
      expect(find.byTooltip('Expand navigation'), findsNothing);
      expect(find.byTooltip('Collapse navigation'), findsNothing);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<NavigationBar>(find.byType(NavigationBar))
              .selectedIndex,
          0);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('hidden tablet sidebar does not hide narrow bottom navigation', (
    tester,
  ) async {
    await _setSize(tester, 750);
    await tester.pumpWidget(const _Harness(platform: TargetPlatform.iOS));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Hide navigation'));
    await tester.pumpAndSettle();

    tester.view.physicalSize = const Size(400, 1000);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byTooltip('Show navigation'), findsNothing);
    expect(find.byTooltip('Hide navigation'), findsNothing);
    expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        1);

    tester.view.physicalSize = const Size(750, 1000);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byTooltip('Show navigation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom rail headers remain available in both rail states', (
    tester,
  ) async {
    await _setSize(tester, 1300);
    await tester.pumpWidget(
      const _Harness(
        leadingExtended: Text('Extended header'),
        leadingUnextended: Text('Compact header'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Extended header'), findsOneWidget);
    expect(find.byTooltip('Hide navigation'), findsOneWidget);
    await tester.tap(find.byTooltip('Collapse navigation'));
    await tester.pumpAndSettle();
    expect(find.text('Compact header'), findsOneWidget);
    expect(find.byTooltip('Hide navigation'), findsOneWidget);
    await tester.tap(find.byTooltip('Hide navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Show navigation'));
    await tester.pumpAndSettle();
    expect(find.text('Compact header'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('controlled rail extension retains the caller override', (
    tester,
  ) async {
    await _setSize(tester, 1300);
    final changes = <bool>[];
    await tester.pumpWidget(
      _Harness(isExtendedOverride: false, onExtendedChange: changes.add),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Expand navigation'));
    await tester.pumpAndSettle();
    expect(changes, [true]);
    expect(tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isFalse);
    expect(find.byTooltip('Expand navigation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('caller can disable the rail collapse toggle', (tester) async {
    await _setSize(tester, 1300);
    await tester.pumpWidget(const _Harness(showCollapseToggle: false));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byTooltip('Hide navigation'), findsOneWidget);
    expect(find.byTooltip('Collapse navigation'), findsNothing);
    expect(find.byTooltip('Expand navigation'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('large body override retains its state when sidebar is hidden', (
    tester,
  ) async {
    await _setSize(tester, 1300);
    await tester.pumpWidget(const _Harness(largeBodyOverride: true));
    await tester.pumpAndSettle();
    expect(find.text('Large body'), findsOneWidget);
    final originalBody = tester.state<_DraftBodyState>(find.byType(_DraftBody));
    await tester.enterText(find.byType(TextField), 'Override draft');
    await tester.tap(find.byTooltip('Hide navigation'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Show navigation'), findsOneWidget);
    expect(find.text('Large body'), findsOneWidget);
    expect(find.text('Override draft'), findsOneWidget);
    expect(
        tester.state<_DraftBodyState>(find.byType(_DraftBody)), originalBody);
    await tester.tap(find.byTooltip('Show navigation'));
    await tester.pumpAndSettle();
    expect(find.text('Override draft'), findsOneWidget);
    expect(
        tester.state<_DraftBodyState>(find.byType(_DraftBody)), originalBody);
    expect(tester.takeException(), isNull);
  });

  testWidgets('restore control does not cover the nested AppBar back button', (
    tester,
  ) async {
    await _setSize(tester, 1300);
    await tester.pumpWidget(const _Harness());
    await tester.pumpAndSettle();
    final bodyState = tester.state<_DraftBodyState>(find.byType(_DraftBody));
    await tester.tap(find.byTooltip('Hide navigation'));
    await tester.pumpAndSettle();
    final show = find.byTooltip('Show navigation');
    final back = find.byType(BackButton);
    expect(tester.getRect(show).overlaps(tester.getRect(back)), isFalse);
    await tester.tap(back);
    await tester.pumpAndSettle();
    expect(bodyState.backPressed, isTrue);
    expect(show, findsOneWidget);
    await tester.tap(show);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(tester.state<_DraftBodyState>(find.byType(_DraftBody)), bodyState);
    expect(tester.takeException(), isNull);
  });

  for (final width in [400.0, 1300.0]) {
    testWidgets('explicit navigationVisible false hides navigation at $width', (
      tester,
    ) async {
      await _setSize(tester, width);
      await tester.pumpWidget(const _Harness(navigationVisible: false));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(_DraftBody), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

class _RouteHarness extends StatelessWidget {
  const _RouteHarness({
    this.initialExtension,
    this.firstExtensionOverride,
    this.onFirstExtendedChange,
  });

  final bool? initialExtension;
  final bool? firstExtensionOverride;
  final ValueChanged<bool>? onFirstExtendedChange;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = NavigationBloc();
        final extension = initialExtension;
        if (extension != null) {
          bloc.add(NavigationRailExtendedChanged(extension));
        }
        return bloc;
      },
      child: MaterialApp(
        theme: ThemeData(platform: TargetPlatform.macOS),
        initialRoute: 'first',
        onGenerateRoute: (settings) => PageRouteBuilder<void>(
          settings: settings,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (context, animation, secondaryAnimation) {
            final route = settings.name!;
            return AppAdaptiveScaffold(
              key: ValueKey('$route-scaffold'),
              selectedIndex: route == 'first' ? 1 : 2,
              isExtendedOverride:
                  route == 'first' ? firstExtensionOverride : null,
              onExtendedChange: route == 'first' ? onFirstExtendedChange : null,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(
                    icon: Icon(Icons.explore), label: 'Explore'),
                NavigationDestination(
                    icon: Icon(Icons.settings), label: 'Settings'),
              ],
              body: (_) => _DraftBody(title: 'Route $route'),
            );
          },
        ),
      ),
    );
  }
}

Future<void> _setSize(WidgetTester tester, double width) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 1000);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

class _Harness extends StatefulWidget {
  const _Harness({
    this.platform = TargetPlatform.macOS,
    this.onExtendedChange,
    this.leadingExtended,
    this.leadingUnextended,
    this.largeBodyOverride = false,
    this.navigationVisible = true,
    this.isExtendedOverride,
    this.showCollapseToggle = true,
  });

  final TargetPlatform platform;
  final ValueChanged<bool>? onExtendedChange;
  final Widget? leadingExtended;
  final Widget? leadingUnextended;
  final bool largeBodyOverride;
  final bool navigationVisible;
  final bool? isExtendedOverride;
  final bool showCollapseToggle;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  int selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(platform: widget.platform),
      home: AppAdaptiveScaffold(
        selectedIndex: selectedIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onSelectedIndexChange: (index) => setState(() => selectedIndex = index),
        onExtendedChange: widget.onExtendedChange,
        leadingExtendedNavRail: widget.leadingExtended,
        leadingUnextendedNavRail: widget.leadingUnextended,
        navigationVisible: widget.navigationVisible,
        isExtendedOverride: widget.isExtendedOverride,
        showCollapseToggle: widget.showCollapseToggle,
        body: (_) => const _DraftBody(title: 'Chat'),
        largeBody: widget.largeBodyOverride
            ? (_) => const _DraftBody(title: 'Large body')
            : null,
      ),
    );
  }
}

class _DraftBody extends StatefulWidget {
  const _DraftBody({required this.title});

  final String title;

  @override
  State<_DraftBody> createState() => _DraftBodyState();
}

class _DraftBodyState extends State<_DraftBody> {
  final controller = TextEditingController();
  bool backPressed = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading:
            BackButton(onPressed: () => setState(() => backPressed = true)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: TextField(controller: controller),
        ),
      ),
    );
  }
}
