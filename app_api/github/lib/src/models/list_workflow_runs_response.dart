// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'workflow_run.dart';

part 'list_workflow_runs_response.g.dart';

@JsonSerializable()
class ListWorkflowRunsResponse {
  const ListWorkflowRunsResponse({
    required this.totalCount,
    required this.workflowRuns,
  });

  factory ListWorkflowRunsResponse.fromJson(Map<String, Object?> json) =>
      _$ListWorkflowRunsResponseFromJson(json);

  @JsonKey(name: 'total_count')
  final int totalCount;
  @JsonKey(name: 'workflow_runs')
  final List<WorkflowRun> workflowRuns;

  Map<String, Object?> toJson() => _$ListWorkflowRunsResponseToJson(this);
}
