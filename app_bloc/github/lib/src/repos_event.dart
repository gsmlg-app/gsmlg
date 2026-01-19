part of 'repos_bloc.dart';

@immutable
sealed class GitHubReposEvent extends Equatable {
  const GitHubReposEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch user repositories and organizations
final class GitHubReposFetch extends GitHubReposEvent {
  const GitHubReposFetch();
}

/// Fetch organizations list
final class GitHubReposFetchOrgs extends GitHubReposEvent {
  const GitHubReposFetchOrgs();
}

/// Fetch repositories for a specific organization
final class GitHubReposFetchOrgRepos extends GitHubReposEvent {
  const GitHubReposFetchOrgRepos({required this.orgLogin});

  final String orgLogin;

  @override
  List<Object?> get props => [orgLogin];
}

/// Refresh all repositories
final class GitHubReposRefresh extends GitHubReposEvent {
  const GitHubReposRefresh();
}
