// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimpleUser _$SimpleUserFromJson(Map<String, dynamic> json) => SimpleUser(
  id: (json['id'] as num).toInt(),
  login: json['login'] as String,
  nodeId: json['node_id'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  gravatarId: json['gravatar_id'] as String?,
  url: json['url'] as String?,
  htmlUrl: json['html_url'] as String?,
  type: json['type'] as String?,
  siteAdmin: json['site_admin'] as bool?,
  name: json['name'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$SimpleUserToJson(SimpleUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'login': instance.login,
      'node_id': instance.nodeId,
      'avatar_url': instance.avatarUrl,
      'gravatar_id': instance.gravatarId,
      'url': instance.url,
      'html_url': instance.htmlUrl,
      'type': instance.type,
      'site_admin': instance.siteAdmin,
      'name': instance.name,
      'email': instance.email,
    };
