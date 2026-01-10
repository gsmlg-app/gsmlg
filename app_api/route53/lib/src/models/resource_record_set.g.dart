// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_record_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResourceRecordSet _$ResourceRecordSetFromJson(Map<String, dynamic> json) =>
    ResourceRecordSet(
      name: json['name'] as String,
      type: $enumDecode(_$RecordTypeEnumMap, json['type']),
      setIdentifier: json['setIdentifier'] as String?,
      weight: (json['weight'] as num?)?.toInt(),
      region: json['region'] as String?,
      geoLocation: json['geoLocation'] == null
          ? null
          : GeoLocation.fromJson(json['geoLocation'] as Map<String, dynamic>),
      failover: $enumDecodeNullable(
          _$ResourceRecordSetFailoverEnumMap, json['failover']),
      multiValueAnswer: json['multiValueAnswer'] as bool?,
      ttl: (json['ttl'] as num?)?.toInt(),
      resourceRecords: (json['resourceRecords'] as List<dynamic>?)
          ?.map((e) => ResourceRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      aliasTarget: json['aliasTarget'] == null
          ? null
          : AliasTarget.fromJson(json['aliasTarget'] as Map<String, dynamic>),
      healthCheckId: json['healthCheckId'] as String?,
    );

Map<String, dynamic> _$ResourceRecordSetToJson(ResourceRecordSet instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$RecordTypeEnumMap[instance.type]!,
      'setIdentifier': instance.setIdentifier,
      'weight': instance.weight,
      'region': instance.region,
      'geoLocation': instance.geoLocation,
      'failover': _$ResourceRecordSetFailoverEnumMap[instance.failover],
      'multiValueAnswer': instance.multiValueAnswer,
      'ttl': instance.ttl,
      'resourceRecords': instance.resourceRecords,
      'aliasTarget': instance.aliasTarget,
      'healthCheckId': instance.healthCheckId,
    };

const _$RecordTypeEnumMap = {
  RecordType.a: 'A',
  RecordType.aaaa: 'AAAA',
  RecordType.caa: 'CAA',
  RecordType.cname: 'CNAME',
  RecordType.ds: 'DS',
  RecordType.mx: 'MX',
  RecordType.naptr: 'NAPTR',
  RecordType.ns: 'NS',
  RecordType.ptr: 'PTR',
  RecordType.soa: 'SOA',
  RecordType.spf: 'SPF',
  RecordType.srv: 'SRV',
  RecordType.txt: 'TXT',
};

const _$ResourceRecordSetFailoverEnumMap = {
  ResourceRecordSetFailover.primary: 'PRIMARY',
  ResourceRecordSetFailover.secondary: 'SECONDARY',
};
