import 'dart:convert';
import 'dart:typed_data';

import 'package:app_editor/app_editor.dart';
import 'package:editor_bloc/editor_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/app.dart';
import 'package:gsmlg/router.dart';
import 'package:gsmlg/screens/app/splash_screen.dart';
import 'package:gsmlg/screens/home/home_screen.dart';
import 'package:gsmlg/screens/toolbox/editor/editor_screen.dart';
import 'package:gsmlg/screens/toolbox/toolbox_routes.dart';
import 'package:navigation_bloc/navigation_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_bloc/theme_bloc.dart';

void main() {
  GoRouter router() => GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: '/home',
        name: HomeScreen.name,
        builder: (_, _) => const Text('home'),
      ),
      GoRoute(path: '/toolbox/editor', builder: (_, _) => const Text('editor')),
    ],
  );

  testWidgets('normal startup reaches Home after splash delay', (tester) async {
    final routes = router();
    addTearDown(routes.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: routes));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(routes.routeInformationProvider.value.uri.path, '/home');
  });

  testWidgets('file-open navigation cannot be overwritten by splash timer', (
    tester,
  ) async {
    final routes = router();
    addTearDown(routes.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: routes));
    await tester.pump(const Duration(milliseconds: 100));
    routes.go('/toolbox/editor');
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    expect(routes.routeInformationProvider.value.uri.path, '/toolbox/editor');
    expect(tester.takeException(), isNull);
  });

  group('App file-open during Editor exit', () {
    late GoRouter previousRouter;
    late GoRouter routes;
    late _Files files;
    late EditorCubit editor;
    late NavigationBloc navigation;
    late DmThemeBloc theme;
    late List<String> committedRoutes;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      theme = DmThemeBloc(prefs: await SharedPreferences.getInstance());
      navigation = NavigationBloc();
      files = _Files();
      editor = EditorCubit(files);
      previousRouter = AppRouter.router;
      routes = GoRouter(
        navigatorKey: AppRouter.key,
        initialLocation: '/toolbox/editor',
        routes: [
          toolboxRoutes(),
          GoRoute(
            path: '/other',
            builder: (_, _) => const Scaffold(body: Text('Other page')),
          ),
        ],
      );
      committedRoutes = [];
      routes.routerDelegate.addListener(() {
        committedRoutes.add(
          routes.routerDelegate.currentConfiguration.uri.path,
        );
      });
      AppRouter.router = routes;
    });

    tearDown(() async {
      AppRouter.router = previousRouter;
      routes.dispose();
      await editor.close();
      await navigation.close();
      await theme.close();
      files.dispose();
    });

    for (final choice in ['Cancel', 'Discard']) {
      testWidgets('$choice exit preserves one queued system file-open', (
        tester,
      ) async {
        addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
        await tester.pumpWidget(
          RepositoryProvider<EditorFileService>.value(
            value: files,
            child: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: editor),
                BlocProvider.value(value: navigation),
                BlocProvider.value(value: theme),
              ],
              child: const App(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        editor.updateText('unsaved edits');
        await tester.pump();
        final previousEditor = tester.state(find.byType(EditorScreen));
        routes.go('/other');
        await tester.pumpAndSettle();
        expect(routes.routeInformationProvider.value.uri.path, '/other');
        expect(
          routes.routerDelegate.currentConfiguration.uri.path,
          '/toolbox/editor',
        );

        files.receiveFiles(['incoming.json']);
        await tester.pumpAndSettle();
        expect(files.reads, isEmpty);
        expect(files.hasPendingFiles, isTrue);
        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.tap(find.text(choice));
        await tester.pumpAndSettle();

        if (choice == 'Cancel') {
          expect(previousEditor.mounted, isTrue);
          expect(committedRoutes, isNot(contains('/other')));
          expect(editor.state.text, 'unsaved edits');
          expect(find.byType(AlertDialog), findsOneWidget);
          await tester.tap(find.text('Discard'));
          await tester.pumpAndSettle();
        } else {
          expect(previousEditor.mounted, isFalse);
          expect(committedRoutes, contains('/other'));
        }

        expect(find.byType(EditorScreen), findsOneWidget);
        expect(files.reads, ['incoming.json']);
        expect(editor.state.name, 'incoming.json');
        expect(files.hasPendingFiles, isFalse);
        expect(find.byType(AlertDialog), findsNothing);

        // A later dirty request must still be able to confirm and drain.
        editor.updateText('more edits');
        await tester.pump();
        files.receiveFiles(['next.txt']);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.tap(find.text('Discard'));
        await tester.pumpAndSettle();
        expect(files.reads, ['incoming.json', 'next.txt']);
        expect(editor.state.name, 'next.txt');
        expect(files.hasPendingFiles, isFalse);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  });
}

class _Files extends EditorFileService {
  _Files() : super(nativeDocuments: false);

  final reads = <String>[];

  @override
  Future<EditorFile> readFile(String uri) async {
    reads.add(uri);
    return EditorFile(
      uri: uri,
      name: uri,
      bytes: Uint8List.fromList(utf8.encode('{}')),
    );
  }
}
