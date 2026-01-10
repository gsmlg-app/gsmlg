// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum(alwaysCreate: true)
enum ZoneStatus {
  @JsonValue('initializing')
  initializing,
  @JsonValue('pending')
  pending,
  @JsonValue('active')
  active,
  @JsonValue('moved')
  moved,
  @JsonValue('deactivated')
  deactivated,
  @JsonValue('read only')
  readOnly,
  @JsonValue('deleted')
  deleted;

  @override
  String toString() => switch (this) {
        ZoneStatus.initializing => 'initializing',
        ZoneStatus.pending => 'pending',
        ZoneStatus.active => 'active',
        ZoneStatus.moved => 'moved',
        ZoneStatus.deactivated => 'deactivated',
        ZoneStatus.readOnly => 'read only',
        ZoneStatus.deleted => 'deleted',
      };
}
