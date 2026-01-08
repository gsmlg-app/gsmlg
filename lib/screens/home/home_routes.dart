import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/home/home_screen.dart';

GoRoute homeRoutes() => GoRoute(
      name: HomeScreen.name,
      path: HomeScreen.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const HomeScreen(),
        );
      },
      routes: <RouteBase>[
        // Add any nested routes here if needed
      ],
    );
