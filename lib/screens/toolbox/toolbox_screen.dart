import 'dart:io';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_components/app_components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/constants.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/toolbox/bluetooth/bluetooth_scanner_screen.dart';
import 'package:gsmlg/screens/toolbox/camera/camera_macos_screen.dart';
import 'package:gsmlg/screens/toolbox/camera/camera_screen.dart';
import 'package:gsmlg/screens/toolbox/ip_geo/ip_geo_screen.dart';
import 'package:gsmlg/screens/toolbox/monitor/monitor_screen.dart';
import 'package:gsmlg/screens/toolbox/whois/whois_screen.dart';

class ToolboxScreen extends StatelessWidget {
  static const name = 'Toolbox';
  static const path = '/toolbox';

  const ToolboxScreen({super.key});

  /// Check if platform supports Bluetooth (Android, iOS, macOS)
  static bool get _isBluetoothPlatform {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  }

  /// Check if platform is mobile (Android, iOS)
  static bool get _isMobilePlatform {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(const Key(name), context),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => SafeArea(
        minimum: const EdgeInsets.symmetric(
          horizontal: Constants.defaultGridGap,
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              expandedHeight: 160.0,
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: Constants.logoTag,
                  child: SvgPicture.asset(
                    'packages/app_artwork/assets/svg/gsmlg-dev.svg',
                    semanticsLabel: 'GSMLG.dev',
                  ),
                ),
              ),
            ),
            SliverGrid.count(
              crossAxisSpacing: Constants.defaultGridGap,
              mainAxisSpacing: Constants.defaultGridGap,
              crossAxisCount: (screenSize.width / 300).ceil(),
              children: <Widget>[
                AppGridTile(
                  onTap: () => context.goNamed(WhoisScreen.name),
                  child: const Text('Whois'),
                ),
                AppGridTile(
                  onTap: () => context.goNamed(IpGeoScreen.name),
                  child: const Text('IP Geolocation'),
                ),
                AppGridTile(
                  onTap: () => context.goNamed(MonitorScreen.name),
                  child: const Text('Monitor'),
                ),
                if (_isBluetoothPlatform)
                  AppGridTile(
                    onTap: () => context.goNamed(BluetoothScannerScreen.name),
                    child: const Text('Bluetooth Scanner'),
                  ),
                if (_isMobilePlatform)
                  AppGridTile(
                    onTap: () => context.goNamed(CameraScreen.name),
                    child: const Text('Camera'),
                  ),
                if (!kIsWeb && Platform.isMacOS)
                  AppGridTile(
                    onTap: () => context.goNamed(CameraMacosScreen.name),
                    child: const Text('Camera'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
