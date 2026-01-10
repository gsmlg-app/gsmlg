// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'change_action.dart';
import 'resource_record_set.dart';

part 'change.g.dart';

@JsonSerializable()
class Change {
  const Change({
    required this.action,
    required this.resourceRecordSet,
  });
  
  factory Change.fromJson(Map<String, Object?> json) => _$ChangeFromJson(json);
  
  final ChangeAction action;
  final ResourceRecordSet resourceRecordSet;

  Map<String, Object?> toJson() => _$ChangeToJson(this);
}
