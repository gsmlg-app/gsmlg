// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'result_info.g.dart';

@JsonSerializable()
class ResultInfo {
  const ResultInfo({
    this.page,
    this.perPage,
    this.count,
    this.totalCount,
    this.totalPages,
  });

  factory ResultInfo.fromJson(Map<String, Object?> json) =>
      _$ResultInfoFromJson(json);

  /// Current page number.
  final int? page;

  /// Number of items per page.
  @JsonKey(name: 'per_page')
  final int? perPage;

  /// Number of items in current page.
  final int? count;

  /// Total number of items.
  @JsonKey(name: 'total_count')
  final int? totalCount;

  /// Total number of pages.
  @JsonKey(name: 'total_pages')
  final int? totalPages;

  Map<String, Object?> toJson() => _$ResultInfoToJson(this);
}
