// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'dns_record_data.dart';
import 'dns_record_meta.dart';
import 'dns_record_type.dart';

part 'dns_record.g.dart';

@JsonSerializable()
class DnsRecord {
  const DnsRecord({
    required this.id,
    required this.name,
    required this.type,
    required this.content,
    this.zoneId,
    this.zoneName,
    this.proxiable,
    this.proxied,
    this.ttl,
    this.locked,
    this.meta,
    this.comment,
    this.tags,
    this.createdOn,
    this.modifiedOn,
    this.data,
    this.priority,
  });
  
  factory DnsRecord.fromJson(Map<String, Object?> json) => _$DnsRecordFromJson(json);
  
  /// DNS record identifier.
  final String id;

  /// Zone identifier.
  @JsonKey(name: 'zone_id')
  final String? zoneId;

  /// The domain of the record.
  @JsonKey(name: 'zone_name')
  final String? zoneName;

  /// DNS record name (or @ for the zone apex).
  final String name;
  final DnsRecordType type;

  /// A valid DNS record value.
  final String content;

  /// Whether the record can be proxied by Cloudflare or not.
  final bool? proxiable;

  /// Whether the record is receiving the performance and security benefits of Cloudflare.
  final bool? proxied;

  /// Time To Live (TTL) of the DNS record in seconds. Setting to 1 means automatic.
  final int? ttl;

  /// Whether this record can be modified/deleted.
  final bool? locked;
  final DnsRecordMeta? meta;

  /// Comments or notes about the DNS record.
  final String? comment;

  /// Custom tags for the DNS record.
  final List<String>? tags;

  /// When the record was created.
  @JsonKey(name: 'created_on')
  final DateTime? createdOn;

  /// When the record was last modified.
  @JsonKey(name: 'modified_on')
  final DateTime? modifiedOn;
  final DnsRecordData? data;

  /// Required for MX, SRV and URI records; unused by other record types.
  final int? priority;

  Map<String, Object?> toJson() => _$DnsRecordToJson(this);
}
