// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispatch_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkflowDispatchRequest _$WorkflowDispatchRequestFromJson(
  Map<String, dynamic> json,
) => _WorkflowDispatchRequest(
  ref: json['ref'] as String,
  inputs: (json['inputs'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
);

Map<String, dynamic> _$WorkflowDispatchRequestToJson(
  _WorkflowDispatchRequest instance,
) => <String, dynamic>{'ref': instance.ref, 'inputs': instance.inputs};
