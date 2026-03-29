// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'api_error.dart';
import 'api_message.dart';
import 'result_info.dart';
import 'zone.dart';

part 'list_zones_response.g.dart';

@JsonSerializable()
class ListZonesResponse {
  const ListZonesResponse({
    required this.success,
    required this.errors,
    required this.messages,
    required this.result,
    this.resultInfo,
  });

  factory ListZonesResponse.fromJson(Map<String, Object?> json) =>
      _$ListZonesResponseFromJson(json);

  final bool success;
  final List<ApiError> errors;
  final List<ApiMessage> messages;
  final List<Zone> result;
  @JsonKey(name: 'result_info')
  final ResultInfo? resultInfo;

  Map<String, Object?> toJson() => _$ListZonesResponseToJson(this);
}
