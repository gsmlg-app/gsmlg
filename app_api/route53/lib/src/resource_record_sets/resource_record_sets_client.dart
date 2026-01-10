// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/change_resource_record_sets_request.dart';
import '../models/change_resource_record_sets_response.dart';
import '../models/get_change_response.dart';
import '../models/list_resource_record_sets_response.dart';
import '../models/record_type.dart';

part 'resource_record_sets_client.g.dart';

@RestApi()
abstract class ResourceRecordSetsClient {
  factory ResourceRecordSetsClient(Dio dio, {String? baseUrl}) = _ResourceRecordSetsClient;

  /// List resource record sets.
  ///
  /// Lists the resource record sets in a specified hosted zone.
  ///
  /// [hostedZoneId] - The ID of the hosted zone that contains the resource record sets.
  ///
  /// [name] - The first name in the lexicographic ordering of resource record sets to return.
  ///
  /// [type] - The type of resource record set to begin the record listing from.
  ///
  /// [identifier] - Resource record sets that have a routing policy other than simple.
  ///
  /// [maxitems] - The maximum number of records to return.
  @GET('/hostedzone/{hostedZoneId}/rrset')
  Future<ListResourceRecordSetsResponse> listResourceRecordSets({
    @Path('hostedZoneId') required String hostedZoneId,
    @Query('maxitems') int? maxitems = 300,
    @Query('name') String? name,
    @Query('type') RecordType? type,
    @Query('identifier') String? identifier,
  });

  /// Create, update, or delete resource record sets.
  ///
  /// Creates, changes, or deletes a resource record set, which contains authoritative DNS information for a specified domain name or subdomain name.
  ///
  /// [hostedZoneId] - The ID of the hosted zone that contains the resource record sets.
  @POST('/hostedzone/{hostedZoneId}/rrset/')
  Future<ChangeResourceRecordSetsResponse> changeResourceRecordSets({
    @Path('hostedZoneId') required String hostedZoneId,
    @Body() required ChangeResourceRecordSetsRequest body,
  });

  /// Get change status.
  ///
  /// Returns the current status of a change batch request.
  ///
  /// [changeId] - The ID of the change batch request.
  @GET('/change/{changeId}')
  Future<GetChangeResponse> getChange({
    @Path('changeId') required String changeId,
  });
}
