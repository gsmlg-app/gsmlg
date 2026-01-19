part of 'bloc.dart';

@immutable
class GitHubUser extends Equatable {
  const GitHubUser({
    required this.id,
    required this.login,
    this.name,
    this.email,
    this.avatarUrl,
    this.bio,
    this.company,
    this.location,
    this.blog,
    this.publicRepos,
    this.publicGists,
    this.followers,
    this.following,
    this.createdAt,
  });

  final int id;
  final String login;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final String? bio;
  final String? company;
  final String? location;
  final String? blog;
  final int? publicRepos;
  final int? publicGists;
  final int? followers;
  final int? following;
  final DateTime? createdAt;

  factory GitHubUser.fromJson(Map<String, dynamic> json) {
    return GitHubUser(
      id: json['id'] as int,
      login: json['login'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      company: json['company'] as String?,
      location: json['location'] as String?,
      blog: json['blog'] as String?,
      publicRepos: json['public_repos'] as int?,
      publicGists: json['public_gists'] as int?,
      followers: json['followers'] as int?,
      following: json['following'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  factory GitHubUser.fromApiResponse(GitHubUserResponse response) {
    return GitHubUser(
      id: response.id,
      login: response.login,
      name: response.name,
      email: response.email,
      avatarUrl: response.avatarUrl,
      bio: response.bio,
      company: response.company,
      location: response.location,
      blog: null,
      publicRepos: response.publicRepos,
      publicGists: response.publicGists,
      followers: response.followers,
      following: response.following,
      createdAt: response.createdAt,
    );
  }

  /// Display name (name if available, otherwise login)
  String get displayName => name ?? login;

  @override
  List<Object?> get props => [
        id,
        login,
        name,
        email,
        avatarUrl,
        bio,
        company,
        location,
        blog,
        publicRepos,
        publicGists,
        followers,
        following,
        createdAt,
      ];
}
