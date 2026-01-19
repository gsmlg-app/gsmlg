// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workflow.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkflowResponse _$WorkflowResponseFromJson(Map<String, dynamic> json) =>
    _WorkflowResponse(
      id: (json['id'] as num).toInt(),
      nodeId: json['node_id'] as String?,
      name: json['name'] as String,
      path: json['path'] as String,
      state: json['state'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      url: json['url'] as String?,
      htmlUrl: json['html_url'] as String?,
      badgeUrl: json['badge_url'] as String?,
    );

Map<String, dynamic> _$WorkflowResponseToJson(_WorkflowResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'node_id': instance.nodeId,
      'name': instance.name,
      'path': instance.path,
      'state': instance.state,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'url': instance.url,
      'html_url': instance.htmlUrl,
      'badge_url': instance.badgeUrl,
    };

_ListWorkflowsResponse _$ListWorkflowsResponseFromJson(
  Map<String, dynamic> json,
) => _ListWorkflowsResponse(
  totalCount: (json['total_count'] as num).toInt(),
  workflows: (json['workflows'] as List<dynamic>)
      .map((e) => WorkflowResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ListWorkflowsResponseToJson(
  _ListWorkflowsResponse instance,
) => <String, dynamic>{
  'total_count': instance.totalCount,
  'workflows': instance.workflows,
};
