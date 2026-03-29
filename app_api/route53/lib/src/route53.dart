// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'hosted_zones/hosted_zones_client.dart';
import 'resource_record_sets/resource_record_sets_client.dart';

/// AWS Route 53 API `v1.0.0`.
///
/// AWS Route 53 API client for managing hosted zones and DNS records.
/// This is a simplified API specification covering zone listing and record CRUD operations.
///
class Route53 {
  Route53(
    Dio dio, {
    String? baseUrl,
  })  : _dio = dio,
        _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => '1.0.0';

  HostedZonesClient? _hostedZones;
  ResourceRecordSetsClient? _resourceRecordSets;

  HostedZonesClient get hostedZones =>
      _hostedZones ??= HostedZonesClient(_dio, baseUrl: _baseUrl);

  ResourceRecordSetsClient get resourceRecordSets =>
      _resourceRecordSets ??= ResourceRecordSetsClient(_dio, baseUrl: _baseUrl);
}
