// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_dns_record_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateDnsRecordRequest _$CreateDnsRecordRequestFromJson(
        Map<String, dynamic> json) =>
    CreateDnsRecordRequest(
      name: json['name'] as String,
      type: $enumDecode(_$DnsRecordTypeEnumMap, json['type']),
      content: json['content'] as String,
      priority: (json['priority'] as num?)?.toInt(),
      comment: json['comment'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      data: json['data'],
      ttl: (json['ttl'] as num?)?.toInt() ?? 1,
      proxied: json['proxied'] as bool? ?? false,
    );

Map<String, dynamic> _$CreateDnsRecordRequestToJson(
        CreateDnsRecordRequest instance) =>
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
