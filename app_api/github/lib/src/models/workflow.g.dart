// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workflow.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Workflow _$WorkflowFromJson(Map<String, dynamic> json) => Workflow(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  path: json['path'] as String,
  state: $enumDecode(_$WorkflowStateEnumMap, json['state']),
  nodeId: json['node_id'] as String?,
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

Map<String, dynamic> _$WorkflowToJson(Workflow instance) => <String, dynamic>{
  'id': instance.id,
  'node_id': instance.nodeId,
  'name': instance.name,
  'path': instance.path,
  'state': _$WorkflowStateEnumMap[instance.state]!,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'url': instance.url,
  'html_url': instance.htmlUrl,
  'badge_url': instance.badgeUrl,
};

const _$WorkflowStateEnumMap = {
  WorkflowState.active: 'active',
  WorkflowState.deleted: 'deleted',
  WorkflowState.disabledFork: 'disabled_fork',
  WorkflowState.disabledInactivity: 'disabled_inactivity',
  WorkflowState.disabledManually: 'disabled_manually',
};
