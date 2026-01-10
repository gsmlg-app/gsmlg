// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dns_record_meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DnsRecordMeta _$DnsRecordMetaFromJson(Map<String, dynamic> json) =>
    DnsRecordMeta(
      autoAdded: json['auto_added'] as bool?,
      source: json['source'] as String?,
    );

Map<String, dynamic> _$DnsRecordMetaToJson(DnsRecordMeta instance) =>
    <String, dynamic>{
      'auto_added': instance.autoAdded,
      'source': instance.source,
    };
