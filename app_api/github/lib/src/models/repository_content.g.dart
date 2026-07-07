// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepositoryContent _$RepositoryContentFromJson(Map<String, dynamic> json) =>
    RepositoryContent(
      type: json['type'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      sha: json['sha'] as String,
      encoding: json['encoding'] as String?,
      size: (json['size'] as num?)?.toInt(),
      content: json['content'] as String?,
      url: json['url'] as String?,
      gitUrl: json['git_url'] as String?,
      htmlUrl: json['html_url'] as String?,
      downloadUrl: json['download_url'] as String?,
    );

Map<String, dynamic> _$RepositoryContentToJson(RepositoryContent instance) =>
    <String, dynamic>{
      'type': instance.type,
      'encoding': instance.encoding,
      'size': instance.size,
      'name': instance.name,
      'path': instance.path,
      'content': instance.content,
      'sha': instance.sha,
      'url': instance.url,
      'git_url': instance.gitUrl,
      'html_url': instance.htmlUrl,
      'download_url': instance.downloadUrl,
    };
