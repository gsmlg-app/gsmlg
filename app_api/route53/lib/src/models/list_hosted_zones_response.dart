// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'hosted_zone.dart';

part 'list_hosted_zones_response.g.dart';

@JsonSerializable()
class ListHostedZonesResponse {
  const ListHostedZonesResponse({
    required this.hostedZones,
    required this.isTruncated,
    required this.maxItems,
    this.marker,
    this.nextMarker,
  });

  factory ListHostedZonesResponse.fromJson(Map<String, Object?> json) =>
      _$ListHostedZonesResponseFromJson(json);

  final List<HostedZone> hostedZones;
  final String? marker;
  final bool isTruncated;
  final String? nextMarker;
  final int maxItems;

  Map<String, Object?> toJson() => _$ListHostedZonesResponseToJson(this);
}
