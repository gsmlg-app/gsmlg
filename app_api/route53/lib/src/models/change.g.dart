// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Change _$ChangeFromJson(Map<String, dynamic> json) => Change(
      action: $enumDecode(_$ChangeActionEnumMap, json['action']),
      resourceRecordSet: ResourceRecordSet.fromJson(
          json['resourceRecordSet'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChangeToJson(Change instance) => <String, dynamic>{
      'action': _$ChangeActionEnumMap[instance.action]!,
      'resourceRecordSet': instance.resourceRecordSet,
    };

const _$ChangeActionEnumMap = {
  ChangeAction.create: 'CREATE',
  ChangeAction.delete: 'DELETE',
  ChangeAction.upsert: 'UPSERT',
};
