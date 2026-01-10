// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoLocation _$GeoLocationFromJson(Map<String, dynamic> json) => GeoLocation(
      continentCode: json['continentCode'] as String?,
      countryCode: json['countryCode'] as String?,
      subdivisionCode: json['subdivisionCode'] as String?,
    );

Map<String, dynamic> _$GeoLocationToJson(GeoLocation instance) =>
    <String, dynamic>{
      'continentCode': instance.continentCode,
      'countryCode': instance.countryCode,
      'subdivisionCode': instance.subdivisionCode,
    };
