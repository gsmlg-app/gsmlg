import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';

/// Browser entry point without native shell or FFI dependencies.
class TerminalScreen extends StatelessWidget {
  static const name = 'TerminalScreen';
  static const path = 'terminal';

  const TerminalScreen({super.key});

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
              title: Text(context.l10n.terminalTitle),
            ),
          ),
          SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(context.l10n.terminalBrowserUnsupported),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
