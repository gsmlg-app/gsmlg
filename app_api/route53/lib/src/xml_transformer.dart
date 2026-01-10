import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

/// Dio transformer that converts XML responses to JSON-like Maps.
///
/// Route53 API returns XML, but Retrofit expects JSON.
/// This transformer parses XML and converts it to Map<String, dynamic>.
class XmlTransformer extends BackgroundTransformer {
  @override
  Future<dynamic> transformResponse(
    RequestOptions options,
    ResponseBody responseBody,
  ) async {
    final response = await super.transformResponse(options, responseBody);

    // If response is a string and looks like XML, parse it
    if (response is String && response.trim().startsWith('<?xml')) {
      try {
        final document = XmlDocument.parse(response);
        return _xmlToMap(document.rootElement);
      } catch (e) {
        // If parsing fails, return original response
        return response;
      }
    }

    return response;
  }

  /// Convert PascalCase to camelCase.
  String _toCamelCase(String name) {
    if (name.isEmpty) return name;

    // Handle special all-uppercase abbreviations
    final specialNames = {
      'TTL': 'ttl',
      'ID': 'id',
    };
    if (specialNames.containsKey(name)) {
      return specialNames[name]!;
    }

    return name[0].toLowerCase() + name.substring(1);
  }

  /// Check if this is a plural wrapper element (e.g., HostedZones containing HostedZone)
  bool _isPluralWrapper(XmlElement element) {
    final name = element.name.local;
    final children = element.childElements.toList();

    // Check if element name ends with 's' and all children have singular form
    if (name.endsWith('s') && children.isNotEmpty) {
      final singularName = name.substring(0, name.length - 1);
      return children.every((c) => c.name.local == singularName);
    }

    // Special cases for AWS naming
    if (name == 'ResourceRecords') {
      return children.every((c) => c.name.local == 'ResourceRecord');
    }

    return false;
  }

  /// Convert XML element to a Map structure.
  dynamic _xmlToMap(XmlElement element) {
    final children = element.childElements.toList();

    if (children.isEmpty) {
      // Leaf node - return text content with type conversion
      final text = element.innerText.trim();

      // Convert boolean strings
      if (text.toLowerCase() == 'true') return true;
      if (text.toLowerCase() == 'false') return false;

      // Convert integer strings
      final intValue = int.tryParse(text);
      if (intValue != null) return intValue;

      return text;
    }

    final map = <String, dynamic>{};

    // Group children by name to detect lists
    final childGroups = <String, List<XmlElement>>{};
    for (final child in children) {
      childGroups.putIfAbsent(child.name.local, () => []).add(child);
    }

    for (final entry in childGroups.entries) {
      final name = entry.key;
      final groupChildren = entry.value;
      final camelName = _toCamelCase(name);

      if (groupChildren.length == 1) {
        final child = groupChildren.first;

        // Check if this is a plural wrapper element
        if (_isPluralWrapper(child)) {
          // Unwrap and create a list directly
          final items = child.childElements.map(_xmlToMap).toList();
          map[camelName] = items;
        } else {
          map[camelName] = _xmlToMap(child);
        }
      } else {
        // Multiple children with same name - treat as list
        map[camelName] = groupChildren.map(_xmlToMap).toList();
      }
    }

    return map;
  }
}
