import 'package:freezed_annotation/freezed_annotation.dart';

part 'dispatch_request.freezed.dart';
part 'dispatch_request.g.dart';

/// Request body for dispatching a workflow.
@freezed
class WorkflowDispatchRequest with _$WorkflowDispatchRequest {
  const factory WorkflowDispatchRequest({
    /// The git reference for the workflow (branch or tag name).
    required String ref,
    /// Input keys and values configured in the workflow file.
    Map<String, String>? inputs,
  }) = _WorkflowDispatchRequest;

  factory WorkflowDispatchRequest.fromJson(Map<String, dynamic> json) =>
      _$WorkflowDispatchRequestFromJson(json);
}
