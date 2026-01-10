// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'linked_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinkedService _$LinkedServiceFromJson(Map<String, dynamic> json) =>
    LinkedService(
      servicePrincipal: json['servicePrincipal'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$LinkedServiceToJson(LinkedService instance) =>
    <String, dynamic>{
      'servicePrincipal': instance.servicePrincipal,
      'description': instance.description,
    };
