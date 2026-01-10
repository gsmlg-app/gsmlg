// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_hosted_zones_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListHostedZonesResponse _$ListHostedZonesResponseFromJson(
        Map<String, dynamic> json) =>
    ListHostedZonesResponse(
      hostedZones: (json['hostedZones'] as List<dynamic>)
          .map((e) => HostedZone.fromJson(e as Map<String, dynamic>))
          .toList(),
      isTruncated: json['isTruncated'] as bool,
      maxItems: (json['maxItems'] as num).toInt(),
      marker: json['marker'] as String?,
      nextMarker: json['nextMarker'] as String?,
    );

Map<String, dynamic> _$ListHostedZonesResponseToJson(
        ListHostedZonesResponse instance) =>
    <String, dynamic>{
      'hostedZones': instance.hostedZones,
      'marker': instance.marker,
      'isTruncated': instance.isTruncated,
      'nextMarker': instance.nextMarker,
      'maxItems': instance.maxItems,
    };
