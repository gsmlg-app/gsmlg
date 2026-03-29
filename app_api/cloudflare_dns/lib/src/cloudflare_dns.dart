// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, avoid_print

import 'package:dio/dio.dart';

import 'zones/zones_client.dart';
import 'dns_records/dns_records_client.dart';

/// Cloudflare DNS API `v4.0.0`.
///
/// Cloudflare DNS API client for managing zones and DNS records.
/// This specification covers zone listing and DNS record CRUD operations.
///
class CloudflareDns {
  CloudflareDns(
    Dio dio, {
    String? baseUrl,
    bool enableLogging = false,
  })  : _dio = dio,
        _baseUrl = baseUrl {
    if (enableLogging) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: print,
      ));
    }
  }

  final Dio _dio;
  final String? _baseUrl;

  static String get version => '4.0.0';

  ZonesClient? _zones;
  DnsRecordsClient? _dnsRecords;

  ZonesClient get zones => _zones ??= ZonesClient(_dio, baseUrl: _baseUrl);

  DnsRecordsClient get dnsRecords =>
      _dnsRecords ??= DnsRecordsClient(_dio, baseUrl: _baseUrl);
}
