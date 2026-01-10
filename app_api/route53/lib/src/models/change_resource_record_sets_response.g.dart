// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_resource_record_sets_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangeResourceRecordSetsResponse _$ChangeResourceRecordSetsResponseFromJson(
        Map<String, dynamic> json) =>
    ChangeResourceRecordSetsResponse(
      changeInfo:
          ChangeInfo.fromJson(json['changeInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChangeResourceRecordSetsResponseToJson(
        ChangeResourceRecordSetsResponse instance) =>
    <String, dynamic>{
      'changeInfo': instance.changeInfo,
    };
