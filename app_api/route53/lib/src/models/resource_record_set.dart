// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'alias_target.dart';
import 'geo_location.dart';
import 'record_type.dart';
import 'resource_record.dart';
import 'resource_record_set_failover.dart';

part 'resource_record_set.g.dart';

@JsonSerializable()
class ResourceRecordSet {
  const ResourceRecordSet({
    required this.name,
    required this.type,
    this.setIdentifier,
    this.weight,
    this.region,
    this.geoLocation,
    this.failover,
    this.multiValueAnswer,
    this.ttl,
    this.resourceRecords,
    this.aliasTarget,
    this.healthCheckId,
  });

  factory ResourceRecordSet.fromJson(Map<String, Object?> json) =>
      _$ResourceRecordSetFromJson(json);

  /// The name of the domain.
  final String name;
  final RecordType type;

  /// Resource record sets that have a routing policy other than simple.
  final String? setIdentifier;

  /// Weighted resource record sets only.
  final int? weight;

  /// Latency-based resource record sets only.
  final String? region;
  final GeoLocation? geoLocation;
  final ResourceRecordSetFailover? failover;
  final bool? multiValueAnswer;

  /// The TTL in seconds.
  final int? ttl;
  final List<ResourceRecord>? resourceRecords;
  final AliasTarget? aliasTarget;
  final String? healthCheckId;

  Map<String, Object?> toJson() => _$ResourceRecordSetToJson(this);
}
