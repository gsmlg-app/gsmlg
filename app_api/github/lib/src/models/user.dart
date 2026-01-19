import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// GitHub user model.
@freezed
class GitHubUserResponse with _$GitHubUserResponse {
  const factory GitHubUserResponse({
    required int id,
    required String login,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'html_url') String? htmlUrl,
    String? name,
    String? email,
    String? bio,
    String? company,
    String? location,
    @JsonKey(name: 'public_repos') int? publicRepos,
    @JsonKey(name: 'public_gists') int? publicGists,
    int? followers,
    int? following,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _GitHubUserResponse;

  factory GitHubUserResponse.fromJson(Map<String, dynamic> json) =>
      _$GitHubUserResponseFromJson(json);
}
