// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'hosted_zone_config.g.dart';

@JsonSerializable()
class HostedZoneConfig {
  const HostedZoneConfig({
    this.comment,
    this.privateZone,
  });
  
  factory HostedZoneConfig.fromJson(Map<String, Object?> json) => _$HostedZoneConfigFromJson(json);
  
  /// Any comments that you want to include about the hosted zone.
  final String? comment;

  /// A value that indicates whether this is a private hosted zone.
  final bool? privateZone;

  Map<String, Object?> toJson() => _$HostedZoneConfigToJson(this);
}
