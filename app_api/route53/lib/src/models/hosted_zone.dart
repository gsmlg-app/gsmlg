// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'hosted_zone_config.dart';
import 'linked_service.dart';

part 'hosted_zone.g.dart';

@JsonSerializable()
class HostedZone {
  const HostedZone({
    required this.id,
    required this.name,
    required this.callerReference,
    this.config,
    this.resourceRecordSetCount,
    this.linkedService,
  });
  
  factory HostedZone.fromJson(Map<String, Object?> json) => _$HostedZoneFromJson(json);
  
  /// The ID that Amazon Route 53 assigned to the hosted zone when you created it.
  final String id;

  /// The name of the domain.
  final String name;

  /// A unique string that identifies the request to create the hosted zone.
  final String callerReference;
  final HostedZoneConfig? config;

  /// The number of resource record sets in the hosted zone.
  final int? resourceRecordSetCount;
  final LinkedService? linkedService;

  Map<String, Object?> toJson() => _$HostedZoneToJson(this);
}
