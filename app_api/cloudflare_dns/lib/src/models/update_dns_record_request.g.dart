// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_dns_record_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateDnsRecordRequest _$UpdateDnsRecordRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateDnsRecordRequest(
      name: json['name'] as String,
      type: $enumDecode(_$DnsRecordTypeEnumMap, json['type']),
      content: json['content'] as String,
      ttl: (json['ttl'] as num?)?.toInt(),
      priority: (json['priority'] as num?)?.toInt(),
      proxied: json['proxied'] as bool?,
      comment: json['comment'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      data: json['data'],
    );

Map<String, dynamic> _$UpdateDnsRecordRequestToJson(
        UpdateDnsRecordRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$DnsRecordTypeEnumMap[instance.type]!,
      'content': instance.content,
      'ttl': instance.ttl,
      'priority': instance.priority,
      'proxied': instance.proxied,
      'comment': instance.comment,
      'tags': instance.tags,
      'data': instance.data,
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
