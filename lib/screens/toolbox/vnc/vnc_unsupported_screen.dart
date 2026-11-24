import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';

/// Browser stub for the VNC hosts screen without native socket or isolate imports.
class VncScreen extends StatelessWidget {
  static const name = 'Vnc';
  static const path = 'vnc';

  const VncScreen({super.key, this.autoDiscover = true});

  final bool autoDiscover;

  @override
  Widget build(BuildContext context) => AppAdaptiveScaffold(
    navigationRestoreInHeader: true,
    selectedIndex: Destinations.indexOf(const Key(ToolboxScreen.name), context),
    destinations: Destinations.navs(context),
    onSelectedIndexChange: (index) =>
        Destinations.changeHandler(index, context),
    body: (context) => SafeArea(
      child: CustomScrollView(
        slivers: [
          DmNavigationHeader(
            builder: (context, header) => SliverAppBar(
              leading: header.leading,
              leadingWidth: header.leadingWidth,
              automaticallyImplyLeading: header.automaticallyImplyLeading,
              title: Text(context.l10n.vncTitle),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(context.l10n.vncBrowserUnsupported),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Browser stub for the VNC session screen without native socket or isolate imports.
class VncSessionScreen extends StatelessWidget {
  static const name = 'VncSession';
  static const path = 'session';

  const VncSessionScreen({super.key, this.launchConfig});

  final Object? launchConfig;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.vncTitle)),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(context.l10n.vncBrowserUnsupported),
      ),
    ),
  );
}
