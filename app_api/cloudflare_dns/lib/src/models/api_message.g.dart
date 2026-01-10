// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiMessage _$ApiMessageFromJson(Map<String, dynamic> json) => ApiMessage(
      code: (json['code'] as num?)?.toInt(),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$ApiMessageToJson(ApiMessage instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
    };
