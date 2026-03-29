// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'workflow_dispatch_request.g.dart';

/// Request body for creating a workflow dispatch event
@JsonSerializable()
class WorkflowDispatchRequest {
  const WorkflowDispatchRequest({required this.ref, this.inputs});

  factory WorkflowDispatchRequest.fromJson(Map<String, Object?> json) =>
      _$WorkflowDispatchRequestFromJson(json);

  /// The git reference for the workflow. The reference can be a branch or tag name.
  final String ref;

  /// Input keys and values configured in the workflow file.
  final Map<String, String>? inputs;

  Map<String, Object?> toJson() => _$WorkflowDispatchRequestToJson(this);
}
