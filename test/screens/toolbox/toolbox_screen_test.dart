import 'package:app_components/app_components.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/toolbox/compass/compass_screen.dart';
import 'package:gsmlg/screens/toolbox/toolbox_routes.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const methods = MethodChannel('app_compass');
  const events = MethodChannel('app_compass/events');
  late List<String> channelCalls;

  setUp(() {
    channelCalls = [];
    for (final channel in [methods, events]) {
      binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        channelCalls.add(call.method);
        return null;
      });
    }
  });

  tearDown(() {
    for (final channel in [methods, events]) {
      binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    }
  });

  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
    TargetPlatform.linux,
    TargetPlatform.windows,
  ]) {
    _platformTestWidgets(
      'Compass tile visibility on ${platform.name}',
      platform,
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(900, 1200));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(_localizedApp(const ToolboxScreen()));
        final tile = find.ancestor(
          of: find.text('Compass'),
          matching: find.byType(AppGridTile),
        );
        expect(
          tile,
          platform == TargetPlatform.android || platform == TargetPlatform.iOS
              ? findsOneWidget
              : findsNothing,
        );
        expect(channelCalls, isEmpty);
      },
    );
  }

  _platformTestWidgets(
    'Compass tile opens its production Toolbox child route',
    TargetPlatform.android,
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final router = GoRouter(
        initialLocation: ToolboxScreen.path,
        routes: [toolboxRoutes()],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(_localizedRouterApp(router));
      await tester.pump();
      final tile = find.ancestor(
        of: find.text('Compass'),
        matching: find.byType(AppGridTile),
      );
      await tester.ensureVisible(tile);
      await tester.tap(tile);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(
        router.routeInformationProvider.value.uri.path,
        '/toolbox/compass',
      );
      expect(router.namedLocation(CompassScreen.name), '/toolbox/compass');
      expect(find.byType(CompassScreen), findsOneWidget);
      expect(find.text('Magnetic north'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  _platformTestWidgets(
    'desktop direct Compass route never contacts native channels',
    TargetPlatform.macOS,
    (tester) async {
      final router = GoRouter(
        initialLocation: '/toolbox/compass',
        routes: [toolboxRoutes()],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(_localizedRouterApp(router));
      await tester.pump();
      expect(find.byType(CompassScreen), findsOneWidget);
      expect(
        find.text('Compass is available on Android and iOS.'),
        findsOneWidget,
      );
      expect(channelCalls, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
}

void _platformTestWidgets(
  String description,
  TargetPlatform platform,
  WidgetTesterCallback body,
) {
  testWidgets(description, (tester) async {
    final previous = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = platform;
    try {
      await body(tester);
    } finally {
      debugDefaultTargetPlatformOverride = previous;
    }
  });
}

Widget _localizedApp(Widget child) => MaterialApp(
  localizationsDelegates: AppLocale.localizationsDelegates,
  supportedLocales: AppLocale.supportedLocales,
  home: child,
);

Widget _localizedRouterApp(GoRouter router) => MaterialApp.router(
  localizationsDelegates: AppLocale.localizationsDelegates,
  supportedLocales: AppLocale.supportedLocales,
  routerConfig: router,
);
