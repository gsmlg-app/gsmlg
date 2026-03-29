// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'rerun_workflow_request.g.dart';

/// Request body for re-running a workflow
@JsonSerializable()
class RerunWorkflowRequest {
  const RerunWorkflowRequest({this.enableDebugLogging = false});

  factory RerunWorkflowRequest.fromJson(Map<String, Object?> json) =>
      _$RerunWorkflowRequestFromJson(json);

  /// Whether to enable debug logging for the re-run.
  @JsonKey(name: 'enable_debug_logging')
  final bool enableDebugLogging;

  Map<String, Object?> toJson() => _$RerunWorkflowRequestToJson(this);
}
