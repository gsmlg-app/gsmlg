// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/direction.dart';
import '../models/repository.dart';
import '../models/sort.dart';
import '../models/type2.dart';

part 'orgs_client.g.dart';

@RestApi()
abstract class OrgsClient {
  factory OrgsClient(Dio dio, {String? baseUrl}) = _OrgsClient;

  /// List organization repositories.
  ///
  /// Lists repositories for the specified organization.
  ///
  /// [org] - The organization name.
  ///
  /// [type] - Specifies the types of repositories you want returned.
  ///
  /// [sort] - The property to sort the results by.
  ///
  /// [direction] - The order to sort by.
  ///
  /// [perPage] - The number of results per page (max 100).
  ///
  /// [page] - Page number of the results to fetch.
  @GET('/orgs/{org}/repos')
  Future<List<Repository>> listOrgRepos({
    @Path('org') required String org,
    @Query('direction') Direction? direction,
    @Query('type') Type2? type = Type2.all,
    @Query('sort') Sort? sort = Sort.created,
    @Query('per_page') int? perPage = 30,
    @Query('page') int? page = 1,
  });
}
