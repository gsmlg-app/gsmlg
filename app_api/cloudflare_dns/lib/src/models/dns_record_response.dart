// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'api_error.dart';
import 'api_message.dart';
import 'dns_record.dart';

part 'dns_record_response.g.dart';

@JsonSerializable()
class DnsRecordResponse {
  const DnsRecordResponse({
    required this.success,
    required this.errors,
    required this.messages,
    required this.result,
  });
  
  factory DnsRecordResponse.fromJson(Map<String, Object?> json) => _$DnsRecordResponseFromJson(json);
  
  final bool success;
  final List<ApiError> errors;
  final List<ApiMessage> messages;
  final DnsRecord result;

  Map<String, Object?> toJson() => _$DnsRecordResponseToJson(this);
}
