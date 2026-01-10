// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_hosted_zone_response.dart';
import '../models/list_hosted_zones_response.dart';

part 'hosted_zones_client.g.dart';

@RestApi()
abstract class HostedZonesClient {
  factory HostedZonesClient(Dio dio, {String? baseUrl}) = _HostedZonesClient;

  /// List all hosted zones.
  ///
  /// Retrieves a list of the public and private hosted zones that are associated with the current AWS account.
  ///
  /// [marker] - If the response includes more than maxitems hosted zones, the value of NextMarker is the hosted zone ID of the first hosted zone in the next group.
  ///
  /// [maxitems] - The maximum number of hosted zones to be included in the response body.
  ///
  /// [delegationsetid] - If you're using reusable delegation sets and you want to list all of the hosted zones that are associated with a reusable delegation set, specify the ID of that delegation set.
  @GET('/hostedzone')
  Future<ListHostedZonesResponse> listHostedZones({
    @Query('maxitems') int? maxitems = 100,
    @Query('marker') String? marker,
    @Query('delegationsetid') String? delegationsetid,
  });

  /// Get hosted zone details.
  ///
  /// Gets information about a specified hosted zone including the four name servers assigned to the hosted zone.
  ///
  /// [hostedZoneId] - The ID of the hosted zone that you want to get information about.
  @GET('/hostedzone/{hostedZoneId}')
  Future<GetHostedZoneResponse> getHostedZone({
    @Path('hostedZoneId') required String hostedZoneId,
  });
}
