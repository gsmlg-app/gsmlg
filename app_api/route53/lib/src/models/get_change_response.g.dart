// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_change_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetChangeResponse _$GetChangeResponseFromJson(Map<String, dynamic> json) =>
    GetChangeResponse(
      changeInfo:
          ChangeInfo.fromJson(json['changeInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetChangeResponseToJson(GetChangeResponse instance) =>
    <String, dynamic>{
      'changeInfo': instance.changeInfo,
    };
