// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Repo2 _$Repo2FromJson(Map<String, dynamic> json) => Repo2(
  id: (json['id'] as num?)?.toInt(),
  url: json['url'] as String?,
  name: json['name'] as String?,
);

Map<String, dynamic> _$Repo2ToJson(Repo2 instance) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'name': instance.name,
};
