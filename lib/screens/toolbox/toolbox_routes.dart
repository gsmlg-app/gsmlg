import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/toolbox/bluetooth/bluetooth_device_screen.dart';
import 'package:gsmlg/screens/toolbox/bluetooth/bluetooth_scanner_screen.dart';
import 'package:gsmlg/screens/toolbox/camera/camera_macos_screen.dart';
import 'package:gsmlg/screens/toolbox/camera/camera_screen.dart';
import 'package:gsmlg/screens/toolbox/ip_geo/ip_geo_screen.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';
import 'package:gsmlg/screens/toolbox/whois/whois_history_screen.dart';
import 'package:gsmlg/screens/toolbox/whois/whois_history_show_screen.dart';
import 'package:gsmlg/screens/toolbox/whois/whois_screen.dart';

/// Returns the GoRoute configuration for the Toolbox feature.
GoRoute toolboxRoutes() => GoRoute(
      name: ToolboxScreen.name,
      path: ToolboxScreen.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: const ToolboxScreen(),
        );
      },
      routes: [
        // Whois routes
        GoRoute(
          name: WhoisScreen.name,
          path: WhoisScreen.path,
          pageBuilder: (context, state) {
            return NoTransitionPage<void>(
              key: state.pageKey,
              restorationId: state.pageKey.value,
              child: WhoisScreen(),
            );
          },
          routes: [
            GoRoute(
              name: WhoisHistoryScreen.name,
              path: WhoisHistoryScreen.path,
              pageBuilder: (context, state) {
                return NoTransitionPage<void>(
                  key: state.pageKey,
                  restorationId: state.pageKey.value,
                  child: const WhoisHistoryScreen(),
                );
              },
              routes: [
                GoRoute(
                  name: WhoisHistoryShowScreen.name,
                  path: WhoisHistoryShowScreen.path,
                  pageBuilder: (context, state) {
                    return NoTransitionPage<void>(
                      key: state.pageKey,
                      restorationId: state.pageKey.value,
                      child: WhoisHistoryShowScreen(
                        historyId:
                            int.parse(state.pathParameters['historyId']!),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        // Bluetooth routes
        GoRoute(
          name: BluetoothScannerScreen.name,
          path: BluetoothScannerScreen.path,
          pageBuilder: (context, state) {
            return NoTransitionPage<void>(
              key: state.pageKey,
              restorationId: state.pageKey.value,
              child: const BluetoothScannerScreen(),
            );
          },
          routes: [
            GoRoute(
              name: BluetoothDeviceScreen.name,
              path: BluetoothDeviceScreen.path,
              pageBuilder: (context, state) {
                return NoTransitionPage<void>(
                  key: state.pageKey,
                  restorationId: state.pageKey.value,
                  child: BluetoothDeviceScreen(
                    remoteId: state.pathParameters['remoteId']!,
                  ),
                );
              },
            ),
          ],
        ),
        // Camera routes
        GoRoute(
          name: CameraScreen.name,
          path: CameraScreen.path,
          pageBuilder: (context, state) {
            return NoTransitionPage<void>(
              key: state.pageKey,
              restorationId: state.pageKey.value,
              child: const CameraScreen(),
            );
          },
        ),
        GoRoute(
          name: CameraMacosScreen.name,
          path: CameraMacosScreen.path,
          pageBuilder: (context, state) {
            return NoTransitionPage<void>(
              key: state.pageKey,
              restorationId: state.pageKey.value,
              child: const CameraMacosScreen(),
            );
          },
        ),
        // IP Geolocation route
        GoRoute(
          name: IpGeoScreen.name,
          path: IpGeoScreen.path,
          pageBuilder: (context, state) {
            return NoTransitionPage<void>(
              key: state.pageKey,
              restorationId: state.pageKey.value,
              child: const IpGeoScreen(),
            );
          },
        ),
      ],
    );
