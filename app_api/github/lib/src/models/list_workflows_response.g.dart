// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_workflows_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListWorkflowsResponse _$ListWorkflowsResponseFromJson(
  Map<String, dynamic> json,
) => ListWorkflowsResponse(
  totalCount: (json['total_count'] as num).toInt(),
  workflows: (json['workflows'] as List<dynamic>)
      .map((e) => Workflow.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ListWorkflowsResponseToJson(
  ListWorkflowsResponse instance,
) => <String, dynamic>{
  'total_count': instance.totalCount,
  'workflows': instance.workflows,
};
