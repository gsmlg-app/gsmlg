// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/direction.dart';
import '../models/get_zone_response.dart';
import '../models/list_zones_response.dart';
import '../models/match.dart';
import '../models/order.dart';
import '../models/zone_status.dart';

part 'zones_client.g.dart';

@RestApi()
abstract class ZonesClient {
  factory ZonesClient(Dio dio, {String? baseUrl}) = _ZonesClient;

  /// List zones.
  ///
  /// Lists, searches, sorts, and filters your zones.
  ///
  /// [name] - A domain name. Optional filter operators can be provided to extend refine the search.
  ///
  /// [accountId] - An account identifier.
  ///
  /// [accountName] - An account name.
  ///
  /// [status] - A zone status.
  ///
  /// [page] - Page number of paginated results.
  ///
  /// [perPage] - Number of zones per page.
  ///
  /// [order] - Field to order zones by.
  ///
  /// [direction] - Direction to order zones.
  ///
  /// [match] - Whether to match all search requirements or at least one (any).
  @GET('/zones')
  Future<ListZonesResponse> listZones({
    @Query('page') int? page = 1,
    @Query('per_page') int? perPage = 20,
    @Query('match') Match? match = Match.all,
    @Query('name') String? name,
    @Query('account.id') String? object0,
    @Query('account.name') String? object1,
    @Query('status') ZoneStatus? status,
    @Query('order') Order? order,
    @Query('direction') Direction? direction,
  });

  /// Get zone details.
  ///
  /// Retrieves information about an existing zone.
  ///
  /// [zoneId] - Zone identifier.
  @GET('/zones/{zone_id}')
  Future<GetZoneResponse> getZone({
    @Path('zone_id') required String zoneId,
  });
}
