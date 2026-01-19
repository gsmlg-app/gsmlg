// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum Status {
  @JsonValue('completed')
  completed,
  @JsonValue('action_required')
  actionRequired,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('failure')
  failure,
  @JsonValue('neutral')
  neutral,
  @JsonValue('skipped')
  skipped,
  @JsonValue('stale')
  stale,
  @JsonValue('success')
  success,
  @JsonValue('timed_out')
  timedOut,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('queued')
  queued,
  @JsonValue('requested')
  requested,
  @JsonValue('waiting')
  waiting,
  @JsonValue('pending')
  pending;
}
