import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/service/domain/add_zone_screen.dart';
import 'package:gsmlg/screens/service/domain/domain_screen.dart';
import 'package:gsmlg/screens/service/domain/zone_detail_screen.dart';
import 'package:gsmlg/screens/service/service_screen.dart';

GoRoute serviceRoutes() {
  return GoRoute(
    name: ServiceScreen.name,
    path: ServiceScreen.path,
    pageBuilder: (context, state) {
      return NoTransitionPage<void>(
        key: state.pageKey,
        restorationId: state.pageKey.value,
        child: const ServiceScreen(),
      );
    },
    routes: [
      GoRoute(
        name: DomainScreen.name,
        path: DomainScreen.path,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            restorationId: state.pageKey.value,
            child: const DomainScreen(),
          );
        },
        routes: [
          GoRoute(
            name: AddZoneScreen.name,
            path: AddZoneScreen.path,
            pageBuilder: (context, state) {
              return NoTransitionPage<void>(
                key: state.pageKey,
                restorationId: state.pageKey.value,
                child: const AddZoneScreen(),
              );
            },
          ),
          GoRoute(
            name: ZoneDetailScreen.name,
            path: ZoneDetailScreen.path,
            pageBuilder: (context, state) {
              final zoneId =
                  int.tryParse(state.pathParameters['zoneId'] ?? '') ?? 0;
              return NoTransitionPage<void>(
                key: state.pageKey,
                restorationId: state.pageKey.value,
                child: ZoneDetailScreen(zoneId: zoneId),
              );
            },
          ),
        ],
      ),
    ],
  );
}
