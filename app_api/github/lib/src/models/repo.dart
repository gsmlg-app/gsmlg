import 'package:freezed_annotation/freezed_annotation.dart';

part 'repo.freezed.dart';
part 'repo.g.dart';

/// GitHub repository owner model.
@freezed
class RepoOwner with _$RepoOwner {
  const factory RepoOwner({
    required int id,
    required String login,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'html_url') String? htmlUrl,
    String? type,
  }) = _RepoOwner;

  factory RepoOwner.fromJson(Map<String, dynamic> json) =>
      _$RepoOwnerFromJson(json);
}

/// GitHub repository model.
@freezed
class RepoResponse with _$RepoResponse {
  const factory RepoResponse({
    required int id,
    required String name,
    @JsonKey(name: 'full_name') required String fullName,
    required RepoOwner owner,
    @JsonKey(name: 'private') required bool isPrivate,
    @JsonKey(name: 'html_url') String? htmlUrl,
    String? description,
    bool? fork,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'pushed_at') DateTime? pushedAt,
    @JsonKey(name: 'git_url') String? gitUrl,
    @JsonKey(name: 'ssh_url') String? sshUrl,
    @JsonKey(name: 'clone_url') String? cloneUrl,
    @JsonKey(name: 'default_branch') String? defaultBranch,
    @JsonKey(name: 'stargazers_count') int? stargazersCount,
    @JsonKey(name: 'watchers_count') int? watchersCount,
    @JsonKey(name: 'forks_count') int? forksCount,
    @JsonKey(name: 'open_issues_count') int? openIssuesCount,
    String? language,
    @JsonKey(name: 'has_issues') bool? hasIssues,
    @JsonKey(name: 'has_projects') bool? hasProjects,
    @JsonKey(name: 'has_wiki') bool? hasWiki,
    @JsonKey(name: 'has_pages') bool? hasPages,
    @JsonKey(name: 'has_downloads') bool? hasDownloads,
    bool? archived,
    bool? disabled,
    String? visibility,
  }) = _RepoResponse;

  factory RepoResponse.fromJson(Map<String, dynamic> json) =>
      _$RepoResponseFromJson(json);
}
