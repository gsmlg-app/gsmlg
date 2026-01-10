// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangeInfo _$ChangeInfoFromJson(Map<String, dynamic> json) => ChangeInfo(
      id: json['id'] as String,
      status: $enumDecode(_$ChangeStatusEnumMap, json['status']),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$ChangeInfoToJson(ChangeInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$ChangeStatusEnumMap[instance.status]!,
      'submittedAt': instance.submittedAt.toIso8601String(),
      'comment': instance.comment,
    };

const _$ChangeStatusEnumMap = {
  ChangeStatus.pending: 'PENDING',
  ChangeStatus.insync: 'INSYNC',
};
