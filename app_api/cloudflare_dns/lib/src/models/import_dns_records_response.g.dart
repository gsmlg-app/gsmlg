// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_dns_records_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportDnsRecordsResponse _$ImportDnsRecordsResponseFromJson(
        Map<String, dynamic> json) =>
    ImportDnsRecordsResponse(
      success: json['success'] as bool,
      errors: (json['errors'] as List<dynamic>)
          .map((e) => ApiError.fromJson(e as Map<String, dynamic>))
          .toList(),
      messages: (json['messages'] as List<dynamic>)
          .map((e) => ApiMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      result: json['result'] == null
          ? null
          : Result2.fromJson(json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ImportDnsRecordsResponseToJson(
        ImportDnsRecordsResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'errors': instance.errors,
      'messages': instance.messages,
      'result': instance.result,
    };
