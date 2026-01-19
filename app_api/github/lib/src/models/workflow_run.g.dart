// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workflow_run.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkflowRun _$WorkflowRunFromJson(Map<String, dynamic> json) => WorkflowRun(
  workflowId: (json['workflow_id'] as num).toInt(),
  event: json['event'] as String,
  headSha: json['head_sha'] as String,
  id: (json['id'] as num).toInt(),
  headBranch: json['head_branch'] as String?,
  name: json['name'] as String?,
  nodeId: json['node_id'] as String?,
  path: json['path'] as String?,
  displayTitle: json['display_title'] as String?,
  runNumber: (json['run_number'] as num?)?.toInt(),
  runAttempt: (json['run_attempt'] as num?)?.toInt(),
  referencedWorkflows: (json['referenced_workflows'] as List<dynamic>?)
      ?.map((e) => ReferencedWorkflow.fromJson(e as Map<String, dynamic>))
      .toList(),
  checkSuiteId: (json['check_suite_id'] as num?)?.toInt(),
  status: $enumDecodeNullable(_$WorkflowRunStatusEnumMap, json['status']),
  conclusion: $enumDecodeNullable(
    _$WorkflowRunConclusionEnumMap,
    json['conclusion'],
  ),
  checkSuiteNodeId: json['check_suite_node_id'] as String?,
  url: json['url'] as String?,
  htmlUrl: json['html_url'] as String?,
  pullRequests: (json['pull_requests'] as List<dynamic>?)
      ?.map((e) => PullRequestMinimal.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  actor: json['actor'] == null
      ? null
      : SimpleUser.fromJson(json['actor'] as Map<String, dynamic>),
  headRepository: json['head_repository'] == null
      ? null
      : MinimalRepository.fromJson(
          json['head_repository'] as Map<String, dynamic>,
        ),
  runStartedAt: json['run_started_at'] == null
      ? null
      : DateTime.parse(json['run_started_at'] as String),
  jobsUrl: json['jobs_url'] as String?,
  logsUrl: json['logs_url'] as String?,
  checkSuiteUrl: json['check_suite_url'] as String?,
  artifactsUrl: json['artifacts_url'] as String?,
  cancelUrl: json['cancel_url'] as String?,
  rerunUrl: json['rerun_url'] as String?,
  previousAttemptUrl: json['previous_attempt_url'] as String?,
  workflowUrl: json['workflow_url'] as String?,
  headCommit: json['head_commit'] == null
      ? null
      : Commit.fromJson(json['head_commit'] as Map<String, dynamic>),
  repository: json['repository'] == null
      ? null
      : MinimalRepository.fromJson(json['repository'] as Map<String, dynamic>),
  triggeringActor: json['triggering_actor'] == null
      ? null
      : SimpleUser.fromJson(json['triggering_actor'] as Map<String, dynamic>),
);

Map<String, dynamic> _$WorkflowRunToJson(WorkflowRun instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'node_id': instance.nodeId,
      'check_suite_id': instance.checkSuiteId,
      'check_suite_node_id': instance.checkSuiteNodeId,
      'head_branch': instance.headBranch,
      'head_sha': instance.headSha,
      'path': instance.path,
      'display_title': instance.displayTitle,
      'run_number': instance.runNumber,
      'run_attempt': instance.runAttempt,
      'referenced_workflows': instance.referencedWorkflows,
      'event': instance.event,
      'status': _$WorkflowRunStatusEnumMap[instance.status],
      'conclusion': _$WorkflowRunConclusionEnumMap[instance.conclusion],
      'workflow_id': instance.workflowId,
      'url': instance.url,
      'html_url': instance.htmlUrl,
      'pull_requests': instance.pullRequests,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'actor': instance.actor,
      'triggering_actor': instance.triggeringActor,
      'run_started_at': instance.runStartedAt?.toIso8601String(),
      'jobs_url': instance.jobsUrl,
      'logs_url': instance.logsUrl,
      'check_suite_url': instance.checkSuiteUrl,
      'artifacts_url': instance.artifactsUrl,
      'cancel_url': instance.cancelUrl,
      'rerun_url': instance.rerunUrl,
      'previous_attempt_url': instance.previousAttemptUrl,
      'workflow_url': instance.workflowUrl,
      'head_commit': instance.headCommit,
      'repository': instance.repository,
      'head_repository': instance.headRepository,
    };

const _$WorkflowRunStatusEnumMap = {
  WorkflowRunStatus.requested: 'requested',
  WorkflowRunStatus.inProgress: 'in_progress',
  WorkflowRunStatus.completed: 'completed',
  WorkflowRunStatus.queued: 'queued',
  WorkflowRunStatus.waiting: 'waiting',
  WorkflowRunStatus.pending: 'pending',
};

const _$WorkflowRunConclusionEnumMap = {
  WorkflowRunConclusion.success: 'success',
  WorkflowRunConclusion.failure: 'failure',
  WorkflowRunConclusion.neutral: 'neutral',
  WorkflowRunConclusion.cancelled: 'cancelled',
  WorkflowRunConclusion.skipped: 'skipped',
  WorkflowRunConclusion.timedOut: 'timed_out',
  WorkflowRunConclusion.actionRequired: 'action_required',
  WorkflowRunConclusion.stale: 'stale',
  WorkflowRunConclusion.startupFailure: 'startup_failure',
};
