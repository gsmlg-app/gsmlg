// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'workflow.dart';

part 'list_workflows_response.g.dart';

@JsonSerializable()
class ListWorkflowsResponse {
  const ListWorkflowsResponse({
    required this.totalCount,
    required this.workflows,
  });

  factory ListWorkflowsResponse.fromJson(Map<String, Object?> json) =>
      _$ListWorkflowsResponseFromJson(json);

  @JsonKey(name: 'total_count')
  final int totalCount;
  final List<Workflow> workflows;

  Map<String, Object?> toJson() => _$ListWorkflowsResponseToJson(this);
}
