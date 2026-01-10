// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'api_error.dart';
import 'api_message.dart';
import 'dns_record.dart';
import 'result_info.dart';

part 'list_dns_records_response.g.dart';

@JsonSerializable()
class ListDnsRecordsResponse {
  const ListDnsRecordsResponse({
    required this.success,
    required this.errors,
    required this.messages,
    required this.result,
    this.resultInfo,
  });
  
  factory ListDnsRecordsResponse.fromJson(Map<String, Object?> json) => _$ListDnsRecordsResponseFromJson(json);
  
  final bool success;
  final List<ApiError> errors;
  final List<ApiMessage> messages;
  final List<DnsRecord> result;
  @JsonKey(name: 'result_info')
  final ResultInfo? resultInfo;

  Map<String, Object?> toJson() => _$ListDnsRecordsResponseToJson(this);
}
