// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'dns_record_type.dart';

part 'patch_dns_record_request.g.dart';

@JsonSerializable()
class PatchDnsRecordRequest {
  const PatchDnsRecordRequest({
    this.name,
    this.type,
    this.content,
    this.ttl,
    this.proxied,
    this.comment,
    this.tags,
  });
  
  factory PatchDnsRecordRequest.fromJson(Map<String, Object?> json) => _$PatchDnsRecordRequestFromJson(json);
  
  /// DNS record name (or @ for the zone apex).
  final String? name;
  final DnsRecordType? type;

  /// A valid DNS record value.
  final String? content;

  /// Time To Live (TTL) of the DNS record in seconds.
  final int? ttl;

  /// Whether the record is receiving the performance and security benefits of Cloudflare.
  final bool? proxied;

  /// Comments or notes about the DNS record.
  final String? comment;

  /// Custom tags for the DNS record.
  final List<String>? tags;

  Map<String, Object?> toJson() => _$PatchDnsRecordRequestToJson(this);
}
