part of 'bloc.dart';

@immutable
sealed class GitHubState extends Equatable {
  const GitHubState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading
final class GitHubInitial extends GitHubState {
  const GitHubInitial();
}

/// Loading state
final class GitHubLoading extends GitHubState {
  const GitHubLoading();
}

/// Successfully connected with user info
final class GitHubConnected extends GitHubState {
  const GitHubConnected({
    required this.user,
    required this.pat,
  });

  final GitHubUser user;
  final String pat;

  @override
  List<Object?> get props => [user, pat];
}

/// Not connected (no PAT stored)
final class GitHubDisconnected extends GitHubState {
  const GitHubDisconnected();
}

/// Error state
final class GitHubError extends GitHubState {
  const GitHubError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
