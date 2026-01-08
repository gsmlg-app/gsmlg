import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_components/app_components.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';
import 'package:gsmlg/screens/toolbox/whois/whois_history_show_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:whois_history_bloc/whois_history_bloc.dart';

class WhoisHistoryScreen extends StatefulWidget {
  static const name = 'Whois History';
  static const path = 'history';

  const WhoisHistoryScreen({super.key});

  @override
  State<WhoisHistoryScreen> createState() => _WhoisHistoryScreenState();
}

class _WhoisHistoryScreenState extends State<WhoisHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WhoisHistoryBloc>().add(const WhoisHistorySync());
  }

  @override
  Widget build(BuildContext context) {
    const String title = 'Whois Search History';

    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(ToolboxScreen.name),
        context,
      ),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: kDefaultGridGap),
        child: RefreshIndicator(
          onRefresh: () {
            context.read<WhoisHistoryBloc>().add(const WhoisHistorySync());
            return Future.value(null);
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                title: const Text(title),
                actions: [
                  AppAdaptiveActionList(
                    actions: [
                      AppAdaptiveAction(
                        icon: Icons.clear_all_rounded,
                        title: 'Clear History',
                        onPressed: () {
                          showAdaptiveDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog.adaptive(
                                title: const Text('Clear History'),
                                content: const Text(
                                  'Are you sure you want to clear the history?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      context
                                          .read<WhoisHistoryBloc>()
                                          .add(const WhoisHistoryRemoveAll());
                                    },
                                    child: const Text(
                                      'Clear',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              BlocBuilder<WhoisHistoryBloc, WhoisHistoryState>(
                builder: (context, state) {
                  if (state is WhoisHistoryInitial ||
                      state is WhoisHistoryLoading) {
                    return SliverToBoxAdapter(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.618,
                        child: const Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      ),
                    );
                  }
                  if (state is WhoisHistoryFailure) {
                    return SliverToBoxAdapter(
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
                    if (state.data.isEmpty) {
                      return SliverToBoxAdapter(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.618,
                          child: const Center(
                            child: Text('No history yet'),
                          ),
                        ),
                      );
                    }
                    return SliverList.list(
                      children: [
                        for (final item in state.data)
                          Card(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            elevation: kDefaultGridGap,
                            child: Slidable(
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      context.read<WhoisHistoryBloc>().add(
                                            WhoisHistoryRemoveOne(item),
                                          );
                                    },
                                    label: 'Delete',
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .errorContainer,
                                    icon: Icons.delete,
                                  ),
                                ],
                              ),
                              child: ListTile(
                                title: Hero(
                                  tag: 'whois-history-${item.id}',
                                  createRectTween: (Rect? begin, Rect? end) {
                                    return MaterialRectCenterArcTween(
                                      begin: begin,
                                      end: end,
                                    );
                                  },
                                  child: TextButton(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(item.query ?? ''),
                                    ),
                                    onPressed: () {
                                      context.goNamed(
                                        WhoisHistoryShowScreen.name,
                                        pathParameters: {
                                          'historyId': item.id.toString(),
                                        },
                                      );
                                    },
                                  ),
                                ),
                                trailing: Text(
                                  DateFormat('yyyy-MM-dd HH:mm:ss')
                                      .format(item.createdAt),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.618),
                                      ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
