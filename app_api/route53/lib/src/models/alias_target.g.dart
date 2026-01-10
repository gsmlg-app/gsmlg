// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alias_target.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AliasTarget _$AliasTargetFromJson(Map<String, dynamic> json) => AliasTarget(
      hostedZoneId: json['hostedZoneId'] as String,
      dnsName: json['dnsName'] as String,
      evaluateTargetHealth: json['evaluateTargetHealth'] as bool,
    );

Map<String, dynamic> _$AliasTargetToJson(AliasTarget instance) =>
    <String, dynamic>{
      'hostedZoneId': instance.hostedZoneId,
      'dnsName': instance.dnsName,
      'evaluateTargetHealth': instance.evaluateTargetHealth,
    };
