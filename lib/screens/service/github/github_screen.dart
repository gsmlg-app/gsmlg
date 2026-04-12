import 'dart:io';

import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_components/app_components.dart';
import 'package:app_database/app_database.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_bloc/github_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/service/github/github_repo_screen.dart';
import 'package:gsmlg/screens/service/service_screen.dart';

class GitHubServiceScreen extends StatelessWidget {
  static const name = 'GitHubService';
  static const path = 'github';

  const GitHubServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GitHubBloc, GitHubState>(
      builder: (context, state) {
        if (state is! GitHubConnected) {
          return _buildNotConnected(context, state);
        }

        final api = context.read<GitHubBloc>().api;
        if (api == null) {
          return _buildNotConnected(context, state);
        }

        return MultiBlocProvider(
          providers: [
            BlocProvider<GitHubPinnedReposBloc>(
              create: (context) => GitHubPinnedReposBloc(
                database: context.read<AppDatabase>(),
                api: api,
              )..add(const GitHubPinnedReposLoad()),
            ),
            BlocProvider<GitHubReposBloc>(
              create: (context) =>
                  GitHubReposBloc(api: api)..add(const GitHubReposFetch()),
            ),
          ],
          child: _GitHubReposView(user: state.user),
        );
      },
    );
  }

  Widget _buildNotConnected(BuildContext context, GitHubState state) {
    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(ServiceScreen.name),
        context,
      ),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => SafeArea(
        minimum: Platform.isMacOS
            ? const EdgeInsets.all(kDefaultGridGap)
            : const EdgeInsets.symmetric(horizontal: kDefaultGridGap),
        child: BlocBuilder<AccountsBloc, AccountsState>(
          builder: (context, accountsState) {
            final githubAccounts = accountsState is AccountsLoaded
                ? accountsState.byProvider(ServiceProvider.github)
                : <ServiceAccountTableData>[];

            return CustomScrollView(
              slivers: [
                SliverAppBar(title: const Text('GitHub')),
                if (state is GitHubLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  )
                else if (state is GitHubError)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        color: Theme.of(context).colorScheme.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  state.message,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (githubAccounts.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Select a GitHub Account',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  SliverList.builder(
                    itemCount: githubAccounts.length,
                    itemBuilder: (context, index) {
                      final account = githubAccounts[index];
                      return ListTile(
                        leading: const Icon(Icons.code),
                        title: Text(account.name),
                        subtitle: account.description.isNotEmpty
                            ? Text(account.description)
                            : null,
                        trailing: FilledButton(
                          onPressed: () =>
                              _connectWithAccount(context, account),
                          child: const Text('Connect'),
                        ),
                      );
                    },
                  ),
                  const SliverToBoxAdapter(
                    child: Divider(indent: 16, endIndent: 16),
                  ),
                ] else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.code,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No GitHub Accounts',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          const Text('Add a GitHub account to get started'),
                        ],
                      ),
                    ),
                  ),
                ],
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add GitHub Account'),
                      onPressed: () => _showAddAccountDialog(context),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _connectWithAccount(
    BuildContext context,
    ServiceAccountTableData account,
  ) async {
    final accountsBloc = context.read<AccountsBloc>();
    final apiKey = await accountsBloc.getApiKey(account.id);
    if (apiKey != null && context.mounted) {
      context.read<GitHubBloc>().add(GitHubConnect(pat: apiKey));
    }
  }

  void _showAddAccountDialog(BuildContext context) {
    final nameController = TextEditingController();
    final patController = TextEditingController();
    bool obscurePat = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Add GitHub Account'),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          hintText: 'e.g. Personal, Work',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: patController,
                        obscureText: obscurePat,
                        decoration: InputDecoration(
                          labelText: 'Personal Access Token',
                          hintText: 'ghp_xxxxxxxxxxxxxxxxxxxx',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePat
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => obscurePat = !obscurePat),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                DmDialogAction(
                  onPressed: (ctx) => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final pat = patController.text.trim();
                    if (name.isEmpty || pat.isEmpty) return;

                    context.read<AccountsBloc>().add(
                      AccountsAdd(
                        provider: ServiceProvider.github,
                        name: name,
                        apiKey: pat,
                      ),
                    );
                    context.read<GitHubBloc>().add(GitHubConnect(pat: pat));
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Add & Connect'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _GitHubReposView extends StatefulWidget {
  const _GitHubReposView({required this.user});

  final GitHubUser user;

  @override
  State<_GitHubReposView> createState() => _GitHubReposViewState();
}

class _GitHubReposViewState extends State<_GitHubReposView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(ServiceScreen.name),
        context,
      ),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => Scaffold(
        appBar: DmAppBar(
          title: const Text('GitHub Repositories'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<GitHubPinnedReposBloc>().add(
                  const GitHubPinnedReposRefresh(),
                );
                context.read<GitHubReposBloc>().add(const GitHubReposRefresh());
              },
            ),
          ],
        ),
        body: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Pinned'),
                Tab(text: 'All Repos'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _PinnedReposTab(user: widget.user),
                  _AllReposTab(user: widget.user),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinnedReposTab extends StatelessWidget {
  const _PinnedReposTab({required this.user});

  final GitHubUser user;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GitHubPinnedReposBloc, GitHubPinnedReposState>(
      builder: (context, state) {
        if (state is GitHubPinnedReposLoading) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (state is GitHubPinnedReposError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    context.read<GitHubPinnedReposBloc>().add(
                      const GitHubPinnedReposLoad(),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is GitHubPinnedReposLoaded) {
          if (state.repos.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Pinned Repositories',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('Go to "All Repos" tab to pin repositories'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: state.repos.length,
            itemBuilder: (context, index) {
              final repo = state.repos[index];
              return _PinnedRepoTile(repo: repo);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _PinnedRepoTile extends StatelessWidget {
  const _PinnedRepoTile({required this.repo});

  final GitHubRepoTableData repo;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: repo.ownerAvatarUrl != null
          ? CircleAvatar(backgroundImage: NetworkImage(repo.ownerAvatarUrl!))
          : Icon(
              repo.isPrivate ? Icons.lock : Icons.public,
              color: repo.isPrivate
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.primary,
            ),
      title: Text(repo.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(repo.ownerLogin),
          if (repo.description != null)
            Text(
              repo.description!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_border, size: 16),
          const SizedBox(width: 4),
          Text('${repo.stargazersCount}'),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.bookmark_remove),
            onPressed: () {
              context.read<GitHubPinnedReposBloc>().add(
                GitHubPinnedReposRemove(repoId: repo.repoId),
              );
            },
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
      isThreeLine: repo.description != null,
      onTap: () {
        context.goNamed(
          GitHubRepoScreen.name,
          pathParameters: {'owner': repo.ownerLogin, 'repo': repo.name},
        );
      },
    );
  }
}

class _AllReposTab extends StatelessWidget {
  const _AllReposTab({required this.user});

  final GitHubUser user;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GitHubReposBloc, GitHubReposState>(
      builder: (context, state) {
        if (state is GitHubReposLoading) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (state is GitHubReposError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    context.read<GitHubReposBloc>().add(
                      const GitHubReposFetch(),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is GitHubReposLoaded) {
          return CustomScrollView(
            slivers: [
              // User repos section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      if (user.avatarUrl != null)
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(user.avatarUrl!),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        'Your Repositories (${state.userRepos.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              if (state.userRepos.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No repositories found'),
                  ),
                )
              else
                SliverList.builder(
                  itemCount: state.userRepos.length,
                  itemBuilder: (context, index) {
                    final repo = state.userRepos[index];
                    return _RepoTile(repo: repo);
                  },
                ),

              // Organizations section
              if (state.orgs.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text(
                      'Organizations',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                SliverList.builder(
                  itemCount: state.orgs.length,
                  itemBuilder: (context, index) {
                    final org = state.orgs[index];
                    final orgRepos = state.orgRepos[org.login];
                    return _OrgExpansionTile(
                      org: org,
                      repos: orgRepos,
                      onExpand: () {
                        if (orgRepos == null) {
                          context.read<GitHubReposBloc>().add(
                            GitHubReposFetchOrgRepos(orgLogin: org.login),
                          );
                        }
                      },
                    );
                  },
                ),
              ],

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _RepoTile extends StatelessWidget {
  const _RepoTile({required this.repo});

  final GitHubRepo repo;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GitHubPinnedReposBloc, GitHubPinnedReposState>(
      builder: (context, pinnedState) {
        final isPinned =
            pinnedState is GitHubPinnedReposLoaded &&
            pinnedState.repos.any((r) => r.repoId == repo.id);

        return ListTile(
          leading: Icon(
            repo.private ? Icons.lock : Icons.public,
            color: repo.private
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.primary,
          ),
          title: Text(repo.name),
          subtitle: repo.description != null
              ? Text(
                  repo.description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_border, size: 16),
              const SizedBox(width: 4),
              Text('${repo.stargazersCount}'),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  isPinned ? Icons.bookmark : Icons.bookmark_border,
                  color: isPinned
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onPressed: () {
                  if (isPinned) {
                    context.read<GitHubPinnedReposBloc>().add(
                      GitHubPinnedReposRemove(repoId: repo.id),
                    );
                  } else {
                    context.read<GitHubPinnedReposBloc>().add(
                      GitHubPinnedReposAdd(
                        repoId: repo.id,
                        owner: repo.owner.login,
                        repoName: repo.name,
                      ),
                    );
                  }
                },
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () {
            context.goNamed(
              GitHubRepoScreen.name,
              pathParameters: {'owner': repo.owner.login, 'repo': repo.name},
            );
          },
        );
      },
    );
  }
}

class _OrgExpansionTile extends StatelessWidget {
  const _OrgExpansionTile({
    required this.org,
    required this.repos,
    required this.onExpand,
  });

  final GitHubOrg org;
  final List<GitHubRepo>? repos;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: org.avatarUrl != null
          ? CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(org.avatarUrl!),
            )
          : const Icon(Icons.business),
      title: Text(org.login),
      subtitle: org.description != null
          ? Text(org.description!, maxLines: 1, overflow: TextOverflow.ellipsis)
          : null,
      onExpansionChanged: (expanded) {
        if (expanded) onExpand();
      },
      children: [
        if (repos == null)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator.adaptive()),
          )
        else if (repos!.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No repositories'),
          )
        else
          ...repos!.map((repo) => _RepoTile(repo: repo)),
      ],
    );
  }
}
