// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'dns_record_meta.g.dart';

@JsonSerializable()
class DnsRecordMeta {
  const DnsRecordMeta({
    this.autoAdded,
    this.source,
  });
  
  factory DnsRecordMeta.fromJson(Map<String, Object?> json) => _$DnsRecordMetaFromJson(json);
  
  /// Will exist if Cloudflare automatically added this DNS record.
  @JsonKey(name: 'auto_added')
  final bool? autoAdded;

  /// Where the record originated from.
  final String? source;

  Map<String, Object?> toJson() => _$DnsRecordMetaToJson(this);
}
