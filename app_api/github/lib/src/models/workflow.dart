import 'package:freezed_annotation/freezed_annotation.dart';

part 'workflow.freezed.dart';
part 'workflow.g.dart';

/// GitHub workflow model.
@freezed
class WorkflowResponse with _$WorkflowResponse {
  const factory WorkflowResponse({
    required int id,
    @JsonKey(name: 'node_id') String? nodeId,
    required String name,
    required String path,
    required String state,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    String? url,
    @JsonKey(name: 'html_url') String? htmlUrl,
    @JsonKey(name: 'badge_url') String? badgeUrl,
  }) = _WorkflowResponse;

  factory WorkflowResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkflowResponseFromJson(json);
}

/// List workflows response.
@freezed
class ListWorkflowsResponse with _$ListWorkflowsResponse {
  const factory ListWorkflowsResponse({
    @JsonKey(name: 'total_count') required int totalCount,
    required List<WorkflowResponse> workflows,
  }) = _ListWorkflowsResponse;

  factory ListWorkflowsResponse.fromJson(Map<String, dynamic> json) =>
      _$ListWorkflowsResponseFromJson(json);
}
