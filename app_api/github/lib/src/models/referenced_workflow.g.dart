// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referenced_workflow.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReferencedWorkflow _$ReferencedWorkflowFromJson(Map<String, dynamic> json) =>
    ReferencedWorkflow(
      path: json['path'] as String,
      sha: json['sha'] as String,
      ref: json['ref'] as String?,
    );

Map<String, dynamic> _$ReferencedWorkflowToJson(ReferencedWorkflow instance) =>
    <String, dynamic>{
      'path': instance.path,
      'sha': instance.sha,
      'ref': instance.ref,
    };
