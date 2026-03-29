// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'change_info.dart';

part 'change_resource_record_sets_response.g.dart';

@JsonSerializable()
class ChangeResourceRecordSetsResponse {
  const ChangeResourceRecordSetsResponse({
    required this.changeInfo,
  });

  factory ChangeResourceRecordSetsResponse.fromJson(
          Map<String, Object?> json) =>
      _$ChangeResourceRecordSetsResponseFromJson(json);

  final ChangeInfo changeInfo;

  Map<String, Object?> toJson() =>
      _$ChangeResourceRecordSetsResponseToJson(this);
}
