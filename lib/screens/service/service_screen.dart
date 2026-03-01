import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_components/app_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:github_bloc/github_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/constants.dart';
import 'package:gsmlg/destination.dart';

class ServiceScreen extends StatelessWidget {
  static const name = 'Service';
  static const path = '/service';

  const ServiceScreen({super.key});

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
                  onTap: () => context.go('/service/domain'),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.dns, size: 48),
                      SizedBox(height: 8),
                      Text('Domain'),
                    ],
                  ),
                ),
                AppGridTile(
                  onTap: () => context.go('/service/vultr'),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud, size: 48),
                      SizedBox(height: 8),
                      Text('Vultr'),
                    ],
                  ),
                ),
                BlocBuilder<GitHubBloc, GitHubState>(
                  builder: (context, state) {
                    final isConnected = state is GitHubConnected;
                    return AppGridTile(
                      onTap: () => context.go('/service/github'),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              const Icon(Icons.code, size: 48),
                              if (isConnected)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('GitHub'),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
