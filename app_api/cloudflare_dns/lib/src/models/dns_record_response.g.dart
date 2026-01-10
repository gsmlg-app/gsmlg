// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dns_record_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DnsRecordResponse _$DnsRecordResponseFromJson(Map<String, dynamic> json) =>
    DnsRecordResponse(
      success: json['success'] as bool,
      errors: (json['errors'] as List<dynamic>)
          .map((e) => ApiError.fromJson(e as Map<String, dynamic>))
          .toList(),
      messages: (json['messages'] as List<dynamic>)
          .map((e) => ApiMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      result: DnsRecord.fromJson(json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DnsRecordResponseToJson(DnsRecordResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'errors': instance.errors,
      'messages': instance.messages,
      'result': instance.result,
    };
