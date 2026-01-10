// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_resource_record_sets_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListResourceRecordSetsResponse _$ListResourceRecordSetsResponseFromJson(
        Map<String, dynamic> json) =>
    ListResourceRecordSetsResponse(
      resourceRecordSets: (json['resourceRecordSets'] as List<dynamic>)
          .map((e) => ResourceRecordSet.fromJson(e as Map<String, dynamic>))
          .toList(),
      isTruncated: json['isTruncated'] as bool,
      maxItems: (json['maxItems'] as num).toInt(),
      nextRecordName: json['nextRecordName'] as String?,
      nextRecordType:
          $enumDecodeNullable(_$RecordTypeEnumMap, json['nextRecordType']),
      nextRecordIdentifier: json['nextRecordIdentifier'] as String?,
    );

Map<String, dynamic> _$ListResourceRecordSetsResponseToJson(
        ListResourceRecordSetsResponse instance) =>
    <String, dynamic>{
      'resourceRecordSets': instance.resourceRecordSets,
      'isTruncated': instance.isTruncated,
      'nextRecordName': instance.nextRecordName,
      'nextRecordType': _$RecordTypeEnumMap[instance.nextRecordType],
      'nextRecordIdentifier': instance.nextRecordIdentifier,
      'maxItems': instance.maxItems,
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
