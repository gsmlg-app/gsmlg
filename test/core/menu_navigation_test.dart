import 'package:app_logging/app_logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/core/usage/menu_navigation.dart';
import 'package:gsmlg/core/usage/usage_tracker.dart';

class _Sink implements LogSink {
  final events = <UsageEvent>[];
  @override
  void writeApi(ApiExchangeRecord r) {}
  @override
  void writeAgent(AgentLogEvent e) {}
  @override
  void writeUsage(UsageEvent e) => events.add(e);
}

Widget _app() => MaterialApp.router(
  routerConfig: GoRouter(
    initialLocation: '/toolbox',
    routes: [
      GoRoute(
        name: 'Toolbox',
        path: '/toolbox',
        builder: (_, _) => Builder(
          builder: (context) => Column(
            children: [
              TextButton(
                onPressed: () => context.menuGoNamed('Whois'),
                child: const Text('named'),
              ),
              TextButton(
                onPressed: () => context.menuGo('/service/domain'),
                child: const Text('literal'),
              ),
            ],
          ),
        ),
      ),
      GoRoute(
        name: 'Whois',
        path: '/toolbox/whois',
        builder: (_, _) => const Text('whois page'),
      ),
      GoRoute(
        name: 'Domain',
        path: '/service/domain',
        builder: (_, _) => const Text('domain page'),
      ),
    ],
  ),
);

void main() {
  late _Sink sink;
  late UsageTracker tracker;

  setUp(() {
    sink = _Sink();
    LogCapture.instance.attach(sink);
    tracker = UsageTracker()..start();
    sink.events.clear();
  });
  tearDown(() {
    tracker.dispose();
    LogCapture.instance.attach(null);
  });

  testWidgets('menuGoNamed records the route name and navigates', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('named'));
    await tester.pumpAndSettle();

    expect(find.text('whois page'), findsOneWidget);
    final e = sink.events.single;
    expect(e.eventType, 'menu_tap');
    expect(e.target, 'Whois');
    expect(e.module, 'Toolbox');
    expect(e.sourceScreen, 'Toolbox');
    expect(e.sessionId, tracker.sessionId);
  });

  testWidgets('menuGo records the literal location', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('literal'));
    await tester.pumpAndSettle();

    expect(find.text('domain page'), findsOneWidget);
    final e = sink.events.single;
    expect(e.target, '/service/domain');
    expect(e.module, 'Service');
  });

  testWidgets('navigates without recording when no tracker is active', (
    tester,
  ) async {
    tracker.dispose();
    await tester.pumpWidget(_app());
    await tester.tap(find.text('named'));
    await tester.pumpAndSettle();
    expect(find.text('whois page'), findsOneWidget);
    expect(sink.events.where((e) => e.eventType == 'menu_tap'), isEmpty);
  });
}
