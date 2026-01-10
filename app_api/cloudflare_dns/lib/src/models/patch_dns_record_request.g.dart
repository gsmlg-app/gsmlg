// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_dns_record_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchDnsRecordRequest _$PatchDnsRecordRequestFromJson(
        Map<String, dynamic> json) =>
    PatchDnsRecordRequest(
      name: json['name'] as String?,
      type: $enumDecodeNullable(_$DnsRecordTypeEnumMap, json['type']),
      content: json['content'] as String?,
      ttl: (json['ttl'] as num?)?.toInt(),
      proxied: json['proxied'] as bool?,
      comment: json['comment'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$PatchDnsRecordRequestToJson(
        PatchDnsRecordRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$DnsRecordTypeEnumMap[instance.type],
      'content': instance.content,
      'ttl': instance.ttl,
      'proxied': instance.proxied,
      'comment': instance.comment,
      'tags': instance.tags,
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
