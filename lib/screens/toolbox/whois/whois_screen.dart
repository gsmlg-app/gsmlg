import 'dart:io';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_components/app_components.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';
import 'package:gsmlg/screens/toolbox/whois/whois_history_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:whois_bloc/whois_bloc.dart';

class WhoisScreen extends StatelessWidget {
  static const name = 'Whois';
  static const path = 'whois';

  WhoisScreen({super.key});

  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const String title = 'Whois';

    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(ToolboxScreen.name),
        context,
      ),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => SafeArea(
        minimum: Platform.isMacOS
            ? const EdgeInsets.all(kDefaultGridGap)
            : const EdgeInsets.symmetric(horizontal: kDefaultGridGap),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: const Text(title),
              actions: [
                AppAdaptiveActionList(
                  actions: [
                    AppAdaptiveAction(
                      icon: Icons.history,
                      title: 'History',
                      onPressed: () => context.goNamed(WhoisHistoryScreen.name),
                    ),
                  ],
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48.0 + 24.0),
                child: Container(
                  margin: const EdgeInsets.all(12.0),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    autocorrect: false,
                    controller: _controller,
                    onSubmitted: (value) {
                      context.read<WhoisBloc>().add(WhoisLookup(value));
                    },
                    decoration: InputDecoration(
                      hintText: 'Find Whois',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          context.read<WhoisBloc>().add(const WhoisReset());
                        },
                      ),
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          context
                              .read<WhoisBloc>()
                              .add(WhoisLookup(_controller.text));
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            BlocBuilder<WhoisBloc, WhoisState>(
              builder: (context, state) {
                if (state is WhoisInitial) {
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.618,
                      child: Center(
                        child: Text(
                          'Whois Lookup Tool',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                  );
                }
                if (state is WhoisLoading) {
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.618,
                      child: const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    ),
                  );
                }
                if (state is WhoisFailure) {
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.618,
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Failed to load Whois data',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                if (state is WhoisLoaded) {
                  return SliverList.list(
                    children: [
                      for (final info in state.data) WhoisInfo(info: info),
                    ],
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
    );
  }
}
