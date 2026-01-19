import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/org.dart';
import '../models/user.dart';

part 'users_client.g.dart';

/// GitHub Users API client.
@RestApi()
abstract class UsersClient {
  factory UsersClient(Dio dio, {String? baseUrl}) = _UsersClient;

  /// Get the authenticated user.
  @GET('/user')
  Future<GitHubUserResponse> getAuthenticatedUser();

  /// Get a user by username.
  @GET('/users/{username}')
  Future<GitHubUserResponse> getUser({
    @Path('username') required String username,
  });

  /// List organizations for the authenticated user.
  @GET('/user/orgs')
  Future<List<OrgResponse>> listUserOrgs({
    @Query('per_page') int? perPage = 100,
    @Query('page') int? page = 1,
  });

  /// List organizations for a user.
  @GET('/users/{username}/orgs')
  Future<List<OrgResponse>> listOrgsForUser({
    @Path('username') required String username,
    @Query('per_page') int? perPage = 100,
    @Query('page') int? page = 1,
  });
}
