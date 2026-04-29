import 'dart:convert';

import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:cloudflare_dns/cloudflare_dns.dart' as cf;
import 'package:dio/dio.dart';
import 'package:flutter_gemma/flutter_gemma.dart' as gemma;
import 'package:gsmlg_whois/gsmlg_whois.dart';
import 'package:ip_db/ip_db.dart';
import 'package:route53/route53.dart' as r53;
import 'package:vultr_api/api.dart' as vultr;

/// Executes tool calls from the LLM and provides tool definitions
/// for flutter_gemma's function calling support.
class ToolExecutor {
  ToolExecutor({
    AppDatabase? database,
    VaultRepository? vault,
  })  : _database = database,
        _vault = vault;

  IpDatabase? _ipDatabase;
  final AppDatabase? _database;
  final VaultRepository? _vault;

  /// Tool definitions to pass to [InferenceChat].
  List<gemma.Tool> get toolDefinitions => [
        _whoisTool,
        _ipGeoTool,
        _domainListZonesTool,
        _domainListRecordsTool,
        _domainCreateRecordTool,
        _domainUpdateRecordTool,
        _domainDeleteRecordTool,
        _vultrListServersTool,
        _vultrControlServerTool,
      ];

  /// Tool definitions for OpenAI-compatible chat completion APIs.
  List<Map<String, dynamic>> get openAiToolDefinitions {
    return toolDefinitions
        .map(
          (tool) => {
            'type': 'function',
            'function': {
              'name': tool.name,
              'description': tool.description,
              'parameters': tool.parameters,
            },
          },
        )
        .toList(growable: false);
  }

  static final _whoisTool = gemma.Tool(
    name: 'whois_lookup',
    description: 'Look up WHOIS registration information for a domain name',
    parameters: {
      'type': 'object',
      'properties': {
        'domain': {
          'type': 'string',
          'description': 'The domain name to look up, e.g. example.com',
        },
      },
      'required': ['domain'],
    },
  );

  static final _ipGeoTool = gemma.Tool(
    name: 'ip_geolocation',
    description: 'Look up geographic location for an IP address',
    parameters: {
      'type': 'object',
      'properties': {
        'ip': {
          'type': 'string',
          'description': 'The IP address to geolocate, e.g. 8.8.8.8',
        },
      },
      'required': ['ip'],
    },
  );

  static final _domainListZonesTool = gemma.Tool(
    name: 'domain_list_zones',
    description: 'List DNS zones configured in this app',
    parameters: {
      'type': 'object',
      'properties': {},
    },
  );

  static final _zoneSelectorProperties = {
    'local_zone_id': {
      'type': 'integer',
      'description': 'The local zone ID from domain_list_zones',
    },
    'zone_id': {
      'type': 'string',
      'description': 'The provider zone ID',
    },
    'zone_name': {
      'type': 'string',
      'description': 'The DNS zone name, e.g. example.com',
    },
    'provider': {
      'type': 'string',
      'enum': ['route53', 'cloudflare'],
      'description': 'DNS provider to disambiguate zone_name or zone_id',
    },
  };

  static final _recordProperties = {
    'record_id': {
      'type': 'string',
      'description':
          'Provider record ID. Required for Cloudflare update/delete',
    },
    'name': {
      'type': 'string',
      'description': 'DNS record name, e.g. www.example.com',
    },
    'type': {
      'type': 'string',
      'description': 'DNS record type, e.g. A, AAAA, CNAME, TXT, MX',
    },
    'content': {
      'type': 'string',
      'description': 'DNS record value',
    },
    'ttl': {
      'type': 'integer',
      'description': 'Record TTL in seconds. Cloudflare supports 1 for auto',
    },
    'proxied': {
      'type': 'boolean',
      'description': 'Cloudflare proxy setting',
    },
    'comment': {
      'type': 'string',
      'description': 'Optional Cloudflare record comment',
    },
  };

  static final _domainListRecordsTool = gemma.Tool(
    name: 'domain_list_records',
    description: 'List DNS records for a configured Route53 or Cloudflare zone',
    parameters: {
      'type': 'object',
      'properties': _zoneSelectorProperties,
    },
  );

  static final _domainCreateRecordTool = gemma.Tool(
    name: 'domain_create_record',
    description:
        'Create a DNS record in a configured Route53 or Cloudflare zone',
    parameters: {
      'type': 'object',
      'properties': {
        ..._zoneSelectorProperties,
        ..._recordProperties,
      },
      'required': ['name', 'type', 'content'],
    },
  );

