import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gsmlg/constants.dart';
import 'package:gsmlg/destination.dart';

class HomeScreen extends StatefulWidget {
  static const name = 'Home';
  static const path = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) {});
  }

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      selectedIndex: 0,
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      trailingNavRail: SlotLayout(
        config: {
          AppAdaptiveScaffold.appMediumBreakpoint: SlotLayout.from(
            key: const Key('Body Medium'),
            builder: (context) => AppAdaptiveActionList(
              direction: Axis.vertical,
              actions: [],
            ),
          ),
          AppAdaptiveScaffold.appLargeBreakpoint: SlotLayout.from(
            key: const Key('Body Small'),
            builder: (context) => AppAdaptiveActionList(
              size: AppAdaptiveActionSize.large,
              direction: Axis.vertical,
              actions: [],
            ),
          ),
        },
      ),
      body: (_) => SafeArea(
        minimum:
            const EdgeInsets.symmetric(horizontal: Constants.defaultGridGap),
        child: CustomScrollView(slivers: [
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
        ]),
      ),
    );
  }
}
