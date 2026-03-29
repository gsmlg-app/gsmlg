//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateBaremetalReverseIpv4Request {
  /// Returns a new [CreateBaremetalReverseIpv4Request] instance.
  CreateBaremetalReverseIpv4Request({
    required this.ip,
    required this.reverse,
  });

  /// The IPv4 address.
  String ip;

  /// The IPv4 reverse entry.
  String reverse;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateBaremetalReverseIpv4Request &&
          other.ip == ip &&
          other.reverse == reverse;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (ip.hashCode) + (reverse.hashCode);

  @override
  String toString() =>
      'CreateBaremetalReverseIpv4Request[ip=$ip, reverse=$reverse]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'ip'] = this.ip;
    json[r'reverse'] = this.reverse;
    return json;
  }

  /// Returns a new [CreateBaremetalReverseIpv4Request] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateBaremetalReverseIpv4Request? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "CreateBaremetalReverseIpv4Request[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "CreateBaremetalReverseIpv4Request[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateBaremetalReverseIpv4Request(
        ip: mapValueOfType<String>(json, r'ip')!,
        reverse: mapValueOfType<String>(json, r'reverse')!,
      );
    }
    return null;
  }

  static List<CreateBaremetalReverseIpv4Request> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreateBaremetalReverseIpv4Request>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateBaremetalReverseIpv4Request.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateBaremetalReverseIpv4Request> mapFromJson(
      dynamic json) {
    final map = <String, CreateBaremetalReverseIpv4Request>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateBaremetalReverseIpv4Request.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateBaremetalReverseIpv4Request-objects as value to a dart map
  static Map<String, List<CreateBaremetalReverseIpv4Request>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<CreateBaremetalReverseIpv4Request>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateBaremetalReverseIpv4Request.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'ip',
    'reverse',
  };
}