  static final _domainUpdateRecordTool = gemma.Tool(
    name: 'domain_update_record',
    description:
        'Update or upsert a DNS record in a configured Route53 or Cloudflare zone',
    parameters: {
      'type': 'object',
      'properties': {
        ..._zoneSelectorProperties,
        ..._recordProperties,
      },
      'required': ['name', 'type', 'content'],
    },
  );

  static final _domainDeleteRecordTool = gemma.Tool(
    name: 'domain_delete_record',
    description:
        'Delete a DNS record from a configured Route53 or Cloudflare zone',
    parameters: {
      'type': 'object',
      'properties': {
        ..._zoneSelectorProperties,
        ..._recordProperties,
      },
      'required': ['name', 'type', 'content'],
    },
  );

  static final _vultrListServersTool = gemma.Tool(
    name: 'vultr_list_servers',
    description:
        'List Vultr server instances for one account or all configured Vultr accounts',
    parameters: {
      'type': 'object',
      'properties': {
        'account_id': {
          'type': 'integer',
          'description': 'Optional local service account ID',
        },
      },
    },
  );

  static final _vultrControlServerTool = gemma.Tool(
    name: 'vultr_control_server',
    description: 'Start, stop, or reboot a Vultr server instance',
    parameters: {
      'type': 'object',
      'properties': {
        'account_id': {
          'type': 'integer',
          'description': 'Local Vultr service account ID',
        },
        'instance_id': {
          'type': 'string',
          'description': 'Vultr instance ID',
        },
        'action': {
          'type': 'string',
          'enum': ['start', 'stop', 'reboot'],
          'description': 'Power action to perform',
        },
      },
      'required': ['account_id', 'instance_id', 'action'],
    },
  );

  /// Execute a tool by name and return a JSON-encodable result.
  Future<Map<String, dynamic>> execute(
    String name,
    Map<String, dynamic> args,
  ) async {
    return switch (name) {
      'whois_lookup' => _executeWhois(args),
      'ip_geolocation' => _executeIpGeo(args),
      'domain_list_zones' => _executeDomainListZones(args),
      'domain_list_records' => _executeDomainListRecords(args),
      'domain_create_record' => _executeDomainCreateRecord(args),
      'domain_update_record' => _executeDomainUpdateRecord(args),
      'domain_delete_record' => _executeDomainDeleteRecord(args),
      'vultr_list_servers' => _executeVultrListServers(args),
      'vultr_control_server' => _executeVultrControlServer(args),
      _ => {'error': 'Unknown tool: $name'},
    };
  }

