// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'geo_location.g.dart';

@JsonSerializable()
class GeoLocation {
  const GeoLocation({
    this.continentCode,
    this.countryCode,
    this.subdivisionCode,
  });
  
  factory GeoLocation.fromJson(Map<String, Object?> json) => _$GeoLocationFromJson(json);
  
  final String? continentCode;
  final String? countryCode;
  final String? subdivisionCode;

  Map<String, Object?> toJson() => _$GeoLocationToJson(this);
}
