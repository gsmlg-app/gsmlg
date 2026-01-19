import 'package:dio/dio.dart';

import 'actions/actions_client.dart';
import 'repos/repos_client.dart';
import 'users/users_client.dart';

export 'actions/actions_client.dart';
export 'repos/repos_client.dart';
export 'users/users_client.dart';

/// GitHub API client.
///
/// Provides access to GitHub REST API endpoints for users, repos, and actions.
class GitHubApi {
  GitHubApi({
    required String token,
    Dio? dio,
    String baseUrl = 'https://api.github.com',
  }) : _dio = dio ?? _createDio(token, baseUrl) {
    _users = UsersClient(_dio, baseUrl: baseUrl);
    _repos = ReposClient(_dio, baseUrl: baseUrl);
    _actions = ActionsClient(_dio, baseUrl: baseUrl);
  }

  final Dio _dio;
  late final UsersClient _users;
  late final ReposClient _repos;
  late final ActionsClient _actions;

  /// Users API client.
  UsersClient get users => _users;

  /// Repos API client.
  ReposClient get repos => _repos;

  /// Actions API client.
  ActionsClient get actions => _actions;

  /// Close the HTTP client.
  void close() {
    _dio.close();
  }

  static Dio _createDio(String token, String baseUrl) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Accept': 'application/vnd.github+json',
        'Authorization': 'Bearer $token',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    ));
    return dio;
  }
}
