// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'change_status.dart';

part 'change_info.g.dart';

@JsonSerializable()
class ChangeInfo {
  const ChangeInfo({
    required this.id,
    required this.status,
    required this.submittedAt,
    this.comment,
  });
  
  factory ChangeInfo.fromJson(Map<String, Object?> json) => _$ChangeInfoFromJson(json);
  
  /// The ID of the change.
  final String id;
  final ChangeStatus status;

  /// The date and time the change was submitted.
  final DateTime submittedAt;
  final String? comment;

  Map<String, Object?> toJson() => _$ChangeInfoToJson(this);
}
