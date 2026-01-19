// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workflow_dispatch_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkflowDispatchRequest _$WorkflowDispatchRequestFromJson(
  Map<String, dynamic> json,
) => WorkflowDispatchRequest(
  ref: json['ref'] as String,
  inputs: (json['inputs'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
);

Map<String, dynamic> _$WorkflowDispatchRequestToJson(
  WorkflowDispatchRequest instance,
) => <String, dynamic>{'ref': instance.ref, 'inputs': instance.inputs};
