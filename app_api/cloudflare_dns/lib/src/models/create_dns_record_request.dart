// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'dns_record_data.dart';
import 'dns_record_type.dart';

part 'create_dns_record_request.g.dart';

@JsonSerializable()
class CreateDnsRecordRequest {
  const CreateDnsRecordRequest({
    required this.name,
    required this.type,
    required this.content,
    this.priority,
    this.comment,
    this.tags,
    this.data,
    this.ttl = 1,
    this.proxied = false,
  });
  
  factory CreateDnsRecordRequest.fromJson(Map<String, Object?> json) => _$CreateDnsRecordRequestFromJson(json);
  
  /// DNS record name (or @ for the zone apex).
  final String name;
  final DnsRecordType type;

  /// A valid DNS record value.
  final String content;

  /// Time To Live (TTL) of the DNS record in seconds. Setting to 1 means automatic.
  final int ttl;

  /// Required for MX, SRV and URI records.
  final int? priority;

  /// Whether the record is receiving the performance and security benefits of Cloudflare.
  final bool proxied;

  /// Comments or notes about the DNS record.
  final String? comment;

  /// Custom tags for the DNS record.
  final List<String>? tags;
  final DnsRecordData? data;

  Map<String, Object?> toJson() => _$CreateDnsRecordRequestToJson(this);
}
