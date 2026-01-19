// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// GitHub user account
@JsonSerializable()
class User {
  const User({
    required this.type,
    required this.login,
    required this.id,
    this.organizationsUrl,
    this.gravatarId,
    this.url,
    this.htmlUrl,
    this.followersUrl,
    this.followingUrl,
    this.gistsUrl,
    this.starredUrl,
    this.subscriptionsUrl,
    this.nodeId,
    this.reposUrl,
    this.eventsUrl,
    this.receivedEventsUrl,
    this.avatarUrl,
    this.siteAdmin,
    this.name,
    this.company,
    this.blog,
    this.location,
    this.email,
    this.hireable,
    this.twoFactorAuthentication,
    this.twitterUsername,
    this.publicRepos,
    this.publicGists,
    this.followers,
    this.following,
    this.createdAt,
    this.updatedAt,
    this.privateGists,
    this.totalPrivateRepos,
    this.ownedPrivateRepos,
    this.diskUsage,
    this.collaborators,
    this.bio,
  });
  
  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);
  
  /// Unique identifier of the user
  final int id;

  /// The username used to login
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
  @JsonKey(name: 'followers_url')
  final String? followersUrl;
  @JsonKey(name: 'following_url')
  final String? followingUrl;
  @JsonKey(name: 'gists_url')
  final String? gistsUrl;
  @JsonKey(name: 'starred_url')
  final String? starredUrl;
  @JsonKey(name: 'subscriptions_url')
  final String? subscriptionsUrl;
  @JsonKey(name: 'organizations_url')
  final String? organizationsUrl;
  @JsonKey(name: 'repos_url')
  final String? reposUrl;
  @JsonKey(name: 'events_url')
  final String? eventsUrl;
  @JsonKey(name: 'received_events_url')
  final String? receivedEventsUrl;
  final String type;
  @JsonKey(name: 'site_admin')
  final bool? siteAdmin;
  final String? name;
  final String? company;
  final String? blog;
  final String? location;
  final String? email;
  final bool? hireable;
  final String? bio;
  @JsonKey(name: 'twitter_username')
  final String? twitterUsername;
  @JsonKey(name: 'public_repos')
  final int? publicRepos;
  @JsonKey(name: 'public_gists')
  final int? publicGists;
  final int? followers;
  final int? following;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'private_gists')
  final int? privateGists;
  @JsonKey(name: 'total_private_repos')
  final int? totalPrivateRepos;
  @JsonKey(name: 'owned_private_repos')
  final int? ownedPrivateRepos;
  @JsonKey(name: 'disk_usage')
  final int? diskUsage;
  final int? collaborators;
  @JsonKey(name: 'two_factor_authentication')
  final bool? twoFactorAuthentication;

  Map<String, Object?> toJson() => _$UserToJson(this);
}
