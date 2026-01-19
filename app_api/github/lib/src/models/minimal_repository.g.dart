// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'minimal_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MinimalRepository _$MinimalRepositoryFromJson(Map<String, dynamic> json) =>
    MinimalRepository(
      id: (json['id'] as num?)?.toInt(),
      nodeId: json['node_id'] as String?,
      name: json['name'] as String?,
      fullName: json['full_name'] as String?,
      owner: json['owner'] == null
          ? null
          : SimpleUser.fromJson(json['owner'] as Map<String, dynamic>),
      private: json['private'] as bool?,
      htmlUrl: json['html_url'] as String?,
      description: json['description'] as String?,
      fork: json['fork'] as bool?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$MinimalRepositoryToJson(MinimalRepository instance) =>
    <String, dynamic>{
      'id': instance.id,
      'node_id': instance.nodeId,
      'name': instance.name,
      'full_name': instance.fullName,
      'owner': instance.owner,
      'private': instance.private,
      'html_url': instance.htmlUrl,
      'description': instance.description,
      'fork': instance.fork,
      'url': instance.url,
    };
