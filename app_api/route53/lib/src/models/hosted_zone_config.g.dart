// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hosted_zone_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HostedZoneConfig _$HostedZoneConfigFromJson(Map<String, dynamic> json) =>
    HostedZoneConfig(
      comment: json['comment'] as String?,
      privateZone: json['privateZone'] as bool?,
    );

Map<String, dynamic> _$HostedZoneConfigToJson(HostedZoneConfig instance) =>
    <String, dynamic>{
      'comment': instance.comment,
      'privateZone': instance.privateZone,
    };
