// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// The conclusion of the workflow run
@JsonEnum()
enum WorkflowRunConclusion {
  @JsonValue('success')
  success,
  @JsonValue('failure')
  failure,
  @JsonValue('neutral')
  neutral,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('skipped')
  skipped,
  @JsonValue('timed_out')
  timedOut,
  @JsonValue('action_required')
  actionRequired,
  @JsonValue('stale')
  stale,
  @JsonValue('startup_failure')
  startupFailure,
}
