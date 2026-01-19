// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workflow_run.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RunActor _$RunActorFromJson(Map<String, dynamic> json) => _RunActor(
  id: (json['id'] as num).toInt(),
  login: json['login'] as String,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$RunActorToJson(_RunActor instance) => <String, dynamic>{
  'id': instance.id,
  'login': instance.login,
  'avatar_url': instance.avatarUrl,
};

_WorkflowRunResponse _$WorkflowRunResponseFromJson(Map<String, dynamic> json) =>
    _WorkflowRunResponse(
      id: (json['id'] as num).toInt(),
      nodeId: json['node_id'] as String?,
      name: json['name'] as String?,
      headBranch: json['head_branch'] as String?,
      headSha: json['head_sha'] as String?,
      path: json['path'] as String?,
      displayTitle: json['display_title'] as String?,
      runNumber: (json['run_number'] as num).toInt(),
      event: json['event'] as String?,
      status: json['status'] as String?,
      conclusion: json['conclusion'] as String?,
      workflowId: (json['workflow_id'] as num).toInt(),
      htmlUrl: json['html_url'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      runStartedAt: json['run_started_at'] == null
          ? null
          : DateTime.parse(json['run_started_at'] as String),
      actor: json['actor'] == null
          ? null
          : RunActor.fromJson(json['actor'] as Map<String, dynamic>),
      triggeringActor: json['triggering_actor'] == null
          ? null
          : RunActor.fromJson(json['triggering_actor'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WorkflowRunResponseToJson(
  _WorkflowRunResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'node_id': instance.nodeId,
  'name': instance.name,
  'head_branch': instance.headBranch,
  'head_sha': instance.headSha,
  'path': instance.path,
  'display_title': instance.displayTitle,
  'run_number': instance.runNumber,
  'event': instance.event,
  'status': instance.status,
  'conclusion': instance.conclusion,
  'workflow_id': instance.workflowId,
  'html_url': instance.htmlUrl,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'run_started_at': instance.runStartedAt?.toIso8601String(),
  'actor': instance.actor,
  'triggering_actor': instance.triggeringActor,
};

_ListWorkflowRunsResponse _$ListWorkflowRunsResponseFromJson(
  Map<String, dynamic> json,
) => _ListWorkflowRunsResponse(
  totalCount: (json['total_count'] as num).toInt(),
  workflowRuns: (json['workflow_runs'] as List<dynamic>)
      .map((e) => WorkflowRunResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ListWorkflowRunsResponseToJson(
  _ListWorkflowRunsResponse instance,
) => <String, dynamic>{
  'total_count': instance.totalCount,
  'workflow_runs': instance.workflowRuns,
};
