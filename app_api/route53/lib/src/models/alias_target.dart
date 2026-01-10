// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'alias_target.g.dart';

@JsonSerializable()
class AliasTarget {
  const AliasTarget({
    required this.hostedZoneId,
    required this.dnsName,
    required this.evaluateTargetHealth,
  });
  
  factory AliasTarget.fromJson(Map<String, Object?> json) => _$AliasTargetFromJson(json);
  
  /// The hosted zone ID for the AWS resource.
  final String hostedZoneId;

  /// The DNS domain name for the AWS resource.
  final String dnsName;

  /// When EvaluateTargetHealth is true, an alias resource record set inherits the health of the referenced AWS resource.
  final bool evaluateTargetHealth;

  Map<String, Object?> toJson() => _$AliasTargetToJson(this);
}
