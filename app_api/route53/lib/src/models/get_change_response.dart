// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'change_info.dart';

part 'get_change_response.g.dart';

@JsonSerializable()
class GetChangeResponse {
  const GetChangeResponse({
    required this.changeInfo,
  });

  factory GetChangeResponse.fromJson(Map<String, Object?> json) =>
      _$GetChangeResponseFromJson(json);

  final ChangeInfo changeInfo;

  Map<String, Object?> toJson() => _$GetChangeResponseToJson(this);
}
