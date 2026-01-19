part of 'bloc.dart';

@immutable
sealed class GitHubEvent extends Equatable {
  const GitHubEvent();

  @override
  List<Object?> get props => [];
}

/// Load GitHub account status from secure storage
final class GitHubLoad extends GitHubEvent {
  const GitHubLoad();
}

/// Connect GitHub account with a Personal Access Token
final class GitHubConnect extends GitHubEvent {
  const GitHubConnect({required this.pat});

  final String pat;

  @override
  List<Object?> get props => [pat];
}

/// Disconnect GitHub account and remove PAT from storage
final class GitHubDisconnect extends GitHubEvent {
  const GitHubDisconnect();
}

/// Refresh GitHub user info
final class GitHubRefresh extends GitHubEvent {
  const GitHubRefresh();
}
