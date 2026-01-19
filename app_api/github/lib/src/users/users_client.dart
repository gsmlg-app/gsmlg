// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/organization.dart';
import '../models/user.dart';

part 'users_client.g.dart';

@RestApi()
abstract class UsersClient {
  factory UsersClient(Dio dio, {String? baseUrl}) = _UsersClient;

  /// Get the authenticated user.
  ///
  /// If the authenticated user is authenticated with an OAuth token with the `user` scope,.
  /// then the response lists public and private profile information.
  @GET('/user')
  Future<User> getAuthenticatedUser();

  /// List organizations for the authenticated user.
  ///
  /// List organizations for the authenticated user.
  ///
  /// [perPage] - The number of results per page (max 100).
  ///
  /// [page] - Page number of the results to fetch.
  @GET('/user/orgs')
  Future<List<Organization>> listOrgsForAuthenticatedUser({
    @Query('per_page') int? perPage = 30,
    @Query('page') int? page = 1,
  });
}
