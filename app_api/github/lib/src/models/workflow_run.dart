import 'package:freezed_annotation/freezed_annotation.dart';

part 'workflow_run.freezed.dart';
part 'workflow_run.g.dart';

/// GitHub workflow run actor.
@freezed
class RunActor with _$RunActor {
  const factory RunActor({
    required int id,
    required String login,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _RunActor;

  factory RunActor.fromJson(Map<String, dynamic> json) =>
      _$RunActorFromJson(json);
}

/// GitHub workflow run model.
@freezed
class WorkflowRunResponse with _$WorkflowRunResponse {
  const factory WorkflowRunResponse({
    required int id,
    @JsonKey(name: 'node_id') String? nodeId,
    String? name,
    @JsonKey(name: 'head_branch') String? headBranch,
    @JsonKey(name: 'head_sha') String? headSha,
    String? path,
    @JsonKey(name: 'display_title') String? displayTitle,
    @JsonKey(name: 'run_number') required int runNumber,
    String? event,
    String? status,
    String? conclusion,
    @JsonKey(name: 'workflow_id') required int workflowId,
    @JsonKey(name: 'html_url') String? htmlUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'run_started_at') DateTime? runStartedAt,
    RunActor? actor,
    @JsonKey(name: 'triggering_actor') RunActor? triggeringActor,
  }) = _WorkflowRunResponse;

  factory WorkflowRunResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkflowRunResponseFromJson(json);
}

/// List workflow runs response.
@freezed
class ListWorkflowRunsResponse with _$ListWorkflowRunsResponse {
  const factory ListWorkflowRunsResponse({
    @JsonKey(name: 'total_count') required int totalCount,
    @JsonKey(name: 'workflow_runs') required List<WorkflowRunResponse> workflowRuns,
  }) = _ListWorkflowRunsResponse;

  factory ListWorkflowRunsResponse.fromJson(Map<String, dynamic> json) =>
      _$ListWorkflowRunsResponseFromJson(json);
}
