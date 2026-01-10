// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_dns_record_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteDnsRecordResponse _$DeleteDnsRecordResponseFromJson(
        Map<String, dynamic> json) =>
    DeleteDnsRecordResponse(
      success: json['success'] as bool,
      errors: (json['errors'] as List<dynamic>)
          .map((e) => ApiError.fromJson(e as Map<String, dynamic>))
          .toList(),
      messages: (json['messages'] as List<dynamic>)
          .map((e) => ApiMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      result: json['result'] == null
          ? null
          : Result.fromJson(json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DeleteDnsRecordResponseToJson(
        DeleteDnsRecordResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'errors': instance.errors,
      'messages': instance.messages,
      'result': instance.result,
    };
