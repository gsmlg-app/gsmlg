// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'api_error.dart';
import 'api_message.dart';
import 'result.dart';

part 'delete_dns_record_response.g.dart';

@JsonSerializable()
class DeleteDnsRecordResponse {
  const DeleteDnsRecordResponse({
    required this.success,
    required this.errors,
    required this.messages,
    this.result,
  });
  
  factory DeleteDnsRecordResponse.fromJson(Map<String, Object?> json) => _$DeleteDnsRecordResponseFromJson(json);
  
  final bool success;
  final List<ApiError> errors;
  final List<ApiMessage> messages;
  final Result? result;

  Map<String, Object?> toJson() => _$DeleteDnsRecordResponseToJson(this);
}