  Future<Map<String, dynamic>> _executeWhois(
    Map<String, dynamic> args,
  ) async {
    final domain = args['domain'] as String? ?? '';
    try {
      final results = await Whois.queryList(domain);
      return {'domain': domain, 'results': results};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _executeIpGeo(
    Map<String, dynamic> args,
  ) async {
    final ip = args['ip'] as String? ?? '';
    try {
      _ipDatabase ??= IpDatabase();
      if (!_ipDatabase!.isReady) {
        await _ipDatabase!.initialize();
      }
      final location = await _ipDatabase!.lookup(ip);
      if (location == null) return {'ip': ip, 'error': 'Not found'};
      return {
        'ip': ip,
        'city': location.city,
        'region': location.stateProv,
        'country': location.country,
        'countryCode': location.countryCode,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'timezone': location.timezone,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _executeDomainListZones(
    Map<String, dynamic> args,
  ) async {
    try {
      final database = _requireDatabase();
      final zones = await database.select(database.dnsZoneTable).get();
      return {
        'zones': zones.map(_zoneToJson).toList(growable: false),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _executeDomainListRecords(
    Map<String, dynamic> args,
  ) async {
    try {
      final zone = await _findZone(args);
      return {
        'zone': _zoneToJson(zone),
        'records': await _listDomainRecords(zone),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _executeDomainCreateRecord(
    Map<String, dynamic> args,
  ) async {
    try {
      final zone = await _findZone(args);
      final record = _recordFromArgs(args);
      switch (zone.provider) {
        case DnsProvider.route53:
          await _changeRoute53Record(
            zone: zone,
            action: r53.ChangeAction.create,
            record: record,
          );
        case DnsProvider.cloudflare:
          final client = await _cloudflareClient(zone);
          await client.dnsRecords.createDnsRecord(
            zoneId: zone.zoneId,
            body: cf.CreateDnsRecordRequest(
              name: record.name,
              type: _cloudflareRecordType(record.type),
              content: record.content,
              ttl: record.ttl,
              proxied: record.proxied ?? false,
              comment: record.comment,
            ),
          );
      }
      return {
        'status': 'created',
        'zone': _zoneToJson(zone),
        'record': record.toJson(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _executeDomainUpdateRecord(
    Map<String, dynamic> args,
  ) async {
    try {
      final zone = await _findZone(args);
      final record = _recordFromArgs(args);
      switch (zone.provider) {
        case DnsProvider.route53:
          await _changeRoute53Record(
            zone: zone,
            action: r53.ChangeAction.upsert,
            record: record,
          );
        case DnsProvider.cloudflare:
          if (record.id == null || record.id!.isEmpty) {
            throw Exception('record_id is required for Cloudflare updates');
          }
          final client = await _cloudflareClient(zone);
          await client.dnsRecords.updateDnsRecord(
            zoneId: zone.zoneId,
            dnsRecordId: record.id!,
            body: cf.UpdateDnsRecordRequest(
              name: record.name,
              type: _cloudflareRecordType(record.type),
              content: record.content,
              ttl: record.ttl,
              proxied: record.proxied,
              comment: record.comment,
            ),
          );
      }
      return {
        'status': 'updated',
        'zone': _zoneToJson(zone),
        'record': record.toJson(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _executeDomainDeleteRecord(
    Map<String, dynamic> args,
  ) async {
    try {
      final zone = await _findZone(args);
      final record = _recordFromArgs(args);
      switch (zone.provider) {
        case DnsProvider.route53:
          await _changeRoute53Record(
            zone: zone,
            action: r53.ChangeAction.delete,
            record: record,
          );
        case DnsProvider.cloudflare:
          if (record.id == null || record.id!.isEmpty) {
            throw Exception('record_id is required for Cloudflare deletes');
          }
          final client = await _cloudflareClient(zone);
          await client.dnsRecords.deleteDnsRecord(
            zoneId: zone.zoneId,
            dnsRecordId: record.id!,
          );
      }
      return {
        'status': 'deleted',
        'zone': _zoneToJson(zone),
        'record': record.toJson(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _executeVultrListServers(
    Map<String, dynamic> args,
  ) async {
    try {
      final accounts =
          await _vultrAccounts(accountId: _intArg(args['account_id']));
      final results = <Map<String, dynamic>>[];
      for (final account in accounts) {
        final api = await _vultrInstancesApi(account.id);
        final response = await api.listInstances();
        results.add({
          'account': _serviceAccountToJson(account),
          'servers': (response?.instances ?? <vultr.InstanceGet>[])
              .map(_vultrInstanceToJson)
              .toList(growable: false),
        });
      }
      return {'accounts': results};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _executeVultrControlServer(
    Map<String, dynamic> args,
  ) async {
    try {
      final accountId = _requiredIntArg(args, 'account_id');
      final instanceId = _requiredStringArg(args, 'instance_id');
      final action = _requiredStringArg(args, 'action').toLowerCase();
      final api = await _vultrInstancesApi(accountId);

      switch (action) {
        case 'start':
          await api.startInstance(instanceId);
        case 'stop':
          await api.haltInstance(instanceId);
        case 'reboot':
          await api.rebootInstance(instanceId);
        default:
          throw Exception('Unsupported Vultr action: $action');
      }

      final response = await api.listInstances();
      final instance = (response?.instances ?? <vultr.InstanceGet>[])
          .where((item) => item.id == instanceId)
          .firstOrNull;
      return {
        'status': action,
        'account_id': accountId,
        'instance_id': instanceId,
        if (instance != null) 'server': _vultrInstanceToJson(instance),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  AppDatabase _requireDatabase() {
    final database = _database;
    if (database == null) {
      throw StateError('ToolExecutor database dependency is not configured');
    }
    return database;
  }

  VaultRepository _requireVault() {
    final vault = _vault;
    if (vault == null) {
      throw StateError('ToolExecutor vault dependency is not configured');
    }
    return vault;
  }

  Future<DnsZoneTableData> _findZone(Map<String, dynamic> args) async {
    final database = _requireDatabase();
    final localZoneId = _intArg(args['local_zone_id']);
    final zoneId = args['zone_id'] as String?;
    final zoneName = args['zone_name'] as String?;
    final provider = args['provider'] as String?;

    final query = database.select(database.dnsZoneTable);
    if (localZoneId != null) {
      query.where((t) => t.id.equals(localZoneId));
    } else if (zoneId != null && zoneId.isNotEmpty) {
      query.where((t) => t.zoneId.equals(zoneId));
    } else if (zoneName != null && zoneName.isNotEmpty) {
      query.where((t) => t.zoneName.equals(zoneName));
    } else {
      throw Exception('Provide local_zone_id, zone_id, or zone_name');
    }

    if (provider != null && provider.isNotEmpty) {
      query.where((t) => t.provider.equals(provider));
    }

    final zones = await query.get();
    if (zones.isEmpty) {
      throw Exception('DNS zone not found');
    }
    if (zones.length > 1) {
      throw Exception(
        'Multiple DNS zones matched. Provide local_zone_id to disambiguate',
      );
    }
    return zones.single;
  }

  Future<String> _serviceAccountSecret(int accountId) async {
    final secret =
        await _requireVault().read(key: 'service_account_$accountId');
    if (secret == null || secret.isEmpty) {
      throw Exception('No credentials found for service account $accountId');
    }
    return secret;
  }

  Future<List<Map<String, dynamic>>> _listDomainRecords(
    DnsZoneTableData zone,
  ) async {
    switch (zone.provider) {
      case DnsProvider.route53:
        final client = await _route53Client(zone);
        final response = await client.resourceRecordSets
            .listResourceRecordSets(hostedZoneId: zone.zoneId);
        return response.resourceRecordSets.expand((rrset) {
          final records = rrset.resourceRecords ?? <r53.ResourceRecord>[];
          return records.map(
            (rr) => {
              'name': rrset.name,
              'type': rrset.type.toString(),
              'content': rr.value,
              'ttl': rrset.ttl ?? 300,
            },
          );
        }).toList(growable: false);
      case DnsProvider.cloudflare:
        final client = await _cloudflareClient(zone);
        final response = await client.dnsRecords.listDnsRecords(
          zoneId: zone.zoneId,
        );
        return response.result
            .map(
              (record) => {
                'id': record.id,
                'name': record.name,
                'type': record.type.toString(),
                'content': record.content,
                'ttl': record.ttl,
                'proxied': record.proxied,
                'comment': record.comment,
              },
            )
            .toList(growable: false);
    }
  }

  Future<r53.Route53> _route53Client(DnsZoneTableData zone) async {
    final secret = await _serviceAccountSecret(zone.serviceAccountId);
    final credentials = jsonDecode(secret) as Map<String, dynamic>;
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://route53.amazonaws.com/2013-04-01',
        headers: {'Content-Type': 'application/xml'},
      ),
    );
    dio.transformer = r53.XmlTransformer();
    dio.interceptors.add(r53.XmlRequestInterceptor());
    dio.interceptors.add(
      r53.AwsSigV4Interceptor(
        accessKeyId: credentials['accessKeyId'] as String,
        secretAccessKey: credentials['secretAccessKey'] as String,
        region: credentials['region'] as String? ?? 'us-east-1',
        serviceName: 'route53',
      ),
    );
    return r53.Route53(dio);
  }

  Future<cf.CloudflareDns> _cloudflareClient(DnsZoneTableData zone) async {
    final apiToken = await _serviceAccountSecret(zone.serviceAccountId);
    return cf.CloudflareDns(
      Dio(
        BaseOptions(
          baseUrl: 'https://api.cloudflare.com/client/v4',
          headers: {
            'Authorization': 'Bearer $apiToken',
            'Content-Type': 'application/json',
          },
        ),
      ),
    );
  }

  Future<void> _changeRoute53Record({
    required DnsZoneTableData zone,
    required r53.ChangeAction action,
    required _DnsRecordInput record,
  }) async {
    final client = await _route53Client(zone);
    await client.resourceRecordSets.changeResourceRecordSets(
      hostedZoneId: zone.zoneId,
      body: r53.ChangeResourceRecordSetsRequest(
        changeBatch: r53.ChangeBatch(
          changes: [
            r53.Change(
              action: action,
              resourceRecordSet: r53.ResourceRecordSet(
                name: record.name,
                type: _route53RecordType(record.type),
                ttl: record.ttl,
                resourceRecords: [
                  r53.ResourceRecord(value: record.content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  r53.RecordType _route53RecordType(String type) {
    final normalized = type.toUpperCase();
    return r53.RecordType.values.firstWhere(
      (value) => value.toString() == normalized,
      orElse: () => throw Exception('Unknown Route53 record type: $type'),
    );
  }

  cf.DnsRecordType _cloudflareRecordType(String type) {
    final normalized = type.toUpperCase();
    return cf.DnsRecordType.values.firstWhere(
      (value) => value.toString() == normalized,
      orElse: () => throw Exception('Unknown Cloudflare record type: $type'),
    );
  }

  _DnsRecordInput _recordFromArgs(Map<String, dynamic> args) {
    return _DnsRecordInput(
      id: args['record_id'] as String?,
      name: _requiredStringArg(args, 'name'),
      type: _requiredStringArg(args, 'type').toUpperCase(),
      content: _requiredStringArg(args, 'content'),
      ttl: _intArg(args['ttl']) ?? 300,
      proxied: args['proxied'] as bool?,
      comment: args['comment'] as String?,
    );
  }

  Future<List<ServiceAccountTableData>> _vultrAccounts({int? accountId}) async {
    final database = _requireDatabase();
    final query = database.select(database.serviceAccountTable)
      ..where((t) => t.provider.equals(ServiceProvider.vultr.name));
    if (accountId != null) {
      query.where((t) => t.id.equals(accountId));
    }
    final accounts = await query.get();
    if (accounts.isEmpty) {
      throw Exception(
        accountId == null
            ? 'No Vultr service accounts configured'
            : 'Vultr service account $accountId not found',
      );
    }
    return accounts;
  }

  Future<vultr.InstancesApi> _vultrInstancesApi(int accountId) async {
    final secret = await _serviceAccountSecret(accountId);
    final auth = vultr.HttpBearerAuth()..accessToken = secret;
    return vultr.InstancesApi(vultr.ApiClient(authentication: auth));
  }

  int? _intArg(Object? value) {
    return switch (value) {
      int value => value,
      num value => value.toInt(),
      String value => int.tryParse(value),
      _ => null,
    };
  }

  int _requiredIntArg(Map<String, dynamic> args, String name) {
    final value = _intArg(args[name]);
    if (value == null) throw Exception('$name is required');
    return value;
  }

  String _requiredStringArg(Map<String, dynamic> args, String name) {
    final value = args[name] as String?;
    if (value == null || value.isEmpty) throw Exception('$name is required');
    return value;
  }

  Map<String, dynamic> _zoneToJson(DnsZoneTableData zone) {
    return {
      'local_zone_id': zone.id,
      'provider': zone.provider.name,
      'zone_id': zone.zoneId,
      'zone_name': zone.zoneName,
      'service_account_id': zone.serviceAccountId,
      'comment': zone.comment,
    };
  }

  Map<String, dynamic> _serviceAccountToJson(ServiceAccountTableData account) {
    return {
      'account_id': account.id,
      'provider': account.provider.name,
      'name': account.name,
      'description': account.description,
    };
  }

  Map<String, dynamic> _vultrInstanceToJson(vultr.InstanceGet instance) {
    return {
      'id': instance.id,
      'label': instance.label,
      'hostname': instance.hostname,
      'main_ip': instance.mainIp,
      'region': instance.region,
      'plan': instance.plan,
      'os': instance.os,
      'status': instance.status,
      'power_status': instance.powerStatus,
      'server_status': instance.serverStatus,
      'vcpu_count': instance.vcpuCount,
      'ram_mb': instance.ram,
      'disk_gb': instance.disk,
      'tags': instance.tags,
    };
  }

  /// Clean up resources.
  void dispose() {
    _ipDatabase?.close();
    _ipDatabase = null;
  }
}

class _DnsRecordInput {
  const _DnsRecordInput({
    required this.name,
    required this.type,
    required this.content,
    required this.ttl,
    this.id,
    this.proxied,
    this.comment,
  });

  final String? id;
  final String name;
  final String type;
  final String content;
  final int ttl;
  final bool? proxied;
  final String? comment;

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'type': type,
        'content': content,
        'ttl': ttl,
        if (proxied != null) 'proxied': proxied,
        if (comment != null) 'comment': comment,
      };
}
