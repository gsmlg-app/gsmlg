// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'workflow_state.dart';

part 'workflow.g.dart';

/// A GitHub Actions workflow
@JsonSerializable()
class Workflow {
  const Workflow({
    required this.id,
    required this.name,
    required this.path,
    required this.state,
    this.nodeId,
    this.createdAt,
    this.updatedAt,
    this.url,
    this.htmlUrl,
    this.badgeUrl,
  });

  factory Workflow.fromJson(Map<String, Object?> json) =>
      _$WorkflowFromJson(json);

  /// Unique identifier of the workflow
  final int id;
  @JsonKey(name: 'node_id')
  final String? nodeId;

  /// The name of the workflow
  final String name;

  /// The path of the workflow file
  final String path;

  /// State of the workflow
  final WorkflowState state;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  final String? url;
  @JsonKey(name: 'html_url')
  final String? htmlUrl;
  @JsonKey(name: 'badge_url')
  final String? badgeUrl;

  Map<String, Object?> toJson() => _$WorkflowToJson(this);
}
