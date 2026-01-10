// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'result2.g.dart';

@JsonSerializable()
class Result2 {
  const Result2({
    this.recsAdded,
    this.recsAddedByType,
    this.totalRecordsParsed,
  });
  
  factory Result2.fromJson(Map<String, Object?> json) => _$Result2FromJson(json);
  
  /// Number of DNS records added.
  @JsonKey(name: 'recs_added')
  final int? recsAdded;

  /// Number of DNS records added by type.
  @JsonKey(name: 'recs_added_by_type')
  final Map<String, int>? recsAddedByType;

  /// Total number of DNS records parsed.
  @JsonKey(name: 'total_records_parsed')
  final int? totalRecordsParsed;

  Map<String, Object?> toJson() => _$Result2ToJson(this);
}
