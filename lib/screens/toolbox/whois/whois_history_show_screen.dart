import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_components/app_components.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whois_history_bloc/whois_history_bloc.dart';

class WhoisHistoryShowScreen extends StatelessWidget {
  static const name = 'WhoisHistoryShowId';
  static const path = ':historyId';

  const WhoisHistoryShowScreen({super.key, required this.historyId});

  final int historyId;

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(ToolboxScreen.name),
        context,
      ),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: kDefaultGridGap),
        child: BlocBuilder<WhoisHistoryBloc, WhoisHistoryState>(
          builder: (context, state) {
            if (state is WhoisHistoryInitial || state is WhoisHistoryLoading) {
              return Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.618,
                  child: const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
              );
            }
            if (state is WhoisHistoryFailure) {
              return Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.618,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Error:'),
                        Text('Error: ${state.error}'),
                      ],
                    ),
                  ),
                ),
              );
            }
            if (state is WhoisHistoryLoaded) {
              final whoisHistory = state.data
                  .where((element) => element.id == historyId)
                  .firstOrNull;
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    title: Hero(
                      tag: 'whois-history-$historyId',
                      createRectTween: (Rect? begin, Rect? end) {
                        return MaterialRectCenterArcTween(
                          begin: begin,
                          end: end,
                        );
                      },
                      child: whoisHistory?.query != null
                          ? Text('Whois History: ${whoisHistory?.query}')
                          : const Text('Whois History'),
                    ),
                  ),
                  SliverList.list(
                    children: [
                      if (whoisHistory != null && whoisHistory.result != null)
                        for (final info in whoisHistory.result!)
                          WhoisInfo(info: info),
                    ],
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
