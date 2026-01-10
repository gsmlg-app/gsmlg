// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'linked_service.g.dart';

@JsonSerializable()
class LinkedService {
  const LinkedService({
    this.servicePrincipal,
    this.description,
  });
  
  factory LinkedService.fromJson(Map<String, Object?> json) => _$LinkedServiceFromJson(json);
  
  final String? servicePrincipal;
  final String? description;

  Map<String, Object?> toJson() => _$LinkedServiceToJson(this);
}
