// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/direction.dart';
import '../models/repository.dart';
import '../models/sort.dart';
import '../models/type.dart';
import '../models/visibility.dart';

part 'repos_client.g.dart';

@RestApi()
abstract class ReposClient {
  factory ReposClient(Dio dio, {String? baseUrl}) = _ReposClient;

  /// List repositories for the authenticated user.
  ///
  /// Lists repositories that the authenticated user has explicit permission.
  /// (:read, :write, or :admin) to access.
  ///
  /// [visibility] - Limit results to repositories with the specified visibility.
  ///
  /// [affiliation] - Comma-separated list of values. Can include:.
  /// * `owner`: Repositories that are owned by the authenticated user.
  /// * `collaborator`: Repositories that the user has been added to as a collaborator.
  /// * `organization_member`: Repositories that the user has access to through being a member of an organization.
  ///
  ///
  /// [type] - Limit results to repositories of the specified type.
  ///
  /// [sort] - The property to sort the results by.
  ///
  /// [direction] - The order to sort by.
  ///
  /// [perPage] - The number of results per page (max 100).
  ///
  /// [page] - Page number of the results to fetch.
  @GET('/user/repos')
  Future<List<Repository>> listReposForAuthenticatedUser({
    @Query('direction') Direction? direction,
    @Query('visibility') Visibility? visibility = Visibility.all,
    @Query('affiliation')
    String? affiliation = 'owner,collaborator,organization_member',
    @Query('type') Type? type = Type.all,
    @Query('sort') Sort? sort = Sort.fullName,
    @Query('per_page') int? perPage = 30,
    @Query('page') int? page = 1,
  });

  /// Get a repository.
  ///
  /// The `parent` and `source` objects are present when the repository is a fork.
  ///
  /// [owner] - The account owner of the repository.
  ///
  /// [repo] - The name of the repository without the `.git` extension.
  @GET('/repos/{owner}/{repo}')
  Future<Repository> getRepo({
    @Path('owner') required String owner,
    @Path('repo') required String repo,
  });
}
