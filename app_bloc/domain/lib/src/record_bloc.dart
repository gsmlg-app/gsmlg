import 'dart:convert';

import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:bloc/bloc.dart';
import 'package:cloudflare_dns/cloudflare_dns.dart' as cf;
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:route53/route53.dart' as r53;

import 'models/credentials_model.dart';
import 'models/dns_record_model.dart';

part 'record_event.dart';
part 'record_state.dart';

/// BLoC for managing DNS records within a zone.
///
/// Fetches credentials from the vault via the zone's linked service account.
class RecordBloc extends Bloc<RecordEvent, RecordState> {
  final VaultRepository vault;

  RecordBloc(this.vault) : super(const RecordInitial()) {
    on<RecordSync>(_onSync);
    on<RecordAdd>(_onCreate);
    on<RecordUpdate>(_onUpdate);
    on<RecordRemove>(_onDelete);
  }

  /// Retrieve credentials for a zone by reading the linked service account
  /// from the vault using key `service_account_<serviceAccountId>`.
  Future<String> _getApiKey(DnsZoneTableData zone) async {
    final key = 'service_account_${zone.serviceAccountId}';
    final apiKey = await vault.read(key: key);
    if (apiKey == null) {
      throw Exception(
        'No credentials found for service account. '
        'Please check Settings > Accounts.',
      );
    }
    return apiKey;
  }

  Future<Route53Credentials> _getRoute53Credentials(
      DnsZoneTableData zone) async {
    final apiKey = await _getApiKey(zone);
    final map = jsonDecode(apiKey) as Map<String, dynamic>;
    return Route53Credentials(
      accessKeyId: map['accessKeyId'] as String,
      secretAccessKey: map['secretAccessKey'] as String,
      region: map['region'] as String? ?? 'us-east-1',
    );
  }

  Future<CloudflareCredentials> _getCloudflareCredentials(
      DnsZoneTableData zone) async {
    final apiKey = await _getApiKey(zone);
    return CloudflareCredentials(apiToken: apiKey);
  }

