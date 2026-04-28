import 'package:flutter_gemma/flutter_gemma.dart' as gemma;
import 'package:gsmlg_whois/gsmlg_whois.dart';
import 'package:ip_db/ip_db.dart';

/// Executes tool calls from the LLM and provides tool definitions
/// for flutter_gemma's function calling support.
class ToolExecutor {
  ToolExecutor();

  IpDatabase? _ipDatabase;

  /// Tool definitions to pass to [InferenceChat].
  List<gemma.Tool> get toolDefinitions => [_whoisTool, _ipGeoTool];

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

  /// Execute a tool by name and return a JSON-encodable result.
  Future<Map<String, dynamic>> execute(
    String name,
    Map<String, dynamic> args,
  ) async {
    return switch (name) {
      'whois_lookup' => _executeWhois(args),
      'ip_geolocation' => _executeIpGeo(args),
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

  /// Clean up resources.
  void dispose() {
    _ipDatabase?.close();
    _ipDatabase = null;
  }
}
