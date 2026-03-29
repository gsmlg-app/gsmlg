// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// The status of the workflow run
@JsonEnum()
enum WorkflowRunStatus {
  @JsonValue('requested')
  requested,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('queued')
  queued,
  @JsonValue('waiting')
  waiting,
  @JsonValue('pending')
  pending,
}
