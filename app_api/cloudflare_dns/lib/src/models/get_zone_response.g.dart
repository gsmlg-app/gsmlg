// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_zone_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetZoneResponse _$GetZoneResponseFromJson(Map<String, dynamic> json) =>
    GetZoneResponse(
      success: json['success'] as bool,
      errors: (json['errors'] as List<dynamic>)
          .map((e) => ApiError.fromJson(e as Map<String, dynamic>))
          .toList(),
      messages: (json['messages'] as List<dynamic>)
          .map((e) => ApiMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      result: Zone.fromJson(json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetZoneResponseToJson(GetZoneResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'errors': instance.errors,
      'messages': instance.messages,
      'result': instance.result,
    };
