// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Zone _$ZoneFromJson(Map<String, dynamic> json) => Zone(
      id: json['id'] as String,
      name: json['name'] as String,
      status: $enumDecodeNullable(_$ZoneStatusEnumMap, json['status'],
          unknownValue: JsonKey.nullForUndefinedEnumValue),
      paused: json['paused'] as bool?,
      type: $enumDecodeNullable(_$ZoneTypeEnumMap, json['type'],
          unknownValue: JsonKey.nullForUndefinedEnumValue),
      developmentMode: (json['development_mode'] as num?)?.toInt(),
      nameServers: (json['name_servers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      originalNameServers: (json['original_name_servers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      originalRegistrar: json['original_registrar'] as String?,
      originalDnshost: json['original_dnshost'] as String?,
      modifiedOn: json['modified_on'] == null
          ? null
          : DateTime.parse(json['modified_on'] as String),
      createdOn: json['created_on'] == null
          ? null
          : DateTime.parse(json['created_on'] as String),
      activatedOn: json['activated_on'] == null
          ? null
          : DateTime.parse(json['activated_on'] as String),
      meta: json['meta'],
      owner: json['owner'] == null
          ? null
          : Owner.fromJson(json['owner'] as Map<String, dynamic>),
      account: json['account'] == null
          ? null
          : Account.fromJson(json['account'] as Map<String, dynamic>),
      permissions: (json['permissions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      plan: json['plan'] == null
          ? null
          : Plan.fromJson(json['plan'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ZoneToJson(Zone instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': _$ZoneStatusEnumMap[instance.status],
      'paused': instance.paused,
      'type': _$ZoneTypeEnumMap[instance.type],
      'development_mode': instance.developmentMode,
      'name_servers': instance.nameServers,
      'original_name_servers': instance.originalNameServers,
      'original_registrar': instance.originalRegistrar,
      'original_dnshost': instance.originalDnshost,
      'modified_on': instance.modifiedOn?.toIso8601String(),
      'created_on': instance.createdOn?.toIso8601String(),
      'activated_on': instance.activatedOn?.toIso8601String(),
      'meta': instance.meta,
      'owner': instance.owner,
      'account': instance.account,
      'permissions': instance.permissions,
      'plan': instance.plan,
    };

const _$ZoneStatusEnumMap = {
  ZoneStatus.initializing: 'initializing',
  ZoneStatus.pending: 'pending',
  ZoneStatus.active: 'active',
  ZoneStatus.moved: 'moved',
  ZoneStatus.deactivated: 'deactivated',
  ZoneStatus.readOnly: 'read only',
  ZoneStatus.deleted: 'deleted',
};

const _$ZoneTypeEnumMap = {
  ZoneType.full: 'full',
  ZoneType.partial: 'partial',
  ZoneType.secondary: 'secondary',
};
