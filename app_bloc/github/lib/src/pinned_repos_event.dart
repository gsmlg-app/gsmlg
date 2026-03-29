part of 'pinned_repos_bloc.dart';

@immutable
sealed class GitHubPinnedReposEvent extends Equatable {
  const GitHubPinnedReposEvent();

  @override
  List<Object?> get props => [];
}

/// Load pinned repos from database.
final class GitHubPinnedReposLoad extends GitHubPinnedReposEvent {
  const GitHubPinnedReposLoad();
}

/// Add a repo to pinned list.
final class GitHubPinnedReposAdd extends GitHubPinnedReposEvent {
  const GitHubPinnedReposAdd({this.repoId, this.owner, this.repoName});

  /// Repository ID (if known).
  final int? repoId;

  /// Repository owner login.
  final String? owner;

  /// Repository name.
  final String? repoName;

  @override
  List<Object?> get props => [repoId, owner, repoName];
}

/// Remove a repo from pinned list.
final class GitHubPinnedReposRemove extends GitHubPinnedReposEvent {
  const GitHubPinnedReposRemove({required this.repoId});

  final int repoId;

  @override
  List<Object?> get props => [repoId];
}

/// Refresh pinned repos from API.
final class GitHubPinnedReposRefresh extends GitHubPinnedReposEvent {
  const GitHubPinnedReposRefresh();
}
