import 'package:flutter/material.dart';
import 'package:gsmlg/screens/app/error_screen.dart';
import 'package:gsmlg/screens/app/splash_screen.dart';
import 'package:gsmlg/screens/home/home_screen.dart';
import 'package:gsmlg/screens/service/service_routes.dart';
import 'package:gsmlg/screens/settings/settings_routes.dart';
import 'package:gsmlg/screens/sign/auth_screen.dart';
import 'package:gsmlg/screens/toolbox/toolbox_routes.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>(
    debugLabel: 'routerKey',
  );

  static GoRouter router = GoRouter(
    navigatorKey: key,
    debugLogDiagnostics: true,
    initialLocation: SplashScreen.path,
    routes: routes,
    errorBuilder: (context, state) {
      return ErrorScreen(routerState: state);
    },
  );

  static List<GoRoute> routes = [
    GoRoute(
      name: SplashScreen.name,
      path: SplashScreen.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: const SplashScreen(),
        );
      },
    ),
    GoRoute(
      name: HomeScreen.name,
      path: HomeScreen.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: const HomeScreen(),
        );
      },
    ),
    serviceRoutes(),
    toolboxRoutes(),
    GoRoute(
      name: AuthScreen.name,
      path: AuthScreen.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: const AuthScreen(),
        );
      },
    ),
    settingsRoutes(),
  ];
}
