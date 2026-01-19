// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'organization.g.dart';

/// GitHub organization
@JsonSerializable()
class Organization {
  const Organization({
    required this.id,
    required this.login,
    this.nodeId,
    this.url,
    this.reposUrl,
    this.eventsUrl,
    this.hooksUrl,
    this.issuesUrl,
    this.membersUrl,
    this.publicMembersUrl,
    this.avatarUrl,
    this.description,
  });
  
  factory Organization.fromJson(Map<String, Object?> json) => _$OrganizationFromJson(json);
  
  final int id;
  final String login;
  @JsonKey(name: 'node_id')
  final String? nodeId;
  final String? url;
  @JsonKey(name: 'repos_url')
  final String? reposUrl;
  @JsonKey(name: 'events_url')
  final String? eventsUrl;
  @JsonKey(name: 'hooks_url')
  final String? hooksUrl;
  @JsonKey(name: 'issues_url')
  final String? issuesUrl;
  @JsonKey(name: 'members_url')
  final String? membersUrl;
  @JsonKey(name: 'public_members_url')
  final String? publicMembersUrl;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  final String? description;

  Map<String, Object?> toJson() => _$OrganizationToJson(this);
}
