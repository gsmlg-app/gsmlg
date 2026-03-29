// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'delegation_set.dart';
import 'hosted_zone.dart';
import 'vpc.dart';

part 'get_hosted_zone_response.g.dart';

@JsonSerializable()
class GetHostedZoneResponse {
  const GetHostedZoneResponse({
    required this.hostedZone,
    this.delegationSet,
    this.vpCs,
  });

  factory GetHostedZoneResponse.fromJson(Map<String, Object?> json) =>
      _$GetHostedZoneResponseFromJson(json);

  final HostedZone hostedZone;
  final DelegationSet? delegationSet;
  final List<Vpc>? vpCs;

  Map<String, Object?> toJson() => _$GetHostedZoneResponseToJson(this);
}
