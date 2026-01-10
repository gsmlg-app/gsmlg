// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'result.g.dart';

@JsonSerializable()
class Result {
  const Result({
    this.id,
  });
  
  factory Result.fromJson(Map<String, Object?> json) => _$ResultFromJson(json);
  
  /// Identifier of the deleted record.
  final String? id;

  Map<String, Object?> toJson() => _$ResultToJson(this);
}
