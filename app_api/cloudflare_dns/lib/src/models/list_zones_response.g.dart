// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_zones_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListZonesResponse _$ListZonesResponseFromJson(Map<String, dynamic> json) =>
    ListZonesResponse(
      success: json['success'] as bool,
      errors: (json['errors'] as List<dynamic>)
          .map((e) => ApiError.fromJson(e as Map<String, dynamic>))
          .toList(),
      messages: (json['messages'] as List<dynamic>)
          .map((e) => ApiMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      result: (json['result'] as List<dynamic>)
          .map((e) => Zone.fromJson(e as Map<String, dynamic>))
          .toList(),
      resultInfo: json['result_info'] == null
          ? null
          : ResultInfo.fromJson(json['result_info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ListZonesResponseToJson(ListZonesResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'errors': instance.errors,
      'messages': instance.messages,
      'result': instance.result,
      'result_info': instance.resultInfo,
    };
