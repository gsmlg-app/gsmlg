// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hosted_zone.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HostedZone _$HostedZoneFromJson(Map<String, dynamic> json) => HostedZone(
      id: json['id'] as String,
      name: json['name'] as String,
      callerReference: json['callerReference'] as String,
      config: json['config'] == null
          ? null
          : HostedZoneConfig.fromJson(json['config'] as Map<String, dynamic>),
      resourceRecordSetCount: (json['resourceRecordSetCount'] as num?)?.toInt(),
      linkedService: json['linkedService'] == null
          ? null
          : LinkedService.fromJson(
              json['linkedService'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HostedZoneToJson(HostedZone instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'callerReference': instance.callerReference,
      'config': instance.config,
      'resourceRecordSetCount': instance.resourceRecordSetCount,
      'linkedService': instance.linkedService,
    };
