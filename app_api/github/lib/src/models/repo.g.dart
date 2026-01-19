// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RepoOwner _$RepoOwnerFromJson(Map<String, dynamic> json) => _RepoOwner(
  id: (json['id'] as num).toInt(),
  login: json['login'] as String,
  avatarUrl: json['avatar_url'] as String?,
  htmlUrl: json['html_url'] as String?,
  type: json['type'] as String?,
);

Map<String, dynamic> _$RepoOwnerToJson(_RepoOwner instance) =>
    <String, dynamic>{
      'id': instance.id,
      'login': instance.login,
      'avatar_url': instance.avatarUrl,
      'html_url': instance.htmlUrl,
      'type': instance.type,
    };

_RepoResponse _$RepoResponseFromJson(Map<String, dynamic> json) =>
    _RepoResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      owner: RepoOwner.fromJson(json['owner'] as Map<String, dynamic>),
      isPrivate: json['private'] as bool,
      htmlUrl: json['html_url'] as String?,
      description: json['description'] as String?,
      fork: json['fork'] as bool?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      pushedAt: json['pushed_at'] == null
          ? null
          : DateTime.parse(json['pushed_at'] as String),
      gitUrl: json['git_url'] as String?,
      sshUrl: json['ssh_url'] as String?,
      cloneUrl: json['clone_url'] as String?,
      defaultBranch: json['default_branch'] as String?,
      stargazersCount: (json['stargazers_count'] as num?)?.toInt(),
      watchersCount: (json['watchers_count'] as num?)?.toInt(),
      forksCount: (json['forks_count'] as num?)?.toInt(),
      openIssuesCount: (json['open_issues_count'] as num?)?.toInt(),
      language: json['language'] as String?,
      hasIssues: json['has_issues'] as bool?,
      hasProjects: json['has_projects'] as bool?,
      hasWiki: json['has_wiki'] as bool?,
      hasPages: json['has_pages'] as bool?,
      hasDownloads: json['has_downloads'] as bool?,
      archived: json['archived'] as bool?,
      disabled: json['disabled'] as bool?,
      visibility: json['visibility'] as String?,
    );

Map<String, dynamic> _$RepoResponseToJson(_RepoResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'full_name': instance.fullName,
      'owner': instance.owner,
      'private': instance.isPrivate,
      'html_url': instance.htmlUrl,
      'description': instance.description,
      'fork': instance.fork,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'pushed_at': instance.pushedAt?.toIso8601String(),
      'git_url': instance.gitUrl,
      'ssh_url': instance.sshUrl,
      'clone_url': instance.cloneUrl,
      'default_branch': instance.defaultBranch,
      'stargazers_count': instance.stargazersCount,
      'watchers_count': instance.watchersCount,
      'forks_count': instance.forksCount,
      'open_issues_count': instance.openIssuesCount,
      'language': instance.language,
      'has_issues': instance.hasIssues,
      'has_projects': instance.hasProjects,
      'has_wiki': instance.hasWiki,
      'has_pages': instance.hasPages,
      'has_downloads': instance.hasDownloads,
      'archived': instance.archived,
      'disabled': instance.disabled,
      'visibility': instance.visibility,
    };
