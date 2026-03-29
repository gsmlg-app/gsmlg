// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'api_error.dart';
import 'api_message.dart';
import 'result2.dart';

part 'import_dns_records_response.g.dart';

@JsonSerializable()
class ImportDnsRecordsResponse {
  const ImportDnsRecordsResponse({
    required this.success,
    required this.errors,
    required this.messages,
    this.result,
  });

  factory ImportDnsRecordsResponse.fromJson(Map<String, Object?> json) =>
      _$ImportDnsRecordsResponseFromJson(json);

  final bool success;
  final List<ApiError> errors;
  final List<ApiMessage> messages;
  final Result2? result;

  Map<String, Object?> toJson() => _$ImportDnsRecordsResponseToJson(this);
}
