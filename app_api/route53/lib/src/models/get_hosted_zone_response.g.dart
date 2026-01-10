// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_hosted_zone_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetHostedZoneResponse _$GetHostedZoneResponseFromJson(
        Map<String, dynamic> json) =>
    GetHostedZoneResponse(
      hostedZone:
          HostedZone.fromJson(json['hostedZone'] as Map<String, dynamic>),
      delegationSet: json['delegationSet'] == null
          ? null
          : DelegationSet.fromJson(
              json['delegationSet'] as Map<String, dynamic>),
      vpCs: (json['vpCs'] as List<dynamic>?)
          ?.map((e) => Vpc.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetHostedZoneResponseToJson(
        GetHostedZoneResponse instance) =>
    <String, dynamic>{
      'hostedZone': instance.hostedZone,
      'delegationSet': instance.delegationSet,
      'vpCs': instance.vpCs,
    };
