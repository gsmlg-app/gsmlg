import 'package:app_editor/app_editor.dart';
import 'package:app_logging/app_logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/app.dart';
import 'package:gsmlg/router.dart';
import 'package:navigation_bloc/navigation_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_bloc/theme_bloc.dart';

class _Sink implements LogSink {
  final usage = <UsageEvent>[];
  @override
  void writeApi(ApiExchangeRecord r) {}
  @override
  void writeAgent(AgentLogEvent e) {}
  @override
  void writeUsage(UsageEvent e) => usage.add(e);
}

void main() {
  late GoRouter previousRouter;
  late GoRouter routes;
  late NavigationBloc navigation;
  late DmThemeBloc theme;
  late EditorFileService files;
  late _Sink sink;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    theme = DmThemeBloc(prefs: await SharedPreferences.getInstance());
    navigation = NavigationBloc();
    files = EditorFileService(nativeDocuments: false);
    sink = _Sink();
    LogCapture.instance.attach(sink);
    previousRouter = AppRouter.router;
    routes = GoRouter(
      navigatorKey: AppRouter.key,
      initialLocation: '/page',
      routes: [
        GoRoute(
          path: '/page',
          name: 'Page',
          builder: (_, _) => const Scaffold(body: Text('page')),
        ),
      ],
    );
    AppRouter.router = routes;
  });

  tearDown(() async {
    LogCapture.instance.attach(null);
    AppRouter.router = previousRouter;
    routes.dispose();
    await navigation.close();
    await theme.close();
    files.dispose();
  });

  testWidgets('pause flushes logs after the open screen visit is closed', (
    tester,
  ) async {
    final flushedWithVisit = <bool>[];
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpWidget(
      RepositoryProvider<EditorFileService>.value(
        value: files,
        child: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: navigation),
            BlocProvider.value(value: theme),
          ],
          child: App(
            flushLogs: () async => flushedWithVisit.add(
              sink.usage.any((e) => e.eventType == 'screen_view'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(flushedWithVisit, isEmpty);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    expect(flushedWithVisit, isNotEmpty);
    expect(flushedWithVisit.first, isTrue);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
