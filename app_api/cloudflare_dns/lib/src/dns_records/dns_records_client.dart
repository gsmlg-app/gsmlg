// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_dns_record_request.dart';
import '../models/delete_dns_record_response.dart';
import '../models/direction.dart';
import '../models/dns_record_response.dart';
import '../models/dns_record_type.dart';
import '../models/import_dns_records_response.dart';
import '../models/list_dns_records_response.dart';
import '../models/match.dart';
import '../models/order2.dart';
import '../models/patch_dns_record_request.dart';
import '../models/update_dns_record_request.dart';

part 'dns_records_client.g.dart';

@RestApi()
abstract class DnsRecordsClient {
  factory DnsRecordsClient(Dio dio, {String? baseUrl}) = _DnsRecordsClient;

  /// List DNS records.
  ///
  /// Lists all DNS records for a zone.
  ///
  /// [zoneId] - Zone identifier.
  ///
  /// [name] - DNS record name (or @ for the zone apex).
  ///
  /// [type] - Record type.
  ///
  /// [content] - DNS record content.
  ///
  /// [proxied] - Whether the record is receiving the performance and security benefits of Cloudflare.
  ///
  /// [comment] - Comments or notes about the DNS record.
  ///
  /// [tag] - Custom tags for the DNS record.
  ///
  /// [page] - Page number of paginated results.
  ///
  /// [perPage] - Number of DNS records per page.
  ///
  /// [order] - Field to order records by.
  ///
  /// [direction] - Direction to order records.
  ///
  /// [match] - Whether to match all search requirements or at least one (any).
  @GET('/zones/{zone_id}/dns_records')
  Future<ListDnsRecordsResponse> listDnsRecords({
    @Path('zone_id') required String zoneId,
    @Query('page') int? page = 1,
    @Query('per_page') int? perPage = 100,
    @Query('match') Match? match = Match.all,
    @Query('name') String? name,
    @Query('type') DnsRecordType? type,
    @Query('content') String? content,
    @Query('proxied') bool? proxied,
    @Query('comment') String? comment,
    @Query('tag') String? tag,
    @Query('order') Order2? order,
    @Query('direction') Direction? direction,
  });

  /// Create DNS record.
  ///
  /// Creates a new DNS record for a zone.
  ///
  /// [zoneId] - Zone identifier.
  @POST('/zones/{zone_id}/dns_records')
  Future<DnsRecordResponse> createDnsRecord({
    @Path('zone_id') required String zoneId,
    @Body() required CreateDnsRecordRequest body,
  });

  /// Get DNS record.
  ///
  /// Retrieves details of a specific DNS record.
  ///
  /// [zoneId] - Zone identifier.
  ///
  /// [dnsRecordId] - DNS record identifier.
  @GET('/zones/{zone_id}/dns_records/{dns_record_id}')
  Future<DnsRecordResponse> getDnsRecord({
    @Path('zone_id') required String zoneId,
    @Path('dns_record_id') required String dnsRecordId,
  });

  /// Update DNS record.
  ///
  /// Updates an existing DNS record.
  ///
  /// [zoneId] - Zone identifier.
  ///
  /// [dnsRecordId] - DNS record identifier.
  @PUT('/zones/{zone_id}/dns_records/{dns_record_id}')
  Future<DnsRecordResponse> updateDnsRecord({
    @Path('zone_id') required String zoneId,
    @Path('dns_record_id') required String dnsRecordId,
    @Body() required UpdateDnsRecordRequest body,
  });

  /// Patch DNS record.
  ///
  /// Partially updates an existing DNS record.
  ///
  /// [zoneId] - Zone identifier.
  ///
  /// [dnsRecordId] - DNS record identifier.
  @PATCH('/zones/{zone_id}/dns_records/{dns_record_id}')
  Future<DnsRecordResponse> patchDnsRecord({
    @Path('zone_id') required String zoneId,
    @Path('dns_record_id') required String dnsRecordId,
    @Body() required PatchDnsRecordRequest body,
  });

  /// Delete DNS record.
  ///
  /// Deletes an existing DNS record.
  ///
  /// [zoneId] - Zone identifier.
  ///
  /// [dnsRecordId] - DNS record identifier.
  @DELETE('/zones/{zone_id}/dns_records/{dns_record_id}')
  Future<DeleteDnsRecordResponse> deleteDnsRecord({
    @Path('zone_id') required String zoneId,
    @Path('dns_record_id') required String dnsRecordId,
  });

  /// Export DNS records.
  ///
  /// Exports DNS records in BIND config format.
  ///
  /// [zoneId] - Zone identifier.
  @GET('/zones/{zone_id}/dns_records/export')
  Future<String> exportDnsRecords({
    @Path('zone_id') required String zoneId,
  });

  /// Import DNS records.
  ///
  /// Imports DNS records from a BIND config file.
  ///
  /// [zoneId] - Zone identifier.
  ///
  /// [file] - BIND config file to import.
  ///
  /// [proxied] - Whether or not proxiable records should receive the performance and security benefits of Cloudflare.
  @MultiPart()
  @POST('/zones/{zone_id}/dns_records/import')
  Future<ImportDnsRecordsResponse> importDnsRecords({
    @Path('zone_id') required String zoneId,
    @Part(name: 'file') File? file,
    @Part(name: 'proxied') String? proxied,
  });
}
