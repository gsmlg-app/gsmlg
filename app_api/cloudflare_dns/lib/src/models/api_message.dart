// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'api_message.g.dart';

@JsonSerializable()
class ApiMessage {
  const ApiMessage({
    this.code,
    this.message,
  });

  factory ApiMessage.fromJson(Map<String, Object?> json) =>
      _$ApiMessageFromJson(json);

  final int? code;
  final String? message;

  Map<String, Object?> toJson() => _$ApiMessageToJson(this);
}
