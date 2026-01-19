// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'referenced_workflow.g.dart';

@JsonSerializable()
class ReferencedWorkflow {
  const ReferencedWorkflow({
    required this.path,
    required this.sha,
    this.ref,
  });
  
  factory ReferencedWorkflow.fromJson(Map<String, Object?> json) => _$ReferencedWorkflowFromJson(json);
  
  final String path;
  final String sha;
  final String? ref;

  Map<String, Object?> toJson() => _$ReferencedWorkflowToJson(this);
}
