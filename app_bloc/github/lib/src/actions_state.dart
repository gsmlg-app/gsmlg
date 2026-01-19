part of 'actions_bloc.dart';

@immutable
sealed class GitHubActionsState extends Equatable {
  const GitHubActionsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
final class GitHubActionsInitial extends GitHubActionsState {
  const GitHubActionsInitial();
}

/// Loading state
final class GitHubActionsLoading extends GitHubActionsState {
  const GitHubActionsLoading();
}

/// Loaded state with workflows and runs
final class GitHubActionsLoaded extends GitHubActionsState {
  const GitHubActionsLoaded({
    required this.workflows,
    required this.runs,
    this.isDispatching = false,
  });

  final List<GitHubWorkflow> workflows;
  final List<GitHubWorkflowRun> runs;
  final bool isDispatching;

  GitHubActionsLoaded copyWith({
    List<GitHubWorkflow>? workflows,
    List<GitHubWorkflowRun>? runs,
    bool? isDispatching,
  }) {
    return GitHubActionsLoaded(
      workflows: workflows ?? this.workflows,
      runs: runs ?? this.runs,
      isDispatching: isDispatching ?? this.isDispatching,
    );
  }

  @override
  List<Object?> get props => [workflows, runs, isDispatching];
}

/// Error state
final class GitHubActionsError extends GitHubActionsState {
  const GitHubActionsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
