import 'package:freezed_annotation/freezed_annotation.dart';

part 'org.freezed.dart';
part 'org.g.dart';

/// GitHub organization model.
@freezed
class OrgResponse with _$OrgResponse {
  const factory OrgResponse({
    required int id,
    required String login,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'html_url') String? htmlUrl,
    String? description,
    String? name,
    String? company,
    String? blog,
    String? location,
    String? email,
    @JsonKey(name: 'public_repos') int? publicRepos,
    @JsonKey(name: 'public_gists') int? publicGists,
    int? followers,
    int? following,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _OrgResponse;

  factory OrgResponse.fromJson(Map<String, dynamic> json) =>
      _$OrgResponseFromJson(json);
}