  Dio _createRoute53Dio(Route53Credentials credentials) {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://route53.amazonaws.com/2013-04-01',
      headers: {
        'Content-Type': 'application/xml',
      },
    ));
    dio.transformer = r53.XmlTransformer();
    dio.interceptors.add(r53.XmlRequestInterceptor());
    dio.interceptors.add(r53.AwsSigV4Interceptor(
      accessKeyId: credentials.accessKeyId,
      secretAccessKey: credentials.secretAccessKey,
      region: credentials.region,
      serviceName: 'route53',
    ));
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: print,
    ));
    return dio;
  }

  Dio _createCloudflareDio(CloudflareCredentials credentials) {
    return Dio(BaseOptions(
      baseUrl: 'https://api.cloudflare.com/client/v4',
      headers: {
        'Authorization': 'Bearer ${credentials.apiToken}',
        'Content-Type': 'application/json',
      },
    ));
  }

  cf.CloudflareDns _createCloudflareClient(CloudflareCredentials credentials) {
    return cf.CloudflareDns(
      _createCloudflareDio(credentials),
      enableLogging: true,
    );
  }

  cf.DnsRecordType _findCloudflareRecordType(String type) {
    return cf.DnsRecordType.values.firstWhere(
      (t) => t.toString() == type,
      orElse: () => throw Exception(
        'Unknown Cloudflare record type: $type. '
        'Available: ${cf.DnsRecordType.values.map((t) => t.toString()).join(", ")}',
      ),
    );
  }

  r53.RecordType _findRoute53RecordType(String type) {
    return r53.RecordType.values.firstWhere(
      (t) => t.toString() == type,
      orElse: () => throw Exception(
        'Unknown Route53 record type: $type. '
        'Available: ${r53.RecordType.values.map((t) => t.toString()).join(", ")}',
      ),
    );
  }

  Future<void> _onSync(
    RecordSync event,
    Emitter<RecordState> emit,
  ) async {
    final existingRecords = state is RecordLoaded
        ? (state as RecordLoaded).records
        : state is RecordLoading
            ? (state as RecordLoading).records
            : null;
    emit(RecordLoading(event.zone, records: existingRecords));
    try {
      final records = <DnsRecordModel>[];

      switch (event.zone.provider) {
        case DnsProvider.route53:
          final credentials = await _getRoute53Credentials(event.zone);
          final dio = _createRoute53Dio(credentials);
          final client = r53.Route53(dio);

          final response = await client.resourceRecordSets
              .listResourceRecordSets(hostedZoneId: event.zone.zoneId);

          for (final rrset in response.resourceRecordSets) {
            for (final rr in rrset.resourceRecords ?? <r53.ResourceRecord>[]) {
              records.add(DnsRecordModel(
                name: rrset.name,
                type: rrset.type.toString(),
                content: rr.value,
                ttl: rrset.ttl ?? 300,
              ));
            }
          }

        case DnsProvider.cloudflare:
          final credentials = await _getCloudflareCredentials(event.zone);
          final client = _createCloudflareClient(credentials);

          final response = await client.dnsRecords.listDnsRecords(
            zoneId: event.zone.zoneId,
          );

          for (final record in response.result) {
            records.add(DnsRecordModel(
              id: record.id,
              name: record.name,
              type: record.type.toString(),
              content: record.content,
              ttl: record.ttl ?? 1,
              proxied: record.proxied,
              comment: record.comment,
            ));
          }
      }

      emit(RecordLoaded(zone: event.zone, records: records));
    } catch (e) {
      emit(RecordFailure(zone: event.zone, error: e.toString()));
    }
  }

  Future<void> _onCreate(
    RecordAdd event,
    Emitter<RecordState> emit,
  ) async {
    try {
      switch (event.zone.provider) {
        case DnsProvider.route53:
          final credentials = await _getRoute53Credentials(event.zone);
          final dio = _createRoute53Dio(credentials);
          final client = r53.Route53(dio);

          await client.resourceRecordSets.changeResourceRecordSets(
            hostedZoneId: event.zone.zoneId,
            body: r53.ChangeResourceRecordSetsRequest(
              changeBatch: r53.ChangeBatch(
                changes: [
                  r53.Change(
                    action: r53.ChangeAction.create,
                    resourceRecordSet: r53.ResourceRecordSet(
                      name: event.record.name,
                      type: _findRoute53RecordType(event.record.type),
                      ttl: event.record.ttl,
                      resourceRecords: [
                        r53.ResourceRecord(value: event.record.content),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );

        case DnsProvider.cloudflare:
          final credentials = await _getCloudflareCredentials(event.zone);
          final client = _createCloudflareClient(credentials);

          await client.dnsRecords.createDnsRecord(
            zoneId: event.zone.zoneId,
            body: cf.CreateDnsRecordRequest(
              name: event.record.name,
              type: _findCloudflareRecordType(event.record.type),
              content: event.record.content,
              ttl: event.record.ttl,
              proxied: event.record.proxied ?? false,
              comment: event.record.comment,
            ),
          );
      }

      add(RecordSync(event.zone));
    } catch (e) {
      emit(RecordFailure(zone: event.zone, error: e.toString()));
    }
  }

  Future<void> _onUpdate(
    RecordUpdate event,
    Emitter<RecordState> emit,
  ) async {
    try {
      switch (event.zone.provider) {
        case DnsProvider.route53:
          final credentials = await _getRoute53Credentials(event.zone);
          final dio = _createRoute53Dio(credentials);
          final client = r53.Route53(dio);

          await client.resourceRecordSets.changeResourceRecordSets(
            hostedZoneId: event.zone.zoneId,
            body: r53.ChangeResourceRecordSetsRequest(
              changeBatch: r53.ChangeBatch(
                changes: [
                  r53.Change(
                    action: r53.ChangeAction.upsert,
                    resourceRecordSet: r53.ResourceRecordSet(
                      name: event.record.name,
                      type: _findRoute53RecordType(event.record.type),
                      ttl: event.record.ttl,
                      resourceRecords: [
                        r53.ResourceRecord(value: event.record.content),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );

        case DnsProvider.cloudflare:
          final credentials = await _getCloudflareCredentials(event.zone);
          final client = _createCloudflareClient(credentials);

          if (event.record.id == null) {
            throw Exception('Record ID is required for Cloudflare updates');
          }

          await client.dnsRecords.updateDnsRecord(
            zoneId: event.zone.zoneId,
            dnsRecordId: event.record.id!,
            body: cf.UpdateDnsRecordRequest(
              name: event.record.name,
              type: _findCloudflareRecordType(event.record.type),
              content: event.record.content,
              ttl: event.record.ttl,
              proxied: event.record.proxied,
              comment: event.record.comment,
            ),
          );
      }

      add(RecordSync(event.zone));
    } catch (e) {
      emit(RecordFailure(zone: event.zone, error: e.toString()));
    }
  }

  Future<void> _onDelete(
    RecordRemove event,
    Emitter<RecordState> emit,
  ) async {
    try {
      switch (event.zone.provider) {
        case DnsProvider.route53:
          final credentials = await _getRoute53Credentials(event.zone);
          final dio = _createRoute53Dio(credentials);
          final client = r53.Route53(dio);

          await client.resourceRecordSets.changeResourceRecordSets(
            hostedZoneId: event.zone.zoneId,
            body: r53.ChangeResourceRecordSetsRequest(
              changeBatch: r53.ChangeBatch(
                changes: [
                  r53.Change(
                    action: r53.ChangeAction.delete,
                    resourceRecordSet: r53.ResourceRecordSet(
                      name: event.record.name,
                      type: _findRoute53RecordType(event.record.type),
                      ttl: event.record.ttl,
                      resourceRecords: [
                        r53.ResourceRecord(value: event.record.content),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );

        case DnsProvider.cloudflare:
          final credentials = await _getCloudflareCredentials(event.zone);
          final client = _createCloudflareClient(credentials);

          if (event.record.id == null) {
            throw Exception('Record ID is required for Cloudflare deletions');
          }

          await client.dnsRecords.deleteDnsRecord(
            zoneId: event.zone.zoneId,
            dnsRecordId: event.record.id!,
          );
      }

      add(RecordSync(event.zone));
    } catch (e) {
      emit(RecordFailure(zone: event.zone, error: e.toString()));
    }
  }
}
