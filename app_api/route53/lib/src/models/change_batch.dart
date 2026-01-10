// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'change.dart';

part 'change_batch.g.dart';

@JsonSerializable()
class ChangeBatch {
  const ChangeBatch({
    required this.changes,
    this.comment,
  });
  
  factory ChangeBatch.fromJson(Map<String, Object?> json) => _$ChangeBatchFromJson(json);
  
  /// Optional comment about the changes.
  final String? comment;
  final List<Change> changes;

  Map<String, Object?> toJson() => _$ChangeBatchToJson(this);
}
