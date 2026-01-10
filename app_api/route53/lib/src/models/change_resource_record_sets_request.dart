// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'change_batch.dart';

part 'change_resource_record_sets_request.g.dart';

@JsonSerializable()
class ChangeResourceRecordSetsRequest {
  const ChangeResourceRecordSetsRequest({
    required this.changeBatch,
  });
  
  factory ChangeResourceRecordSetsRequest.fromJson(Map<String, Object?> json) => _$ChangeResourceRecordSetsRequestFromJson(json);
  
  final ChangeBatch changeBatch;

  Map<String, Object?> toJson() => _$ChangeResourceRecordSetsRequestToJson(this);
}
