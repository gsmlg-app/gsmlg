part of 'pinned_repos_bloc.dart';

@immutable
sealed class GitHubPinnedReposState extends Equatable {
  const GitHubPinnedReposState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
final class GitHubPinnedReposInitial extends GitHubPinnedReposState {
  const GitHubPinnedReposInitial();
}

/// Loading state.
final class GitHubPinnedReposLoading extends GitHubPinnedReposState {
  const GitHubPinnedReposLoading();
}

/// Loaded state with pinned repos.
final class GitHubPinnedReposLoaded extends GitHubPinnedReposState {
  const GitHubPinnedReposLoaded({required this.repos});

  final List<GitHubRepoTableData> repos;

  @override
  List<Object?> get props => [repos];
}

/// Error state.
final class GitHubPinnedReposError extends GitHubPinnedReposState {
  const GitHubPinnedReposError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
