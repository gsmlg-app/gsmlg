// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'resource_record.g.dart';

@JsonSerializable()
class ResourceRecord {
  const ResourceRecord({
    required this.value,
  });

  factory ResourceRecord.fromJson(Map<String, Object?> json) =>
      _$ResourceRecordFromJson(json);

  /// The current or new DNS record value.
  final String value;

  Map<String, Object?> toJson() => _$ResourceRecordToJson(this);
}
