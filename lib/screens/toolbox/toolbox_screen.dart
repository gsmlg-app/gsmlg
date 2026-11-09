import 'dart:io';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_components/app_components.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gsmlg/constants.dart';
import 'package:gsmlg/core/usage/menu_navigation.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/toolbox/bluetooth/bluetooth_scanner_screen.dart';
import 'package:gsmlg/screens/toolbox/camera/camera_macos_screen.dart';
import 'package:gsmlg/screens/toolbox/camera/camera_screen.dart';
import 'package:gsmlg/screens/toolbox/compass/compass_screen.dart';
import 'package:gsmlg/screens/toolbox/editor/editor_screen.dart';
import 'package:gsmlg/screens/toolbox/ip_geo/ip_geo_screen.dart';
import 'package:gsmlg/screens/toolbox/log_viewer/log_viewer_screen.dart';
import 'package:gsmlg/screens/toolbox/monitor/monitor_screen.dart';
import 'package:gsmlg/screens/toolbox/terminal/terminal_screen.dart';
import 'package:gsmlg/screens/toolbox/tts_dataset/tts_dataset_screen.dart';
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
      navigationRestoreInHeader: true,
      selectedIndex: Destinations.indexOf(const Key(name), context),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => SafeArea(
        minimum: const EdgeInsets.symmetric(
          horizontal: Constants.defaultGridGap,
        ),
        child: CustomScrollView(
          slivers: [
            DmNavigationHeader(
              builder: (context, header) => SliverAppBar(
                leading: header.leading,
                leadingWidth: header.leadingWidth,
                automaticallyImplyLeading: header.automaticallyImplyLeading,
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
            ),
            SliverGrid.count(
              crossAxisSpacing: Constants.defaultGridGap,
              mainAxisSpacing: Constants.defaultGridGap,
              crossAxisCount: (screenSize.width / 300).ceil(),
              children: <Widget>[
                if (!kIsWeb)
                  AppGridTile(
                    onTap: () => context.menuGoNamed(TerminalScreen.name),
                    child: Text(context.l10n.terminalTitle),
                  ),
                AppGridTile(
                  onTap: () => context.menuGoNamed(EditorScreen.name),
                  child: Text(context.l10n.editorTitle),
                ),
                AppGridTile(
                  onTap: () => context.menuGoNamed(WhoisScreen.name),
                  child: const Text('Whois'),
                ),
                AppGridTile(
                  onTap: () => context.menuGoNamed(IpGeoScreen.name),
                  child: const Text('IP Geolocation'),
                ),
                AppGridTile(
                  onTap: () => context.menuGoNamed(MonitorScreen.name),
                  child: const Text('Monitor'),
                ),
                AppGridTile(
                  onTap: () => context.menuGoNamed(TtsDatasetScreen.name),
                  child: Text(context.l10n.ttsDatasetTitle),
                ),
                AppGridTile(
                  onTap: () => context.menuGoNamed(LogViewerScreen.name),
                  child: Text(context.l10n.jsonLogInspectorTitle),
                ),
                if (_isBluetoothPlatform)
                  AppGridTile(
                    onTap: () =>
                        context.menuGoNamed(BluetoothScannerScreen.name),
                    child: const Text('Bluetooth Scanner'),
                  ),
                if (_isMobilePlatform)
                  AppGridTile(
                    onTap: () => context.menuGoNamed(CameraScreen.name),
                    child: const Text('Camera'),
                  ),
                if (isCompassPlatformSupported(
                  isWeb: kIsWeb,
                  platform: defaultTargetPlatform,
                ))
                  AppGridTile(
                    onTap: () => context.menuGoNamed(CompassScreen.name),
                    child: Text(context.l10n.compassTitle),
                  ),
                if (!kIsWeb && Platform.isMacOS)
                  AppGridTile(
                    onTap: () => context.menuGoNamed(CameraMacosScreen.name),
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
