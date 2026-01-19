// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_workflow_runs_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListWorkflowRunsResponse _$ListWorkflowRunsResponseFromJson(
  Map<String, dynamic> json,
) => ListWorkflowRunsResponse(
  totalCount: (json['total_count'] as num).toInt(),
  workflowRuns: (json['workflow_runs'] as List<dynamic>)
      .map((e) => WorkflowRun.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ListWorkflowRunsResponseToJson(
  ListWorkflowRunsResponse instance,
) => <String, dynamic>{
  'total_count': instance.totalCount,
  'workflow_runs': instance.workflowRuns,
};
