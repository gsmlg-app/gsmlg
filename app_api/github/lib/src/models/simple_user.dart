// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'simple_user.g.dart';

/// A GitHub user
@JsonSerializable()
class SimpleUser {
  const SimpleUser({
    required this.id,
    required this.login,
    this.nodeId,
    this.avatarUrl,
    this.gravatarId,
    this.url,
    this.htmlUrl,
    this.type,
    this.siteAdmin,
    this.name,
    this.email,
  });

  factory SimpleUser.fromJson(Map<String, Object?> json) =>
      _$SimpleUserFromJson(json);

  final int id;
  final String login;
  @JsonKey(name: 'node_id')
  final String? nodeId;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @JsonKey(name: 'gravatar_id')
  final String? gravatarId;
  final String? url;
  @JsonKey(name: 'html_url')
  final String? htmlUrl;
  final String? type;
  @JsonKey(name: 'site_admin')
  final bool? siteAdmin;
  final String? name;
  final String? email;

  Map<String, Object?> toJson() => _$SimpleUserToJson(this);
}
