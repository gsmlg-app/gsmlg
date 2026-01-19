part of 'actions_bloc.dart';

@immutable
sealed class GitHubActionsEvent extends Equatable {
  const GitHubActionsEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch workflows and recent runs
final class GitHubActionsFetch extends GitHubActionsEvent {
  const GitHubActionsFetch();
}

/// Fetch runs for a specific workflow
final class GitHubActionsFetchRuns extends GitHubActionsEvent {
  const GitHubActionsFetchRuns({required this.workflowId});

  final int workflowId;

  @override
  List<Object?> get props => [workflowId];
}

/// Dispatch (trigger) a workflow
final class GitHubActionsDispatch extends GitHubActionsEvent {
  const GitHubActionsDispatch({
    required this.workflowId,
    required this.ref,
    this.inputs,
  });

  final int workflowId;
  final String ref; // branch or tag
  final Map<String, String>? inputs;

  @override
  List<Object?> get props => [workflowId, ref, inputs];
}

/// Refresh workflows and runs
final class GitHubActionsRefresh extends GitHubActionsEvent {
  const GitHubActionsRefresh();
}

/// Re-run a workflow run
final class GitHubActionsRerun extends GitHubActionsEvent {
  const GitHubActionsRerun({required this.runId});

  final int runId;

  @override
  List<Object?> get props => [runId];
}

/// Cancel a workflow run
final class GitHubActionsCancel extends GitHubActionsEvent {
  const GitHubActionsCancel({required this.runId});

  final int runId;

  @override
  List<Object?> get props => [runId];
}
