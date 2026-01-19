part of 'repos_bloc.dart';

@immutable
sealed class GitHubReposState extends Equatable {
  const GitHubReposState();

  @override
  List<Object?> get props => [];
}

/// Initial state
final class GitHubReposInitial extends GitHubReposState {
  const GitHubReposInitial();
}

/// Loading state
final class GitHubReposLoading extends GitHubReposState {
  const GitHubReposLoading();
}

/// Loaded state with repos
final class GitHubReposLoaded extends GitHubReposState {
  const GitHubReposLoaded({
    required this.userRepos,
    required this.orgs,
    required this.orgRepos,
  });

  final List<GitHubRepo> userRepos;
  final List<GitHubOrg> orgs;
  final Map<String, List<GitHubRepo>> orgRepos;

  GitHubReposLoaded copyWith({
    List<GitHubRepo>? userRepos,
    List<GitHubOrg>? orgs,
    Map<String, List<GitHubRepo>>? orgRepos,
  }) {
    return GitHubReposLoaded(
      userRepos: userRepos ?? this.userRepos,
      orgs: orgs ?? this.orgs,
      orgRepos: orgRepos ?? this.orgRepos,
    );
  }

  @override
  List<Object?> get props => [userRepos, orgs, orgRepos];
}

/// Error state
final class GitHubReposError extends GitHubReposState {
  const GitHubReposError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
