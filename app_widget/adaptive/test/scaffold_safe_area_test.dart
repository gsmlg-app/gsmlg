import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_bloc/navigation_bloc.dart';

/// iPhone in landscape reports a horizontal safe-area inset on the Dynamic
/// Island side (≈62 pt). The navigation rail must keep its icons inside the
/// rail and clear of the inset instead of clipping them under the body.
void main() {
  for (final extended in [false, true]) {
    for (final leftInset in [0.0, 62.0]) {
      testWidgets(
          'rail icons stay inside the ${extended ? 'extended' : 'collapsed'} '
          'rail with horizontal inset $leftInset', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(874, 402);
        tester.view.padding =
            FakeViewPadding(left: leftInset, right: leftInset, bottom: 21);
        tester.view.viewPadding =
            FakeViewPadding(left: leftInset, right: leftInset, bottom: 21);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          BlocProvider(
            create: (_) => NavigationBloc(),
            child: MaterialApp(
              theme: ThemeData(platform: TargetPlatform.iOS),
              home: AppAdaptiveScaffold(
                navigationRestoreInHeader: true,
                isExtendedOverride: extended,
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                  NavigationDestination(
                    icon: Icon(Icons.explore),
                    label: 'Explore',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
                body: (_) => const ColoredBox(
                  color: Colors.black,
                  child: SizedBox.expand(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final rail = tester.getRect(find.byType(NavigationRail));
        for (final icon in [Icons.home, Icons.explore, Icons.settings]) {
          final rect = tester.getRect(
            find.descendant(
              of: find.byType(NavigationRail),
              matching: find.byIcon(icon),
            ),
          );
          expect(
            rect.size,
            const Size(24, 24),
            reason: '$icon must keep its full size (not squeezed or clipped)',
          );
          expect(
            rect.left,
            greaterThanOrEqualTo(leftInset),
            reason: '$icon must not sit under the safe-area inset',
          );
          expect(
            rect.right,
            lessThanOrEqualTo(rail.right),
            reason: '$icon must not be clipped at the rail edge',
          );
        }
      });
    }
  }
}
