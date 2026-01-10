import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

/// Dio interceptor that converts JSON request bodies to XML for Route53.
///
/// Route53 API expects XML in POST/PUT request bodies.
class XmlRequestInterceptor extends Interceptor {
  static const _namespace = 'https://route53.amazonaws.com/doc/2013-04-01/';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Only transform POST/PUT requests with data
    if ((options.method == 'POST' || options.method == 'PUT') &&
        options.data != null) {
      try {
        // Convert entire object tree to JSON-serializable Map
        final data = _deepConvertToMap(options.data);

        if (data is Map) {
          final xmlBody = _convertToXml(data, options.path);
          options.data = xmlBody;
        }
      } catch (e, stack) {
        // If conversion fails, let it through (will likely fail on server)
        print('XML conversion error: $e');
        print('Stack: $stack');
      }
    }
    handler.next(options);
  }

  /// Recursively convert an object and all its nested objects to Maps.
  dynamic _deepConvertToMap(dynamic value) {
    if (value == null) return null;

    if (value is String || value is num || value is bool) {
      return value;
    }

    if (value is List) {
      return value.map(_deepConvertToMap).toList();
    }

    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _deepConvertToMap(v)));
    }

    // Try to call toJson() on the object
    try {
      final json = (value as dynamic).toJson();
      return _deepConvertToMap(json);
    } catch (_) {
      // If toJson fails, try JSON encode/decode roundtrip
      try {
        return jsonDecode(jsonEncode(value));
      } catch (_) {
        // Last resort: return string representation
        return value.toString();
      }
    }
  }

  String _convertToXml(Map data, String path) {
    // Determine root element based on the data structure
    String rootElement = 'Request';

    if (data.containsKey('changeBatch')) {
      rootElement = 'ChangeResourceRecordSetsRequest';
    }

    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element(rootElement, attributes: {'xmlns': _namespace}, nest: () {
      _buildXmlFromMap(builder, data);
    });

    return builder.buildDocument().toXmlString();
  }

  void _buildXmlFromMap(XmlBuilder builder, dynamic data) {
    if (data is Map) {
      for (final entry in data.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        final elementName = _toPascalCase(key);

        if (value == null) continue;

        if (value is List) {
          // For lists, create a wrapper element with singular child elements
          final singularName = _getSingularName(elementName);
          builder.element(elementName, nest: () {
            for (final item in value) {
              builder.element(singularName, nest: () {
                _buildXmlFromMap(builder, item);
              });
            }
          });
        } else if (value is Map) {
          builder.element(elementName, nest: () {
            _buildXmlFromMap(builder, value);
          });
        } else {
          // Leaf value - convert to string
          builder.element(elementName, nest: () {
            builder.text(_valueToString(value));
          });
        }
      }
    }
  }

  String _toPascalCase(String name) {
    if (name.isEmpty) return name;

    // Handle special Route53 element names that need specific casing
    final specialNames = {
      'ttl': 'TTL',
      'id': 'Id',
      'type': 'Type',
      'name': 'Name',
      'value': 'Value',
      'action': 'Action',
      'comment': 'Comment',
      'hostedZoneId': 'HostedZoneId',
      'dnsName': 'DNSName',
      'evaluateTargetHealth': 'EvaluateTargetHealth',
    };

    if (specialNames.containsKey(name)) {
      return specialNames[name]!;
    }

    return name[0].toUpperCase() + name.substring(1);
  }

  String _getSingularName(String pluralName) {
    // Handle common Route53 plural -> singular mappings
    if (pluralName == 'Changes') return 'Change';
    if (pluralName == 'ResourceRecords') return 'ResourceRecord';
    if (pluralName == 'HostedZones') return 'HostedZone';

    // Generic: remove trailing 's' if present
    if (pluralName.endsWith('s') && pluralName.length > 1) {
      return pluralName.substring(0, pluralName.length - 1);
    }
    return pluralName;
  }

  String _valueToString(dynamic value) {
    if (value is bool) {
      return value.toString().toLowerCase();
    }
    return value.toString();
  }
}
