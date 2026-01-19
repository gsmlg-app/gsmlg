// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'org.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrgResponse _$OrgResponseFromJson(Map<String, dynamic> json) => _OrgResponse(
  id: (json['id'] as num).toInt(),
  login: json['login'] as String,
  avatarUrl: json['avatar_url'] as String?,
  htmlUrl: json['html_url'] as String?,
  description: json['description'] as String?,
  name: json['name'] as String?,
  company: json['company'] as String?,
  blog: json['blog'] as String?,
  location: json['location'] as String?,
  email: json['email'] as String?,
  publicRepos: (json['public_repos'] as num?)?.toInt(),
  publicGists: (json['public_gists'] as num?)?.toInt(),
  followers: (json['followers'] as num?)?.toInt(),
  following: (json['following'] as num?)?.toInt(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$OrgResponseToJson(_OrgResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'login': instance.login,
      'avatar_url': instance.avatarUrl,
      'html_url': instance.htmlUrl,
      'description': instance.description,
      'name': instance.name,
      'company': instance.company,
      'blog': instance.blog,
      'location': instance.location,
      'email': instance.email,
      'public_repos': instance.publicRepos,
      'public_gists': instance.publicGists,
      'followers': instance.followers,
      'following': instance.following,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
