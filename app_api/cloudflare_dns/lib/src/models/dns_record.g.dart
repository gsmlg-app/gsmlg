// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dns_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DnsRecord _$DnsRecordFromJson(Map<String, dynamic> json) => DnsRecord(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$DnsRecordTypeEnumMap, json['type']),
      content: json['content'] as String,
      zoneId: json['zone_id'] as String?,
      zoneName: json['zone_name'] as String?,
      proxiable: json['proxiable'] as bool?,
      proxied: json['proxied'] as bool?,
      ttl: (json['ttl'] as num?)?.toInt(),
      locked: json['locked'] as bool?,
      meta: json['meta'] == null
          ? null
          : DnsRecordMeta.fromJson(json['meta'] as Map<String, dynamic>),
      comment: json['comment'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      createdOn: json['created_on'] == null
          ? null
          : DateTime.parse(json['created_on'] as String),
      modifiedOn: json['modified_on'] == null
          ? null
          : DateTime.parse(json['modified_on'] as String),
      data: json['data'],
      priority: (json['priority'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DnsRecordToJson(DnsRecord instance) => <String, dynamic>{
      'id': instance.id,
      'zone_id': instance.zoneId,
      'zone_name': instance.zoneName,
      'name': instance.name,
      'type': _$DnsRecordTypeEnumMap[instance.type]!,
      'content': instance.content,
      'proxiable': instance.proxiable,
      'proxied': instance.proxied,
      'ttl': instance.ttl,
      'locked': instance.locked,
      'meta': instance.meta,
      'comment': instance.comment,
      'tags': instance.tags,
      'created_on': instance.createdOn?.toIso8601String(),
      'modified_on': instance.modifiedOn?.toIso8601String(),
      'data': instance.data,
      'priority': instance.priority,
    };

const _$DnsRecordTypeEnumMap = {
  DnsRecordType.a: 'A',
  DnsRecordType.aaaa: 'AAAA',
  DnsRecordType.caa: 'CAA',
  DnsRecordType.cert: 'CERT',
  DnsRecordType.cname: 'CNAME',
  DnsRecordType.dnskey: 'DNSKEY',
  DnsRecordType.ds: 'DS',
  DnsRecordType.https: 'HTTPS',
  DnsRecordType.loc: 'LOC',
  DnsRecordType.mx: 'MX',
  DnsRecordType.naptr: 'NAPTR',
  DnsRecordType.ns: 'NS',
  DnsRecordType.ptr: 'PTR',
  DnsRecordType.smimea: 'SMIMEA',
  DnsRecordType.srv: 'SRV',
  DnsRecordType.sshfp: 'SSHFP',
  DnsRecordType.svcb: 'SVCB',
  DnsRecordType.tlsa: 'TLSA',
  DnsRecordType.txt: 'TXT',
  DnsRecordType.uri: 'URI',
};
