// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// State of the workflow
@JsonEnum()
enum WorkflowState {
  @JsonValue('active')
  active,
  @JsonValue('deleted')
  deleted,
  @JsonValue('disabled_fork')
  disabledFork,
  @JsonValue('disabled_inactivity')
  disabledInactivity,
  @JsonValue('disabled_manually')
  disabledManually;
}
