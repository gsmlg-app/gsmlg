// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delegation_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DelegationSet _$DelegationSetFromJson(Map<String, dynamic> json) =>
    DelegationSet(
      id: json['id'] as String?,
      callerReference: json['callerReference'] as String?,
      nameServers: (json['nameServers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$DelegationSetToJson(DelegationSet instance) =>
    <String, dynamic>{
      'id': instance.id,
      'callerReference': instance.callerReference,
      'nameServers': instance.nameServers,
    };
