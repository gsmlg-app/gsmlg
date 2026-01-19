import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/repo.dart';

part 'repos_client.g.dart';

/// GitHub Repositories API client.
@RestApi()
abstract class ReposClient {
  factory ReposClient(Dio dio, {String? baseUrl}) = _ReposClient;

  /// List repositories for the authenticated user.
  @GET('/user/repos')
  Future<List<RepoResponse>> listUserRepos({
    @Query('visibility') String? visibility,
    @Query('affiliation') String? affiliation,
    @Query('type') String? type,
    @Query('sort') String? sort = 'updated',
    @Query('direction') String? direction = 'desc',
    @Query('per_page') int? perPage = 100,
    @Query('page') int? page = 1,
  });

  /// List repositories for a user.
  @GET('/users/{username}/repos')
  Future<List<RepoResponse>> listReposForUser({
    @Path('username') required String username,
    @Query('type') String? type,
    @Query('sort') String? sort = 'updated',
    @Query('direction') String? direction = 'desc',
    @Query('per_page') int? perPage = 100,
    @Query('page') int? page = 1,
  });

  /// List organization repositories.
  @GET('/orgs/{org}/repos')
  Future<List<RepoResponse>> listOrgRepos({
    @Path('org') required String org,
    @Query('type') String? type,
    @Query('sort') String? sort = 'updated',
    @Query('direction') String? direction = 'desc',
    @Query('per_page') int? perPage = 100,
    @Query('page') int? page = 1,
  });

  /// Get a repository.
  @GET('/repos/{owner}/{repo}')
  Future<RepoResponse> getRepo({
    @Path('owner') required String owner,
    @Path('repo') required String repo,
  });
}
