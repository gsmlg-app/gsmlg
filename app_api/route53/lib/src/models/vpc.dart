// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'vpc.g.dart';

@JsonSerializable()
class Vpc {
  const Vpc({
    this.vpcRegion,
    this.vpcId,
  });
  
  factory Vpc.fromJson(Map<String, Object?> json) => _$VpcFromJson(json);
  
  final String? vpcRegion;
  final String? vpcId;

  Map<String, Object?> toJson() => _$VpcToJson(this);
}
