// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Repo _$RepoFromJson(Map<String, dynamic> json) => Repo(
  id: (json['id'] as num?)?.toInt(),
  url: json['url'] as String?,
  name: json['name'] as String?,
);

Map<String, dynamic> _$RepoToJson(Repo instance) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'name': instance.name,
};
